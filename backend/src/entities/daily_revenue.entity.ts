import { Entity, Column, PrimaryGeneratedColumn, CreateDateColumn } from 'typeorm';

@Entity('daily_revenues')
export class DailyRevenue {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ nullable: true, default: 1 })
  user_id: number;

  @Column()
  date_recette: Date;

  @Column('decimal', { precision: 10, scale: 2 })
  montant: number;

  @CreateDateColumn()
  created_at: Date;
}
