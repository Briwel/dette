import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { SuppliersModule } from './suppliers/suppliers.module';
import { PurchasesModule } from './purchases/purchases.module';
import { ProductsModule } from './products/products.module';
import { RepaymentsModule } from './repayments/repayments.module';
import { DailyRevenuesModule } from './daily-revenues/daily-revenues.module';
import { AdviceModule } from './advice/advice.module';

@Module({
  imports: [
    TypeOrmModule.forRoot({
      type: 'better-sqlite3',
      database: 'dantokpa.sqlite',
      entities: [__dirname + '/**/*.entity{.ts,.js}'],
      synchronize: true,
    }),
    SuppliersModule,
    PurchasesModule,
    ProductsModule,
    RepaymentsModule,
    DailyRevenuesModule,
    AdviceModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
