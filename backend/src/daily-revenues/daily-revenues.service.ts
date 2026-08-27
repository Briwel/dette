import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { DailyRevenue } from '../entities/daily_revenue.entity';

@Injectable()
export class DailyRevenuesService {
  constructor(
    @InjectRepository(DailyRevenue)
    private dailyRevenuesRepository: Repository<DailyRevenue>,
  ) {}

  async findAll() {
    return this.dailyRevenuesRepository.find({ order: { created_at: 'DESC' } });
  }

  async getSummary() {
    const revenues = await this.dailyRevenuesRepository.find();
    const today = new Date().toISOString().split('T')[0];
    const todayRevenues = revenues.filter(r => new Date(r.date_recette).toISOString().split('T')[0] === today);
    const todayTotal = todayRevenues.reduce((sum, r) => sum + Number(r.montant || 0), 0);
    
    const totalAll = revenues.reduce((sum, r) => sum + Number(r.montant || 0), 0);
    const avg = revenues.length > 0 ? Math.round(totalAll / revenues.length) : 0;

    return {
      todayTotal,
      averageRevenue: avg,
    };
  }

  async create(revenueData: any) {
    const newRevenue = this.dailyRevenuesRepository.create({
      user_id: 1,
      date_recette: revenueData.date_recette ? new Date(revenueData.date_recette) : new Date(),
      montant: Number(revenueData.montant || 0),
    });
    return this.dailyRevenuesRepository.save(newRevenue);
  }
}
