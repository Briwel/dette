import { User } from './user.entity';
export declare class Notification {
    id: number;
    user_id: number;
    user: User;
    type: string;
    titre: string;
    message: string;
    date_programmee: Date;
    lu: boolean;
    active: boolean;
    created_at: Date;
}
