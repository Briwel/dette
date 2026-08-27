import { Repository } from 'typeorm';
import { DailyRevenue } from '../entities/daily_revenue.entity';
export declare class DailyRevenuesService {
    private dailyRevenuesRepository;
    constructor(dailyRevenuesRepository: Repository<DailyRevenue>);
    findAll(): Promise<DailyRevenue[]>;
    getSummary(): Promise<{
        todayTotal: number;
        averageRevenue: number;
    }>;
    create(revenueData: any): Promise<DailyRevenue>;
}
