@extends('layouts.app')

@section('content')
<div class="container">
    <h2>Daftar Jurusan</h2>
    <a href="{{ route('majors.create') }}" class="btn btn-primary mb-3">Tambah Jurusan</a>

    @if(session('success'))
    <div class="alert alert-success">{{ session('success') }}</div>
    @endif

    <table class="table table-bordered">
        <thead>
            <tr>
                <th>ID</th>
                <th>Nama</th>
                <th>Kode</th>
                <th>Aksi</th>
            </tr>
        </thead>
        <tbody>
            @foreach($majors as $major)
            <tr>
                <td>{{ $major->id }}</td>
                <td>{{ $major->name }}</td>
                <td>{{ $major->code ?? '-' }}</td>
                <td>
                    <a href="{{ route('majors.show', $major->id) }}" class="btn btn-sm btn-light" title="Detail">
                        <i class="bi bi-eye"></i>
                    </a>
                    <a href="{{ route('majors.edit', $major->id) }}" class="btn btn-sm btn-light" title="Edit">
                        <i class="bi bi-pencil"></i>
                    </a>
                    <form action="{{ route('majors.destroy', $major->id) }}" method="POST" style="display:inline;">
                        @csrf
                        @method('DELETE')
                        <button type="submit" onclick="return confirm('Yakin ingin menghapus jurusan ini?')"
                            class="btn btn-sm btn-light" title="Hapus">
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
