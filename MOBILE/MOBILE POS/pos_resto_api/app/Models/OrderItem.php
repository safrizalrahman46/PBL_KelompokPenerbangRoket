<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class OrderItem extends Model
{
    use HasFactory;

    /**
     * ProPERTIES $fillable untuk OrderItem.
     */
    protected $fillable = [
        'order_id',
        'menu_id',
        'quantity',
        'price_at_time',
    ];

    /**
     * Relasi: Item ini milik Order (Bon) mana?
     */
    public function order(): BelongsTo
    {
        return $this->belongsTo(Order::class);
    }

    /**
     * Relasi: Item ini merujuk ke Menu apa?
     */
    public function menu(): BelongsTo
    {
        return $this->belongsTo(Menu::class);
    }
}
