<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('attendance_records', function (Blueprint $table) {
            // 1. If it's a foreign key, drop the constraint first
            // Usually follows the pattern: table_column_foreign
            $table->dropForeign(['module_id']); 

            // 2. Now drop the column
            $table->dropColumn('module_id');
        });
    }

    public function down(): void
    {
        Schema::table('attendance_records', function (Blueprint $table) {
            // This allows you to 'rollback' the migration if needed
            $table->unsignedBigInteger('module_id')->nullable();
            
            // Re-add the foreign key if necessary
            // $table->foreign('module_id')->references('id')->on('modules');
        });
    }
};