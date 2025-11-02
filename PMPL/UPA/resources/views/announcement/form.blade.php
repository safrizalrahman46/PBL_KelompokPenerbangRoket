@php
    $a = $announcement ?? null;
@endphp

<div class="mb-3">
    <label>Title</label>
    <input type="text" name="title" class="form-control" value="{{ old('title', $a->title ?? '') }}" required>
</div>

<div class="mb-3">
    <label>Content</label>
    <textarea name="content" class="form-control" rows="5" required>{{ old('content', $a->content ?? '') }}</textarea>
</div>

<div class="mb-3">
    <label>Type</label>
    <select name="type" class="form-control" id="type" required>
        @foreach (['test_schedule', 'test_result', 'certificate', 'general'] as $type)
            <option value="{{ $type }}" {{ old('type', $a->type ?? '') === $type ? 'selected' : '' }}>
                {{ ucfirst(str_replace('_', ' ', $type)) }}
            </option>
        @endforeach
    </select>
</div>

<div class="mb-3">
    <label>Target Audience</label>
    <select name="target_audience" class="form-control" required>
        @foreach (['student', 'admin', 'all'] as $target)
            <option value="{{ $target }}" {{ old('target_audience', $a->target_audience ?? '') === $target ? 'selected' : '' }}>
                {{ ucfirst($target) }}
            </option>
        @endforeach
    </select>
</div>

<div class="mb-3">
    <label>Event Date</label>
    <input type="date" name="event_date" class="form-control" id="event_date"
        value="{{ old('event_date', isset($a->event_date) ? $a->event_date->format('Y-m-d') : '') }}">
</div>

<div class="mb-3">
    <label>Pickup Certificate</label>
    <input type="date" name="pickup_certificate" class="form-control" id="pickup_certificate"
        value="{{ old('pickup_certificate', isset($a->pickup_certificate) ? $a->pickup_certificate->format('Y-m-d') : '') }}">
</div>
