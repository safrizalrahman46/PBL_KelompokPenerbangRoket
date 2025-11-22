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
        Schema::table('menus', function (Blueprint $table) {
            // TAMBAHKAN INI:
            $table->foreignId('category_id')
                  ->nullable()
                  ->constrained('categories')
                  ->after('id'); // (Opsional) Biar rapi di database
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('menus', function (Blueprint $table) {
            // INI UNTUK ROLLBACK
            $table->dropForeign(['category_id']); // 1. Hapus kunci
            $table->dropColumn('category_id');   // 2. Hapus kolom
        });
    }
};
