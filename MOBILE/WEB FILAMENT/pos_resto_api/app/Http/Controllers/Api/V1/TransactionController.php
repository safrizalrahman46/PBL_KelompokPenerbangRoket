<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\Order; // <-- Import Order
use App\Models\Transaction; // <-- Import Transaction
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB; // <-- Import DB

class TransactionController extends Controller
{
    /**
     * POST /api/v1/transactions
     * Membuat transaksi baru (dipanggil Flutter saat Bayar).
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'order_id' => 'required|exists:orders,id',
            'payment_method' => 'required|string|in:cash,qris,debit',
            'amount_paid' => 'required|numeric|min:0',
        ]);

        // Gunakan DB Transaction agar aman
        try {
            DB::beginTransaction();

            // 1. Ambil data Order
            $order = Order::findOrFail($validated['order_id']);

            // (Opsional) Cek apakah jumlah bayar cukup
            if ($validated['amount_paid'] < $order->total_price) {
                 return response()->json(['message' => 'Jumlah bayar kurang'], 422);
            }

            // 2. Buat data transaksi
            $transaction = Transaction::create([
                'order_id' => $order->id,
                'payment_method' => $validated['payment_method'],
                'amount_paid' => $validated['amount_paid'],
            ]);

            // 3. Update status order menjadi 'paid'
            $order->status = 'paid';
            $order->save();

            // 4. Update status meja (jika ada) menjadi 'available'
            if ($order->restoTable) {
                $order->restoTable->status = 'available';
                $order->restoTable->save();
            }

            DB::commit();

            // Kembalikan data transaksi yang baru dibuat
            return response()->json($transaction->load('order'), 201); // 201 = Created

        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json(['message' => 'Gagal memproses transaksi: ' . $e->getMessage()], 500);
        }
    }
}
