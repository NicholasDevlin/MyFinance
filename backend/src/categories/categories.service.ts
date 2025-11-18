import { Injectable, NotFoundException, OnModuleInit } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Category, CategoryType } from './entities/category.entity';
import { CreateCategoryDto } from './dto/create-category.dto';
import { UpdateCategoryDto } from './dto/update-category.dto';

@Injectable()
export class CategoriesService implements OnModuleInit {
  constructor(
    @InjectRepository(Category)
    private categoriesRepository: Repository<Category>,
  ) {}

  /**
   * Initialize default categories
   */
  async onModuleInit() {
    await this.createDefaultCategories();
  }

  /**
   * Create default categories if they don't exist
   */
  private async createDefaultCategories() {
    const existingCategories = await this.categoriesRepository.count();
    
    if (existingCategories === 0) {
      const defaultCategories = [
        // Income categories
        { name: 'Salary', type: CategoryType.INCOME, color: '#28a745' },
        { name: 'Freelance', type: CategoryType.INCOME, color: '#17a2b8' },
        { name: 'Investment', type: CategoryType.INCOME, color: '#ffc107' },
        { name: 'Gift', type: CategoryType.INCOME, color: '#e83e8c' },
        { name: 'Other Income', type: CategoryType.INCOME, color: '#6f42c1' },

        // Expense categories
        { name: 'Food & Dining', type: CategoryType.EXPENSE, color: '#dc3545' },
        { name: 'Transportation', type: CategoryType.EXPENSE, color: '#fd7e14' },
        { name: 'Shopping', type: CategoryType.EXPENSE, color: '#6610f2' },
        { name: 'Entertainment', type: CategoryType.EXPENSE, color: '#e83e8c' },
        { name: 'Bills & Utilities', type: CategoryType.EXPENSE, color: '#20c997' },
        { name: 'Healthcare', type: CategoryType.EXPENSE, color: '#17a2b8' },
        { name: 'Education', type: CategoryType.EXPENSE, color: '#ffc107' },
        { name: 'Other Expense', type: CategoryType.EXPENSE, color: '#6c757d' },
      ];

      for (const categoryData of defaultCategories) {
        const category = this.categoriesRepository.create(categoryData);
        await this.categoriesRepository.save(category);
      }
    }
  }

  /**
   * Create a new category
   */
  async create(createCategoryDto: CreateCategoryDto): Promise<Category> {
    const category = this.categoriesRepository.create(createCategoryDto);
    return await this.categoriesRepository.save(category);
  }

  /**
   * Find all categories
   */
  async findAll(): Promise<Category[]> {
    return await this.categoriesRepository.find({
      order: { type: 'ASC', name: 'ASC' },
    });
  }

  /**
   * Find categories by type
   */
  async findByType(type: CategoryType): Promise<Category[]> {
    return await this.categoriesRepository.find({
      where: { type },
      order: { name: 'ASC' },
    });
  }

  /**
   * Find category by ID
   */
  async findOne(id: number): Promise<Category> {
    const category = await this.categoriesRepository.findOne({
      where: { id },
    });

    if (!category) {
      throw new NotFoundException('Category not found');
    }

    return category;
  }

  /**
   * Update category
   */
  async update(id: number, updateCategoryDto: UpdateCategoryDto): Promise<Category> {
    await this.categoriesRepository.update(id, updateCategoryDto);
    return this.findOne(id);
  }

  /**
   * Delete category
   */
  async remove(id: number): Promise<void> {
    const result = await this.categoriesRepository.delete(id);
    if (result.affected === 0) {
      throw new NotFoundException('Category not found');
    }
  }
}