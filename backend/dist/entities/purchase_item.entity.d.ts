import { Purchase } from './purchase.entity';
import { Product } from './product.entity';
export declare class PurchaseItem {
    id: number;
    purchase_id: number;
    purchase: Purchase;
    product_id: number;
    product: Product;
    quantite: number;
    prix_unitaire: number;
    montant: number;
}
