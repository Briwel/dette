import { ProductsService } from './products.service';
export declare class ProductsController {
    private readonly productsService;
    constructor(productsService: ProductsService);
    findAll(): Promise<import("../entities/product.entity").Product[]>;
    create(createProductDto: any): Promise<import("../entities/product.entity").Product[]>;
}
