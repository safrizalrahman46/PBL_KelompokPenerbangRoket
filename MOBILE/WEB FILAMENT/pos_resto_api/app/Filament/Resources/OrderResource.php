<?php

namespace App\Filament\Resources;

use App\Filament\Resources\OrderResource\Pages;
use App\Filament\Resources\OrderResource\RelationManagers;
use App\Models\Order;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\SoftDeletingScope;

use App\Models\Menu; // <-- Penting
// use Illuminate\Database\Eloquent\Model; // <-- Penting
use Filament\Forms\Set;
use Illuminate\Support\Facades\Auth;

// ----------------------------------------------------
// ⬇️ IMPORT YANG DIPERBAIKI ⬇️
// ----------------------------------------------------
use Illuminate\Database\Eloquent\Model; // <-- FIX 1: Import Model
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Columns\SelectColumn;
use Filament\Tables\Actions\ViewAction;
use Filament\Tables\Actions\BulkActionGroup;
use Filament\Tables\Actions\DeleteBulkAction;
// FIX 2 & 3: Import class-nya secara langsung
use App\Filament\Resources\OrderResource\Pages\ListOrders;
use App\Filament\Resources\OrderResource\Pages\ViewOrder;
use App\Filament\Resources\OrderResource\RelationManagers\OrderItemsRelationManager;
use Filament\Forms\Components\Grid;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Repeater;
use Filament\Forms\Components\Hidden;
use Filament\Forms\Get;



class OrderResource extends Resource
{
    protected static ?string $model = Order::class;

    protected static ?string $navigationIcon = 'heroicon-o-rectangle-stack';
    protected static ?string $navigationGroup = 'Pesanan';

    // public static function canCreate(): bool { return false; }
    // public static function canEdit(Model $record): bool { return false; }
    public static function form(Form $form): Form
    {
        return $form
        ->schema([
                Grid::make(3)->schema([
                    // Kolom Kiri: Info Order
                    Grid::make(1)->schema([
                        Select::make('user_id')
                            ->label('Kasir')
                            ->relationship('user', 'name')
                            ->default(Auth::id())
                            // ->default(auth()->id())
                            ->required(),

                        Select::make('resto_table_id')
                            ->label('Meja')
                            ->relationship('restoTable', 'name')
                            ->searchable()
                            ->preload(),

                        TextInput::make('customer_name')
                            ->label('Nama Customer'),

                        Select::make('status')
                            ->options([
                                'pending' => 'Pending',
                                'preparing' => 'Preparing',
                                'ready' => 'Ready',
                                'delivered' => 'Delivered',
                                'paid' => 'Paid',
                                'cancelled' => 'Cancelled',
                            ])
                            ->default('pending')
                            ->required(),

                    ])->columnSpan(1),

                    // Kolom Kanan: Detail Item
                    Grid::make(1)->schema([
                        Repeater::make('orderItems')
                            ->relationship()
                            ->schema([
                                Select::make('menu_id')
                                    ->label('Menu')
                                    ->options(Menu::pluck('name', 'id'))
                                    ->searchable()
                                    ->required()
                                    ->reactive() // <-- Tetap reaktif
                                    ->afterStateUpdated(function ($state, Set $set) {
                                        $menu = Menu::find($state);
                                        $set('price_at_time', $menu->price ?? 0);
                                    }),

                                TextInput::make('quantity')
                                    ->numeric()
                                    ->required()
                                    ->default(1)
                                    ->minValue(1)
                                    ->live(onBlur: true), // <-- UBAH INI: jadi 'live'

                                Hidden::make('price_at_time')
                                    ->default(0),
                            ])
                            ->columns(2)
                            ->defaultItems(1)
                            ->required()
                            ->live() // <-- TAMBAHKAN INI: Buat Repeater jadi 'live'
                            // ⬇️ TAMBAHKAN FUNGSI INI ⬇️
                            ->afterStateUpdated(function (Get $get, Set $set) {
                                // Hitung total secara manual
                                $totalPrice = 0;
                                $items = $get('orderItems'); // Ambil semua item

                                if (is_array($items)) {
                                    foreach ($items as $item) {
                                        // price_at_time * quantity
                                        // $totalPrice += ($item['price_at_time'] ?? 0) * ($item['quantity'] ?? 1);
                                        $totalPrice += (float)($item['price_at_time'] ?? 0) * (int)($item['quantity'] ?? 1);
                                    }
                                }
                                // Set nilai 'total_price' di form
                                $set('total_price', $totalPrice);
                            }),

                        TextInput::make('total_price')
                            ->numeric()
                            ->prefix('Rp')
                            ->readonly()
                            ->default(0), // <-- Kita biarkan readonly

                    ])->columnSpan(2),
                ])->columnSpanFull(),
            ]);

    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                TextColumn::make('id')->sortable(),
                TextColumn::make('customer_name')->label('Customer')->searchable(),
                TextColumn::make('restoTable.name')->label('Meja')->sortable(),
                TextColumn::make('total_price')->money('IDR')->sortable(),

                // INI UNTUK INOVASI ANDA (Bisa ganti status dari admin)
                SelectColumn::make('status')
                    ->options([
                        'pending' => 'Pending',
                        'preparing' => 'Preparing',
                        'ready' => 'Ready',
                        'delivered' => 'Delivered',
                        'paid' => 'Paid',
                        'cancelled' => 'Cancelled',
                    ])
                    ->sortable(),

                TextColumn::make('user.name')->label('Kasir')->sortable(),
                TextColumn::make('created_at')->dateTime('d-M-Y H:i')->sortable(),
            ])
            ->defaultSort('created_at', 'desc')
            ->filters([
                //
            ])
            ->actions([
               Tables\Actions\EditAction::make(), // <-- Ganti View jadi Edit
                Tables\Actions\ViewAction::make(),

            ])
            ->bulkActions([
                Tables\Actions\BulkActionGroup::make([
                    Tables\Actions\DeleteBulkAction::make(),
                ]),
            ]);
    }

    public static function getRelations(): array
    {
        return [
            RelationManagers\OrderItemsRelationManager::class,
        ];
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListOrders::route('/'),
            'create' => Pages\CreateOrder::route('/create'),
            'edit' => Pages\EditOrder::route('/{record}/edit'),
            'view' => Pages\ViewOrder::route('/{record}'),
        ];
    }
}



