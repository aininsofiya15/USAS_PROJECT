<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\TreasurerController;

// This is the "door" the Flutter app is knocking on
Route::post('/login', [AuthController::class, 'login']);

Route::get('/treasury/student-count', [TreasurerController::class, 'getStudentCount']);