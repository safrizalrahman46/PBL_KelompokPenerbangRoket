<?php

namespace App\Filament\Resources\TransactionResource\Pages;

use App\Filament\Resources\TransactionResource;
use Filament\Actions;
use Filament\Resources\Pages\ViewRecord; // <-- 1. UBAH INI

class ViewTransaction extends ViewRecord // <-- 2. UBAH INI
{
    protected static string $resource = TransactionResource::class;

    // Kita tidak perlu tombol apa-apa di halaman view
    protected function getHeaderActions(): array
    {
        return [
            // (Biarkan kosong atau tambahkan EditAction jika mau)
            // Actions\EditAction::make(),
        ];
    }
}
