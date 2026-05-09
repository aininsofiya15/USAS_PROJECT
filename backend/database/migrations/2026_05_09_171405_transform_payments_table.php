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
        Schema::table('payments', function (Blueprint $table) {
            // Only try to add it if it doesn't exist yet
            if (!Schema::hasColumn('payments', 'payment_desc')) {
                $table->text('payment_desc')->nullable()->after('amount');
            }
        });

        // Handle the ID change separately
        // We use a try-catch or check to ensure we don't fail if already changed
        try {
            DB::statement('ALTER TABLE payments MODIFY payment_id VARCHAR(50) NOT NULL');
        } catch (\Exception $e) {
            // Log or ignore if already a VARCHAR
        }
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        //
    }
};
