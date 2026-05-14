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
            // 1. Change payment_id to String. 
            // Note: You may need to drop the primary key first if it's an auto-increment int.
            $table->string('payment_id', 50)->change();
            
            // 2. Add the Description field
            $table->text('payment_desc')->nullable()->after('amount');
        });
    }
    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('payments', function (Blueprint $table) {
            //
        });
    }
};
