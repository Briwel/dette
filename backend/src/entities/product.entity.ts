import { Entity, Column, PrimaryGeneratedColumn, CreateDateColumn, ManyToOne, JoinColumn } from 'typeorm';
import { User } from './user.entity';

@Entity('products')
export class Product {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  user_id: number;

  @ManyToOne(() => User)
  @JoinColumn({ name: 'user_id' })
  user: User;

  @Column()
  nom: string;

  @Column({ nullable: true })
  photo_uri: string;

  @Column()
  unite: string;

  @Column({ default: true })
  actif: boolean;

  @CreateDateColumn()
  date_creation: Date;
}
