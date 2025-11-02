@extends('layouts.app')

@section('content')
<div class="container">
    <h2>Edit Jurusan</h2>
    <form action="{{ route('majors.update', $major->id) }}" method="POST">
        @csrf @method('PUT')
        <div class="mb-3">
            <label for="name" class="form-label">Nama Jurusan</label>
            <input type="text" name="name" class="form-control" value="{{ $major->name }}" required>
            @error('name') <small class="text-danger">{{ $message }}</small> @enderror
        </div>
        <div class="mb-3">
            <label for="code" class="form-label">Kode</label>
            <input type="text" name="code" class="form-control" value="{{ $major->code }}">
            @error('code') <small class="text-danger">{{ $message }}</small> @enderror
        </div>
        <button class="btn btn-primary">Perbarui</button>
    </form>
</div>
@endsection
