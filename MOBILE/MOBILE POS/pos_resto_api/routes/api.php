<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

// Import semua Controller Anda
use App\Http\Controllers\Api\V1\OrderController;
use App\Http\Controllers\Api\V1\MenuController;
use App\Http\Controllers\Api\V1\CategoryController;
use App\Http\Controllers\Api\V1\RestoTableController;
use App\Http\Controllers\Api\V1\TransactionController;
use App\Http\Controllers\Api\V1\AuthController;
use App\Http\Controllers\Api\V1\DataController; // (Dari file Anda)

/*
|--------------------------------------------------------------------------
| Rute API v1
|--------------------------------------------------------------------------
|
| Semua rute API untuk aplikasi Flutter Anda harus ada di sini.
| Dikelompokkan berdasarkan prefix 'v1'.
|
*/

Route::prefix('v1')->group(function () {

    // --- Rute PUBLIK (Tidak perlu Login) ---

    // Auth
    Route::post('/login', [AuthController::class, 'login']);
    Route::post('/register', [AuthController::class, 'register']); // Ini untuk API

    // Data Publik (Untuk Cashier & Dapur)
    Route::get('/menu', [MenuController::class, 'index']);
    Route::get('/categories', [CategoryController::class, 'index']);
    Route::get('/tables', [RestoTableController::class, 'index']);
    Route::get('/orders', [OrderController::class, 'index']); // (Untuk Dapur GET pesanan)


    // --- Rute TERLINDUNGI (Perlu Token / Login) ---
    Route::middleware('auth:sanctum')->group(function () {

        // Auth
        Route::post('/logout', [AuthController::class, 'logout']);
        Route::get('/user', [AuthController::class, 'user']);

        // Meja (Cashier)
        Route::patch('/tables/{restoTable}/status', [RestoTableController::class, 'updateStatus']);

        // Pesanan (Order)
        // INI MEMPERBAIKI ERROR ANDA ('Lanjutkan Transaksi') [cite: image_3995b6.png]
        Route::post('/orders', [OrderController::class, 'store']);

        // INI UNTUK KITCHEN SCREEN (Tombol 'Mulai Siapkan' / 'Selesai')
        Route::patch('/orders/{order}/status', [OrderController::class, 'updateStatus']);

        // Transaksi (Cashier - "Bayar Sekarang")
        Route::post('/transactions', [TransactionController::class, 'store']);

        // Rute 'posts' Anda
        Route::apiResource('posts', DataController::class);
    });
});
