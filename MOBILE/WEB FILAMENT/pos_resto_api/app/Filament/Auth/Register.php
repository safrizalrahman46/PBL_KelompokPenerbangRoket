<?php

namespace App\Filament\Auth;

use Filament\Forms\Components\Select;
use Filament\Forms\Form;
use Filament\Pages\Auth\Register as AuthRegister;

class Register extends AuthRegister

{
    /**
     * Modifikasi form registrasi bawaan.
     */
    public function form(Form $form): Form
    {
        // Ambil form bawaan (Nama, Email, Password, Konfirmasi Password)
        // lalu tambahkan field baru kita di bawahnya.
        return parent::form($form)
            ->schema([
                ...$form->getComponents(), // Mengambil semua field default

                // --- INI ADALAH TAMBAHAN UNTUK ROLE ---
                Select::make('role')
                    ->label('Daftar sebagai')
                    ->options([
                        'cashier' => 'Kasir',
                        'kitchen' => 'Dapur',
                        'admin' => 'Admin',
                    ])
                    ->required()
                    ->default('cashier'), // Role default saat mendaftar
                // ------------------------------------
            ]);
    }
}
