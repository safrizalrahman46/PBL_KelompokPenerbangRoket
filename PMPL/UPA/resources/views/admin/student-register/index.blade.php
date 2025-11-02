@extends('layouts.app')

@section('content')
<div class="d-flex justify-content-between align-items-center mb-3">
    <h4>Student Registrations</h4>
    <a href="#" class="btn btn-success">+ Add Student</a>
</div>

<div class="table-responsive">
    <table class="table table-bordered bg-white shadow-sm">
        <thead>
            <tr>
                <th>No</th>
                <th>Username</th>
                <th>Name</th>
                <th>Email</th>
                <th>NIM</th>
                <th>Study Program</th>
                <th>Major</th>
                <th>Campus</th>
                <th>Status</th>
                <th>Reason</th>
                <th>Action</th>
            </tr>
        </thead>
        <tbody>
            @foreach ($students as $index => $student)
            <tr>
                <td>{{ $index + 1 }}</td>
                <td>{{ $student->username }}</td>
                <td>{{ $student->name }}</td>
                <td>{{ $student->email }}</td>
                <td>{{ $student->nim }}</td>
                <td>{{ optional($student->studyProgram)->name }}</td>
                <td>{{ optional($student->major)->name }}</td>
                <td>{{ $student->campus }}</td>
                <td>
                    <span class="badge text-capitalize text-nowrap
                        @if($student->status == 'approved') bg-success
                        @elseif($student->status == 'rejected') bg-danger
                        @else bg-secondary
                        @endif">
                        {{ ucfirst($student->status) }}
                    </span>
                </td>
                <td>
                    {{ $student->status == 'rejected' ? $student->rejection_reason : '-' }}
                </td>
                <td>
                    <a href="#" class="btn btn-sm btn-light"><i class="bi bi-eye"></i></a>
                    <a href="#" class="btn btn-sm btn-light"><i class="bi bi-pencil"></i></a>
                    <a href="#" class="btn btn-sm btn-light"><i class="bi bi-trash"></i></a>
                </td>
            </tr>
            @endforeach
        </tbody>
    </table>
</div>
@endsection
