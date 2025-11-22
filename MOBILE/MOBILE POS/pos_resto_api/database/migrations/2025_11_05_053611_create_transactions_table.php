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
Schema::create('transactions', function (Blueprint $table) {
    $table->id();

    // Relasi: Pembayaran ini untuk order yang mana
    $table->foreignId('order_id')->constrained('orders');

    $table->string('payment_method'); // 'Cash', 'QRIS', 'Debit'
    $table->decimal('amount_paid', 10, 2);

    $table->timestamps();
});
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('transactions');
    }
};
