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
        Schema::table('subjects', function (Blueprint $table) {

            $table->unsignedBigInteger('faculty_registrar_id')
                  ->nullable()
                  ->after('subject_status');

            $table->foreign('faculty_registrar_id')
                  ->references('registrar_id')
                  ->on('faculty_registrar')
                  ->onDelete('cascade');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('subjects', function (Blueprint $table) {

            $table->dropForeign(['faculty_registrar_id']);
            $table->dropColumn('faculty_registrar_id');
        });
    }
};