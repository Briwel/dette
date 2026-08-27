import { DailyRevenuesService } from './daily-revenues.service';
export declare class DailyRevenuesController {
    private readonly dailyRevenuesService;
    constructor(dailyRevenuesService: DailyRevenuesService);
    getSummary(): Promise<{
        todayTotal: number;
        averageRevenue: number;
    }>;
    findAll(): Promise<import("../entities/daily_revenue.entity").DailyRevenue[]>;
    create(createRevenueDto: any): Promise<import("../entities/daily_revenue.entity").DailyRevenue>;
}
