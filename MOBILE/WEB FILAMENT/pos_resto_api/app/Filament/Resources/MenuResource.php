<?php

namespace App\Filament\Resources;

use App\Filament\Resources\MenuResource\Pages;
use App\Filament\Resources\MenuResource\RelationManagers;
use App\Models\Menu;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\SoftDeletingScope;
use Filament\Forms\Components\Textarea;
use Filament\Forms\Components\TextInput;
use Filament\Tables\Columns\TextColumn;
use Filament\Forms\Components\FileUpload;
use Filament\Tables\Columns\ImageColumn;

// ⬇️ Import yang Anda Butuhkan ⬇️
use Filament\Forms\Components\Grid;
use Filament\Forms\Components\Select;


class MenuResource extends Resource
{
    protected static ?string $model = Menu::class;

    protected static ?string $navigationIcon = 'heroicon-o-rectangle-stack';

    public static function form(Form $form): Form
    {
       return $form
        ->schema([

            // Pilihan Kategori (Dropdown)
                Select::make('category_id')
                    ->relationship('category', 'name') // 'category' = nama fungsi relasi
                    ->searchable()
                    ->preload()
                    ->required()
                    ->columnSpanFull(), // Biar 1 baris penuh

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

            Textarea::make('description')
                ->columnSpanFull(),



            // TAMBAHKAN INI
            FileUpload::make('image')
                ->image() // Hanya menerima file gambar
                ->directory('menus') // Simpan di folder storage/app/public/menus
                ->imageEditor() // (Opsional) bisa crop/rotate
                ->columnSpanFull(),
        ]);
    }

    public static function table(Table $table): Table
    {
        return $table
          ->columns([
            // TAMBAHKAN INI
            ImageColumn::make('image')
                ->disk('public'), // Beri tahu dia untuk mencari di storage link

            TextColumn::make('name')->searchable(),
            TextColumn::make('price')
                ->money('IDR')
                ->sortable(),

            TextColumn::make('stock')
                ->label('Stok')
                ->sortable(),

            TextColumn::make('name')->searchable(),
            TextColumn::make('price')
                ->money('IDR') // Langsung format Rupiah
                ->sortable(),
            TextColumn::make('created_at')
                ->dateTime()
                ->sortable()
                ->toggleable(isToggledHiddenByDefault: true),

                // Tampilkan Nama Kategori (bukan ID)
                TextColumn::make('category.name')
                    ->sortable()
                    ->searchable(),

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
