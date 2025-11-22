<?php

use Illuminate\Support\Facades\File;
use Illuminate\Support\Facades\Response;
use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    // return view('landing');
    return view('landing', [
        'title' => 'Eat.o | Solusi POS Restoran Modern' // Tambahkan variabel ini
    ]);
});


// ✅ Route ini untuk mengizinkan Flutter Web atau frontend lain mengakses file di storage/public
// Route ini sudah dilengkapi dengan CORS headers yang lengkap.
Route::get('/storage/{folder}/{filename}', function ($folder, $filename) {
    // Tentukan path ke file di storage/app/public/
    $path = storage_path("app/public/{$folder}/{$filename}");

    if (!File::exists($path)) {
        abort(404, 'File not found.');
    }

    $file = File::get($path);
    $type = File::mimeType($path);

    // Klien (Browser/Flutter Web) terkadang mengirimkan OPTIONS request (preflight).
    // Tangani preflight OPTIONS request.
    if (request()->isMethod('OPTIONS')) {
        return response()->make(null, 200)
            ->header('Access-Control-Allow-Origin', '*')
            ->header('Access-Control-Allow-Methods', 'GET, OPTIONS')
            ->header('Access-Control-Allow-Headers', 'Content-Type, X-Auth-Token, Origin, Authorization')
            ->header('Access-Control-Max-Age', '86400'); // Cache preflight selama 24 jam
    }

    return Response::make($file, 200)
        ->header('Content-Type', $type)
        // ⬇️ PERBAIKAN DAN PENAMBAHAN HEADER CORS ⬇️
        ->header('Access-Control-Allow-Origin', '*') // Mengizinkan akses dari semua domain
        ->header('Access-Control-Allow-Methods', 'GET, OPTIONS') // Mengizinkan metode GET dan OPTIONS
        ->header('Access-Control-Allow-Headers', 'Content-Type, Authorization, X-Requested-With'); // Headers yang diizinkan
});