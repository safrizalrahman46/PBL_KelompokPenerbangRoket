@extends('layouts.app')

@section('content')
<h4>Add Announcement</h4>

<form action="{{ route('announcement.store') }}" method="POST">
    @csrf
    @include('announcement.form')
    <button type="submit" class="btn btn-primary">Save</button>
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
