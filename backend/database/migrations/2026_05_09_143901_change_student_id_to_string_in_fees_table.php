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
        Schema::table('fees', function (Blueprint $table) {
            // 1. Drop the old foreign key constraint
            // This is usually named 'tablename_columnname_foreign'
            $table->dropForeign(['student_id']); 
            
            // 2. Change the column type from INT to STRING
            $table->string('student_id')->change();

            // 3. Re-add the foreign key pointing to the STRING student_id in students table
            $table->foreign('student_id')
                ->references('student_id')
                ->on('students')
                ->onUpdate('cascade')
                ->onDelete('cascade');
        });

        Schema::table('students', function (Blueprint $table) {
            $table->string('student_id')->unique()->change();
        });
    }

    public function down(): void
    {
        Schema::table('fees', function (Blueprint $table) {
            $table->dropForeign(['student_id']);
            $table->unsignedBigInteger('student_id')->change();
        });
    }
};
