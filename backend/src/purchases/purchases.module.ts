import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { PurchasesController } from './purchases.controller';
import { PurchasesService } from './purchases.service';
import { Purchase } from '../entities/purchase.entity';
import { PurchaseItem } from '../entities/purchase_item.entity';
import { Supplier } from '../entities/supplier.entity';

@Module({
  imports: [TypeOrmModule.forFeature([Purchase, PurchaseItem, Supplier])],
  controllers: [PurchasesController],
  providers: [PurchasesService],
  exports: [PurchasesService],
})
export class PurchasesModule {}
