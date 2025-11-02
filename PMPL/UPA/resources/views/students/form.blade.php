@php $s = $student ?? null; @endphp

<div class="mb-3">
    <label>Username</label>
    <input type="text" name="username" class="form-control" value="{{ old('username', $s->username ?? '') }}" required>
</div>

<div class="mb-3">
    <label>NIM</label>
    <input type="text" name="nim" class="form-control" value="{{ old('nim', $s->nim ?? '') }}" required>
</div>

<div class="mb-3">
    <label>Name</label>
    <input type="text" name="name" class="form-control" value="{{ old('name', $s->name ?? '') }}" required>
</div>

<div class="mb-3">
    <label>Email</label>
    <input type="email" name="email" class="form-control" value="{{ old('email', $s->email ?? '') }}" required>
</div>

<div class="mb-3">
    <label>NIK</label>
    <input type="text" name="nik" class="form-control" value="{{ old('nik', $s->nik ?? '') }}">
</div>

<div class="mb-3">
    <label>Phone</label>
    <input type="text" name="phone" class="form-control" value="{{ old('phone', $s->phone ?? '') }}">
</div>

<div class="mb-3">
    <label>Address</label>
    <textarea name="origin_address" class="form-control" rows="2">{{ old('origin_address', $s->origin_address ?? '') }}</textarea>
</div>

<div class="mb-3">
    <label>Study Program</label>
    <select name="study_program_id" class="form-control" required>
        <option value="">-- Choose --</option>
        @foreach ($studyPrograms as $program)
        <option value="{{ $program->id }}" {{ old('study_program_id', $s->study_program_id ?? '') == $program->id ? 'selected' : '' }}>
            {{ $program->name }}
        </option>
        @endforeach
    </select>
</div>

<div class="mb-3">
    <label>Major</label>
    <select name="major_id" class="form-control" required>
        <option value="">-- Choose --</option>
        @foreach ($majors as $major)
        <option value="{{ $major->id }}" {{ old('major_id', $s->major_id ?? '') == $major->id ? 'selected' : '' }}>
            {{ $major->name }}
        </option>
        @endforeach
    </select>
</div>

<div class="mb-3">
    <label>Campus</label>
    <select name="campus" class="form-control">
        <option value="">-- Select Campus --</option>
        @foreach (['Main', 'PSDKU Kediri', 'PSDKU Lumajang', 'PSDKU Pamekasan'] as $campus)
            <option value="{{ $campus }}" {{ old('campus', $s->campus ?? '') == $campus ? 'selected' : '' }}>{{ $campus }}</option>
        @endforeach
    </select>
</div>

<div class="mb-3">
    <label>Photo (optional)</label>
    <input type="file" name="photo_path" class="form-control">
    @if(isset($s->photo_path))
        <small class="d-block mt-1"><a href="{{ Storage::url($s->photo_path) }}" target="_blank">Current Photo</a></small>
    @endif
</div>

<div class="mb-3">
    <label>ID Card (optional)</label>
    <input type="file" name="id_card_path" class="form-control">
    @if(isset($s->id_card_path))
        <small class="d-block mt-1"><a href="{{ Storage::url($s->id_card_path) }}" target="_blank">Current ID Card</a></small>
    @endif
</div>

<div class="mb-3">
    <label>Student Card (optional)</label>
    <input type="file" name="student_card_path" class="form-control">
    @if(isset($s->student_card_path))
        <small class="d-block mt-1"><a href="{{ Storage::url($s->student_card_path) }}" target="_blank">Current Student Card</a></small>
    @endif
</div>
