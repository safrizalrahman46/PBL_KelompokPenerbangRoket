<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;
// use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\Storage;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Menu extends Model
{
    use HasFactory;

    // TAMBAHKAN INI
    protected $fillable = [
        'name',
        'price',
        'stock', // safrizal ini yang menambahkan
        'description',
        'image',
        'category_id',
    ];

    protected $appends = ['image_url'];

    public function category(): BelongsTo
    {
        return $this->belongsTo(Category::class);
    }

    /**
     * Membuat atribut 'image_url' secara otomatis.
     */
    public function getImageUrlAttribute(): ?string
    {
        // Jika kolom 'image' tidak kosong (ada file)
        if ($this->image) {
            // Kembalikan URL lengkap dari file di public disk
            return Storage::disk('public')->url($this->image);
        }

        // Jika tidak ada gambar, kembalikan null
        return null;
    }
}
