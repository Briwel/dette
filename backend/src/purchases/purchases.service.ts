import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Purchase } from '../entities/purchase.entity';
import { PurchaseItem } from '../entities/purchase_item.entity';
import { Supplier } from '../entities/supplier.entity';

@Injectable()
export class PurchasesService {
  constructor(
    @InjectRepository(Purchase)
    private purchasesRepository: Repository<Purchase>,
    @InjectRepository(PurchaseItem)
    private purchaseItemsRepository: Repository<PurchaseItem>,
    @InjectRepository(Supplier)
    private suppliersRepository: Repository<Supplier>,
  ) {}

  async getSummary() {
    const purchases = await this.purchasesRepository.find();
    const totalDebt = purchases.reduce((sum, p) => sum + Number(p.montant_restant || 0), 0);
    const activePurchasesCount = purchases.filter(p => Number(p.montant_restant || 0) > 0).length;
    const urgentPaymentsCount = purchases.filter(p => Number(p.montant_restant || 0) > 20000).length;

    return {
      totalDebt,
      activePurchasesCount,
      urgentPaymentsCount,
    };
  }

  async findAll() {
    const purchases = await this.purchasesRepository.find({
      relations: { supplier: true },
      order: { date_achat: 'DESC' },
    });
    return purchases;
  }

  async findBySupplier(supplierId: number) {
    const purchases = await this.purchasesRepository.find({
      where: { supplier_id: supplierId },
      order: { date_achat: 'DESC' },
    });
    return purchases;
  }

  async create(data: any) {
    let supplierId = data.supplier_id || data.supplierId;

    if (!supplierId && data.supplierNom) {
      let supplier = await this.suppliersRepository.findOne({ where: { nom: data.supplierNom } });
      if (!supplier) {
        supplier = await this.suppliersRepository.save({
          nom: data.supplierNom,
          user_id: 1,
        });
      }
      supplierId = supplier.id;
    }

    const items = data.items || [];
    let calculatedTotal = 0;
    for (const item of items) {
      calculatedTotal += Number(item.price || item.unitPrice || 0);
    }

    const totalAmount = data.montant_total || calculatedTotal || 0;
    const initialPayment = Number(data.deja_paye || data.initialPayment || 0);
    const remainingAmount = Math.max(0, totalAmount - initialPayment);
    const status = remainingAmount === 0 ? 'paid' : initialPayment > 0 ? 'partially_paid' : 'unpaid';

    const newPurchase = this.purchasesRepository.create({
      user_id: 1,
      supplier_id: supplierId,
      date_achat: data.date_achat ? new Date(data.date_achat) : new Date(),
      montant_total: totalAmount,
      montant_initialement_paye: initialPayment,
      montant_restant: remainingAmount,
      statut: status,
    });

    const savedPurchase = await this.purchasesRepository.save(newPurchase);

    return savedPurchase;
  }
}
