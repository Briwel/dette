import { Entity, Column, PrimaryGeneratedColumn, CreateDateColumn, ManyToOne, JoinColumn } from 'typeorm';
import { User } from './user.entity';

@Entity('audit_logs')
export class AuditLog {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  user_id: number;

  @ManyToOne(() => User)
  @JoinColumn({ name: 'user_id' })
  user: User;

  @Column()
  action: string;

  @Column()
  table_cible: string;

  @Column()
  identifiant_cible: number;

  @Column({ nullable: true })
  ancienne_valeur: string;

  @Column({ nullable: true })
  nouvelle_valeur: string;

  @CreateDateColumn()
  date_action: Date;
}
