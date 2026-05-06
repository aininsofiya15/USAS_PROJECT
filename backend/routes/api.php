<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\TreasurerController;
use App\Http\Controllers\Api\ModuleController;
use App\Http\Controllers\Api\AttendanceController;
use App\Models\Section;
use Illuminate\Http\Request;
use App\Models\Attendance;
use App\Models\Subject; 


// This is the "door" the Flutter app is knocking on
Route::post('/login', [AuthController::class, 'login']);

//LECTURER ROUTES
Route::get('/lecturer/subjects', [AttendanceController::class, 'getLecturerSubjects']);

// PUSAT ADAB ROUTES

Route::get('/modules', [ModuleController::class, 'index']);
Route::post('/modules', [ModuleController::class, 'store']);
Route::post('/modules/update-existing', [ModuleController::class, 'update']);

// STUDENT ROUTES
//AININ 
Route::post('/modules/apply', [ModuleController::class, 'applyModule']);
Route::get('/students/{studentId}/bookings', [ModuleController::class, 'getStudentBookings']);
Route::delete('/bookings/{id}', [ModuleController::class, 'destroy']);
Route::put('/bookings/{id}/claim', [ModuleController::class, 'claimModule']);


//YAYA


//WIDA


//JIHA


//TREASURER ROUTES
Route::get('/treasurer/student-count', [TreasurerController::class, 'getStudentCount']);
Route::get('/treasurer/dashboard-summary', [TreasurerController::class, 'dashboardSummary']);
