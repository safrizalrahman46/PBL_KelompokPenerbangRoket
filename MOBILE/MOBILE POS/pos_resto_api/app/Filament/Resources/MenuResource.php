<?php

namespace App\Filament\Resources;

use App\Filament\Resources\MenuResource\Pages;
use App\Models\Menu;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;

// ----------------------------------------------------
// ⬇️ IMPORT LENGKAP YANG KITA BUTUHKAN ⬇️
// ----------------------------------------------------
use Filament\Forms\Components\Grid;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Textarea;
use Filament\Forms\Components\FileUpload;
use Filament\Tables\Columns\ImageColumn;
use Filament\Tables\Columns\TextColumn;
use Illuminate\Support\Facades\Auth;

class MenuResource extends Resource
{
    protected static ?string $model = Menu::class;

    protected static ?string $navigationIcon = 'heroicon-o-shopping-bag'; // Icon yang lebih pas
    protected static ?string $navigationGroup = 'Manajemen Menu';

        public static function canViewAny(): bool
    {
        /** @var \App\Models\User|null $user */
        $user = Auth::user(); // Gunakan Facade Auth::user() lebih aman untuk IDE

        // Pastikan user ada DAN role-nya admin
        // return $user !== null && $user->role === ['admin', 'cashier'];
        return $user !== null && in_array($user->role, ['admin', 'cashier']);
    }

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                // Pilihan Kategori (Dropdown)
                Select::make('category_id')
                    ->relationship('category', 'name')
                    ->searchable()
                    ->preload()
                    ->required()
                    ->columnSpanFull(), // Biar 1 baris penuh

                // ⬇️ PERBAIKAN: Gunakan Grid agar rapi ⬇️
                Grid::make(3)->schema([
                    TextInput::make('name')
                        ->required()
                        ->maxLength(255),

                    TextInput::make('price')
                        ->required()
                        ->numeric()
                        ->prefix('Rp'),

                    TextInput::make('stock')
                        ->label('Stok')
                        ->numeric()
                        ->default(0)
                        ->required(),
                ]), // ⬅️ Penutup Grid

                Textarea::make('description')
                    ->columnSpanFull(),

    //             FileUpload::make('image')
    //                 ->image()
    //                 ->directory('menus')
    //                 ->imageEditor()
    //                 ->columnSpanFull(),
    //         ]);
    // }
                FileUpload::make('image')
                        ->image()
                        ->directory('menus')
                        ->imageEditor() // Izinkan edit

                        // ⬇️ KODE OPTIMASI DI SINI ⬇️
                        ->maxSize(1050) // Maksimal 1MB
                        ->imageCropAspectRatio('1:1') // Paksa rasio 1:1 (Kotak)
                        ->imageResizeTargetWidth('500') // Resize jadi 500px lebar
                        ->imageResizeTargetHeight('500') // Resize jadi 500px tinggi
                        ->columnSpanFull(),
                    ]);
                    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                // ⬇️ PERBAIKAN: Susunan kolom yang lebih rapi ⬇️

                ImageColumn::make('image')
                    ->disk('public'), // Pastikan ini ada

                TextColumn::make('name')->searchable(),

                TextColumn::make('category.name') // <-- Pindahkan ke sini
                    ->sortable()
                    ->searchable(),

                TextColumn::make('price')
                    ->money('IDR')
                    ->sortable(),

                TextColumn::make('stock')
                    ->label('Stok')
                    ->sortable(),

                // ⬇️ PERBAIKAN: Hapus kolom duplikat di bawah ini ⬇️
                // TextColumn::make('name')->searchable(), <-- DUPLIKAT
                // TextColumn::make('price')->money('IDR'), <-- DUPLIKAT

                TextColumn::make('created_at')
                    ->dateTime()
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
            ])
            ->filters([
                //
            ])
            ->actions([
                Tables\Actions\EditAction::make(),
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
            //
        ];
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListMenus::route('/'),
            'create' => Pages\CreateMenu::route('/create'),
            'edit' => Pages\EditMenu::route('/{record}/edit'),
        ];
    }
}
