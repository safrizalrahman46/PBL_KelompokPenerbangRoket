<?php

namespace App\Filament\Resources\OrderResource\Pages;

use App\Filament\Resources\OrderResource;
use Filament\Actions;
use Filament\Resources\Pages\CreateRecord;
use App\Models\Menu;
use Illuminate\Validation\ValidationException;
use Illuminate\Support\Facades\DB; // <-- 1. Import DB
use Illuminate\Database\Eloquent\Model; // <-- 2. Import Model

class CreateOrder extends CreateRecord
{
    protected static string $resource = OrderResource::class;

    /**
     * HAPUS 'mutateFormDataBeforeCreate' LAMA ANDA
     * GANTI DENGAN 'handleRecordCreation'
     *
     * Fungsi ini akan:
     * 1. Menjalankan logika STOK
     * 2. Menyimpan TOTAL PRICE dari form (yang sudah dihitung live update)
     */
    protected function handleRecordCreation(array $data): Model
    {
        // $data di sini HANYA berisi data form utama
        // ['user_id' => 1, 'total_price' => 36000, ...]

        // Data Repeater 'orderItems' ada di tempat terpisah:
        $repeaterItems = $this->data['orderItems'];

        // Kita mulai "Transaksi Database" agar aman
        return DB::transaction(function () use ($data, $repeaterItems) {

            // 1. CEK STOK & KURANGI STOK
            foreach ($repeaterItems as $item) {
                $menu = Menu::lockForUpdate()->find($item['menu_id']);

                // CEK
                if (!$menu || $menu->stock < $item['quantity']) {
                    // JIKA GAGAL, kirim error ke form
                    throw ValidationException::withMessages([
                        'data.orderItems' => "Stok untuk ".($menu->name ?? 'Menu')." tidak cukup! Sisa: ".($menu->stock ?? 0),
                    ]);
                }

                // KURANGI
                $menu->stock -= $item['quantity'];
                $menu->save();
            }

            // 2. BUAT ORDER UTAMA
            // $data sudah berisi total_price, user_id, dll dari form
            $order = static::getModel()::create($data);

            // 3. BUAT ORDER ITEMS
            foreach ($repeaterItems as $item) {
                $order->orderItems()->create([
                    'menu_id' => $item['menu_id'],
                    'quantity' => $item['quantity'],
                    'price_at_time' => $item['price_at_time'],
                ]);
            }

            // 4. Kembalikan order yang sudah dibuat
            return $order;
        });
    }
}
