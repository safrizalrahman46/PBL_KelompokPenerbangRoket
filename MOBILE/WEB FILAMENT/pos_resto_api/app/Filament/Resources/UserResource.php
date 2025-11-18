<?php

namespace App\Filament\Resources;

use App\Filament\Resources\UserResource\Pages;
use App\Models\User;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;

// 1. IMPORT SEMUA YANG KITA BUTUHKAN
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Columns\BadgeColumn; // Untuk 'role'
use Illuminate\Support\Facades\Hash; // Untuk enkripsi password
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\Auth;

class UserResource extends Resource
{
    protected static ?string $model = User::class;

    protected static ?string $icon = 'heroicon-o-users';
    protected static ?string $navigationGroup = 'Manajemen Restoran';

    
   // ⬇️ TAMBAHKAN FUNGSI INI ⬇️
     public static function canViewAny(): bool
    {
        /** @var \App\Models\User|null $user */
        $user = Auth::user(); // Gunakan Facade Auth::user() lebih aman untuk IDE

        // Pastikan user ada DAN role-nya admin
        return $user !== null && $user->role === 'admin';
    }

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                TextInput::make('name')
                    ->required()
                    ->maxLength(255),
                TextInput::make('email')
                    ->email()
                    ->required()
                    ->maxLength(255)
                    // Pastikan email unik (tidak ada yg sama)
                    ->unique(ignoreRecord: true),

                // 2. INI ADALAH FORM UNTUK 3 ROLE ANDA
                Select::make('role')
                    ->options([
                        'admin' => 'Admin',
                        'cashier' => 'Kasir',
                        'kitchen' => 'Dapur',
                    ])
                    ->required()
                    ->default('cashier'), // Defaultnya 'kasir'

                // 3. FORM PASSWORD DENGAN ENKRIPSI
                TextInput::make('password')
                    ->password() // Tipe password (***)
                    ->required(fn (string $context): bool => $context === 'create') // Wajib diisi HANYA saat buat baru
                    ->maxLength(255)
                    // Enkripsi otomatis saat disimpan
                    ->dehydrateStateUsing(fn ($state) => Hash::make($state))
                    // Jangan tampilkan password saat edit
                    ->dehydrated(fn ($state) => filled($state)),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                TextColumn::make('name')->searchable(),
                TextColumn::make('email')->searchable(),

                // 4. TAMPILKAN ROLE DENGAN BADGE (BIAR KEREN)
                BadgeColumn::make('role')
                    ->colors([
                        'danger' => 'admin',
                        'primary' => 'cashier',
                        'info' => 'kitchen',
                    ])
                    ->sortable(),

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
            'index' => Pages\ListUsers::route('/'),
            'create' => Pages\CreateUser::route('/create'), // Halaman "Registrasi"
            'edit' => Pages\EditUser::route('/{record}/edit'),
        ];
    }
}
