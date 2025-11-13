import { IsNotEmpty, IsEnum, IsOptional, IsHexColor } from 'class-validator';
import { CategoryType } from '../entities/category.entity';

export class CreateCategoryDto {
  @IsNotEmpty()
  name: string;

  @IsEnum(CategoryType)
  type: CategoryType;

  @IsOptional()
  description?: string;

  @IsOptional()
  @IsHexColor()
  color?: string = '#007bff';
}