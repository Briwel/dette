import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Supplier } from '../entities/supplier.entity';
import { Purchase } from '../entities/purchase.entity';

@Injectable()
export class SuppliersService {
  constructor(
    @InjectRepository(Supplier)
    private suppliersRepository: Repository<Supplier>,
    @InjectRepository(Purchase)
    private purchasesRepository: Repository<Purchase>,
  ) {}

  async findAll() {
    const suppliers = await this.suppliersRepository.find({ where: { actif: true } });
    const purchases = await this.purchasesRepository.find();

    return suppliers.map(s => {
      const supplierPurchases = purchases.filter(p => p.supplier_id === s.id);
      const detteTotale = supplierPurchases.reduce((sum, p) => sum + Number(p.montant_restant || 0), 0);
      const nbAchats = supplierPurchases.filter(p => Number(p.montant_restant || 0) > 0).length;

      return {
        ...s,
        dette: detteTotale,
        nbAchats: nbAchats,
      };
    });
  }

  async findOne(id: number) {
    const supplier = await this.suppliersRepository.findOne({ where: { id } });
    if (!supplier) return null;
    const purchases = await this.purchasesRepository.find({ where: { supplier_id: id } });
    const detteTotale = purchases.reduce((sum, p) => sum + Number(p.montant_restant || 0), 0);
    const nbAchats = purchases.filter(p => Number(p.montant_restant || 0) > 0).length;
    return {
      ...supplier,
      dette: detteTotale,
      nbAchats: nbAchats,
      purchases,
    };
  }

  async create(supplierData: Partial<Supplier>) {
    const newSupplier = this.suppliersRepository.create({
      user_id: 1,
      ...supplierData,
    });
    const saved = await this.suppliersRepository.save(newSupplier);
    return {
      ...saved,
      dette: 0,
      nbAchats: 0,
    };
  }
}
