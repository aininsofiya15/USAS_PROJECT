$subject = Subject::create([

    'subject_name' =>
        $request->subject_name,

    'subject_code' =>
        $request->subject_code,

    'credit_hours' =>
        $request->credit_hours,

    'total_section' =>
        $request->total_section,

    'total_lab' => 0,

    'subject_status' => 'Active',
]);