<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Str;
use Illuminate\Support\Facades\DB;
use App\Models\Attendance;
use App\Models\Module;
use App\Models\AttendanceRecord;
use App\Models\ModuleAttendance;
use Illuminate\Support\Facades\Log;

class AttendanceController extends Controller
{
    /**
     * Get subjects for a specific lecturer
     */
    public function getLecturerSubjects(Request $request)
    {
        $lecturerId = $request->query('user_id');

        if (!$lecturerId) {
            return response()->json(['success' => false, 'message' => 'Lecturer ID required'], 400);
        }

        // Using DB::table for a flatter, simpler structure like your Tuition controller
        $subjects = DB::table('subjects')
            ->join('sections', 'subjects.subject_id', '=', 'sections.subject_id')
            ->where('sections.lecturer_id', $lecturerId)
            ->select(
                'subjects.subject_id',
                'subjects.subject_code',
                'subjects.subject_name',
                'sections.section_id',
                'sections.section_no'
            )
            ->get();

        return response()->json([
            'success' => true,
            'data' => $subjects
        ]);
    }

    public function getSectionLabs($sectionId)
    {
        $labs = DB::table('labs')
            ->where('section_id', $sectionId)
            ->select('lab_id', 'lab_name')
            ->get();

        return response()->json($labs);
    }

    /**
     * Create a new attendance session
     */
    public function store(Request $request)
    {
        $request->validate([
            'section_id' => 'required',
            'lab_name'   => 'required', // This comes from your Flutter dropdown
            'geo_lat'    => 'required',
            'geo_long'   => 'required',
            'date'       => 'required|date',
            'time'       => 'required',
        ]);

        return DB::transaction(function () use ($request) {
            // 1. Create the General Attendance (Code & GPS)
            $code = strtoupper(Str::random(6));
            
            $attendance = Attendance::create([
                'attendance_code' => $code,
                'geo_lat'         => $request->geo_lat,
                'geo_long'        => $request->geo_long,
                'geo_radius'      => 500,
            ]);

            // 2. Create the Specific Class Attendance
            // This links the section and the lab name
            DB::table('class_attendances')->insert([
                'attendance_id' => $attendance->id,
                'section_id'    => $request->section_id,
                'class_type'    => $request->lab_name, // "Computer Lab 1", etc.
                'date'          => $request->date,
                'time'          => date('H:i:s', strtotime($request->time)),
                'created_at'    => now(),
                'updated_at'    => now(),
            ]);

            return response()->json([
                'success' => true,
                'code'    => $code,
                'attendance_id' => $attendance->id
            ], 201);
        });
    }

    public function getAttendanceHistory($lecturerId)
{
    $history = DB::table('class_attendances')
        ->join('attendances', 'class_attendances.attendance_id', '=', 'attendances.id')
        ->join('sections', 'class_attendances.section_id', '=', 'sections.section_id')
        ->join('subjects', 'sections.subject_id', '=', 'subjects.subject_id')
        ->where('sections.lecturer_id', $lecturerId)
        ->select(
            'subjects.subject_code',
            'class_attendances.class_type as lecture_lab',
            'class_attendances.date',
            'class_attendances.time',
            'attendances.attendance_code',
            'attendances.id as attendance_id'
        )
        ->orderBy('class_attendances.date', 'desc')
        ->get();

    return response()->json($history);
}

public function getDetails($id) {
        // Try to find in Academic Attendances first
        $attendance = DB::table('class_attendances')
            ->join('attendances', 'class_attendances.attendance_id', '=', 'attendances.id')
            ->leftJoin('sections', 'class_attendances.section_id', '=', 'sections.section_id')
            ->leftJoin('subjects', 'sections.subject_id', '=', 'subjects.subject_id')
            ->where('attendances.id', $id)
            ->select(
                'attendances.id as attendance_id',
                'attendances.geo_lat',
                'attendances.geo_long',
                'class_attendances.class_type',
                'class_attendances.date',
                'class_attendances.time',
                'subjects.subject_name',
                'sections.section_no'
            )
            ->first();

        // Fallback for Module Attendances if not found in academic
        if (!$attendance) {
            $attendance = DB::table('module_attendances')
                ->join('attendances', 'module_attendances.attendance_id', '=', 'attendances.id')
                ->leftJoin('modules', 'module_attendances.module_id', '=', 'modules.id')
                ->where('attendances.id', $id)
                ->select(
                    'attendances.id as attendance_id',
                    'attendances.geo_lat',
                    'attendances.geo_long',
                    DB::raw("'Module' as class_type"), 
                    'module_attendances.date',
                    'module_attendances.time',
                    'modules.activity_name as subject_name',
                    'modules.venue as section_no'
                )
                ->first();
        }

        if (!$attendance) {
            return response()->json(['message' => 'Not found'], 404);
        }

        return response()->json($attendance);
    }

