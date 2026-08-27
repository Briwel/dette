import { Repository } from 'typeorm';
import { Product } from '../entities/product.entity';
export declare class ProductsService {
    private productsRepository;
    constructor(productsRepository: Repository<Product>);
    findAll(): Promise<Product[]>;
    create(productData: any): Promise<Product[]>;
}
