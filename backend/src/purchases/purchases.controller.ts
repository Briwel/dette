import { Controller, Get, Post, Body, Param, Query } from '@nestjs/common';
import { PurchasesService } from './purchases.service';

@Controller('purchases')
export class PurchasesController {
  constructor(private readonly purchasesService: PurchasesService) {}

  @Get('summary')
  getSummary() {
    return this.purchasesService.getSummary();
  }

  @Get()
  findAll(@Query('supplierId') supplierId?: string) {
    if (supplierId) {
      return this.purchasesService.findBySupplier(+supplierId);
    }
    return this.purchasesService.findAll();
  }

  @Post()
  create(@Body() createPurchaseDto: any) {
    return this.purchasesService.create(createPurchaseDto);
  }
}
