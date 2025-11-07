<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\V1\MenuController;

use App\Http\Controllers\Api\V1\CategoryController;

use App\Http\Controllers\Api\V1\RestoTableController;

use App\Http\Controllers\Api\V1\OrderController;

use App\Http\Controllers\Api\V1\TransactionController;

use App\Http\Controllers\Api\V1\AuthController; // Kita akan buat ini nanti
use App\Http\Controllers\Api\V1\DataController; // Kita akan buat ini nanti

// Route::get('/user', function (Request $request) {
//     return $request->user();
// })->middleware('auth:sanctum');


// DAFTARKAN API MENU ANDA DI SINI
Route::get('/v1/menu', [MenuController::class, 'index']);
Route::get('/v1/tables', [RestoTableController::class, 'index']);
Route::get('/v1/orders', [OrderController::class, 'index']);
Route::get('/v1/categories', [CategoryController::class, 'index']);

// Endpoint untuk update status meja (Perlu login)
Route::middleware('auth:sanctum')->group(function () {
    // ... (Rute Anda yang lain seperti POST order, logout)
    Route::patch('/v1/tables/{restoTable}/status', [RestoTableController::class, 'updateStatus']);
});
Route::middleware('auth:sanctum')->group(function () {
    // ... (Rute Anda yang lain seperti POST order, logout, PATCH status)

    // Endpoint untuk Flutter "Bayar"
    Route::post('/v1/transactions', [TransactionController::class, 'store']);
});

Route::prefix('v1')->group(function () {

    // --- Rute Otentikasi (API Public) ---
    Route::post('/login', [AuthController::class, 'login']);
    Route::post('/register', [AuthController::class, 'register']);

    // --- Rute Terlindungi (Membutuhkan Token Otentikasi) ---
    Route::middleware('auth:sanctum')->group(function () {
        // Otentikasi
        Route::post('/logout', [AuthController::class, 'logout']);
        Route::get('/user', [AuthController::class, 'user']); // API: /v1/user

        // Rute Meja
        Route::patch('/tables/{restoTable}/status', [RestoTableController::class, 'updateStatus']);

        // Rute Transaksi (Pembayaran)
        Route::post('/transactions', [TransactionController::class, 'store']); // API: /v1/transactions

        // Contoh rute untuk mengambil data
        Route::apiResource('posts', DataController::class);
    });
});

Route::middleware('auth:sanctum')->get('/v1/user', function (Request $request) {
    return $request->user();
});
