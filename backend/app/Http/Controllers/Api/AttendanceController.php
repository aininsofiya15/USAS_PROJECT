<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Str;
use Illuminate\Support\Facades\DB;
use App\Models\Attendance;
use App\Models\AttendanceRecord;
use App\Models\ModuleAttendance;

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
    $attendance = DB::table('class_attendances')
        ->join('attendances', 'class_attendances.attendance_id', '=', 'attendances.id')
        ->join('sections', 'class_attendances.section_id', '=', 'sections.section_id')
        ->join('subjects', 'sections.subject_id', '=', 'subjects.subject_id')
        ->where('attendances.id', $id)
        ->select(
            'attendances.*', 
            'class_attendances.*', 
            'subjects.subject_name', 
            'sections.section_no'
        )
        ->first();

    if (!$attendance) {
        return response()->json(['message' => 'Not found'], 404);
    }

    return response()->json($attendance);
}

public function updateAttendanceDetails(Request $request, $id) {
    // Validate to prevent nulls hitting the DB
    $request->validate([
        'geo_lat' => 'required',
        'geo_long' => 'required',
        'lab_name' => 'required',
        'date' => 'required',
        'time' => 'required',
    ]);

    return DB::transaction(function () use ($request, $id) {
        // Update General GPS info
        DB::table('attendances')->where('id', $id)->update([
            'geo_lat' => $request->geo_lat,
            'geo_long' => $request->geo_long,
            'updated_at' => now(),
        ]);

        // Update Class details
        DB::table('class_attendances')->where('attendance_id', $id)->update([
            'class_type' => $request->lab_name,
            'date' => $request->date,
            'time' => $request->time,
            'updated_at' => now(),
        ]);

        return response()->json(['success' => true]);
    });
}
public function getStudentAttendance($id)
{
    // Fetch students linked to this attendance session
    $records = DB::table('attendance_records')
        ->join('students', 'attendance_records.student_id', '=', 'students.student_id')
        ->join('users', 'students.user_id', '=', 'users.id')
        ->where('attendance_records.attendance_id', $id)
        ->select(
            'attendance_records.id as record_id',
            'students.matric_no', // Or student_id depending on your column name
            'users.name as student_name',
            'attendance_records.status',
            'attendance_records.updated_at as check_in_time'
        )
        ->get();

    return response()->json($records);
}

public function getNotPresentStudents($attendanceId, $sectionId)
{
    // 1. Get IDs of students who ARE present
    $presentStudentIds = DB::table('attendance_records')
        ->where('attendance_id', $attendanceId)
        ->pluck('student_id');

    // 2. Get students in this section who are NOT in that list
    $notPresent = DB::table('section_student') // Assuming this is your pivot table name
        ->join('students', 'section_student.student_id', '=', 'students.student_id')
        ->join('users', 'students.user_id', '=', 'users.id')
        ->where('section_student.section_id', $sectionId)
        ->whereNotIn('students.student_id', $presentStudentIds)
        ->select('students.student_id as matric_no', 'users.name as student_name')
        ->get();

    return response()->json($notPresent);
}


    /**
     * Fetch attendance details for a specific Pusat ADAB module session.
     * This follows the logic: Booking -> ModuleAttendance -> Attendance -> Records.
     */
    public function getPusatAdabAttendance($bookingId)
    {
        // 1. Find the bridge record linked to your specific booking
        // We load 'attendance' for the session info and 'booking.module' for the name
        $moduleSession = ModuleAttendance::where('booking_id', $bookingId)
            ->with(['attendance', 'booking.module'])
            ->first();

        if (!$moduleSession) {
            return response()->json([
                'message' => 'No attendance session found for this module.'
            ], 404);
        }

        // 2. Fetch the student list from the shared records table
        // We include 'student.user' to get their Name and Matric ID for your Flutter list
        $records = AttendanceRecord::where('attendance_id', $moduleSession->attendance_id)
            ->with(['student.user'])
            ->get();

        // 3. Format the response for your Flutter AttendanceSubject and AttendanceRecord domains
        return response()->json([
            'header' => [
                'id' => $moduleSession->booking->module->id,
                'activity_name' => $moduleSession->booking->module->activity_name,
                'venue' => $moduleSession->booking->module->venue,
                'date_time' => $moduleSession->attendance->created_at->format('d/m/Y h:i A'),
                'lecturer_name' => $moduleSession->booking->module->lecturer->user->name,
            ],

            'records' => $records->map(function ($record) {
                return [
                    'id' => $record->id,
                    'student_id' => $record->student->student_id,
                    'student_name' => $record->student->user->name,
                    'status' => $record->status,
                    'marks' => $record->marks,
                    'grade_category' => $record->grade_category,
                ];
            })
        ]);
    }
    /**
     * Update a student's grade/marks from the Flutter "Grade" button.
     */
    public function updateGrade(Request $request, $recordId)
    {
        $request->validate([
            'marks' => 'required|numeric|min:0|max:100',
        ]);

        $record = AttendanceRecord::findOrFail($recordId);
        $record->update([
            'marks' => $request->marks,
            // Logic to auto-assign category based on marks if needed
            'grade_category' => $request->marks >= 50 ? 'Pass' : 'Fail', 
        ]);

        return response()->json([
            'message' => 'Grade updated successfully',
            'record' => $record
        ]);
    }
}