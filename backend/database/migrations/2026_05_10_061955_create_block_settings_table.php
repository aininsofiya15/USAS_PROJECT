<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create('block_settings', function (Blueprint $table) {
            $table->id('block_id'); // Primary Key
            
            // Set as string to match your TR-001 format
            $table->string('treasurer_id', 255); 
            
            $table->date('block_date');
            $table->timestamps();

            // Add Foreign Key constraint to link back to the treasurers table
            // This ensures only valid treasurers can set block dates
            $table->foreign('treasurer_id')
                  ->references('treasurer_id')
                  ->on('treasurers')
                  ->onDelete('cascade');
        });
    }

    public function down()
    {
        Schema::dropIfExists('block_settings');
    }
};