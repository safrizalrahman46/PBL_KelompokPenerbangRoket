@extends('layouts.app')

@section('content')
<h4>Edit Announcement</h4>

<form action="{{ route('announcement.update', $announcement->id) }}" method="POST">
    @csrf
    @method('PUT')
    @include('announcement.form', ['announcement' => $announcement])
    <button type="submit" class="btn btn-primary">Update</button>
    <a href="{{ route('announcement.index') }}" class="btn btn-secondary">Back</a>
</form>
@endsection

@push('scripts')
<script>
document.addEventListener('DOMContentLoaded', function () {
    const typeSelect = document.getElementById('type');
    const eventDate = document.getElementById('event_date');
    const pickupCert = document.getElementById('pickup_certificate');

    function toggleFields() {
        const selectedType = typeSelect.value;

        if (selectedType === 'certificate') {
            eventDate.disabled = true;
            pickupCert.disabled = false;
        } else {
            eventDate.disabled = false;
            pickupCert.disabled = true;
        }
    }

    toggleFields();
    typeSelect.addEventListener('change', toggleFields);
});
</script>
@endpush
