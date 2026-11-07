import { Repository } from 'typeorm';
import { Supplier } from '../entities/supplier.entity';
import { Purchase } from '../entities/purchase.entity';
export declare class SuppliersService {
    private suppliersRepository;
    private purchasesRepository;
    constructor(suppliersRepository: Repository<Supplier>, purchasesRepository: Repository<Purchase>);
    findAll(): Promise<{
        dette: number;
        nbAchats: number;
        id: number;
        user_id: number;
        nom: string;
        telephone: string;
        photo_uri: string;
        couleur: string;
        actif: boolean;
        date_creation: Date;
    }[]>;
    findOne(id: number): Promise<{
        dette: number;
        nbAchats: number;
        purchases: Purchase[];
        id: number;
        user_id: number;
        nom: string;
        telephone: string;
        photo_uri: string;
        couleur: string;
        actif: boolean;
        date_creation: Date;
    } | null>;
    create(supplierData: Partial<Supplier>): Promise<{
        dette: number;
        nbAchats: number;
        id: number;
        user_id: number;
        nom: string;
        telephone: string;
        photo_uri: string;
        couleur: string;
        actif: boolean;
        date_creation: Date;
    }>;
    update(id: number, supplierData: Partial<Supplier>): Promise<{
        dette: number;
        nbAchats: number;
        purchases: Purchase[];
        id: number;
        user_id: number;
        nom: string;
        telephone: string;
        photo_uri: string;
        couleur: string;
        actif: boolean;
        date_creation: Date;
    } | null>;
    remove(id: number): Promise<{
        success: boolean;
    }>;
}
