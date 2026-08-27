import { Controller, Get, Post, Body } from '@nestjs/common';
import { RepaymentsService } from './repayments.service';

@Controller('repayments')
export class RepaymentsController {
  constructor(private readonly repaymentsService: RepaymentsService) {}

  @Get()
  findAll() {
    return this.repaymentsService.findAll();
  }

  @Post()
  create(@Body() createRepaymentDto: any) {
    return this.repaymentsService.create(createRepaymentDto);
  }
}
