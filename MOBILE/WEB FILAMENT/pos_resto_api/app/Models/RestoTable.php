<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;
// use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class RestoTable extends Model
{
    use HasFactory;

    /**
     * Kolom yang boleh diisi secara massal (PENTING!).
     */
    protected $fillable = [
        'name',
        'status',
    ];

    /**
     * Relasi: Satu meja bisa punya banyak pesanan (Orders).
     */
    public function orders(): HasMany
    {
        return $this->hasMany(Order::class);
    }
}
