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
    Schema::create('menus', function (Blueprint $table) {
        $table->id();

        // INI YANG DITAMBAHKAN
    $table->foreignId('category_id') // 1. Buat kolomnya
          ->nullable()               // 2. Boleh kosong (opsional)
          ->constrained('categories'); // 3. Sambungkan ke tabel 'categories'

        $table->string('name');
        $table->decimal('price', 10, 2);
        $table->text('description')->nullable();
        $table->timestamps();
    });
}

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('menus');
    }
};
