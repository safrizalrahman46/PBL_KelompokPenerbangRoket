@extends('layouts.app')

@section('content')
<div class="container">
    <h2>Detail Jurusan</h2>
    <p><strong>ID:</strong> {{ $major->id }}</p>
    <p><strong>Nama:</strong> {{ $major->name }}</p>
    <p><strong>Kode:</strong> {{ $major->code ?? '-' }}</p>
    <a href="{{ route('majors.index') }}" class="btn btn-secondary">Kembali</a>
</div>
@endsection
