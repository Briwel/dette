import { RepaymentsService } from './repayments.service';
export declare class RepaymentsController {
    private readonly repaymentsService;
    constructor(repaymentsService: RepaymentsService);
    findAll(): Promise<import("../entities/repayment.entity").Repayment[]>;
    create(createRepaymentDto: any): Promise<import("../entities/repayment.entity").Repayment>;
}
