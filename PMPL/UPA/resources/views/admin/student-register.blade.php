@extends('layouts.app')

@section('content')
<div class="container py-4">
    <h3>Admin Mahasiswa Registration</h3>

    @if(session('success'))
        <div class="alert alert-success">{{ session('success') }}</div>
    @endif

    <form action="{{ route('admin.student.register.store') }}" method="POST">
        @csrf

        <div class="row g-3">
            <div class="col-md-6">
                <label>Username</label>
                <input type="text" name="username" class="form-control" required>
            </div>
            <div class="col-md-6">
                <label>Email</label>
                <input type="email" name="email" class="form-control" required>
            </div>
            <div class="col-md-6">
                <label>Password</label>
                <input type="password" name="password" class="form-control" required>
            </div>
            <div class="col-md-6">
                <label>Confirm Password</label>
                <input type="password" name="password_confirmation" class="form-control" required>
            </div>
            <div class="col-md-6">
                <label>NIM</label>
                <input type="text" name="nim" class="form-control" required>
            </div>
            <div class="col-md-6">
                <label>Nama Lengkap</label>
                <input type="text" name="name" class="form-control" required>
            </div>
            <div class="col-md-6">
                <label>NIK</label>
                <input type="text" name="nik" class="form-control" required>
            </div>
            <div class="col-md-6">
                <label>No. Telepon</label>
                <input type="text" name="phone" class="form-control" required>
            </div>
            <div class="col-md-6">
                <label>Alamat Asal</label>
                <textarea name="origin_address" class="form-control" required></textarea>
            </div>
            <div class="col-md-6">
                <label>Alamat Sekarang</label>
                <textarea name="current_address" class="form-control" required></textarea>
            </div>
            <div class="col-md-6">
                <label>Program Studi</label>
                <select name="study_program_id" class="form-control" required>
                    @foreach ($studyPrograms as $program)
                        <option value="{{ $program->id }}">{{ $program->name }}</option>
                    @endforeach
                </select>
            </div>
            <div class="col-md-6">
                <label>Jurusan</label>
                <select name="major_id" class="form-control" required>
                    @foreach ($majors as $major)
                        <option value="{{ $major->id }}">{{ $major->name }}</option>
                    @endforeach
                </select>
            </div>
            <div class="col-md-6">
                <label>Kampus</label>
                <select name="campus" class="form-control" required>
                    <option value="Main">Main</option>
                    <option value="PSDKU Kediri">PSDKU Kediri</option>
                    <option value="PSDKU Lumajang">PSDKU Lumajang</option>
                    <option value="PSDKU Pamekasan">PSDKU Pamekasan</option>
                </select>
            </div>
        </div>

        <div class="mt-3">
            <button class="btn btn-primary">Daftarkan Mahasiswa</button>
        </div>
    </form>
</div>
@endsection