    // POST: Update details
    public function updateAttendanceDetails(Request $request) {
        $request->validate([
            'attendance_id' => 'required',
            'lab_name'      => 'required',
            'date'          => 'required',
            'time'          => 'required',
        ]);

        try {
            DB::transaction(function () use ($request) {
                // Update the specialized table
                DB::table('class_attendances')
                    ->where('attendance_id', $request->attendance_id)
                    ->update([
                        'class_type' => $request->lab_name,
                        'date'       => $request->date,
                        'time'       => date('H:i:s', strtotime($request->time)),
                    ]);

                // Update the main attendance table (GPS)
                DB::table('attendances')
                    ->where('id', $request->attendance_id)
                    ->update([
                        'geo_lat'  => $request->lat ?? 0.0,
                        'geo_long' => $request->lng ?? 0.0,
                    ]);
            });

            return response()->json(['success' => true, 'message' => 'Updated!']);
        } catch (\Exception $e) {
            return response()->json(['success' => false, 'error' => $e->getMessage()], 500);
        }
    }

/**
 * Function 1: Fetch students who ARE present (have an attendance record)
 */
public function getClassStudentAttendance($attendanceId)
{
    $present = DB::table('attendance_records')
        ->join('students', 'attendance_records.student_id', '=', 'students.student_id')
        ->join('users', 'students.user_id', '=', 'users.id')
        ->where('attendance_records.attendance_id', $attendanceId)
        ->select(
            'attendance_records.id as record_id',
            'students.student_id as matric_no',
            'users.name as student_name',
            'attendance_records.status',
            'attendance_records.updated_at as check_in_time'
        )
        ->get();

    return response()->json([
        'success' => true,
        'data' => $present
    ]);
}

/**
 * Function 2: Fetch students who are NOT present (enrolled but no record)
 */
public function getClassNotPresentStudents($attendanceId)
{
    // 1. Get the section ID associated with this attendance session
    $session = DB::table('class_attendances')
        ->where('attendance_id', $attendanceId)
        ->first();

    if (!$session) {
        return response()->json(['success' => false, 'message' => 'Session not found'], 404);
    }

    // 2. Identify students who already have a record for this session
    $presentIds = DB::table('attendance_records')
        ->where('attendance_id', $attendanceId)
        ->pluck('student_id');

    // 3. Find students in the section who are NOT in the present list
    $notPresent = DB::table('section_student')
        ->join('students', 'section_student.student_id', '=', 'students.student_id')
        ->join('users', 'students.user_id', '=', 'users.id')
        ->where('section_student.section_id', $session->section_id)
        ->whereNotIn('students.student_id', $presentIds)
        ->select(
            'students.student_id as matric_no',
            'users.name as student_name'
        )
        ->get();

    return response()->json([
        'success' => true,
        'data' => $notPresent
    ]);
}


//PUSATADAB
public function getAdabModules(Request $request)
{
    try {
        $query = Module::query();

        // Check if the Flutter app sent a ?date=YYYY-MM-DD parameter
        if ($request->has('date') && !empty($request->date)) {
            $query->whereDate('date_time', $request->date);
        }

        $modules = $query->select('id', 'activity_name', 'date_time', 'venue', 'status')
                         ->orderBy('date_time', 'asc')
                         ->get();

        return response()->json([
            'success' => true,
            'data' => $modules
        ], 200);

    } catch (\Exception $e) {
        return response()->json([
            'success' => false, 
            'message' => 'Error: ' . $e->getMessage()
        ], 500);
    }
}

