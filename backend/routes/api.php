<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\TreasurerController;
use App\Http\Controllers\Api\ModuleController;
use App\Models\Section;


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

//TREASURY ROUTES
Route::get('/treasury/student-count', [TreasurerController::class, 'getStudentCount']);


//PUSAT ADAB ROUTES
Route::post('/modules', [ModuleController::class, 'store']);