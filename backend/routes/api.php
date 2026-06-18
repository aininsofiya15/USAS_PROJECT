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

// Login route for all users 
Route::post('/login', [AuthController::class, 'login']);

//--------------------------------------------------------------------------------------------------------------------//
//AININ 
// -------- Pusat Adab Routes ------------------------------------------------------

// 1. Route to fetch all modules for Pusat Adab
Route::get('/modules', [ModuleController::class, 'index']);
// 2. Route to create a new module (Pusat Adab)
Route::post('/modules', [ModuleController::class, 'store']);
// 3. Route to update an existing module (Pusat Adab)
Route::post('/modules/update-existing', [ModuleController::class, 'update']);
// 4. Route to delete a module (Pusat Adab)
Route::get('/modules/{id}/students', [BookingController::class, 'getRegisteredStudents']);
// 5. Route to fetch all modules for Pusat Adab (for attendance)
Route::get('/attendance/pusat-adab', [AttendanceRecordController::class, 'fetchPusatAdabModules']);
// 6. Route to fetch students who are present for a specific module (Pusat Adab)
Route::get('/attendance/pusat-adab/{moduleId}/present', [AttendanceRecordController::class, 'getPresentStudents']);
// 7. Route to fetch students data for grading (Pusat Adab)
Route::post('/attendance/pusat-adab/grade/{recordId}', [AttendanceRecordController::class, 'updateStudentGrade']);
// 8. Route to fetch students credit claims submissions (Pusat Adab)
Route::get('/pusat-adab/credit-claims', [CreditController::class, 'index']);
// 9. Route to approve a credit claim (Pusat Adab)
Route::post('/pusat-adab/credit-claims/{id}/approve', [CreditController::class, 'updateStatus']);
// 10. Route to reject a credit claim (Pusat Adab)
Route::post('/pusat-adab/credit-claims/{id}/reject', [CreditController::class, 'rejectClaim']);

// STUDENT ROUTES
//AININ 
// -------------------Student Routes----------------------------------------------------

// 1. Route for students to apply for a module (Student)
Route::post('/modules/apply', [BookingController::class, 'applyToModule']);
// 2. Route to fetch a student's bookings
Route::get('/students/{studentId}/bookings', [BookingController::class, 'getStudentBookings']);
// 3. Route to delete a booking (Student)
Route::delete('/bookings/{id}', [BookingController::class, 'destroy']);
// 4. Route for students to claim a module (Student)
Route::post('/bookings/{id}/claim', [CreditController::class, 'claimIndividualModule']);
// 5. Route for students to submit final credit claim (Student)
Route::post('/credit-claims/submit', [CreditController::class, 'submitFinalCredit']);
// 6. Route to fetch a student's credit claim status (Student)
Route::get('/credit-claims/status/{studentId}', [CreditController::class, 'getClaimStatus']);

//---------------------------------------------------------------------------------------


//---------------------------------------------------------------------------------------//
// YAYA - MANAGE SUBJECT REGISTRATION

// FACULTY REGISTRAR ROUTES

// Create a new subject with sections and labs
Route::post('/register-subject', [RegistrarSubjectController::class, 'registerSubject']);

// Retrieve all subjects
Route::get('/subjects', [RegistrarSubjectController::class, 'getSubjects']); 

// Retrieve lecturer list for section assignment
Route::get('/lecturers', [RegistrarSubjectController::class, 'getLecturers']);

// Retrieve subject details including sections, labs and registrations
Route::get('/subject-details/{id}', [RegistrarSubjectController::class, 'getSubjectDetails']);

// Retrieve total number of subjects
Route::get('/total-subjects', function () {
    return response()->json([
        'totalSubjects' => Subject::count()
    ]);
});

// Update subject
Route::put(
    '/subject/{id}',
    [RegistrarSubjectController::class, 'updateSubject']
);

// Delete subject
Route::delete(
    '/subject/{id}',
    [RegistrarSubjectController::class, 'deleteSubject']
);



// STUDENT ROUTES

// Retrieve available subjects for registration
Route::get('/student/subjects', [StudentSubjectController::class, 'getSubjects']);

// Retrieve registered subjects for selected student
Route::get('/student/registered-subjects/{student_id}', [StudentSubjectController::class, 'getRegisteredSubjects']);

// Register student into selected subject and lab
Route::post('/student/register-subject', [StudentSubjectController::class, 'registerSubject']);

// Drop registered subject
Route::put('/student/drop-subject/{registration_id}', [StudentSubjectController::class, 'dropSubject']);

//-----------------------------------------------------------------------------


