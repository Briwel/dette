import { Entity, Column, PrimaryGeneratedColumn, CreateDateColumn, UpdateDateColumn, ManyToOne, JoinColumn } from 'typeorm';
import { Supplier } from './supplier.entity';

@Entity('purchases')
export class Purchase {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ nullable: true, default: 1 })
  user_id: number;

  @Column()
  supplier_id: number;

  @ManyToOne(() => Supplier, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'supplier_id' })
  supplier: Supplier;

  @Column()
  date_achat: Date;

  @Column({ nullable: true })
  date_echeance: Date;

  @Column('decimal', { precision: 10, scale: 2 })
  montant_total: number;

  @Column('decimal', { precision: 10, scale: 2 })
  montant_initialement_paye: number;

  @Column('decimal', { precision: 10, scale: 2 })
  montant_restant: number;

  @Column()
  statut: string;

  @CreateDateColumn()
  created_at: Date;

  @UpdateDateColumn()
  updated_at: Date;
}
