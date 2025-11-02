@extends('layouts.app')

@section('content')
<div class="d-flex justify-content-between align-items-center mb-3">
    <h4>TOEIC Scores</h4>
</div>

<table class="table table-bordered bg-white shadow-sm">
    <thead>
        <tr>
            <th>No</th>
            <th>Name</th>
            <th>Test Type</th>
            <th>Score</th>
            <th>Status</th>
            <th>Test Date</th>
            <th>Certificate</th>
            <th>Request Letter</th>
        </tr>
    </thead>
    <tbody>
        @foreach ($scores as $index => $score)
        <tr>
            <td>{{ $index + 1 }}</td>
            <td>{{ $score->user->name ?? '-' }}</td>
            <td><span class="badge bg-info text-dark">{{ ucfirst($score->test_type) }}</span></td>
            <td>{{ $score->score }}</td>
            <td>
                <span class="badge bg-{{ $score->passed ? 'success' : 'danger' }}">
                    {{ $score->passed ? 'Passed' : 'Failed' }}
                </span>
            </td>
            <td>{{ \Carbon\Carbon::parse($score->test_date)->format('d/m/Y') }}</td>
            <td>
                @if ($score->certificate_path)
                    <a href="{{ asset('storage/'.$score->certificate_path) }}" target="_blank">View</a>
                @else
                    -
                @endif
            </td>
            <td>
                @if ($score->request_letter_path)
                    <a href="{{ asset('storage/'.$score->request_letter_path) }}" target="_blank">View</a>
                @else
                    -
                @endif
            </td>
        </tr>
        @endforeach
    </tbody>
</table>
@endsection
