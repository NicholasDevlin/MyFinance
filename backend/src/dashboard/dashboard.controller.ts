import {
  Controller,
  Get,
  UseGuards,
  Request,
  Param,
  ParseIntPipe,
} from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { DashboardService } from './dashboard.service';

@Controller('dashboard')
@UseGuards(AuthGuard('jwt'))
export class DashboardController {
  constructor(private readonly dashboardService: DashboardService) {}

  /**
   * Get main dashboard data
   */
  @Get()
  getDashboardData(@Request() req) {
    return this.dashboardService.getDashboardData(req.user.id);
  }

  /**
   * Get yearly overview
   */
  @Get('yearly/:year')
  getYearlyOverview(
    @Request() req,
    @Param('year', ParseIntPipe) year: number,
  ) {
    return this.dashboardService.getYearlyOverview(req.user.id, year);
  }

  /**
   * Get spending by category
   */
  @Get('spending-by-category')
  getSpendingByCategory(@Request() req) {
    return this.dashboardService.getSpendingByCategory(req.user.id);
  }
}