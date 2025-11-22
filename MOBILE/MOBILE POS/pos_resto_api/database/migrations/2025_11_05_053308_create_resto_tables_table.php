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
Schema::create('resto_tables', function (Blueprint $table) {
    $table->id();
    $table->string('name'); // Contoh: "Meja 1", "VIP Room"
    $table->string('status')->default('available'); // 'available', 'occupied'
    $table->timestamps();
});
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('resto_tables');
    }
};
