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
        Schema::create('notifications', function (Blueprint $table) {
            // 1. Explicitly name your primary key 'notification_id'
            $table->bigIncrements('notification_id'); 
            
            // 2. Your user foreign key column named 'id'
            $table->unsignedBigInteger('id'); 
            
            $table->string('title');
            $table->text('message');
            $table->boolean('is_read')->default(false);
            $table->string('type');
            $table->string('reference_id')->nullable();
            $table->timestamps();

            // Setup the foreign key constraint pointing to users table
            $table->foreign('id')->references('id')->on('users')->onDelete('cascade');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('notifications');
    }
};