import { Controller, Get, Post, Put, Delete, Body, Param } from '@nestjs/common';
import { SuppliersService } from './suppliers.service';

@Controller('suppliers')
export class SuppliersController {
  constructor(private readonly suppliersService: SuppliersService) {}

  @Get()
  findAll() {
    return this.suppliersService.findAll();
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.suppliersService.findOne(+id);
  }

  @Post()
  create(@Body() createSupplierDto: any) {
    return this.suppliersService.create(createSupplierDto);
  }

  @Put(':id')
  update(@Param('id') id: string, @Body() updateSupplierDto: any) {
    return this.suppliersService.update(+id, updateSupplierDto);
  }

  @Delete(':id')
  remove(@Param('id') id: string) {
    return this.suppliersService.remove(+id);
  }
}
