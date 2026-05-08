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
        Schema::create('labs', function (Blueprint $table) {

            $table->id('lab_id');

            $table->unsignedBigInteger('section_id');

            $table->string('lab_name');

            $table->integer('capacity');

            $table->integer('enrolled')->default(0);

            $table->timestamps();

            $table->foreign('section_id')
                  ->references('section_id')
                  ->on('sections')
                  ->onDelete('cascade');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('labs');
    }
};