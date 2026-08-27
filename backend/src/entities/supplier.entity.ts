import { Entity, Column, PrimaryGeneratedColumn, CreateDateColumn } from 'typeorm';

@Entity('suppliers')
export class Supplier {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ nullable: true, default: 1 })
  user_id: number;

  @Column()
  nom: string;

  @Column({ nullable: true })
  telephone: string;

  @Column({ nullable: true })
  photo_uri: string;

  @Column({ nullable: true, default: '#86EFAC' })
  couleur: string;

  @Column({ default: true })
  actif: boolean;

  @CreateDateColumn()
  date_creation: Date;
}
