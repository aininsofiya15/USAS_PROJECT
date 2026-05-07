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
        Schema::table('bookings', function (Blueprint $table) {
            // 🔥 This safely appends the column without deleting any existing rows!
            $table->tinyInteger('is_claimed')->default(0)->after('total_marks');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('bookings', function (Blueprint $table) {
            // Drops only this column if we roll back
            $table->dropColumn('is_claimed');
        });
    }
};