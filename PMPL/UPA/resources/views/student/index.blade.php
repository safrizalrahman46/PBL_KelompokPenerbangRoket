@extends('layouts.app')

@section('content')
    <div class="d-flex justify-content-between align-items-center mb-3">
        <h4>TOEIC Registration & Test Status</h4>
        <button class="btn btn-success">+ Add Participant</button>
    </div>

    <div class="input-group mb-3">
        <input type="text" class="form-control" placeholder="Search by NIM or Name">
        <button class="btn btn-outline-secondary">Filter</button>
        <button class="btn btn-outline-secondary">Sort By</button>
    </div>

    <table class="table table-bordered bg-white shadow-sm">
        <thead class="table-light">
            <tr>
                <th>No</th>
                <th>NIM</th>
                <th>Name</th>
                <th>Type</th>
                <th>Registration Status</th>
                <th>Payment Status</th>
                <th>Test Status</th>
                <th>Score</th>
                <th>Action</th>
            </tr>
        </thead>
        <tbody>
            @foreach ($students as $index => $s)
            <tr>
                <td>{{ $index + 1 }}</td>
                <td>{{ $s->nim }}</td>
                <td>{{ $s->name }}</td>
                <td>
                    @if ($s->type)
                        <span class="badge bg-primary">{{ ucfirst($s->type) }}</span>
                    @else
                        <span class="text-muted">-</span>
                    @endif
                </td>
                <td>
                    @if ($s->registered)
                        <span class="badge bg-success">Registered</span>
                    @else
                        <span class="badge bg-secondary">Not Registered</span>
                    @endif
                </td>
                <td>
                    @if ($s->type === 'paid')
                        @if ($s->payment_status === 'Paid')
                            <span class="badge bg-success">Paid</span>
                        @else
                            <span class="badge bg-warning text-dark">{{ $s->payment_status ?? 'Pending' }}</span>
                        @endif
                    @else
                        <span class="text-muted">-</span>
                    @endif
                </td>
                <td>
                    @if ($s->tested)
                        <span class="badge bg-info">✔ Tested</span>
                    @else
                        <span class="badge bg-danger">✖ Not Tested</span>
                    @endif
                </td>
                <td>{{ $s->score ?? '-' }}</td>
                <td>
                    <button class="btn btn-sm btn-light"><i class="bi bi-eye"></i></button>
                    <button class="btn btn-sm btn-light"><i class="bi bi-trash"></i></button>
                    <button class="btn btn-sm btn-light"><i class="bi bi-pencil"></i></button>
                </td>
            </tr>
            @endforeach
        </tbody>
    </table>
@endsection
    