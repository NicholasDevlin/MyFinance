import {
  Controller,
  Get,
  Post,
  Body,
  Patch,
  Param,
  Delete,
  UseGuards,
  Request,
  Query,
  UseInterceptors,
  UploadedFile,
  ParseIntPipe,
  BadRequestException,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { AuthGuard } from '@nestjs/passport';
import { TransactionsService } from './transactions.service';
import { CreateTransactionDto } from './dto/create-transaction.dto';
import { UpdateTransactionDto } from './dto/update-transaction.dto';
import { TransactionType } from './entities/transaction.entity';

@Controller('transactions')
@UseGuards(AuthGuard('jwt'))
export class TransactionsController {
  constructor(private readonly transactionsService: TransactionsService) {}

  /**
   * Create new transaction with optional receipt upload
   */
  @Post()
  @UseInterceptors(FileInterceptor('receipt'))
  create(
    @Request() req,
    @Body() createTransactionDto: CreateTransactionDto,
    @UploadedFile() receiptFile?: Express.Multer.File,
  ) {
    return this.transactionsService.create(req.user.id, createTransactionDto, receiptFile);
  }

  /**
   * Get all transactions for user with optional filters
   */
  @Get()
  findAll(
    @Request() req,
    @Query('type') type?: TransactionType,
    @Query('accountId', new ParseIntPipe({ optional: true })) accountId?: number,
    @Query('categoryId', new ParseIntPipe({ optional: true })) categoryId?: number,
    @Query('startDate') startDate?: string,
    @Query('endDate') endDate?: string,
  ) {
    const start = startDate ? new Date(startDate) : undefined;
    const end = endDate ? new Date(endDate) : undefined;

    return this.transactionsService.findAllByUser(
      req.user.id,
      type,
      accountId,
      categoryId,
      start,
      end,
    );
  }

  /**
   * Get monthly summary
   */
  @Get('summary/:year/:month')
  getMonthlySummary(
    @Request() req,
    @Param('year', ParseIntPipe) year: number,
    @Param('month', ParseIntPipe) month: number,
  ) {
    if (month < 1 || month > 12) {
      throw new BadRequestException('Month must be between 1 and 12');
    }
    return this.transactionsService.getMonthlySummary(req.user.id, year, month);
  }

  /**
   * Get transaction by ID
   */
  @Get(':id')
  findOne(@Request() req, @Param('id', ParseIntPipe) id: number) {
    return this.transactionsService.findOne(id, req.user.id);
  }

  /**
   * Update transaction
   */
  @Patch(':id')
  @UseInterceptors(FileInterceptor('receipt'))
  update(
    @Request() req,
    @Param('id', ParseIntPipe) id: number,
    @Body() updateTransactionDto: UpdateTransactionDto,
    @UploadedFile() receiptFile?: Express.Multer.File,
  ) {
    return this.transactionsService.update(req.user.id, id, updateTransactionDto, receiptFile);
  }

  /**
   * Delete transaction
   */
  @Delete(':id')
  remove(@Request() req, @Param('id', ParseIntPipe) id: number) {
    return this.transactionsService.remove(id, req.user.id);
  }
}