//WIDA
//LECTURER ROUTES
Route::get('/lecturer/{lecturerId}/attendance-insights', [AttendanceController::class, 'getAttendanceInsights']);
Route::get('/lecturer/subjects/{lecturerId}', [AttendanceController::class, 'getLecturerSubjects']);
Route::get('/sections/{sectionId}/labs', [AttendanceController::class, 'getSectionLabs']);
Route::post('/attendance/store', [AttendanceController::class, 'store']);
Route::get('/lecturer/{lecturerId}/attendance-history', [AttendanceController::class, 'getAttendanceHistory']);
Route::get('/attendance/{id}', [AttendanceController::class, 'getDetails']);
Route::post('/update-attendance', [AttendanceController::class, 'updateAttendanceDetails']);
Route::get('/attendance/present/{id}', [AttendanceController::class, 'getClassPresentStudents']);
Route::get('/attendance/not-present/{id}', [AttendanceController::class, 'getClassNotPresentStudents']);
Route::post('/attendance/update-status', [AttendanceController::class, 'updateStudentStatus']);
Route::post('/attendance/update/{id}', [AttendanceController::class, 'updateStudentAttendanceStatus']);

//PUSAT ADAB ROUTES
Route::get('/get-adab-modules', [AttendanceController::class, 'getAdabModules']);
Route::post('/module-attendance/store', [AttendanceController::class, 'storeModuleAttendance']);
Route::post('/attendance/update-location', [AttendanceController::class, 'updateModuleAttendanceDetails']);
Route::post('/module-attendance/update', [AttendanceController::class, 'updateStudentModuleAttendance']);

//STUDENT ROUTES
Route::get('/student/dashboard/{studentId}', [AttendanceController::class, 'fetchStudentClassModule']);
Route::get('/attendance/submissions/{sectionId}/{studentId}', [AttendanceController::class, 'getAttendanceSubmission']);
Route::post('/attendance/submit', [AttendanceController::class, 'submitAttendance']);
Route::get('/attendance/records/{studentId}', [AttendanceController::class, 'getSubmittedAttendanceRecords']);
Route::get('/student/modules/{studentId}', [AttendanceController::class, 'fetchStudentClassModule']);


//JIHA
//TREASURER ROUTES
Route::get('/treasurer/student-count', [TuitionFeesController::class, 'getStudentCount']);
Route::get('/treasurer/dashboard-summary', [TuitionFeesController::class, 'getDashboardSummary']);
Route::get('/treasurer/fees-summary', [TuitionFeesController::class, 'getTuitionFeesSummary']);
Route::get('/treasurer/fees-status', [TuitionFeesController::class, 'getStudentsFeeStatus']);
Route::get('/treasurer/student-details/{userId}', [TuitionFeesController::class, 'getStudentDetail']);
Route::get('/treasurer/unpaid-count', [TuitionFeesController::class, 'getUnpaidCount']);
Route::post('/treasurer/block-settings', [TuitionFeesController::class, 'updateBlockSettings']);
Route::get('/treasurer/report-totals', [TuitionFeesController::class, 'getFinancialReportTotals']);
Route::get('/treasurer/report/download-pdf', [TuitionFeesController::class, 'downloadFinancialReportPDF']);
Route::get('/treasurer/report/download-csv', [TuitionFeesController::class, 'downloadFinancialReportCSV']);
Route::post('/treasurer/block-settings', [TuitionFeesController::class, 'updateBlockSettings']);
Route::get('/treasurer/block-settings/latest', [TuitionFeesController::class, 'getLatestBlockSettings']);
//STUDENT ROUTES
Route::get('/student/dashboard-status/{student_id}', [TuitionFeesController::class, 'getStudentDashboardStatus']);
Route::get('/student/financial-details/{id}', [TuitionFeesController::class, 'getStudentFinancialProfile']);
Route::post('/student/complete-payment', [TuitionFeesController::class, 'completePayment']);
Route::get('/student/payment-history/{userId}', [TuitionFeesController::class, 'getPaymentHistory']); 
Route::post('/student/update-bank', [TuitionFeesController::class, 'updateStudentBank']);
Route::post('/tuition/payment-intent', [TuitionFeesController::class, 'generateStripeIntent']);
Route::get('/notifications/{userId}', [TuitionFeesController::class, 'getUserNotifications']);
Route::post('/notifications/{notificationId}/read', [TuitionFeesController::class, 'markNotificationAsRead']);
Route::post('/notifications/mark-all-read', [TuitionFeesController::class, 'markAllNotificationsAsRead']);
Route::post('/notifications/send-block-warnings', [TuitionFeesController::class, 'checkAndSendBlockWarnings']);
Route::get('/student/check-block/{userId}', [TuitionFeesController::class, 'checkBlockStatus']);