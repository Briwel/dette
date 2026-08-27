import { Test, TestingModule } from '@nestjs/testing';
import { DailyRevenuesController } from './daily-revenues.controller';

describe('DailyRevenuesController', () => {
  let controller: DailyRevenuesController;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [DailyRevenuesController],
    }).compile();

    controller = module.get<DailyRevenuesController>(DailyRevenuesController);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });
});
