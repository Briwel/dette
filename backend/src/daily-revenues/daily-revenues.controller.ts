import { Controller, Get, Post, Body } from '@nestjs/common';
import { DailyRevenuesService } from './daily-revenues.service';

@Controller('daily-revenues')
export class DailyRevenuesController {
  constructor(private readonly dailyRevenuesService: DailyRevenuesService) {}

  @Get('summary')
  getSummary() {
    return this.dailyRevenuesService.getSummary();
  }

  @Get()
  findAll() {
    return this.dailyRevenuesService.findAll();
  }

  @Post()
  create(@Body() createRevenueDto: any) {
    return this.dailyRevenuesService.create(createRevenueDto);
  }
}
