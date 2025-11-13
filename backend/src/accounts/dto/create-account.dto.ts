import { IsNotEmpty, IsEnum, IsOptional, IsDecimal, Min, ValidateIf } from 'class-validator';
import { AccountType } from '../entities/account.entity';

export class CreateAccountDto {
  @IsNotEmpty()
  name: string;

  @IsEnum(AccountType)
  type: AccountType;

  @IsOptional()
  balance?: number;

  @IsOptional()
  description?: string;
}