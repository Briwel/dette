import { Controller, Get } from '@nestjs/common';
import { AdviceService } from './advice.service';

@Controller()
export class AdviceController {
  constructor(private readonly adviceService: AdviceService) {}

  @Get('repayment-advice')
  getAdvice() {
    return this.adviceService.getAdvice();
  }

  @Get('repayment-plan')
  getPlan() {
    return this.adviceService.getAdvice();
  }
}
