@extends('layouts.app')

@section('content')
<div class="container">
    <h2>Tambah Jurusan</h2>
    <form action="{{ route('majors.store') }}" method="POST">
        @csrf
        <div class="mb-3">
            <label for="name" class="form-label">Nama Jurusan</label>
            <input type="text" name="name" class="form-control" required>
            @error('name') <small class="text-danger">{{ $message }}</small> @enderror
        </div>
        <div class="mb-3">
            <label for="code" class="form-label">Kode (Opsional)</label>
            <input type="text" name="code" class="form-control">
            @error('code') <small class="text-danger">{{ $message }}</small> @enderror
        </div>
        <button class="btn btn-success">Simpan</button>
    </form>
</div>
@endsection
