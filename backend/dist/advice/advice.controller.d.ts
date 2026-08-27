import { AdviceService } from './advice.service';
export declare class AdviceController {
    private readonly adviceService;
    constructor(adviceService: AdviceService);
    getAdvice(): Promise<{
        hasRevenues: boolean;
        noticeMessage: string | null;
        avgRevenue: number;
        totalDebt: number;
        urgentAmount: number;
        suggestedDailyPayment: number;
        cards: any[];
    }>;
    getPlan(): Promise<{
        hasRevenues: boolean;
        noticeMessage: string | null;
        avgRevenue: number;
        totalDebt: number;
        urgentAmount: number;
        suggestedDailyPayment: number;
        cards: any[];
    }>;
}
