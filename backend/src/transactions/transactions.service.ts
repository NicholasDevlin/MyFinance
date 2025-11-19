import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Transaction, TransactionType } from './entities/transaction.entity';
import { CreateTransactionDto } from './dto/create-transaction.dto';
import { UpdateTransactionDto } from './dto/update-transaction.dto';
import { AccountsService } from '../accounts/accounts.service';

@Injectable()
export class TransactionsService {
  constructor(
    @InjectRepository(Transaction)
    private transactionsRepository: Repository<Transaction>,
    private accountsService: AccountsService,
  ) {}

  /**
   * Create a new transaction
   */
  async create(
    userId: number,
    createTransactionDto: CreateTransactionDto,
    receiptFile?: Express.Multer.File,
  ): Promise<Transaction> {
    await this.accountsService.findOne(createTransactionDto.accountId, userId);

    const transaction = this.transactionsRepository.create({
      ...createTransactionDto,
      userId,
      receiptImage: receiptFile ? receiptFile.filename : null,
    });

    const savedTransaction = await this.transactionsRepository.save(transaction);

    return await this.findOne(savedTransaction.id, userId);
  }

  /**
   * Find all transactions for a user with optional filters
   */
  async findAllByUser(
    userId: number,
    type?: TransactionType,
    accountId?: number,
    categoryId?: number,
    startDate?: Date,
    endDate?: Date,
  ): Promise<Transaction[]> {
    const query = this.transactionsRepository
      .createQueryBuilder('transaction')
      .leftJoinAndSelect('transaction.account', 'account')
      .leftJoinAndSelect('transaction.category', 'category')
      .where('transaction.userId = :userId', { userId });

    if (type) {
      query.andWhere('transaction.type = :type', { type });
    }

    if (accountId) {
      query.andWhere('transaction.accountId = :accountId', { accountId });
    }

    if (categoryId) {
      query.andWhere('transaction.categoryId = :categoryId', { categoryId });
    }

    if (startDate && endDate) {
      query.andWhere('transaction.date BETWEEN :startDate AND :endDate', {
        startDate,
        endDate,
      });
    }

    return query.orderBy('transaction.date', 'DESC').getMany();
  }

  /**
   * Find transaction by ID
   */
  async findOne(id: number, userId: number): Promise<Transaction> {
    const transaction = await this.transactionsRepository.findOne({
      where: { id, userId },
      relations: ['account', 'category'],
    });

    if (!transaction) {
      throw new NotFoundException('Transaction not found');
    }

    return transaction;
  }

  /**
   * Update transaction
   */
  async update(
    id: number,
    userId: number,
    updateTransactionDto: UpdateTransactionDto,
    receiptFile?: Express.Multer.File,
  ): Promise<Transaction> {
    const transaction = await this.findOne(id, userId);

    // If account is changing, verify new account belongs to user
    if (updateTransactionDto.accountId && updateTransactionDto.accountId !== transaction.accountId) {
      await this.accountsService.findOne(updateTransactionDto.accountId, userId);
    }

    const updateData = {
      ...updateTransactionDto,
      receiptImage: receiptFile ? receiptFile.filename : transaction.receiptImage,
    };

    await this.transactionsRepository.update(id, updateData);

    return this.findOne(id, userId);
  }

  /**
   * Delete transaction
   */
  async remove(id: number, userId: number): Promise<void> {
    const transaction = await this.findOne(id, userId);

    await this.transactionsRepository.delete(id);
  }

  /**
   * Get monthly summary for user
   */
  async getMonthlySummary(userId: number, year: number, month: number) {
    const startDate = new Date(year, month - 1, 1);
    const endDate = new Date(year, month, 0, 23, 59, 59);

    const transactions = await this.findAllByUser(userId, undefined, undefined, undefined, startDate, endDate);

    const income = transactions
      .filter(t => t.type === TransactionType.INCOME)
      .reduce((sum, t) => sum + Number(t.amount), 0);

    const expenses = transactions
      .filter(t => t.type === TransactionType.EXPENSE)
      .reduce((sum, t) => sum + Number(t.amount), 0);

    return {
      month,
      year,
      totalIncome: income,
      totalExpenses: expenses,
      netBalance: income - expenses,
      transactionCount: transactions.length,
    };
  }
}