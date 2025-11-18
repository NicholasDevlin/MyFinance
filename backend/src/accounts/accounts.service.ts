import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, In } from 'typeorm';
import { Account } from './entities/account.entity';
import { CreateAccountDto } from './dto/create-account.dto';
import { UpdateAccountDto } from './dto/update-account.dto';
import { Transaction, TransactionType } from '../transactions/entities/transaction.entity';

@Injectable()
export class AccountsService {
  constructor(
    @InjectRepository(Account)
    private accountsRepository: Repository<Account>,
    @InjectRepository(Transaction)
    private transactionsRepository: Repository<Transaction>,
  ) {}

  /**
   * Create a new account for user
   */
  async create(userId: number, createAccountDto: CreateAccountDto): Promise<Account> {
    const account = this.accountsRepository.create({
      ...createAccountDto,
      userId,
    });
    return await this.accountsRepository.save(account);
  }

  /**
   * Find all accounts for a user with transaction counts (excluding soft deleted)
   */
  async findAllByUser(userId: number): Promise<Account[]> {
    const accountsWithCounts = await this.accountsRepository
      .createQueryBuilder('account')
      .leftJoin('account.transactions', 'transaction')
      .addSelect('COUNT(transaction.id)', 'transactionCount')
      .where('account.userId = :userId', { userId })
      .andWhere('account.deletedAt IS NULL')
      .groupBy('account.id')
      .orderBy('account.createdAt', 'DESC')
      .getRawAndEntities();

    const accounts = accountsWithCounts.entities;
    const rawResults = accountsWithCounts.raw;

    accounts.forEach((account, index) => {
      (account as any).transactionCount = parseInt(rawResults[index].transactionCount) || 0;
      (account as any).canModify = (account as any).transactionCount === 0;
    });

    const accountIds = accounts.map(account => account.id);
    const calculatedBalances = await this.calculateAccountBalances(accountIds);

    accounts.forEach(account => {
      account.balance = calculatedBalances[account.id] || 0;
    });

    return accounts;
  }

  /**
   * Find account by ID (with user validation, excluding soft deleted)
   */
  async findOne(id: number, userId: number): Promise<Account> {
    const account = await this.accountsRepository.findOne({
      where: { id, userId },
      withDeleted: false,
    });

    if (!account) {
      throw new NotFoundException('Account not found');
    }

    const calculatedBalances = await this.calculateAccountBalances([account.id]);
    account.balance = calculatedBalances[account.id] || 0;

    return account;
  }

  /**
   * Update account
   */
  async update(id: number, userId: number, updateAccountDto: UpdateAccountDto): Promise<Account> {
    await this.findOne(id, userId);
    await this.validateAccountHasNoTransactions(id);

    await this.accountsRepository.update(id, updateAccountDto);

    return this.findOne(id, userId);
  }

  /**
   * Delete account (soft delete)
   */
  async remove(id: number, userId: number): Promise<void> {
    await this.findOne(id, userId);
    await this.validateAccountHasNoTransactions(id);
    
    await this.accountsRepository.softDelete(id);
  }

  /**
   * Restore soft deleted account
   */
  async restore(id: number, userId: number): Promise<Account> {
    // First check if the account exists (including soft deleted ones)
    const account = await this.accountsRepository.findOne({
      where: { id, userId },
      withDeleted: true,
    });

    if (!account) {
      throw new NotFoundException('Account not found');
    }

    if (!account.deletedAt) {
      throw new NotFoundException('Account is not deleted');
    }

    await this.accountsRepository.restore(id);

    return this.findOne(id, userId);
  }

  /**
   * Find all soft deleted accounts for a user
   */
  async findDeletedByUser(userId: number): Promise<Account[]> {
    return await this.accountsRepository.find({
      where: { userId },
      withDeleted: true,
      order: { deletedAt: 'DESC' },
    }).then(accounts => accounts.filter(account => account.deletedAt));
  }

  /**
   * Validate that account has no transactions before allowing modifications
   */
  private async validateAccountHasNoTransactions(accountId: number): Promise<void> {
    const transactionCount = await this.transactionsRepository.count({
      where: { accountId }
    });

    if (transactionCount > 0) {
      throw new BadRequestException(
        `Cannot modify account because it has ${transactionCount} transaction(s). Please delete all transactions first.`
      );
    }
  }

  /**
   * Get total balance for all user accounts (excluding soft deleted)
   */
  async getTotalBalance(userId: number): Promise<number> {
    const accounts = await this.accountsRepository.find({
      where: { userId },
      select: ['id'],
      withDeleted: false,
    });

    const accountIds = accounts.map(account => account.id);
    const calculatedBalances = await this.calculateAccountBalances(accountIds);

    return Object.values(calculatedBalances).reduce((total, balance) => total + balance, 0);
  }

  private async calculateAccountBalances(accountIds: number[]): Promise<Record<number, number>> {
    if (accountIds.length === 0) {
      return {};
    }

    const accounts = await this.accountsRepository.find({
      where: { id: In(accountIds) },
      select: ['id', 'balance'],
      withDeleted: false,
    });

    const baseBalances: Record<number, number> = {};
    accounts.forEach(account => {
      baseBalances[account.id] = parseFloat(account.balance.toString()) || 0;
    });

    const transactionResults = await this.transactionsRepository
      .createQueryBuilder('transaction')
      .select('transaction.accountId', 'accountId')
      .addSelect('SUM(CASE WHEN transaction.type = :income THEN transaction.amount ELSE -transaction.amount END)', 'transactionBalance')
      .where('transaction.accountId IN (:...accountIds)', { accountIds })
      .setParameter('income', TransactionType.INCOME)
      .groupBy('transaction.accountId')
      .getRawMany();

    const transactionBalances: Record<number, number> = {};
    transactionResults.forEach(result => {
      const accountId = parseInt(result.accountId);
      transactionBalances[accountId] = parseFloat(result.transactionBalance) || 0;
    });

    const finalBalances: Record<number, number> = {};
    accountIds.forEach(accountId => {
      finalBalances[accountId] = (baseBalances[accountId] || 0) + (transactionBalances[accountId] || 0);
    });

    return finalBalances;
  }
}