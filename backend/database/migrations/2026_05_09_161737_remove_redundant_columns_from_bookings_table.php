<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('bookings', function (Blueprint $table) {
            // Dropping the columns we decided to move/remove
            $table->dropColumn(['attendance', 'total_marks']); 
        });
    }

    public function down(): void
    {
        Schema::table('bookings', function (Blueprint $table) {
            // This allows you to rollback if you change your mind
            $table->string('attendance')->default('-');
            $table->string('total_marks')->default('-');
        });
    }
};