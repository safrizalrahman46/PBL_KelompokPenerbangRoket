<?php

namespace App\Filament\Resources;

use App\Filament\Resources\OrderResource\Pages;
use App\Filament\Resources\OrderResource\RelationManagers;
use App\Models\Order;
use App\Models\Menu;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\SoftDeletingScope;
use Illuminate\Support\Facades\Auth;
use Illuminate\Database\Eloquent\Model;

// --- IMPORT KOMPONEN FORM & TABEL ---
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Columns\SelectColumn;
use Filament\Tables\Actions\ViewAction;
use Filament\Tables\Actions\EditAction;
use Filament\Tables\Actions\BulkActionGroup;
use Filament\Tables\Actions\DeleteBulkAction;
use Filament\Forms\Components\Grid;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Repeater;
use Filament\Forms\Components\Hidden;
use Filament\Forms\Get;
use Filament\Forms\Set;

// --- IMPORT PLUGIN EXPORT (Wajib agar tombol muncul) ---
use pxlrbt\FilamentExcel\Actions\Tables\ExportAction;
use pxlrbt\FilamentExcel\Exports\ExcelExport;
use Maatwebsite\Excel\Excel;

class OrderResource extends Resource
{
    protected static ?string $model = Order::class;

    protected static ?string $navigationIcon = 'heroicon-o-clipboard-document-list';
    protected static ?string $navigationGroup = 'Pesanan';

    // ✅ LOGIKA HAK AKSES (RBAC)
    public static function canViewAny(): bool
    {
        /** @var \App\Models\User|null $user */
        $user = Auth::user();

        // Admin, Kasir, dan Kitchen boleh akses
        return $user !== null && in_array($user->role, ['admin', 'cashier', 'kitchen']);
    }
    
    // ✅ FORM DENGAN KALKULASI OTOMATIS (Live Update)
    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Grid::make(3)->schema([
                    // --- KOLOM KIRI: INFO ORDER ---
                    Grid::make(1)->schema([
                        Select::make('user_id')
                            ->label('Kasir')
                            ->relationship('user', 'name')
                            ->default(fn () => Auth::id())
                            ->required(),

                        Select::make('resto_table_id')
                            ->label('Meja')
                            ->relationship('restoTable', 'name')
                            ->searchable()
                            ->preload(),

                        TextInput::make('customer_name')
                            ->label('Nama Customer')
                            ->required()
                            ->maxLength(255),

                        Select::make('status')
                            ->options([
                                'pending' => 'Pending',
                                'preparing' => 'Preparing',
                                'ready' => 'Ready',
                                'delivered' => 'Delivered',
                                'paid' => 'Paid',
                                'completed' => 'Completed',
                                'cancelled' => 'Cancelled',
                            ])
                            ->default('pending')
                            ->required(),

                    ])->columnSpan(1),

                    // --- KOLOM KANAN: DETAIL ITEM & HARGA ---
                    Grid::make(1)->schema([
                        Repeater::make('orderItems')
                            ->relationship()
                            ->schema([
                                Select::make('menu_id')
                                    ->label('Menu')
                                    ->options(Menu::query()->where('stock', '>', 0)->pluck('name', 'id'))
                                    ->searchable()
                                    ->required()
                                    ->reactive() // Agar harga terupdate saat menu dipilih
                                    ->afterStateUpdated(function ($state, Set $set) {
                                        $menu = Menu::find($state);
                                        $set('price_at_time', $menu->price ?? 0);
                                    })
                                    ->columnSpan(2),
                                
                                TextInput::make('quantity')
                                    ->numeric()
                                    ->required()
                                    ->default(1)
                                    ->minValue(1)
                                    ->live(onBlur: true) // Update total saat user selesai ketik/klik luar
                                    ->columnSpan(1),

                                TextInput::make('price_at_time')
                                    ->label('Harga')
                                    ->disabled()
                                    ->dehydrated()
                                    ->numeric()
                                    ->required()
                                    ->columnSpan(1),
                            ])
                            ->columns(4)
                            ->defaultItems(1)
                            ->required()
                            ->live() // Agar Repeater memicu update total
                            // LOGIKA HITUNG TOTAL HARGA
                            ->afterStateUpdated(function (Get $get, Set $set) {
                                $totalPrice = 0;
                                $items = $get('orderItems'); 

                                if (is_array($items)) {
                                    foreach ($items as $item) {
                                        $qty = (int)($item['quantity'] ?? 0);
                                        $price = (float)($item['price_at_time'] ?? 0);
                                        $totalPrice += $qty * $price;
                                    }
                                }
                                $set('total_price', $totalPrice);
                            }),

                        TextInput::make('total_price')
                            ->label('Total Harga')
                            ->numeric()
                            ->prefix('Rp')
                            ->readonly() // Readonly karena dihitung otomatis
                            ->dehydrated() // Tetap dikirim ke database
                            ->default(0),

                    ])->columnSpan(2),
                ])->columnSpanFull(),
            ]);
    }

    // ✅ TABEL DENGAN TOMBOL EXPORT
    public static function table(Table $table): Table
    {
        return $table
            // ⬇️ INI BAGIAN PENTING UNTUK EXPORT ⬇️
            ->headerActions([
                ExportAction::make()
                    ->label('Export Data')
                    ->exports([
                        ExcelExport::make('excel')
                            ->fromTable()
                            ->withFilename('Laporan_Order_' . date('Y-m-d'))
                            ->withWriterType(Excel::XLSX)
                            ->label('Download Excel'),
                        
                        ExcelExport::make('pdf')
                            ->fromTable()
                            ->withFilename('Laporan_Order_' . date('Y-m-d'))
                            ->withWriterType(Excel::DOMPDF)
                            ->label('Download PDF'),
                    ]),
            ])
            // ---------------------------------------
            ->columns([
                TextColumn::make('id')->label('ID')->sortable(),
                TextColumn::make('customer_name')->label('Customer')->searchable(),
                TextColumn::make('restoTable.name')->label('Meja')->sortable(),
                
                TextColumn::make('total_price')
                    ->money('IDR')
                    ->sortable(),

                // Inovasi Anda: Ubah status langsung di tabel
                SelectColumn::make('status')
                    ->options([
                        'pending' => 'Pending',
                        'preparing' => 'Preparing',
                        'ready' => 'Ready',
                        'delivered' => 'Delivered',
                        'paid' => 'Paid',
                        'completed' => 'Completed',
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
                Tables\Actions\EditAction::make(),
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