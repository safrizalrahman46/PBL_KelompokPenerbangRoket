<?php

namespace App\Filament\Pages\Auth;

use Filament\Forms\Components\TextInput;
use Filament\Forms\Form;
use Filament\Pages\Auth\EditProfile as BaseEditProfile;

class EditProfile extends BaseEditProfile
{
    // Override function form untuk memodifikasi tampilan
    public function form(Form $form): Form
    {
        return $form
            ->schema([
                // 1. Custom Field Nama
                $this->getNameFormComponent()
                    ->label('Nama Lengkap') // Ubah Label
                    ->placeholder('Masukkan nama lengkap Anda')
                    ->required(),

                // 2. Custom Field Email
                $this->getEmailFormComponent()
                    ->label('Alamat Email'),

                // 3. Field Password (Bawaan)
                $this->getPasswordFormComponent()
                    ->label('Password Baru (Opsional)'),
                
                $this->getPasswordConfirmationFormComponent()
                    ->label('Konfirmasi Password Baru'),

                // CONTOH: Jika nanti Anda punya kolom 'no_hp' di database users,
                // Anda bisa menambahkannya di sini:
                // TextInput::make('no_hp')
                //     ->label('Nomor WhatsApp')
                //     ->tel(),
            ]);
    }
}