import { Test, TestingModule } from '@nestjs/testing';
import { DailyRevenuesService } from './daily-revenues.service';

describe('DailyRevenuesService', () => {
  let service: DailyRevenuesService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [DailyRevenuesService],
    }).compile();

    service = module.get<DailyRevenuesService>(DailyRevenuesService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });
});
