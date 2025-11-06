<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\V1\MenuController;

use App\Http\Controllers\Api\V1\CategoryController;

use App\Http\Controllers\Api\V1\RestoTableController;

use App\Http\Controllers\Api\V1\OrderController;

use App\Http\Controllers\Api\V1\TransactionController;

Route::get('/user', function (Request $request) {
    return $request->user();
})->middleware('auth:sanctum');


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
