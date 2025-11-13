import { Module } from '@nestjs/common';
import { DashboardService } from './dashboard.service';
import { DashboardController } from './dashboard.controller';
import { TransactionsModule } from '../transactions/transactions.module';
import { AccountsModule } from '../accounts/accounts.module';

@Module({
  imports: [TransactionsModule, AccountsModule],
  providers: [DashboardService],
  controllers: [DashboardController],
})
export class DashboardModule {}