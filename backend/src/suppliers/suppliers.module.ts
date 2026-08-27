import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { SuppliersController } from './suppliers.controller';
import { SuppliersService } from './suppliers.service';
import { Supplier } from '../entities/supplier.entity';
import { Purchase } from '../entities/purchase.entity';

@Module({
  imports: [TypeOrmModule.forFeature([Supplier, Purchase])],
  controllers: [SuppliersController],
  providers: [SuppliersService],
  exports: [SuppliersService],
})
export class SuppliersModule {}
