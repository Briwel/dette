import { User } from './user.entity';
export declare class Product {
    id: number;
    user_id: number;
    user: User;
    nom: string;
    photo_uri: string;
    unite: string;
    actif: boolean;
    date_creation: Date;
}
