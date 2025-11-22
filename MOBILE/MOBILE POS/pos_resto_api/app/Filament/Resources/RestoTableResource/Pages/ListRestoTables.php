<?php

namespace App\Filament\Resources\RestoTableResource\Pages;

use App\Filament\Resources\RestoTableResource;
use Filament\Actions;
use Filament\Resources\Pages\ListRecords;

class ListRestoTables extends ListRecords
{
    protected static string $resource = RestoTableResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\CreateAction::make(),
        ];
    }
}
