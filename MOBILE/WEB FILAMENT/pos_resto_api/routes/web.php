<?php

use Illuminate\Support\Facades\File;
use Illuminate\Support\Facades\Response;
use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return view('welcome');
});




// ✅ Route ini untuk mengizinkan Flutter Web atau frontend lain mengakses file di storage/public
// Bisa akses misalnya: http://localhost:8000/storage/menus/nama_file.jpg
Route::get('/storage/{folder}/{filename}', function ($folder, $filename) {
    $path = storage_path("app/public/{$folder}/{$filename}");

    if (!File::exists($path)) {
        abort(404, 'File not found.');
    }

    $file = File::get($path);
    $type = File::mimeType($path);

    return Response::make($file, 200)
        ->header('Content-Type', $type)
        ->header('Access-Control-Allow-Origin', '*')
        ->header('Access-Control-Allow-Methods', 'GET, OPTIONS')
        ->header('Access-Control-Allow-Headers', 'Origin, Content-Type, Accept, Authorization');
});
