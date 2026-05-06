<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void {
        Schema::table('modules', function (Blueprint $table) {
            $table->integer('current_registration')->default(0)->after('capacity');
        });
    }

    public function down(): void {
        Schema::table('modules', function (Blueprint $table) {
            if (Schema::hasColumn('modules', 'current_registration')) {
                $table->dropColumn('current_registration');
            }
        });
    }
};
