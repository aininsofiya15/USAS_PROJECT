<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;

// This is the "door" the Flutter app is knocking on
Route::post('/login', [AuthController::class, 'login']);
