import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Repayment } from '../entities/repayment.entity';
import { Purchase } from '../entities/purchase.entity';
import { Supplier } from '../entities/supplier.entity';

@Injectable()
export class RepaymentsService {
  constructor(
    @InjectRepository(Repayment)
    private repaymentsRepository: Repository<Repayment>,
    @InjectRepository(Purchase)
    private purchasesRepository: Repository<Purchase>,
    @InjectRepository(Supplier)
    private suppliersRepository: Repository<Supplier>,
  ) {}

  async findAll() {
    return this.repaymentsRepository.find({ relations: { supplier: true } });
  }

  async create(data: any) {
    let supplierId = data.supplier_id || data.supplierId;

    if (!supplierId && data.fournisseurNom) {
      const supplier = await this.suppliersRepository.findOne({ where: { nom: data.fournisseurNom } });
      if (supplier) {
        supplierId = supplier.id;
      }
    }

    const amount = Number(data.montant_total || data.amount || 0);
    const paymentMethod = data.mode_paiement || data.paymentMethod || 'Espèces';

    if (supplierId && amount > 0) {
      // Find unpaid/partially paid purchases for this supplier
      const purchases = await this.purchasesRepository.find({
        where: { supplier_id: supplierId },
        order: { date_achat: 'ASC' },
      });

      let remainingPaymentToAllocate = amount;
      for (const purchase of purchases) {
        const currentRestant = Number(purchase.montant_restant || 0);
        if (currentRestant > 0 && remainingPaymentToAllocate > 0) {
          const deduction = Math.min(currentRestant, remainingPaymentToAllocate);
          purchase.montant_restant = currentRestant - deduction;
          remainingPaymentToAllocate -= deduction;
          if (purchase.montant_restant === 0) {
            purchase.statut = 'paid';
          } else {
            purchase.statut = 'partially_paid';
          }
          await this.purchasesRepository.save(purchase);
        }
      }
    }

    const newRepayment = this.repaymentsRepository.create({
      user_id: 1,
      supplier_id: supplierId || 1,
      date_remboursement: data.date ? new Date(data.date) : new Date(),
      montant_total: amount,
      type_remboursement: 'global',
      mode_paiement: paymentMethod,
    });

    return this.repaymentsRepository.save(newRepayment);
  }
}
