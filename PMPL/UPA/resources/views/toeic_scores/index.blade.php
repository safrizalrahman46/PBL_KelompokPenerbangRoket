@extends('layouts.app')

@section('content')
<div class="container">
    <h2>Daftar TOEIC PDFs</h2>
    <a href="{{ route('toeic-scores.create') }}" class="btn btn-primary mb-3">Unggah PDF</a>

    @if(session('success'))
        <div class="alert alert-success">{{ session('success') }}</div>
    @endif

    <table class="table table-bordered">
        <thead>
            <tr>
                <th>ID</th>
                <th>PDF</th>
                <th>Diunggah Pada</th>
                <th>Aksi</th>
            </tr>
        </thead>
        <tbody>
            @foreach($toeicScores as $score)
                <tr>
                    <td>{{ $score->id }}</td>
                    <td><a href="{{ asset('storage/' . $score->pdf) }}" target="_blank">Lihat PDF</a></td>
                    <td>{{ $score->created_at->format('d-m-Y H:i') }}</td>
                    <td>
                        <a href="{{ route('toeic-scores.show', $score->id) }}" class="btn btn-info btn-sm">Detail</a>
                        <a href="{{ route('toeic-scores.edit', $score->id) }}" class="btn btn-warning btn-sm">Edit</a>
                        <form action="{{ route('toeic-scores.destroy', $score->id) }}" method="POST" style="display:inline">
                            @csrf @method('DELETE')
                            <button onclick="return confirm('Yakin ingin menghapus?')" class="btn btn-danger btn-sm">Hapus</button>
                        </form>
                    </td>
                </tr>
            @endforeach
        </tbody>
    </table>
</div>
@endsection
