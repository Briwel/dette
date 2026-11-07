import { SuppliersService } from './suppliers.service';
export declare class SuppliersController {
    private readonly suppliersService;
    constructor(suppliersService: SuppliersService);
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
    findOne(id: string): Promise<{
        dette: number;
        nbAchats: number;
        purchases: import("../entities/purchase.entity").Purchase[];
        id: number;
        user_id: number;
        nom: string;
        telephone: string;
        photo_uri: string;
        couleur: string;
        actif: boolean;
        date_creation: Date;
    } | null>;
    create(createSupplierDto: any): Promise<{
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
    update(id: string, updateSupplierDto: any): Promise<{
        dette: number;
        nbAchats: number;
        purchases: import("../entities/purchase.entity").Purchase[];
        id: number;
        user_id: number;
        nom: string;
        telephone: string;
        photo_uri: string;
        couleur: string;
        actif: boolean;
        date_creation: Date;
    } | null>;
    remove(id: string): Promise<{
        success: boolean;
    }>;
}
