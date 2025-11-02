@extends('layouts.app')

@section('content')
<div class="container">
    <h3>Study Programs</h3>
    <a href="{{ route('study-programs.create') }}" class="btn btn-primary mb-2">Add Study Program</a>
    @if (session('success')) <div class="alert alert-success">{{ session('success') }}</div> @endif

    <table class="table table-bordered">
        <thead>
            <tr><th>ID</th><th>Name</th><th>Code</th><th>Actions</th></tr>
        </thead>
        <tbody>
            @foreach($programs as $program)
            <tr>
                <td>{{ $program->id }}</td>
                <td>{{ $program->name }}</td>
                <td>{{ $program->code }}</td>
                <td>
                    <a href="{{ route('study-programs.show', $program->id) }}" class="btn btn-sm btn-light" title="View"><i class="bi bi-eye"></i></a>
                    <a href="{{ route('study-programs.edit', $program->id) }}" class="btn btn-sm btn-light" title="Edit"><i class="bi bi-pencil"></i></a>
                    <form action="{{ route('study-programs.destroy', $program->id) }}" method="POST" style="display:inline;">
                        @csrf @method('DELETE')
                        <button type="submit" class="btn btn-sm btn-light" onclick="return confirm('Delete this study program?')">
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
