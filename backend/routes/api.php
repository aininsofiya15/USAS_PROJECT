<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\TuitionFeesController;
use App\Http\Controllers\Api\ModuleController;
use App\Http\Controllers\Api\BookingController;
use App\Http\Controllers\Api\AttendanceController;
use App\Http\Controllers\Api\AttendanceRecordController;
use App\Models\Section;
use Illuminate\Http\Request;
use App\Models\Attendance;
use App\Models\Subject; 
use App\Http\Controllers\Api\RegistrarSubjectController;
use App\Http\Controllers\Api\StudentSubjectController;

// This is the "door" the Flutter app is knocking on
Route::post('/login', [AuthController::class, 'login']);

//--------------------------------------------------------------------------------------------------------------------//
//AININ 
// -------- Pusat Adab Routes ---------------------------------------

Route::get('/modules', [ModuleController::class, 'index']);
Route::post('/modules', [ModuleController::class, 'store']);
Route::post('/modules/update-existing', [ModuleController::class, 'update']);
Route::get('/modules/{id}/students', [BookingController::class, 'getRegisteredStudents']);

// 1. Route to get the list of published modules (Selection Page)
// This matches: Provider.fetchPusatAdabModules()
Route::get('/modules', [AttendanceController::class, 'fetchPusatAdabModules']);

// 2. Route to get students for a specific booking (Attendance List Page)
// This matches: Provider.fetchAttendanceDetails(bookingId)
Route::get('/attendance/details/{bookingId}', [AttendanceRecordController::class, 'getPresentStudents']);

// 3. Route to save student grades (Grade Dialog)
// This matches: Provider.updateStudentGrade()
Route::post('/attendance/update-grade', [AttendanceRecordController::class, 'updateStudentGrade']);
//--------------------------------------------------------------------------------------------------------------------//


// STUDENT ROUTES
//AININ 
Route::post('/modules/apply', [BookingController::class, 'applyToModule']);
Route::get('/students/{studentId}/bookings', [BookingController::class, 'getStudentBookings']);
Route::delete('/bookings/{id}', [BookingController::class, 'destroy']);
Route::put('/bookings/{id}/claim', [BookingController::class, 'claimModule']);


//-----------------------------------------------------------------------------


//YAYA 
Route::post('/register-subject', [RegistrarSubjectController::class, 'registerSubject']);
Route::get('/subjects', [RegistrarSubjectController::class, 'getSubjects']); 
Route::get('/lecturers', [RegistrarSubjectController::class, 'getLecturers']);
Route::get('/subject-details/{id}', [RegistrarSubjectController::class, 'getSubjectDetails']);
Route::get('/student/subjects',[StudentSubjectController::class, 'getSubjects']);
Route::get('/student/registered-subjects/{student_id}',[StudentSubjectController::class,'getRegisteredSubjects']);
Route::post('/student/register-subject',[StudentSubjectController::class,'registerSubject']);
Route::put('/student/drop-subject/{registration_id}',[StudentSubjectController::class,'dropSubject']);
//-----------------------------------------------------------------------------


//WIDA
//LECTURER ROUTES
Route::get('/lecturer/subjects', [AttendanceController::class, 'getLecturerSubjects']);
Route::get('/sections/{sectionId}/labs', [App\Http\Controllers\Api\AttendanceController::class, 'getSectionLabs']);
Route::post('/attendance/store', [AttendanceController::class, 'store']);
Route::get('/lecturer/{lecturerId}/attendance-history', [AttendanceController::class, 'getAttendanceHistory']);
Route::get('/attendance/{id}', [AttendanceController::class, 'getDetails']);
Route::post('/attendance/update/{id}', [AttendanceController::class, 'updateAttendanceDetails']);
Route::get('/attendance/present/{id}', [AttendanceController::class, 'getClassStudentAttendance']);
Route::get('/attendance/not-present/{id}', [AttendanceController::class, 'getClassNotPresentStudents']);

//STUDENT ROUTES
Route::get('/student/dashboard/{studentId}', [AttendanceController::class, 'fetchStudentClassModule']);
Route::get('/attendance/submissions/{sectionId}/{studentId}', [AttendanceController::class, 'getAttendanceSubmission']);

//JIHA (TREASURER + STUDENT)
Route::get('/treasurer/student-count', [TuitionFeesController::class, 'getStudentCount']);
Route::get('/treasurer/dashboard-summary', [TuitionFeesController::class, 'dashboardSummary']);
Route::get('/treasurer/fees-summary', [TuitionFeesController::class, 'getTuitionFeesSummary']);
Route::get('/treasurer/fees-status', [TuitionFeesController::class, 'getStudentsFeeStatus']);
Route::get('/treasurer/student-details/{userId}', [TuitionFeesController::class, 'getStudentDetail']);
Route::get('/treasurer/unpaid-count', [TuitionFeesController::class, 'getUnpaidCount']);
Route::post('/treasurer/block-settings', [TuitionFeesController::class, 'updateBlockSettings']);
Route::get('/student/financial-details/{id}', [TuitionFeesController::class, 'getStudentFinancialProfile']);
Route::get('/student/payment-history/{userId}', [TuitionFeesController::class, 'getPaymentHistory']); 
Route::post('/student/update-bank', [TuitionFeesController::class, 'updateStudentBank']);