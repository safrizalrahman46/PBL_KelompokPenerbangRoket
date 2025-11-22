<?php

namespace App\Filament\Widgets;

use Filament\Tables;
use Filament\Tables\Table;
use Filament\Widgets\TableWidget as BaseWidget;
use App\Models\Order;
use Filament\Tables\Actions\ViewAction;
use Filament\Tables\Columns\TextColumn;

class RecentOrdersTable extends BaseWidget
{
    protected static ?string $heading = 'Pesanan Terbaru (Aktif)';
    protected static ?int $sort = 3; // Urutan ketiga
    protected int | string | array $columnSpan = 'full';

    public function table(Table $table): Table
    {
        return $table
            // Ambil 5 pesanan terbaru yang BELUM 'paid' atau 'cancelled'
            ->query(
                Order::query()
                    ->whereNotIn('status', ['paid', 'cancelled'])
                    ->orderBy('created_at', 'desc')
                    ->limit(5)
            )
            ->columns([
                TextColumn::make('id')->label('ID Order'),
                TextColumn::make('customer_name')->label('Customer'),
                TextColumn::make('restoTable.name')->label('Meja'),
                TextColumn::make('status')
                    ->badge()
                    ->color(fn (string $state): string => match ($state) {
                        'pending' => 'warning',
                        'preparing' => 'info',
                        'ready' => 'success',
                        'delivered' => 'primary',
                        default => 'gray',
                    }),
                TextColumn::make('total_price')->money('IDR'),
            ])
            ->actions([
                // Tambahkan tombol View agar bisa diklik
                ViewAction::make()
                    ->url(fn (Order $record): string => route('filament.admin.resources.orders.view', $record)),
            ])
            ->paginated(false);
    }
}
