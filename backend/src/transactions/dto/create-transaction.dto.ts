import { IsNotEmpty, IsEnum, Min, IsOptional, IsInt, IsDateString } from 'class-validator';
import { Transform } from 'class-transformer';
import { TransactionType } from '../entities/transaction.entity';

export class CreateTransactionDto {
  @Transform(({ value }) => parseFloat(value))
  @IsNotEmpty()
  @Min(0.01)
  amount: number;

  @IsEnum(TransactionType)
  type: TransactionType;

  @IsDateString()
  date: Date;

  @IsOptional()
  note?: string;

  @IsInt()
  @Min(1)
  @Transform(({ value }) => parseInt(value))
  accountId: number;

  @IsOptional()
  @IsInt()
  @Min(1)
  @Transform(({ value }) => value ? parseInt(value) : null)
  categoryId?: number;
}