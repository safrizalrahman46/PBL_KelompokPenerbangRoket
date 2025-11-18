<?php

namespace App\Filament\Widgets;

use Filament\Tables;
use Filament\Tables\Table;
use Filament\Widgets\TableWidget as BaseWidget;
use App\Models\Menu;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Columns\ImageColumn;
// 💡 PASTIKAN ANDA IMPORT 'BUILDER'
use Illuminate\Database\Eloquent\Builder; 

class BestSellingMenusTable extends BaseWidget
{
     protected static ?string $heading = 'Top 5 Menu Terlaris (Lunas)'; // Ganti judul
     protected static ?int $sort = 4;
     protected int | string | array $columnSpan = 'full';

     public function table(Table $table): Table
     {
         return $table
            ->query(
              Menu::query()
                   // ⬇️ INI BAGIAN YANG DIPERBARUI ⬇️
                   ->withSum([
                       'orderItems' => function (Builder $query) {
                          // Hanya hitung orderItems...
                          $query->whereHas('order', function (Builder $subQuery) {
                            // ...yang parent order-nya berstatus 'completed'
                            $subQuery->where('status', 'completed');
                          });
                       }
                   ], 'quantity') // Kolom yang dijumlahkan
                   // ⬆️ SELESAI PEMBARUAN ⬆️
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
                   ->label('Jumlah Terjual (Lunas)') // Ganti label
                   ->numeric()
                   ->sortable()
                   ->default(0), // Tampilkan 0 jika tidak ada
            ])
            ->paginated(false);
     }
}