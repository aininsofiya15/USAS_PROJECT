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

//TREASURER ROUTES
Route::get('/treasurer/student-count', [TreasurerController::class, 'getStudentCount']);
Route::get('/treasurer/dashboard-summary', [TreasurerController::class, 'dashboardSummary']);