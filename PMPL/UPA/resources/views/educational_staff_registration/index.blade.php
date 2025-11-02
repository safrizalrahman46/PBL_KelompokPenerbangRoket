@extends('layouts.app')

@section('content')
<div class="container">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h3>Educational Staff Registration</h3>
        <a href="{{ route('educational-staff-registration.create') }}" class="btn btn-success">
            + Register New Staff
        </a>
    </div>

    <table class="table table-bordered table-striped">
        <thead>
            <tr>
                <th>NIK</th>
                <th>Name</th>
                <th>Phone</th>
                {{-- <th>Status</th> --}}
                <th>Photo</th>
                <th>ID Card</th>
                <th>Registered At</th>
                <th>Actions</th>
            </tr>
        </thead>
        <tbody>
            @foreach ($staffs as $staff)
            <tr>
                <td>{{ $staff->nik }}</td>
                <td>{{ $staff->name }}</td>
                <td>{{ $staff->phone }}</td>
                {{-- <td>
                    @if ($staff->status == 'pending')
                    <span class="badge bg-warning text-dark">Pending</span>
                    @elseif ($staff->status == 'approved')
                    <span class="badge bg-success">Approved</span>
                    @elseif ($staff->status == 'rejected')
                    <span class="badge bg-danger">Rejected</span>
                    @else
                    {{ $staff->status }}
                    @endif
                </td> --}}
                <td>
                    @if ($staff->photo_path)
                    <a href="{{ asset('storage/' . $staff->photo_path) }}" target="_blank">View</a>
                    @else
                    -
                    @endif
                </td>
                <td>
                    @if ($staff->id_card_path)
                    <a href="{{ asset('storage/' . $staff->id_card_path) }}" target="_blank">View</a>
                    @else
                    -
                    @endif
                </td>
                <td>{{ $staff->created_at->format('d M Y, H:i') }}</td>
                <td>
                    <a href="{{ route('educational-staff-registration.show', $staff->id) }}"
                        class="btn btn-sm btn-light" title="View">
                        <i class="bi bi-eye"></i>
                    </a>
                    <a href="{{ route('educational-staff-registration.edit', $staff->id) }}"
                        class="btn btn-sm btn-light" title="Edit">
                        <i class="bi bi-pencil"></i>
                    </a>
                    <form action="{{ route('educational-staff-registration.destroy', $staff->id) }}" method="POST"
                        style="display:inline;">
                        @csrf
                        @method('DELETE')
                        <button type="submit" onclick="return confirm('Are you sure you want to delete this staff?')"
                            class="btn btn-sm btn-light" title="Delete">
                            <i class="bi bi-trash"></i>
                        </button>
                    </form>
                </td>

            </tr>
            @endforeach
        </tbody>
    </table>
</div>
@endsection
