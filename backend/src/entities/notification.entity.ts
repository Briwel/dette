import { Entity, Column, PrimaryGeneratedColumn, CreateDateColumn, ManyToOne, JoinColumn } from 'typeorm';
import { User } from './user.entity';

@Entity('notifications')
export class Notification {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  user_id: number;

  @ManyToOne(() => User)
  @JoinColumn({ name: 'user_id' })
  user: User;

  @Column()
  type: string;

  @Column()
  titre: string;

  @Column()
  message: string;

  @Column()
  date_programmee: Date;

  @Column({ default: false })
  lu: boolean;

  @Column({ default: true })
  active: boolean;

  @CreateDateColumn()
  created_at: Date;
}
