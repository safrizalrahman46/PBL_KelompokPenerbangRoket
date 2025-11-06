<?php

namespace App\Filament\Resources;

use App\Filament\Resources\RestoTableResource\Pages;
use App\Filament\Resources\RestoTableResource\RelationManagers;
use App\Models\RestoTable;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\SoftDeletingScope;

// IMPORT YANG DIBUTUHKAN
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Select;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Columns\SelectColumn;

class RestoTableResource extends Resource
{
    protected static ?string $model = RestoTable::class;

    protected static ?string $navigationIcon = 'heroicon-o-rectangle-stack';
    protected static ?string $navigationGroup = 'Manajemen Restoran'; // Grup di sidebar
    protected static ?string $modelLabel = 'Meja'; // Nama di sidebar

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                TextInput::make('name')
                    ->label('Nama Meja')
                    ->required()
                    ->maxLength(255),
                Select::make('status')
                    ->options([
                        'available' => 'Tersedia',
                        'occupied' => 'Terisi',
                    ])
                    ->required()
                    ->default('available'),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                TextColumn::make('name')
                    ->label('Nama Meja')
                    ->searchable(),

                // Kolom ini bisa ganti status langsung dari tabel (SANGAT BERGUNA)
                SelectColumn::make('status')
                    ->options([
                        'available' => 'Tersedia',
                        'occupied' => 'Terisi',
                    ])
                    ->sortable(),

                TextColumn::make('created_at')
                    ->dateTime('d-M-Y')
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
            'index' => Pages\ListRestoTables::route('/'),
            'create' => Pages\CreateRestoTable::route('/create'),
            'edit' => Pages\EditRestoTable::route('/{record}/edit'),
        ];
    }
}
