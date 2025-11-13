import { Injectable } from '@nestjs/common';
import { TransactionsService } from '../transactions/transactions.service';
import { AccountsService } from '../accounts/accounts.service';

@Injectable()
export class DashboardService {
  constructor(
    private transactionsService: TransactionsService,
    private accountsService: AccountsService,
  ) {}

  /**
   * Get dashboard data for current month
   */
  async getDashboardData(userId: number) {
    const now = new Date();
    const currentYear = now.getFullYear();
    const currentMonth = now.getMonth() + 1;

    // Get current month summary
    const currentSummary = await this.transactionsService.getMonthlySummary(
      userId,
      currentYear,
      currentMonth,
    );

    // Get previous month for comparison
    const prevMonth = currentMonth === 1 ? 12 : currentMonth - 1;
    const prevYear = currentMonth === 1 ? currentYear - 1 : currentYear;
    const previousSummary = await this.transactionsService.getMonthlySummary(
      userId,
      prevYear,
      prevMonth,
    );

    // Get total balance across all accounts
    const totalBalance = await this.accountsService.getTotalBalance(userId);

    // Get all user accounts
    const accounts = await this.accountsService.findAllByUser(userId);

    return {
      currentMonth: currentSummary,
      previousMonth: previousSummary,
      totalBalance,
      accounts,
      comparison: {
        incomeChange: this.calculatePercentageChange(
          previousSummary.totalIncome,
          currentSummary.totalIncome,
        ),
        expenseChange: this.calculatePercentageChange(
          previousSummary.totalExpenses,
          currentSummary.totalExpenses,
        ),
        balanceChange: this.calculatePercentageChange(
          previousSummary.netBalance,
          currentSummary.netBalance,
        ),
      },
    };
  }

  /**
   * Get yearly overview with monthly data
   */
  async getYearlyOverview(userId: number, year: number) {
    const monthlyData = [];

    for (let month = 1; month <= 12; month++) {
      const summary = await this.transactionsService.getMonthlySummary(
        userId,
        year,
        month,
      );
      monthlyData.push(summary);
    }

    // Calculate yearly totals
    const yearlyTotals = monthlyData.reduce(
      (totals, month) => ({
        totalIncome: totals.totalIncome + month.totalIncome,
        totalExpenses: totals.totalExpenses + month.totalExpenses,
        netBalance: totals.netBalance + month.netBalance,
        transactionCount: totals.transactionCount + month.transactionCount,
      }),
      { totalIncome: 0, totalExpenses: 0, netBalance: 0, transactionCount: 0 },
    );

    return {
      year,
      monthlyData,
      yearlyTotals,
    };
  }

  /**
   * Get spending by category for current month
   */
  async getSpendingByCategory(userId: number) {
    const now = new Date();
    const startDate = new Date(now.getFullYear(), now.getMonth(), 1);
    const endDate = new Date(now.getFullYear(), now.getMonth() + 1, 0);

    const expenses = await this.transactionsService.findAllByUser(
      userId,
      undefined,
      undefined,
      undefined,
      startDate,
      endDate,
    );

    const categoryTotals = expenses
      .filter(t => t.type === 'expense')
      .reduce((acc, transaction) => {
        const categoryName = transaction.category?.name || 'Uncategorized';
        const categoryColor = transaction.category?.color || '#6c757d';
        
        if (!acc[categoryName]) {
          acc[categoryName] = {
            name: categoryName,
            total: 0,
            color: categoryColor,
            transactions: 0,
          };
        }
        
        acc[categoryName].total += Number(transaction.amount);
        acc[categoryName].transactions += 1;
        
        return acc;
      }, {});

    return Object.values(categoryTotals).sort((a: any, b: any) => b.total - a.total);
  }

  /**
   * Calculate percentage change between two values
   */
  private calculatePercentageChange(oldValue: number, newValue: number): number {
    if (oldValue === 0) {
      return newValue > 0 ? 100 : 0;
    }
    return ((newValue - oldValue) / Math.abs(oldValue)) * 100;
  }
}