<?php

namespace App\Filament\Resources\OrderResource\Pages;

use App\Filament\Resources\OrderResource;
use Filament\Actions;
use Filament\Resources\Pages\EditRecord;
use App\Models\Menu;
use App\Models\OrderItem;
use Illuminate\Validation\ValidationException;
use Illuminate\Support\Facades\DB; // <-- Import DB
use Illuminate\Database\Eloquent\Model; // <-- Import Model

class EditOrder extends EditRecord
{
    protected static string $resource = OrderResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\ViewAction::make(),
            Actions\DeleteAction::make(),
        ];
    }

    /**
     * HAPUS 'mutateFormDataBeforeSave' LAMA ANDA
     * GANTI DENGAN 'handleRecordUpdate'
     *
     * Fungsi ini akan:
     * 1. Menjalankan logika STOK (tambah, kurang, kembalikan)
     * 2. Menyimpan TOTAL PRICE dari form (yang sudah dihitung live update)
     */
    protected function handleRecordUpdate(Model $record, array $data): Model
    {
        // $data HANYA berisi data form utama (user_id, total_price, dll)
        // $record adalah data Order LAMA
        // Data Repeater 'orderItems' ada di tempat terpisah:
        $repeaterItems = $this->data['orderItems'];

        return DB::transaction(function () use ($record, $data, $repeaterItems) {

            // Ambil data item LAMA (sebelum diedit)
            $oldItems = $record->orderItems->keyBy('id');
            // Ambil data item BARU (dari form)
            $newItems = collect($repeaterItems)->keyBy('id');

            // 1. KEMBALIKAN STOK (untuk item yang dihapus dari repeater)
            $deletedItemIds = $oldItems->keys()->diff($newItems->keys());
            foreach ($deletedItemIds as $id) {
                $item = $oldItems[$id];
                $menu = Menu::lockForUpdate()->find($item->menu_id);
                if ($menu) {
                    $menu->stock += $item->quantity; // Stok dikembalikan
                    $menu->save();
                }
            }

            // 2. CEK STOK & KURANGI STOK (untuk item yang baru/diedit)
            foreach ($repeaterItems as $itemData) {
                $menu = Menu::lockForUpdate()->find($itemData['menu_id']);

                // Cek selisih kuantitas lama vs baru
                $oldQuantity = $oldItems->get($itemData['id'])?->quantity ?? 0;
                $newQuantity = $itemData['quantity'];
                $stockDifference = $newQuantity - $oldQuantity; // Selisihnya

                // Jika selisihnya positif (menambah barang), cek stok
                if ($stockDifference > 0 && (!$menu || $menu->stock < $stockDifference)) {
                    throw ValidationException::withMessages([
                        'data.orderItems' => "Stok ".($menu->name ?? 'Menu')." tidak cukup (butuh {$stockDifference}). Sisa: ".($menu->stock ?? 0),
                    ]);
                }

                // Update stok jika ada perubahan
                if ($stockDifference != 0 && $menu) {
                    $menu->stock -= $stockDifference; // Kurangi selisihnya
                    $menu->save();
                }
            }

            // 3. UPDATE ORDER UTAMA
            // $data sudah berisi total_price dari form
            $record->update($data);

            // 4. HAPUS & UPDATE ORDER ITEMS
            $record->orderItems()->whereIn('id', $deletedItemIds)->delete();
            foreach ($repeaterItems as $itemData) {
                $record->orderItems()->updateOrCreate(
                    ['id' => $itemData['id'] ?? null], // Cari berdasarkan ID, atau buat baru
                    [
                        'menu_id' => $itemData['menu_id'],
                        'quantity' => $itemData['quantity'],
                        'price_at_time' => $itemData['price_at_time'],
                    ]
                );
            }

            return $record;
        });
    }
}
