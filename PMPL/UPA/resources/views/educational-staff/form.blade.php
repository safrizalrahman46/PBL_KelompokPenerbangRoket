<div class="mb-3">
    <label>Username</label>
    <input type="text" name="username" class="form-control" value="{{ old('username', $staff->username ?? '') }}" {{ isset($staff) ? 'readonly' : '' }}>
</div>
<div class="mb-3">
    <label>Email</label>
    <input type="email" name="email" class="form-control" value="{{ old('email', $staff->email ?? '') }}">
</div>
{{--  <div class="mb-3">
    <label>NIM</label>
    <input type="text" name="nim" class="form-control" value="{{ old('nim', $staff->nim ?? '') }}">
</div>  --}}
<div class="mb-3">
    <label>Name</label>
    <input type="text" name="name" class="form-control" value="{{ old('name', $staff->name ?? '') }}">
</div>
<div class="mb-3">
    <label>NIK</label>
    <input type="text" name="nik" class="form-control" value="{{ old('nik', $staff->nik ?? '') }}">
</div>
<div class="mb-3">
    <label>Phone</label>
    <input type="text" name="phone" class="form-control" value="{{ old('phone', $staff->phone ?? '') }}">
</div>
<div class="mb-3">
    <label>Origin Address</label>
    <textarea name="origin_address" class="form-control">{{ old('origin_address', $staff->origin_address ?? '') }}</textarea>
</div>
<div class="mb-3">
    <label>Current Address</label>
    <textarea name="current_address" class="form-control">{{ old('current_address', $staff->current_address ?? '') }}</textarea>
</div>
{{--  <div class="mb-3">
    <label>Study Program</label>
    <select name="study_program_id" class="form-select">
        @foreach ($programs as $program)
        <option value="{{ $program->id }}" {{ old('study_program_id', $staff->study_program_id ?? '') == $program->id ? 'selected' : '' }}>{{ $program->name }}</option>
        @endforeach
    </select>
</div>  --}}
{{--  <div class="mb-3">
    <label>Major</label>
    <select name="major_id" class="form-select">
        @foreach ($majors as $major)
        <option value="{{ $major->id }}" {{ old('major_id', $staff->major_id ?? '') == $major->id ? 'selected' : '' }}>{{ $major->name }}</option>
        @endforeach
    </select>
</div>  --}}
{{--  <div class="mb-3">
    <label>Campus</label>
    <select name="campus" class="form-select">
        @foreach (['Main','PSDKU Kediri','PSDKU Lumajang','PSDKU Pamekasan'] as $campus)
        <option value="{{ $campus }}" {{ old('campus', $staff->campus ?? '') == $campus ? 'selected' : '' }}>{{ $campus }}</option>
        @endforeach
    </select>
</div>  --}}
