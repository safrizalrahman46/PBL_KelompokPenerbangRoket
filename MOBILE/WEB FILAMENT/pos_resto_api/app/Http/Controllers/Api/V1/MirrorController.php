<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Cache;

class MirrorController extends Controller
{
    /**
     * update
     * Menerima data dari aplikasi Kasir (CartProvider) dan menyimpannya ke Cache.
     */
    public function update(Request $request)
    {
        // Validasi sederhana (opsional, tapi disarankan)
        // $request->validate([
        //     'cart_items' => 'array',
        //     'total' => 'numeric',
        // ]);

        // Simpan data ke Cache selama 60 menit (3600 detik)
        // 'active_pos_mirror' adalah kuncinya. Jika punya banyak cabang, tambahkan ID toko.
        Cache::put('active_pos_mirror', $request->all(), 3600);

        return response()->json([
            'status' => 'success',
            'message' => 'Data mirror berhasil diupdate'
        ]);
    }

    /**
     * index
     * Dipanggil oleh Layar Mirror (MirrorOrderLogic) untuk mengambil data terbaru.
     */
    public function index()
    {
        // Ambil data dari Cache.
        // Parameter kedua adalah nilai default jika cache kosong.
        $data = Cache::get('active_pos_mirror', [
            'cart_items' => [],
            'subtotal' => 0,
            'total' => 0,
            'payment_method' => '-',
            'customer_name' => '',
            'status' => 'idle'
        ]);

        return response()->json($data);
    }
}