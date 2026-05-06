<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\TreasurerController;
use App\Http\Controllers\Api\ModuleController;
use App\Models\Section;
use Illuminate\Http\Request;
use App\Models\Attendance;
use App\Models\Subject; 


// This is the "door" the Flutter app is knocking on
Route::post('/login', [AuthController::class, 'login']);

//LECTURER ROUTES
Route::get('/lecturer/{lecturer_id}/attendance', function($lecturer_id) {
    // 1. Get all sections for this lecturer and include the subject details
    $sections = Section::with('subject')->where('lecturer_id', $lecturer_id)->get();

    // 2. Group the sections by their Subject Code
    $groupedSections = $sections->groupBy('subject_code');
    $subjectsList = [];

    // 3. Format it into the exact JSON shape Flutter wants
    foreach($groupedSections as $code => $group) {
        $subjectsList[] = [
            'subject_name' => $code . ' ' . $group->first()->subject->subject_name,
            'sections' => $group->pluck('section_name')->values()
        ];
    }

    // 4. Send the package to Flutter!
    return response()->json([
        'semester' => '252026 SEM II',
        'subjects' => $subjectsList
    ]);
});

Route::post('/generate-attendance', function (Request $request) {
    // 1. Grab the exact string from Flutter and make it ALL CAPS
    // Example: "BCY3083 SECURE SOFTWARE DEVELOPMENT"
    $incomingString = strtoupper($request->subject_name); 

    // 2. Split the string into exactly TWO pieces at the first space.
    $parts = explode(' ', $incomingString, 2);
    
    $searchCode = $parts[0]; // This gets "BCY3083"
    $searchName = $parts[1] ?? $incomingString; // This gets "SECURE SOFTWARE DEVELOPMENT"

    // 3. Search the database! Find it by the Code OR the Name.
    $subject = Subject::where('subject_code', $searchCode)
                      ->orWhere('subject_name', $searchName)
                      ->first();

    if (!$subject) {
        return response()->json([
            'error' => "I searched for Code: [$searchCode] or Name: [$searchName] but found nothing!"
        ], 404);
    }

    // 4. Generate a random 6-digit code
    $randomCode = str_pad(mt_rand(0, 999999), 6, '0', STR_PAD_LEFT);

    // 5. Save to database using the correct verified code
    $attendance = Attendance::create([
        'lecturer_id' => '1', 
        'subject_code' => $subject->subject_code, 
        'section_name' => $request->section,
        'class_type' => $request->class_type,
        'class_date' => $request->class_date,
        'class_time' => $request->class_time,
        'latitude' => null, 
        'longitude' => null,
        'generated_code' => $randomCode,
    ]);

    // 6. Return success back to Flutter
    return response()->json([
        'success' => true,
        'data' => [
            'subject_name' => $subject->subject_name,
            'section_name' => $attendance->section_name,
            'class_type' => $attendance->class_type,
            'class_date' => $attendance->class_date,
            'class_time' => $attendance->class_time,
            'generated_code' => $attendance->generated_code,
        ]
    ]);
});

// PUSAT ADAB ROUTES
Route::get('/modules', [ModuleController::class, 'index']);
Route::post('/modules', [ModuleController::class, 'store']);
Route::post('/modules/update-existing', [ModuleController::class, 'update']);

//TREASURER ROUTES
Route::get('/treasurer/student-count', [TreasurerController::class, 'getStudentCount']);
Route::get('/treasurer/dashboard-summary', [TreasurerController::class, 'dashboardSummary']);