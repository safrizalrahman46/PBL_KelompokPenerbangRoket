<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Transaction extends Model
{
    use HasFactory;

    /**
     * Kolom yang boleh diisi oleh API (PENTING!).
     */
    protected $fillable = [
        'order_id',
        'payment_method',
        'amount_paid',
    ];

    /**
     * Relasi: Transaksi ini milik Order (Bon) mana?
     */
    public function order(): BelongsTo
    {
        return $this->belongsTo(Order::class);
    }
}
