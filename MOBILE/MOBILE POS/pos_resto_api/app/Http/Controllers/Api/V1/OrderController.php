<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\Menu;
use App\Models\Order;
use App\Models\OrderItem;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB; // <-- Pastikan ini ada
use Illuminate\Validation\Rule;

class OrderController extends Controller
{
    /**
     * GET /api/v1/orders
     * Mengambil daftar pesanan (untuk antrian dapur/waiter).
     * Bisa difilter ?status=pending
     */
    public function index(Request $request)
    {
        // Selalu ambil dengan relasinya agar datanya lengkap
        $query = Order::with(['orderItems.menu', 'restoTable', 'user']);

        // Filter berdasarkan status (SANGAT PENTING untuk antrian)
        if ($request->has('status')) {
            $query->where('status', $request->status);
        }

        // Filter untuk status "aktif" (bukan paid/cancelled)
        if ($request->get('active') === 'true') {
             $query->whereNotIn('status', ['paid', 'cancelled']);
        }

        $orders = $query->orderBy('created_at', 'asc')->get();
        return response()->json($orders);
    }

    /**
     * POST /api/v1/orders
     * Menyimpan pesanan baru dari Flutter (Kasir).
     * Ini adalah versi LENGKAP dengan cek stok.
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'resto_table_id' => 'nullable|exists:resto_tables,id',
            'customer_name' => 'nullable|string|max:255',

            'items' => 'required|array|min:1',
            'items.*.menu_id' => 'required|exists:menus,id',
            'items.*.quantity' => 'required|integer|min:1',
        ]);

        $totalPrice = 0;
        $menuItemsData = []; // Untuk menyimpan data item

        // Gunakan DB::transaction agar aman
        // Jika stok gagal, seluruh pesanan (termasuk pengurangan stok) akan dibatalkan.
        try {
            DB::beginTransaction();

            // 1. Validasi, Hitung total, Cek Stok, dan Kurangi Stok
            foreach ($validated['items'] as $item) {

                // 'lockForUpdate()' PENTING agar stok tidak bentrok jika ada 2 pesanan bersamaan
                $menu = Menu::lockForUpdate()->find($item['menu_id']);

                if (!$menu) {
                    throw new \Exception("Menu dengan ID {$item['menu_id']} tidak ditemukan.");
                }

                // ⬇️ LOGIKA CEK STOK ⬇️
                if ($menu->stock < $item['quantity']) {
                    // Jika stok tidak cukup, batalkan pesanan
                    throw new \Exception("Stok untuk {$menu->name} tidak cukup. Sisa: {$menu->stock}");
                }

                // Hitung harga
                $itemPrice = $menu->price * $item['quantity'];
                $totalPrice += $itemPrice;

                // ⬇️ LOGIKA KURANGI STOK ⬇️
                $menu->stock -= $item['quantity']; // Kurangi stok
                $menu->save(); // Simpan stok baru

                // Simpan data untuk langkah 3
                $menuItemsData[] = [
                    'menu_id' => $menu->id,
                    'quantity' => $item['quantity'],
                    'price_at_time' => $menu->price, // 'Lock' harga saat itu
                ];
            }

            // 2. Buat Order (bon utama)
            $order = Order::create([
                'user_id' => $request->user()->id, // <-- Cara aman dapat user login
                'resto_table_id' => $validated['resto_table_id'] ?? null,
                'customer_name' => $validated['customer_name'] ?? null,
                'total_price' => $totalPrice,
                'status' => 'pending', // Status awal
            ]);

            // 3. Buat OrderItems (detail item)
            // 'createMany' lebih efisien daripada loop
            $order->orderItems()->createMany($menuItemsData);

            // 4. Jika semua berhasil
            DB::commit();

            // Kembalikan data order lengkap
            return response()->json($order->load(['orderItems.menu', 'restoTable', 'user']), 201); // 201 = Created

        } catch (\Exception $e) {
            // 5. Jika ada error (termasuk error stok)
            DB::rollBack();
            // Kirim pesan error-nya ke Flutter
            return response()->json(['message' => 'Gagal membuat pesanan: ' . $e->getMessage()], 422); // 422 = Unprocessable
        }
    }

    /**
     * PATCH /api/v1/orders/{order}/status
     * Meng-update status pesanan (Inovasi Anda).
     */
    public function updateStatus(Request $request, Order $order)
    {
        $validated = $request->validate([
            'status' => [
                'required', 'string',
                Rule::in(['pending', 'preparing', 'ready', 'delivered', 'paid', 'cancelled', 'completed', 'done']),
            ],
        ]);

        $order->update($validated); // Ini bisa karena 'status' ada di $fillable

        return response()->json($order);
    }
}
