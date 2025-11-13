import { Injectable, NotFoundException, ForbiddenException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Account } from './entities/account.entity';
import { CreateAccountDto } from './dto/create-account.dto';
import { UpdateAccountDto } from './dto/update-account.dto';

@Injectable()
export class AccountsService {
  constructor(
    @InjectRepository(Account)
    private accountsRepository: Repository<Account>,
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
    return await this.accountsRepository.find({
      where: { userId },
      order: { createdAt: 'DESC' },
    });
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

    return account;
  }

  /**
   * Update account
   */
  async update(id: number, userId: number, updateAccountDto: UpdateAccountDto): Promise<Account> {
    const account = await this.findOne(id, userId);
    
    await this.accountsRepository.update(id, updateAccountDto);
    return this.findOne(id, userId);
  }

  /**
   * Update account balance
   */
  async updateBalance(id: number, userId: number, newBalance: number): Promise<Account> {
    const account = await this.findOne(id, userId);
    
    await this.accountsRepository.update(id, { balance: newBalance });
    return this.findOne(id, userId);
  }

  /**
   * Delete account
   */
  async remove(id: number, userId: number): Promise<void> {
    const account = await this.findOne(id, userId);
    
    await this.accountsRepository.delete(id);
  }

  /**
   * Get total balance for all user accounts
   */
  async getTotalBalance(userId: number): Promise<number> {
    const result = await this.accountsRepository
      .createQueryBuilder('account')
      .select('SUM(account.balance)', 'total')
      .where('account.userId = :userId', { userId })
      .getRawOne();

    return parseFloat(result.total) || 0;
  }
}