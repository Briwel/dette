import { Entity, Column, PrimaryGeneratedColumn, CreateDateColumn, ManyToOne, JoinColumn } from 'typeorm';
import { Supplier } from './supplier.entity';

@Entity('repayments')
export class Repayment {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ nullable: true, default: 1 })
  user_id: number;

  @Column()
  supplier_id: number;

  @ManyToOne(() => Supplier)
  @JoinColumn({ name: 'supplier_id' })
  supplier: Supplier;

  @Column()
  date_remboursement: Date;

  @Column('decimal', { precision: 10, scale: 2 })
  montant_total: number;

  @Column()
  type_remboursement: string;

  @Column()
  mode_paiement: string;

  @CreateDateColumn()
  created_at: Date;
}
