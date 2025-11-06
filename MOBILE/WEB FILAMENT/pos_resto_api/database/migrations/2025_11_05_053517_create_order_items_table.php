<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
    // di dalam public function up(): void
Schema::create('order_items', function (Blueprint $table) {
    $table->id();

    // Relasi: Terhubung ke bon/order yang mana
    $table->foreignId('order_id')->constrained('orders')->onDelete('cascade');

    // Relasi: Item menu apa yang dipesan
    $table->foreignId('menu_id')->constrained('menus');

    $table->integer('quantity');
    $table->decimal('price_at_time', 10, 2); // 'Lock' harga saat pesan

    $table->timestamps();
});
}


    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('order_items');
    }
};
