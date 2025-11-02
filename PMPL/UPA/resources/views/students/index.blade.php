@extends('layouts.app')

@section('content')
<div class="container">
    <h3>Free Student Registration</h3>
       <div class="d-flex justify-content-end mb-3">
        <a href="{{ route('students.create') }}" class="btn btn-success">
            <i class="bi bi-plus-circle"></i> Add Student
        </a>
    </div>
    @include('partials.flash')

    <table class="table table-bordered table-striped">
        <thead>
            <tr>
                <th>Username</th>
                <th>NIM</th>
                <th>Name</th>
                <th>Email</th>
                <th>NIK</th>
                <th>Phone</th>
                <th>Address</th>
                <th>Study Program</th>
                <th>Major</th>
                <th>Campus</th>
                <th>Photo</th>
                <th>ID Card</th>
                <th>Student Card</th>
                <th>Status</th>
                <th>Rejection Reason</th>
                <th>Actions</th>
            </tr>
        </thead>
        <tbody>
            @forelse ($students as $student)
            <tr>
                <td>{{ $student->username }}</td>
                <td>{{ $student->nim }}</td>
                <td>{{ $student->name }}</td>
                <td>{{ $student->email }}</td>
                <td>{{ $student->nik }}</td>
                <td>{{ $student->phone }}</td>
                <td>{{ $student->origin_address }}</td>
                <td>{{ $student->studyProgram->name ?? '-' }}</td>
                <td>{{ $student->major->name ?? '-' }}</td>
                <td>{{ $student->campus ?? '-' }}</td>
                <td>@if($student->photo_path) <a href="{{ Storage::url($student->photo_path) }}" target="_blank">View</a> @else - @endif</td>
                <td>@if($student->id_card_path) <a href="{{ Storage::url($student->id_card_path) }}" target="_blank">View</a> @else - @endif</td>
                <td>@if($student->student_card_path) <a href="{{ Storage::url($student->student_card_path) }}" target="_blank">View</a> @else - @endif</td>
                <td>
                    <span class="badge text-capitalize text-nowrap
                        @if($student->status == 'approved') bg-success
                        @elseif($student->status == 'pending') bg-warning text-dark
                        @elseif($student->status == 'rejected') bg-danger
                        @else bg-secondary
                        @endif">
                        {{ $student->status ?? '-' }}
                    </span>
                </td>
                <td>{{ $student->rejection_reason ?? '-' }}</td>
                <td>
                    <a href="{{ route('students.edit', $student->id) }}" class="btn btn-sm btn-light">
                        <i class="bi bi-pencil"></i>
                    </a>
                    <form action="{{ route('students.destroy', $student->id) }}" method="POST" class="d-inline" onsubmit="return confirm('Delete this student?')">
                        @csrf @method('DELETE')
                        <button type="submit" class="btn btn-sm btn-light">
                            <i class="bi bi-trash"></i>
                        </button>
                    </form>
                </td>
            </tr>
            @empty
            <tr><td colspan="16" class="text-center">No students found.</td></tr>
            @endforelse
        </tbody>
    </table>
</div>
@endsection
