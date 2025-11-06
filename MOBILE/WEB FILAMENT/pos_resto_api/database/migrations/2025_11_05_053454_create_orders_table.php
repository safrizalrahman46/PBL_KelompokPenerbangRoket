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
Schema::create('orders', function (Blueprint $table) {
    $table->id();

    // Relasi: Siapa kasir yang input? (Boleh null)
    $table->foreignId('user_id')->nullable()->constrained('users');

    // Relasi: Pesan di meja mana? (Boleh null)
    $table->foreignId('resto_table_id')->nullable()->constrained('resto_tables');

    $table->string('customer_name')->nullable();
    $table->decimal('total_price', 10, 2)->default(0);

    // POIN INOVASI ANDA
    $table->string('status')->default('pending'); // 'pending', 'preparing', 'ready', 'delivered', 'paid'

    $table->timestamps();
});
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('orders');
    }
};
