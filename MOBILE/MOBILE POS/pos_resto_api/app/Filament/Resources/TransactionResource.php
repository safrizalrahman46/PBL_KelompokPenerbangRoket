<?php

namespace App\Filament\Resources;

use App\Filament\Resources\TransactionResource\Pages;
use App\Filament\Resources\TransactionResource\RelationManagers;
use App\Models\Transaction;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\SoftDeletingScope;

// IMPORT YANG DIBUTUHKAN
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Tables\Columns\TextColumn;
use Illuminate\Support\Facades\Auth;

class TransactionResource extends Resource
{
    protected static ?string $model = Transaction::class;

    protected static ?string $navigationIcon = 'heroicon-o-rectangle-stack';

    protected static ?string $navigationGroup = 'Pesanan';
    protected static ?string $modelLabel = 'Riwayat Transaksi';

               public static function canViewAny(): bool
    {
        /** @var \App\Models\User|null $user */
        $user = Auth::user(); // Gunakan Facade Auth::user() lebih aman untuk IDE

        // Pastikan user ada DAN role-nya admin
        // return $user !== null && $user->role === ['admin', 'cashier', 'kitchen'];
        return $user !== null && in_array($user->role, ['admin', 'cashier','kitchen']);
    }

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Select::make('order_id')
                    ->relationship('order', 'id')
                    ->label('Order ID')
                    ->disabled(),
                TextInput::make('payment_method')
                    ->disabled(),
                TextInput::make('amount_paid')
                    ->money('IDR')
                    ->disabled(),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                TextColumn::make('order.id')
                    ->label('Order ID')
                    ->searchable(),
                TextColumn::make('order.customer_name')
                    ->label('Customer')
                    ->searchable(),
                TextColumn::make('payment_method')
                    ->label('Metode Bayar')
                    ->badge()
                    ->color(fn (string $state): string => match ($state) {
                        'cash' => 'success',
                        'qris' => 'info',
                        'debit' => 'warning',
                        default => 'gray',
                    }),
                TextColumn::make('amount_paid')
                    ->label('Jumlah Bayar')
                    ->money('IDR')
                    ->sortable(),
                TextColumn::make('created_at')
                    ->label('Waktu Bayar')
                    ->dateTime('d-M-Y H:i')
                    ->sortable(),
            ])
            ->defaultSort('created_at', 'desc')
            ->filters([
                //
            ])
            ->actions([
                Tables\Actions\EditAction::make(),
            ])
            ->bulkActions([
                // Tables\Actions\BulkActionGroup::make([
                //     Tables\Actions\DeleteBulkAction::make(),
                // ]),
            ]);
    }

    public static function getRelations(): array
    {
        return [
            //
        ];
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListTransactions::route('/'),
            'create' => Pages\CreateTransaction::route('/create'),
            // 'edit' => Pages\EditTransaction::route('/{record}/edit'),
            'view' => Pages\ViewTransaction::route('/{record}'),
        ];
    }
}
