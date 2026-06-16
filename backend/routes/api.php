<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\TuitionFeesController;
use App\Http\Controllers\ModuleController;
use App\Http\Controllers\BookingController;
use App\Http\Controllers\AttendanceController;
use App\Http\Controllers\AttendanceRecordController;
use App\Models\Subject; 
use App\Http\Controllers\RegistrarSubjectController;
use App\Http\Controllers\StudentSubjectController;
use App\Http\Controllers\CreditController;

// This is the "door" the Flutter app is knocking on
Route::post('/login', [AuthController::class, 'login']);

//--------------------------------------------------------------------------------------------------------------------//
//AININ 
// -------- Pusat Adab Routes ---------------------------------------

Route::get('/modules', [ModuleController::class, 'index']);
Route::post('/modules', [ModuleController::class, 'store']);
Route::post('/modules/update-existing', [ModuleController::class, 'update']);
Route::get('/modules/{id}/students', [BookingController::class, 'getRegisteredStudents']);


Route::get('/attendance/pusat-adab', [AttendanceRecordController::class, 'fetchPusatAdabModules']);

// Route to fetch the studentattendance list for a specific module
Route::get('/attendance/pusat-adab/{moduleId}/present', [AttendanceRecordController::class, 'getPresentStudents']);

// 3. Route to save student grades (Grade Dialog)
Route::post('/attendance/pusat-adab/grade/{recordId}', [AttendanceRecordController::class, 'updateStudentGrade']);

Route::get('/pusat-adab/credit-claims', [CreditController::class, 'getAllClaims']);
Route::post('/pusat-adab/credit-claims/{id}/approve', [CreditController::class, 'approveClaim']);
Route::post('/pusat-adab/credit-claims/{id}/reject', [CreditController::class, 'rejectClaim']);
//--------------------------------------------------------------------------------------------------------------------//

// STUDENT ROUTES
//AININ 
Route::post('/modules/apply', [BookingController::class, 'applyToModule']);
Route::get('/students/{studentId}/bookings', [BookingController::class, 'getStudentBookings']);
Route::delete('/bookings/{id}', [BookingController::class, 'destroy']);
Route::post('/bookings/{id}/claim', [BookingController::class, 'claimModule']);
Route::post('/credit-claims/submit', [CreditController::class, 'submitFinalCredit']);
Route::get('/credit-claims/status/{studentId}', [CreditController::class, 'checkCreditStatus']);
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
Route::get('/total-subjects', function () { return response()->json(['totalSubjects' => Subject::count()]);});
//-----------------------------------------------------------------------------


//WIDA
//LECTURER ROUTES
Route::get('/lecturer/subjects', [AttendanceController::class, 'getLecturerSubjects']);
Route::get('/sections/{sectionId}/labs', [AttendanceController::class, 'getSectionLabs']);
Route::post('/attendance/store', [AttendanceController::class, 'store']);
Route::get('/lecturer/{lecturerId}/attendance-history', [AttendanceController::class, 'getAttendanceHistory']);
Route::get('/attendance/{id}', [AttendanceController::class, 'getDetails']);
Route::post('/update-attendance', [AttendanceController::class, 'updateAttendanceDetails']);
Route::get('/attendance/present/{id}', [AttendanceController::class, 'getClassStudentAttendance']);
Route::get('/attendance/not-present/{id}', [AttendanceController::class, 'getClassNotPresentStudents']);

//PUSAT ADAB ROUTES
Route::get('/get-adab-modules', [AttendanceController::class, 'getAdabModules']);
Route::post('/module-attendance/store', [AttendanceController::class, 'storeModuleAttendance']);

//STUDENT ROUTES
Route::get('/student/dashboard/{studentId}', [AttendanceController::class, 'fetchStudentClassModule']);
Route::get('/attendance/submissions/{sectionId}/{studentId}', [AttendanceController::class, 'getAttendanceSubmission']);
Route::post('/attendance/submit', [AttendanceController::class, 'submitAttendance']);
Route::get('/student/attendance-history/{studentId}', [AttendanceController::class, 'getSubmittedAttendanceRecords']);
Route::get('/student/modules/{studentId}', [AttendanceController::class, 'fetchStudentClassModule']);

//JIHA 
//TREASURER ROUTES
Route::get('/treasurer/student-count', [TuitionFeesController::class, 'getStudentCount']);
Route::get('/treasurer/dashboard-summary', [TuitionFeesController::class, 'dashboardSummary']);
Route::get('/treasurer/fees-summary', [TuitionFeesController::class, 'getTuitionFeesSummary']);
Route::get('/treasurer/fees-status', [TuitionFeesController::class, 'getStudentsFeeStatus']);
Route::get('/treasurer/student-details/{userId}', [TuitionFeesController::class, 'getStudentDetail']);
Route::get('/treasurer/unpaid-count', [TuitionFeesController::class, 'getUnpaidCount']);
Route::post('/treasurer/block-settings', [TuitionFeesController::class, 'updateBlockSettings']);
Route::get('/treasurer/report-totals', [TuitionFeesController::class, 'getFinancialReportTotals']);
Route::get('/treasurer/report/download-pdf', [TuitionFeesController::class, 'downloadFinancialReportPDF']);
Route::get('/treasurer/report/download-csv', [TuitionFeesController::class, 'downloadFinancialReportCSV']);

//STUDENT ROUTES
Route::get('/student/dashboard-status/{student_id}', [TuitionFeesController::class, 'getStudentDashboardStatus']);
Route::get('/student/financial-details/{id}', [TuitionFeesController::class, 'getStudentFinancialProfile']);
Route::post('/student/complete-payment', [App\Http\Controllers\TuitionFeesController::class, 'completePayment']);
Route::get('/student/payment-history/{userId}', [TuitionFeesController::class, 'getPaymentHistory']); 
Route::post('/student/update-bank', [TuitionFeesController::class, 'updateStudentBank']);
