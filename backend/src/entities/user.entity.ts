import { Entity, Column, PrimaryGeneratedColumn, CreateDateColumn } from 'typeorm';

@Entity('users')
export class User {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  nom: string;

  @Column()
  telephone: string;

  @Column()
  pin_hash: string;

  @Column({ default: 'fr' })
  langue: string;

  @CreateDateColumn()
  date_creation: Date;
}
