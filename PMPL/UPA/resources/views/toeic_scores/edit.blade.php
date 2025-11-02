@extends('layouts.app')

@section('content')
<div class="container">
    <h2>Edit PDF TOEIC</h2>
    <form action="{{ route('toeic-scores.update', $toeicScore->id) }}" method="POST" enctype="multipart/form-data">
        @csrf @method('PUT')
        <div class="mb-3">
            <label class="form-label">PDF Saat Ini:</label><br>
            <a href="{{ asset('storage/' . $toeicScore->pdf) }}" target="_blank">Lihat PDF</a>
        </div>
        <div class="mb-3">
            <label for="pdf" class="form-label">Upload PDF Baru (Opsional)</label>
            <input type="file" class="form-control" name="pdf">
            @error('pdf') <small class="text-danger">{{ $message }}</small> @enderror
        </div>
        <button class="btn btn-primary">Perbarui</button>
    </form>
</div>
@endsection
