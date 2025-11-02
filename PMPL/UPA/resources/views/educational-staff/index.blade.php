@extends('layouts.app')

@section('content')
<div class="d-flex justify-content-between align-items-center mb-3">
    <h4>Educational Staff</h4>
    <a href="{{ route('educational-staff.create') }}" class="btn btn-success">+ Add Staff</a>
</div>

<div class="table-responsive">
    <table class="table table-bordered bg-white shadow-sm">
        <thead>
            <tr>
                <th>No</th>
                <th>Username</th>
                <th>Name</th>
                <th>Email</th>
                <th>NIK</th>
                <th>Origin Address</th>
                <th>Current Address</th>
                {{--  <th>NIM</th>  --}}
                {{--  <th>Study Program</th>  --}}
                {{--  <th>Major</th>  --}}
                {{--  <th>Campus</th>  --}}
                <th>Action</th>
            </tr>
        </thead>
        <tbody>
            @foreach ($staffs as $index => $staff)
            <tr>
                <td>{{ $index + 1 }}</td>
                <td>{{ $staff->username }}</td>
                <td>{{ $staff->name }}</td>
                <td>{{ $staff->email }}</td>
                <td>{{ $staff->nik }}</td>
                <td>{{ $staff->origin_address }}</td>
                {{--  <td>{{ $staff->nim }}</td>  --}}
                {{--  <td>{{ optional($staff->studyProgram)->name }}</td>  --}}
                {{--  <td>{{ optional($staff->major)->name }}</td>  --}}
                {{--  <td>{{ $staff->campus }}</td>  --}}
                <td>
                    <a href="{{ route('educational-staff.show', $staff->id) }}" class="btn btn-sm btn-light"><i class="bi bi-eye"></i></a>
                    <a href="{{ route('educational-staff.edit', $staff->id) }}" class="btn btn-sm btn-light"><i class="bi bi-pencil"></i></a>
                    <form action="{{ route('educational-staff.destroy', $staff->id) }}" method="POST" style="display:inline;">
                        @csrf
                        @method('DELETE')
                        <button type="submit" onclick="return confirm('Are you sure?')" class="btn btn-sm btn-light"><i class="bi bi-trash"></i></button>
                    </form>
                </td>
            </tr>
            @endforeach
        </tbody>
    </table>
</div>
@endsection
