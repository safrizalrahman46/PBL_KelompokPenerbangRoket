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
        // Tambahkan kolom 'stock', default-nya 0
        $table->integer('stock')->default(0)->after('price');
    });
}

public function down(): void
{
    Schema::table('menus', function (Blueprint $table) {
        $table->dropColumn('stock');
    });
}
};
