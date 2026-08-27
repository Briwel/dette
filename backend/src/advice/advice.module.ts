import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AdviceController } from './advice.controller';
import { AdviceService } from './advice.service';
import { Purchase } from '../entities/purchase.entity';
import { DailyRevenue } from '../entities/daily_revenue.entity';

@Module({
  imports: [TypeOrmModule.forFeature([Purchase, DailyRevenue])],
  controllers: [AdviceController],
  providers: [AdviceService],
  exports: [AdviceService],
})
export class AdviceModule {}
