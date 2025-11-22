<?php

namespace App\Filament\Resources\RestoTableResource\Pages;

use App\Filament\Resources\RestoTableResource;
use Filament\Actions;
use Filament\Resources\Pages\EditRecord;

class EditRestoTable extends EditRecord
{
    protected static string $resource = RestoTableResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\DeleteAction::make(),
        ];
    }
}