    /**
     * Create a new module attendance session
     */
    public function storeModuleAttendance(Request $request)
    {
        $request->validate([
            'module_id'  => 'required|integer',
            'geo_lat'    => 'required',
            'geo_long'   => 'required',
            // Made date and time optional in validation to prevent 500 errors 
            // if your Flutter app doesn't send them for modules.
            'date'       => 'nullable|date',
            'time'       => 'nullable',
        ]);

        return DB::transaction(function () use ($request) {
            // 1. Create the General Attendance (Code & GPS)
            $code = strtoupper(Str::random(6));
            
            $attendance = Attendance::create([
                'attendance_code' => $code,
                'geo_lat'         => $request->geo_lat,
                'geo_long'        => $request->geo_long,
                'geo_radius'      => 500,
            ]);

            // 2. Create the Specific Module Attendance
            // This links the module to the generated attendance
            DB::table('module_attendances')->insert([
                'attendance_id' => $attendance->id,
                'module_id'     => $request->module_id,
                // If Flutter sends the date/time, use it. Otherwise, default to exactly now.
                'date'          => $request->date ?? now()->toDateString(),
                'time'          => $request->time ? date('H:i:s', strtotime($request->time)) : now()->toTimeString(),
                'created_at'    => now(),
                'updated_at'    => now(),
            ]);
    
            return response()->json([
                'success'       => true,
                'code'          => $code,
                'attendance_id' => $attendance->id
            ], 201);
        });
    }


//STUDENT

public function fetchStudentClassModule($studentId)
{
    try {
        // 1. Fetch Academic Curriculum
        $curriculum = DB::table('registration')
            ->join('sections', 'registration.section_id', '=', 'sections.section_id')
            ->join('subjects', 'sections.subject_id', '=', 'subjects.subject_id')
            ->where('registration.student_id', $studentId)
            ->where('registration.status', 'active')
            ->select(
                'subjects.subject_id', 
                'subjects.subject_code', 
                'subjects.subject_name',
                'sections.section_id',
                'sections.section_no'
            )
            ->get();

        // 2. Fetch Co-Curriculum (Bookings -> Modules -> module_attendances)
        // FIXED: Selects the true tracking attendance_id and targets only today's/active slots
        $coCurriculum = DB::table('bookings')
            ->join('modules', 'bookings.module_id', '=', 'modules.id')
            ->leftJoin('module_attendances', 'modules.id', '=', 'module_attendances.module_id')
            ->where('bookings.student_id', $studentId)
            ->select(
                'modules.id as module_id', 
                'modules.activity_name', 
                'modules.date_time', 
                'modules.venue',
                'module_attendances.attendance_id' // 🔴 Grabs the real code connector (e.g., 7)
            )
            // Optional: If you only want to show the module session created for today, uncomment below:
            // ->whereDate('module_attendances.date', date('Y-m-d')) 
            ->get();

        return response()->json([
            'success' => true,
            'data' => [
                'curriculum' => $curriculum,
                'co_curriculum' => $coCurriculum
            ]
        ], 200);

    } catch (\Exception $e) {
        return response()->json([
            'success' => false, 
            'message' => 'Query Error: ' . $e->getMessage()
        ], 500);
    }
}

public function getAttendanceSubmission($sectionId, $studentId)
{
    try {
        // 1. Get all attendance sessions created for this section
        $sessions = DB::table('class_attendances')
            ->join('attendances', 'class_attendances.attendance_id', '=', 'attendances.id')
            ->where('class_attendances.section_id', $sectionId)
            ->select(
                'class_attendances.attendance_id',
                'class_attendances.class_type',
                'class_attendances.date',
                'class_attendances.time',
                'attendances.attendance_code'
            )
            ->orderBy('class_attendances.date', 'desc')
            ->get();

        $today = date('Y-m-d');

        // 2. Loop through to determine the status for the student
        foreach ($sessions as $session) {
            // Check if student has already submitted for this specific session
            $submission = DB::table('attendance_records')
                ->where('attendance_id', $session->attendance_id)
                ->where('student_id', $studentId)
                ->first();

            if ($submission) {
                $session->status = 'Submitted';
            } elseif ($session->date == $today) {
                $session->status = 'Active';
            } else {
                $session->status = 'Expired';
            }
        }

        return response()->json([
            'success' => true,
            'data' => $sessions
        ], 200);

    } catch (\Exception $e) {
        return response()->json(['success' => false, 'message' => $e->getMessage()], 500);
    }
}

public function submitAttendance(Request $request)
{
    $request->validate([
        'attendance_id' => 'required|integer',
        'student_id' => 'required|integer',
        'code' => 'required|string|size:6',
        'student_lat' => 'required|numeric',
        'student_lng' => 'required|numeric',
    ]);

    try {
        // 1. Fetch matching active target tracking session definitions
        $session = DB::table('attendances')->where('id', $request->attendance_id)->first();
        if (!$session) {
            return response()->json(['success' => false, 'message' => 'Attendance session not found.'], 404);
        }

        // 2. Validate the code input string
        if (trim($session->attendance_code) !== trim($request->code)) {
            return response()->json(['success' => false, 'message' => 'Invalid verification code. Please check and try again.'], 200);
        }

        // Defensive checks to stop division-by-zero or empty math crashes
        $targetLat = !empty($session->geo_lat) ? $session->geo_lat : 4.6738; 
        $targetLng = !empty($session->geo_long) ? $session->geo_long : 103.4243;
        $allowedRadius = !empty($session->radius) ? $session->radius : 100;

        // 3. Haversine Mathematical Distance Calculation
        $earthRadius = 6371000; // Meters
        $latDelta = deg2rad($targetLat - $request->student_lat);
        $lngDelta = deg2rad($targetLng - $request->student_lng);

        $a = sin($latDelta / 2) * sin($latDelta / 2) +
             cos(deg2rad($request->student_lat)) * cos(deg2rad($targetLat)) *
             sin($lngDelta / 2) * sin($lngDelta / 2);
             
        $c = 2 * atan2(sqrt($a), sqrt(1 - $a));
        $distance = $earthRadius * $c; 

        $inRange = $distance <= $allowedRadius;

        if (!$inRange) {
            return response()->json([
                'success' => false,
                'in_range' => false,
                'distance' => round($distance),
                'message' => 'Verification failed. Your position falls outside the perimeter range.'
            ], 200);
        }

        // 4. Handle logging entries safely
        $alreadyRecorded = DB::table('attendance_records')
            ->where('attendance_id', $request->attendance_id)
            ->where('student_id', $request->student_id)
            ->exists();

        if (!$alreadyRecorded) {
            // FIXED: Added 'submitted_time' to fulfill your table's database schema constraints
            DB::table('attendance_records')->insert([
                'attendance_id'  => $request->attendance_id,
                'student_id'     => $request->student_id,
                'status'         => 'Present',
                'submitted_time' => now()->toTimeString(), // Sends current time format e.g., '17:34:26'
                'created_at'     => now(),
                'updated_at'     => now(),
            ]);
        }

        return response()->json([
            'success' => true,
            'in_range' => true,
            'distance' => round($distance),
            'message' => 'Success! Attendance recorded successfully!'
        ], 200);

    } catch (\Exception $e) {
        return response()->json(['success' => false, 'message' => 'Internal server crash error: ' . $e->getMessage()], 500);
    }
}

public function getSubmittedAttendanceRecords($studentId)
{
    try {
        // 1. Get Curriculum Attendance Records
        $curriculum = DB::table('attendances')
            ->join('attendance_records', 'attendances.id', '=', 'attendance_records.attendance_id')
            ->join('sections', 'attendances.section_id', '=', 'sections.section_id')
            ->join('subjects', 'sections.subject_id', '=', 'subjects.subject_id')
            ->where('attendance_records.student_id', $studentId)
            ->where('attendance_records.status', 'Present')
            ->select(
                'subjects.subject_code as display_name', // e.g., BCY3083
                'attendances.class_type as lecture_lab', 
                'attendances.date',                      
                'attendances.time',
                DB::raw("'Curriculum' as attendance_type") // Label tag identifier
            );

        // 2. Get Co-Curriculum Attendance Records (Unified via UNION)
        // Adjust the table and column names to match your precise co-curriculum structure
        $records = DB::table('modules')
            ->join('bookings', 'modules.id', '=', 'bookings.module_id')
            ->where('bookings.student_id', $studentId)
            ->where('bookings.status', 'Present') // Or wherever you store verified co-curr attendance
            ->select(
                'modules.activity_name as display_name', // e.g., KAYAKING ADVENTURE
                DB::raw("'Activity' as lecture_lab"),    // Placeholder for table cell consistency
                DB::raw("DATE(modules.date_time) as date"),
                DB::raw("TIME(modules.date_time) as time"),
                DB::raw("'Co-Curriculum' as attendance_type") // Label tag identifier
            )
            ->union($curriculum) // Combine queries
            ->orderBy('date', 'desc')
            ->get();

        return response()->json([
            'success' => true,
            'data' => $records
        ], 200);

    } catch (\Exception $e) {
        return response()->json([
            'success' => false, 
            'message' => 'Failed to fetch historical database records: ' . $e->getMessage()
        ], 500);
    }
}


}
