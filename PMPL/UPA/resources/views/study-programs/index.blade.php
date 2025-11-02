@extends('layouts.app')

@section('content')
<div class="d-flex justify-content-between mb-3">
    <h4>Study Programs</h4>
    <a href="{{ route('study-programs.create') }}" class="btn btn-success">+ Add Study Program</a>
</div>

@if (session('success'))
    <div class="alert alert-success">{{ session('success') }}</div>
@endif

<table class="table table-bordered bg-white shadow-sm">
    <thead>
        <tr>
            <th>No</th>
            <th>Name</th>
            <th>Code</th>
            <th>Action</th>
        </tr>
    </thead>
    <tbody>
        @foreach ($programs as $index => $program)
        <tr>
            <td>{{ $index + 1 }}</td>
            <td>{{ $program->name }}</td>
            <td>{{ $program->code ?? '-' }}</td>
            <td>
                <a href="{{ route('study-programs.edit', $program->id) }}" class="btn btn-sm btn-light"><i class="bi bi-pencil"></i></a>
                <form action="{{ route('study-programs.destroy', $program->id) }}" method="POST" class="d-inline" onsubmit="return confirm('Delete this item?')">
                    @csrf
                    @method('DELETE')
                    <button class="btn btn-sm btn-light"><i class="bi bi-trash"></i></button>
                </form>
            </td>
        </tr>
        @endforeach
    </tbody>
</table>
@endsection
