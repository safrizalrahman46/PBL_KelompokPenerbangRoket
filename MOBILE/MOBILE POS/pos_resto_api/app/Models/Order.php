<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\HasOne;

class Order extends Model
{
    use HasFactory;

    /**
     * Properti $fillable untuk mencegah MassAssignmentException.
     * Ini adalah kolom-kolom yang BOLEH diisi saat membuat Order baru.
     */
    protected $fillable = [
        'user_id',
        'resto_table_id',
        'customer_name',
        'total_price',
        'status',
    ];

    /**
     * Relasi: Order ini dicatat oleh User (Kasir) mana?
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Relasi: Order ini untuk Meja (RestoTable) mana?
     */
    public function restoTable(): BelongsTo
    {
        return $this->belongsTo(RestoTable::class);
    }

    /**
     * Relasi: Order ini punya item apa saja (OrderItems)?
     */
    public function orderItems(): HasMany
    {
        return $this->hasMany(OrderItem::class);
    }

    /**
     * Relasi: Order ini punya satu Transaksi pembayaran.
     */
    public function transaction(): HasOne
    {
        return $this->hasOne(Transaction::class);
    }
}
