import { Injectable, NotFoundException } from '@nestjs/common';
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
   * Find all accounts for a user
   */
  async findAllByUser(userId: number): Promise<Account[]> {
    const accounts = await this.accountsRepository.find({
      where: { userId },
      order: { createdAt: 'DESC' },
    });

    const accountIds = accounts.map(account => account.id);
    const calculatedBalances = await this.calculateAccountBalances(accountIds);

    accounts.forEach(account => {
      account.balance = calculatedBalances[account.id] || 0;
    });

    return accounts;
  }

  /**
   * Find account by ID (with user validation)
   */
  async findOne(id: number, userId: number): Promise<Account> {
    const account = await this.accountsRepository.findOne({
      where: { id, userId },
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
    await this.accountsRepository.update(id, updateAccountDto);

    return this.findOne(id, userId);
  }

  /**
   * Delete account
   */
  async remove(id: number, userId: number): Promise<void> {
    await this.findOne(id, userId);
    await this.accountsRepository.delete(id);
  }

  /**
   * Get total balance for all user accounts
   */
  async getTotalBalance(userId: number): Promise<number> {
    const accounts = await this.accountsRepository.find({
      where: { userId },
      select: ['id'],
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