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
    public function getLecturerSubjects($lecturerId)
    {
        try {
            // Join sections to subjects table
            $data = DB::table('sections')
                ->join('subjects', 'sections.subject_id', '=', 'subjects.subject_id') // 🔑 FIXED: changed subjects.id to subjects.subject_id
                ->where('sections.lecturer_id', $lecturerId)
                ->select(
                    'subjects.subject_id as subject_id', // 🔑 FIXED: changed subjects.id to subjects.subject_id
                    'subjects.subject_code',
                    'subjects.subject_name',
                    'sections.section_id as section_id', 
                    'sections.section_no as section_no' 
                )
                ->get();

            return response()->json([
                'success' => true,
                'message' => 'Lecturer records retrieved successfully.',
                'data' => $data
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Database query exception encountered.',
                'error' => $e->getMessage()
            ], 500);
        }
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

        // Convert the requested form input time string into a clean standard format (H:i:s)
        $requestedTime = date('H:i:s', strtotime($request->time));

        // --- NARROWED ACTIVE RE-ENTRY CHECKER ---
        // Looks ONLY at records matching the requested section and date
        $existingDuplicate = DB::table('class_attendances')
            ->where('section_id', $request->section_id)
            ->where('date', $request->date)
            ->where(function($query) use ($requestedTime) {
                // An active block exists if the entry's start time is less than or equal to the requested time,
                // AND the requested time is within 2 hours of that entry's start time.
                $query->where('time', '<=', $requestedTime)
                      ->whereRaw('ADDTIME(time, "02:00:00") > ?', [$requestedTime]);
            })
            ->first();

        if ($existingDuplicate) {
            // Calculate dynamic active termination boundary time display string (e.g., "11:50 AM")
            $expirationTime = date('h:i A', strtotime('+2 hours', strtotime($existingDuplicate->time)));

            return response()->json([
                'success' => false,
                'message' => "An attendance code for this class session has already been released and is still active until {$expirationTime}.",
                'expires_at' => $expirationTime
            ], 409);
        }

        // --- TRANSACTION EXECUTION ---
        return DB::transaction(function () use ($request, $requestedTime) {
            // 1. Create the General Attendance (Code & GPS)
            $code = strtoupper(Str::random(6));
            
            $attendance = Attendance::create([
                'attendance_code' => $code,
                'geo_lat'         => $request->geo_lat,
                'geo_long'        => $request->geo_long,
                'geo_radius'      => 500,
            ]);

            // 2. Create the Specific Class Attendance
            DB::table('class_attendances')->insert([
                'attendance_id' => $attendance->id,
                'section_id'    => $request->section_id,
                'class_type'    => $request->lab_name, 
                'date'          => $request->date,
                'time'          => $requestedTime,
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
            'subjects.subject_name',
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
 * 1. Fetch students who ARE present (Present / Late / Medical)
 */
public function getClassPresentStudents($attendanceId)
{
    try {
        $presentStudents = DB::table('attendance_records')
            ->join('users', 'attendance_records.student_id', '=', 'users.id')
            ->join('students', 'users.id', '=', 'students.id')
            ->where('attendance_records.attendance_id', $attendanceId)
            ->whereIn('attendance_records.status', ['present', 'late'])
            
            // 🔑 REPLACE YOUR OLD SELECT WITH THIS:
            ->select(
                'attendance_records.id as id',
                'attendance_records.id as record_id', 
                'students.student_id as matric_no',
                'users.name as student_name',
                'attendance_records.status'
            )
            ->get();

        return response()->json([
            'success' => true,
            'data' => $presentStudents
        ], 200);

    } catch (\Exception $e) {
        return response()->json(['success' => false, 'message' => $e->getMessage()], 500);
    }
}

/**
 * 2. Fetch students who are NOT PRESENT 
 * (Registered in the section, but missing an attendance log or marked absent/late/medical)
 */
public function getClassNotPresentStudents($attendanceId)
{
    try {
        $session = DB::table('attendances')->where('id', $attendanceId)->first();
        $sectionId = ($session && isset($session->section_id)) ? $session->section_id : 3;

        $notPresentStudents = DB::table('registration')
            ->join('users', 'registration.student_id', '=', 'users.id')
            ->join('students', 'users.id', '=', 'students.id')
            ->leftJoin('attendance_records', function($join) use ($attendanceId) {
                $join->on('registration.student_id', '=', 'attendance_records.student_id')
                     ->where('attendance_records.attendance_id', '=', $attendanceId);
            })
            ->where('registration.section_id', $sectionId)
            ->where('registration.status', 'active')
            
            // 🔑 UPDATED WHERE CLAUSE:
            ->where(function($query) {
                $query->whereNull('attendance_records.id')
                      ->orWhereIn('attendance_records.status', ['absent', 'late', 'medical']);
            }) 
            
            ->select(
                // Dynamic mapping: Return real ID if row exists so Flutter can edit it; otherwise return 0
                DB::raw('COALESCE(attendance_records.id, 0) as id'),
                DB::raw('COALESCE(attendance_records.id, 0) as record_id'), 
                'students.student_id as matric_no',
                'users.name as student_name',
                // Keeps real DB status if it exists, otherwise defaults to 'absent'
                DB::raw("COALESCE(attendance_records.status, 'absent') as status")
            )
            ->get();

        return response()->json([
            'success' => true,
            'data' => $notPresentStudents
        ], 200);

    } catch (\Exception $e) {
        return response()->json([
            'success' => false,
            'message' => 'Not present query error: ' . $e->getMessage()
        ], 500);
    }
}

public function updateStudentStatus(Request $request)
{
    try {
        $attendanceId = $request->input('attendance_id');
        $matricNo = $request->input('matric_no');
        $newStatus = $request->input('status');

        // 1. Resolve the internal primary key ID for the student using their matric number
        $student = DB::table('students')->where('student_id', $matricNo)->first();
        if (!$student) {
            return response()->json(['success' => false, 'message' => 'Student record not found'], 404);
        }

        // 2. Upsert logic: search by identifiers; if missing, create row; if present, update status
        DB::table('attendance_records')->updateOrInsert(
            [
                'attendance_id' => $attendanceId,
                'student_id' => $student->id
            ],
            [
                'status' => $newStatus,
                'submitted_time' => now(),
                'updated_at' => now(),
                'created_at' => DB::raw('COALESCE(created_at, NOW())')
            ]
        );

        return response()->json([
            'success' => true,
            'message' => 'Attendance status synchronized successfully!'
        ], 200);

    } catch (\Exception $e) {
        return response()->json([
            'success' => false,
            'message' => 'Internal database sync error: ' . $e->getMessage()
        ], 500);
    }
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

    public function updateStudentModuleAttendance(Request $request)
{
    Log::info('updateStudentModuleStatus payload:', $request->all());

    try {
        $attendanceId = $request->input('attendance_id');
        $recordId     = $request->input('record_id');
        $studentId    = $request->input('student_id');
        $newStatus    = $request->input('status');

        if (!$attendanceId || !$studentId || !$newStatus) {
            return response()->json([
                'success' => false,
                'message' => 'Missing required fields: attendance_id, student_id, status'
            ], 422);
        }

        // record_id > 0 → row exists, just update it
        if ($recordId && $recordId > 0) {
            $updated = DB::table('attendance_records')
                ->where('id', $recordId)
                ->update([
                    'status'         => $newStatus,
                    'submitted_time' => now(),
                    'updated_at'     => now(),
                ]);

            if ($updated === 0) {
                return response()->json([
                    'success' => false,
                    'message' => 'No record found for record_id: ' . $recordId
                ], 404);
            }
        } else {
            // record_id = 0 → no row yet, insert a new one
            DB::table('attendance_records')->insert([
                'attendance_id'  => $attendanceId,
                'student_id'     => $studentId,
                'status'         => $newStatus,
                'submitted_time' => now(),
                'created_at'     => now(),
                'updated_at'     => now(),
            ]);
        }

        return response()->json([
            'success' => true,
            'message' => 'Module attendance updated successfully!'
        ], 200);

    } catch (\Exception $e) {
        Log::error('updateStudentModuleStatus error: ' . $e->getMessage());
        return response()->json([
            'success' => false,
            'message' => 'Server error: ' . $e->getMessage()
        ], 500);
    }
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
            // 🔑 FIXED: Changed to now() so that it sends a full 'YYYY-MM-DD HH:MM:SS' string instead of just the time component!
            DB::table('attendance_records')->insert([
                'attendance_id'  => $request->attendance_id,
                'student_id'     => $request->student_id,
                'status'         => 'Present',
                'submitted_time' => now(), // Generates standard full database timestamp
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

public function getSubmittedAttendanceRecords(Request $request, $studentId)
{
    try {
        $dateFilter = $request->query('dateFilter');

        // 1. Build Curriculum Query using 'class_attendances' sub-table
        $curriculumQuery = DB::table('attendance_records')
            ->join('class_attendances', 'attendance_records.attendance_id', '=', 'class_attendances.attendance_id')
            ->join('sections', 'class_attendances.section_id', '=', 'sections.section_id')
            ->join('subjects', 'sections.subject_id', '=', 'subjects.subject_id')
            ->where('attendance_records.student_id', $studentId)
            ->whereIn('attendance_records.status', ['Present', 'present', 'Late', 'late'])
            ->select(
                'subjects.subject_code as display_name', 
                'class_attendances.class_type as lecture_lab', 
                'class_attendances.date as date',              
                'class_attendances.time as time',              
                DB::raw("'Curriculum' as attendance_type") 
            );

        // 2. Build Co-Curriculum Query using 'module_attendances' linked via 'attendance_records'
        // 🔑 FIXED: Changed the entry table from bookings to attendance_records to prevent column crashes
        $coCurriculumQuery = DB::table('attendance_records')
            ->join('module_attendances', 'attendance_records.attendance_id', '=', 'module_attendances.attendance_id')
            ->join('modules', 'module_attendances.module_id', '=', 'modules.id')
            ->where('attendance_records.student_id', $studentId)
            ->whereIn('attendance_records.status', ['Present', 'present', 'Late', 'late']) 
            ->select(
                'modules.activity_name as display_name', 
                DB::raw("'Activity' as lecture_lab"),    
                'module_attendances.date as date',             
                'module_attendances.time as time',             
                DB::raw("'Co-Curriculum' as attendance_type") 
            );

        // 3. Apply the exact query date filter if present
        if (!empty($dateFilter)) {
            $curriculumQuery->where('class_attendances.date', $dateFilter);
            $coCurriculumQuery->where('module_attendances.date', $dateFilter);
        }

        // 4. Combine both subqueries via UNION ALL
        $combinedRecords = $curriculumQuery->unionAll($coCurriculumQuery);
        
        // 5. Wrap in a master subquery wrapper to apply global sorting order cleanly
        $finalResults = DB::table(DB::raw("({$combinedRecords->toSql()}) as combined"))
            ->mergeBindings($combinedRecords) 
            ->orderBy('date', 'desc')
            ->orderBy('time', 'desc')
            ->get();

        return response()->json([
            'success' => true,
            'data' => $finalResults
        ], 200);

    } catch (\Exception $e) {
        return response()->json([
            'success' => false, 
            'message' => 'Failed to fetch historical database records: ' . $e->getMessage()
        ], 500);
    }
}
}

