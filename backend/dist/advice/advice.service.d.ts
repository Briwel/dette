import { Repository } from 'typeorm';
import { Purchase } from '../entities/purchase.entity';
import { DailyRevenue } from '../entities/daily_revenue.entity';
export declare class AdviceService {
    private purchasesRepository;
    private dailyRevenuesRepository;
    constructor(purchasesRepository: Repository<Purchase>, dailyRevenuesRepository: Repository<DailyRevenue>);
    getAdvice(): Promise<{
        hasRevenues: boolean;
        noticeMessage: string | null;
        avgRevenue: number;
        totalDebt: number;
        urgentAmount: number;
        suggestedDailyPayment: number;
        cards: any[];
    }>;
}
