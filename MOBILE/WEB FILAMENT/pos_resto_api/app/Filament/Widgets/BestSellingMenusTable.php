<?php

namespace App\Filament\Widgets;

use Filament\Tables;
use Filament\Tables\Table;
use Filament\Widgets\TableWidget as BaseWidget;
use App\Models\Menu;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Columns\ImageColumn;

class BestSellingMenusTable extends BaseWidget
{
    protected static ?string $heading = 'Top 5 Menu Terlaris';
    protected static ?int $sort = 4; // Urutan keempat
    protected int | string | array $columnSpan = 'full';

    public function table(Table $table): Table
    {
        return $table
            ->query(
                Menu::query()
                    ->withSum('orderItems', 'quantity') // Membuat kolom 'order_items_sum_quantity'
                    ->orderByDesc('order_items_sum_quantity')
                    ->limit(5)
            )
            ->columns([
                ImageColumn::make('image')->disk('public'),
                TextColumn::make('name')->label('Nama Menu'),
                TextColumn::make('stock')->label('Sisa Stok')
                    ->badge()
                    ->color(fn (string $state): string => $state <= 10 ? 'danger' : 'success'),
                TextColumn::make('order_items_sum_quantity')
                    ->label('Jumlah Terjual')
                    ->numeric()
                    ->sortable(),
            ])
            ->paginated(false); // Tidak perlu paginasi
    }
}
