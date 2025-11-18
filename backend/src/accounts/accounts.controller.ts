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
} from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { ApiTags, ApiResponse, ApiBearerAuth } from '@nestjs/swagger';
import { AccountsService } from './accounts.service';
import { CreateAccountDto } from './dto/create-account.dto';
import { UpdateAccountDto } from './dto/update-account.dto';

@ApiTags('Accounts')
@ApiBearerAuth('JWT-auth')
@Controller('accounts')
@UseGuards(AuthGuard('jwt'))
export class AccountsController {
  constructor(private readonly accountsService: AccountsService) {}

  /**
   * Create new account
   */
  @Post()
  @ApiResponse({ status: 201, description: 'Account successfully created' })
  @ApiResponse({ status: 400, description: 'Invalid input data' })
  create(@Request() req, @Body() createAccountDto: CreateAccountDto) {
    return this.accountsService.create(req.user.id, createAccountDto);
  }

  /**
   * Get all user accounts
   */
  @Get()
  findAll(@Request() req) {
    return this.accountsService.findAllByUser(req.user.id);
  }

  /**
   * Get total balance across all accounts
   */
  @Get('total-balance')
  getTotalBalance(@Request() req) {
    return this.accountsService.getTotalBalance(req.user.id);
  }

  /**
   * Get account by ID
   */
  @Get(':id')
  findOne(@Request() req, @Param('id') id: string) {
    return this.accountsService.findOne(+id, req.user.id);
  }

  /**
   * Update account
   */
  @Patch(':id')
  update(@Request() req, @Param('id') id: string, @Body() updateAccountDto: UpdateAccountDto) {
    return this.accountsService.update(+id, req.user.id, updateAccountDto);
  }

  /**
   * Delete account
   */
  @Delete(':id')
  remove(@Request() req, @Param('id') id: string) {
    return this.accountsService.remove(+id, req.user.id);
  }
}