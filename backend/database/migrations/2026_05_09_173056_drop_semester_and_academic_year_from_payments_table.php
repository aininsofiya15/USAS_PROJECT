<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('payments', function (Blueprint $table) {
            $table->dropColumn(['semester', 'academic_year']);
        });
    }

    public function down(): void
    {
        Schema::table('payments', function (Blueprint $table) {
            $table->string('semester')->nullable()->after('payment_desc');
            $table->string('academic_year')->nullable()->after('semester');
        });
    }
};
