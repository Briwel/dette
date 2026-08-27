import { Entity, Column, PrimaryGeneratedColumn, ManyToOne, JoinColumn } from 'typeorm';
import { Purchase } from './purchase.entity';
import { Product } from './product.entity';

@Entity('purchase_items')
export class PurchaseItem {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  purchase_id: number;

  @ManyToOne(() => Purchase)
  @JoinColumn({ name: 'purchase_id' })
  purchase: Purchase;

  @Column()
  product_id: number;

  @ManyToOne(() => Product)
  @JoinColumn({ name: 'product_id' })
  product: Product;

  @Column()
  quantite: number;

  @Column('decimal', { precision: 10, scale: 2 })
  prix_unitaire: number;

  @Column('decimal', { precision: 10, scale: 2 })
  montant: number;
}
