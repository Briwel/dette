import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { DailyRevenuesController } from './daily-revenues.controller';
import { DailyRevenuesService } from './daily-revenues.service';
import { DailyRevenue } from '../entities/daily_revenue.entity';

@Module({
  imports: [TypeOrmModule.forFeature([DailyRevenue])],
  controllers: [DailyRevenuesController],
  providers: [DailyRevenuesService],
})
export class DailyRevenuesModule {}
