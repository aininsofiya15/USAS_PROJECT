<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\TuitionFeesController;
use App\Http\Controllers\Api\ModuleController;
use App\Http\Controllers\Api\AttendanceController;
use App\Models\Section;
use Illuminate\Http\Request;
use App\Models\Attendance;
use App\Models\Subject; 


// This is the "door" the Flutter app is knocking on
Route::post('/login', [AuthController::class, 'login']);

// PUSAT ADAB ROUTES

Route::get('/modules', [ModuleController::class, 'index']);
Route::post('/modules', [ModuleController::class, 'store']);
Route::post('/modules/update-existing', [ModuleController::class, 'update']);
Route::get('/modules/{id}/students', [ModuleController::class, 'getRegisteredStudents']);

// STUDENT ROUTES
//AININ 
Route::post('/modules/apply', [ModuleController::class, 'applyToModule']);
Route::get('/students/{studentId}/bookings', [ModuleController::class, 'getStudentBookings']);
Route::delete('/bookings/{id}', [ModuleController::class, 'destroy']);
Route::put('/bookings/{id}/claim', [ModuleController::class, 'claimModule']);
Route::delete('/bookings/{id}', [ModuleController::class, 'destroy']);

//YAYA


//WIDA
//LECTURER ROUTES
Route::get('/lecturer/subjects', [AttendanceController::class, 'getLecturerSubjects']);
Route::post('/attendance/store', [AttendanceController::class, 'store']);



//JIHA (TREASURER + STUDENT)
Route::get('/treasurer/student-count', [TuitionFeesController::class, 'getStudentCount']);
Route::get('/treasurer/dashboard-summary', [TuitionFeesController::class, 'dashboardSummary']);
Route::get('/treasurer/fees-summary', [TuitionFeesController::class, 'getTuitionFeesSummary']);
Route::get('/treasurer/fees-status', [TuitionFeesController::class, 'getStudentsFeeStatus']);
Route::get('/treasurer/student-details/{userId}', [TuitionFeesController::class, 'getStudentDetail']);
Route::get('/treasurer/unpaid-count', [TuitionFeesController::class, 'getUnpaidCount']);
Route::post('/treasurer/save-block-settings', [TuitionFeesController::class, 'saveBlockSettings']);
