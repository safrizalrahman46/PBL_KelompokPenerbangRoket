@extends('layouts.app')

@section('content')
<div class="container mt-4">
    <div class="row justify-content-center">
        <div class="col-md-10">
            <div class="card shadow-sm">
                <div class="card-header bg-white">
                    <h5 class="mb-0">Free TOEIC Exam Registration Form</h5>
                </div>
                <div class="card-body">
                    @if (session('success'))
                        <div class="alert alert-success">{{ session('success') }}</div>
                    @endif

                    <form method="POST" action="{{ route('free-toeic.register') }}" enctype="multipart/form-data">
                        @csrf

                        <div class="row">
                            <div class="col-md-6 mb-3">
                                <label for="nim" class="form-label">Student ID (NIM)</label>
                                <input type="text" class="form-control" id="nim" name="nim" required>
                            </div>
                            <div class="col-md-6 mb-3">
                                <label for="name" class="form-label">Full Name</label>
                                <input type="text" class="form-control" id="name" name="name" required>
                            </div>
                            <div class="col-md-6 mb-3">
                                <label for="nik" class="form-label">National ID Number (NIK)</label>
                                <input type="text" class="form-control" id="nik" name="nik" required>
                            </div>
                            <div class="col-md-6 mb-3">
                                <label for="phone" class="form-label">Phone Number</label>
                                <input type="text" class="form-control" id="phone" name="phone" required>
                            </div>
                            <div class="col-md-6 mb-3">
                                <label for="origin_address" class="form-label">Permanent Address</label>
                                <textarea class="form-control" id="origin_address" name="origin_address" rows="2" required></textarea>
                            </div>
                            <div class="col-md-6 mb-3">
                                <label for="current_address" class="form-label">Current Address</label>
                                <textarea class="form-control" id="current_address" name="current_address" rows="2" required></textarea>
                            </div>
                            <div class="col-md-6 mb-3">
                                <label for="study_program" class="form-label">Study Program</label>
                                <input type="text" class="form-control" id="study_program" name="study_program" required>
                            </div>
                            <div class="col-md-6 mb-3">
                                <label for="department" class="form-label">Department</label>
                                <input type="text" class="form-control" id="department" name="department" required>
                            </div>
                            <div class="col-md-6 mb-3">
                                <label for="campus" class="form-label">Campus</label>
                                <select class="form-select" id="campus" name="campus" required>
                                    <option value="">-- Select Campus --</option>
                                    <option value="Main">Main</option>
                                    <option value="PSDKU Kediri">PSDKU Kediri</option>
                                    <option value="PSDKU Lumajang">PSDKU Lumajang</option>
                                    <option value="PSDKU Pamekasan">PSDKU Pamekasan</option>
                                </select>
                            </div>
                            <div class="col-md-6 mb-3">
                                <label for="photo" class="form-label">Profile Photo (optional)</label>
                                <input type="file" class="form-control" id="photo" name="photo">
                            </div>
                            <div class="col-md-6 mb-3">
                                <label for="id_card" class="form-label">Upload National ID Card (KTP)</label>
                                <input type="file" class="form-control" id="id_card" name="id_card" required>
                            </div>
                            <div class="col-md-6 mb-3">
                                <label for="student_card" class="form-label">Upload Student Card (KTM)</label>
                                <input type="file" class="form-control" id="student_card" name="student_card" required>
                            </div>
                        </div>

                        <button type="submit" class="btn btn-primary">Register for Free Exam</button>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>
@endsection
