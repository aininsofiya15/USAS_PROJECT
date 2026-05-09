<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\TuitionFeesController;
use App\Http\Controllers\Api\ModuleController;
use App\Http\Controllers\Api\AttendanceController;
use App\Http\Controllers\Api\AttendanceRecordController;
use App\Models\Section;
use Illuminate\Http\Request;
use App\Models\Attendance;
use App\Models\Subject; 
use App\Http\Controllers\Api\RegistrarSubjectController;


// This is the "door" the Flutter app is knocking on
Route::post('/login', [AuthController::class, 'login']);

//--------------------------------------------------------------------------------------------------------------------//
// PUSAT ADAB ROUTES

Route::get('/modules', [ModuleController::class, 'index']);
Route::post('/modules', [ModuleController::class, 'store']);
Route::post('/modules/update-existing', [ModuleController::class, 'update']);
Route::get('/modules/{id}/students', [ModuleController::class, 'getRegisteredStudents']);

// 1. Route to get the list of published modules (Selection Page)
// This matches: Provider.fetchPusatAdabModules()
Route::get('/modules', [AttendanceRecordController::class, 'fetchPusatAdabModules']);

// 2. Route to get students for a specific booking (Attendance List Page)
// This matches: Provider.fetchAttendanceDetails(bookingId)
Route::get('/attendance/details/{bookingId}', [AttendanceRecordController::class, 'getPresentStudents']);

// 3. Route to save student grades (Grade Dialog)
// This matches: Provider.updateStudentGrade()
Route::post('/attendance/update-grade', [AttendanceRecordController::class, 'updateStudentGrade']);
//--------------------------------------------------------------------------------------------------------------------//


// STUDENT ROUTES
//AININ 
Route::post('/modules/apply', [ModuleController::class, 'applyToModule']);
Route::get('/students/{studentId}/bookings', [ModuleController::class, 'getStudentBookings']);
Route::delete('/bookings/{id}', [ModuleController::class, 'destroy']);
Route::put('/bookings/{id}/claim', [ModuleController::class, 'claimModule']);
Route::delete('/bookings/{id}', [ModuleController::class, 'destroy']);

//YAYA 
Route::post('/register-subject', [RegistrarSubjectController::class, 'registerSubject']);
Route::get('/subjects', [RegistrarSubjectController::class, 'getSubjects']); 



//WIDA
//LECTURER ROUTES
Route::get('/lecturer/subjects', [AttendanceController::class, 'getLecturerSubjects']);
Route::get('/sections/{sectionId}/labs', [App\Http\Controllers\Api\AttendanceController::class, 'getSectionLabs']);
Route::post('/attendance/store', [AttendanceController::class, 'store']);
Route::get('/lecturer/{lecturerId}/attendance-history', [AttendanceController::class, 'getAttendanceHistory']);
Route::get('/attendance/{id}', [AttendanceController::class, 'getDetails']);
Route::post('/attendance/update/{id}', [AttendanceController::class, 'updateAttendanceDetails']);
Route::get('/attendance/{id}/students', [AttendanceController::class, 'getStudentAttendance']);



//JIHA (TREASURER + STUDENT)
Route::get('/treasurer/student-count', [TuitionFeesController::class, 'getStudentCount']);
Route::get('/treasurer/dashboard-summary', [TuitionFeesController::class, 'dashboardSummary']);
Route::get('/treasurer/fees-summary', [TuitionFeesController::class, 'getTuitionFeesSummary']);
Route::get('/treasurer/fees-status', [TuitionFeesController::class, 'getStudentsFeeStatus']);
Route::get('/treasurer/student-details/{userId}', [TuitionFeesController::class, 'getStudentDetail']);
Route::get('/treasurer/unpaid-count', [TuitionFeesController::class, 'getUnpaidCount']);
Route::post('/treasurer/save-block-settings', [TuitionFeesController::class, 'saveBlockSettings']);
Route::get('/student/financial-details/{id}', [TuitionFeesController::class, 'getStudentFinancialProfile']);