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
        // Menambah kolom 'image' (bisa null) setelah kolom 'description'
        $table->string('image')->nullable()->after('description');
    });
}

public function down(): void
{
    Schema::table('menus', function (Blueprint $table) {
        // Perintah untuk rollback (menghapus kolom)
        $table->dropColumn('image');
    });
}
};
