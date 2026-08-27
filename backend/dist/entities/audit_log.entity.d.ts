import { User } from './user.entity';
export declare class AuditLog {
    id: number;
    user_id: number;
    user: User;
    action: string;
    table_cible: string;
    identifiant_cible: number;
    ancienne_valeur: string;
    nouvelle_valeur: string;
    date_action: Date;
}
