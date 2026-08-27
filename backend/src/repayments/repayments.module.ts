import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { RepaymentsController } from './repayments.controller';
import { RepaymentsService } from './repayments.service';
import { Repayment } from '../entities/repayment.entity';
import { Purchase } from '../entities/purchase.entity';
import { Supplier } from '../entities/supplier.entity';

@Module({
  imports: [TypeOrmModule.forFeature([Repayment, Purchase, Supplier])],
  controllers: [RepaymentsController],
  providers: [RepaymentsService],
  exports: [RepaymentsService],
})
export class RepaymentsModule {}
