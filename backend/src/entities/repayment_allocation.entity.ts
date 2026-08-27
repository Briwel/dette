import { Entity, Column, PrimaryGeneratedColumn, ManyToOne, JoinColumn } from 'typeorm';
import { Repayment } from './repayment.entity';
import { Purchase } from './purchase.entity';

@Entity('repayment_allocations')
export class RepaymentAllocation {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  repayment_id: number;

  @ManyToOne(() => Repayment)
  @JoinColumn({ name: 'repayment_id' })
  repayment: Repayment;

  @Column()
  purchase_id: number;

  @ManyToOne(() => Purchase)
  @JoinColumn({ name: 'purchase_id' })
  purchase: Purchase;

  @Column('decimal', { precision: 10, scale: 2 })
  montant_affecte: number;
}
