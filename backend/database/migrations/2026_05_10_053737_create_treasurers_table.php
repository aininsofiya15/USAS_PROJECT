<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create('treasurers', function (Blueprint $table) {
            $table->unsignedBigInteger('id')->primary(); 
            $table->string('treasurer_id')->unique(); // Your TR-001 format
            $table->string('department'); 
            $table->timestamps();

            $table->foreign('id')->references('id')->on('users')->onDelete('cascade');
        });
    }

    public function down()
    {
        Schema::dropIfExists('treasurers');
    }
};
