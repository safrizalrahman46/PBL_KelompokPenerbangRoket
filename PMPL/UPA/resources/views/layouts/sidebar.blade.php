<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
<link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css" rel="stylesheet">

<style>
    .nav-link {
        font-size: 14px;
        padding: 8px 12px;
    }

    small {
        font-size: 11px;
        letter-spacing: 0.5px;
    }
</style>

<div class="d-flex flex-column p-3 bg-white shadow-sm" style="width: 240px; height: 100vh;">
    <!-- Logo -->
    <h5 class="text-primary fw-bold mb-4">UPA</h5>

    <!-- General -->
    <small class="text-uppercase text-muted fw-bold mb-2">General</small>
    <ul class="nav nav-pills flex-column mb-3">
        <li class="nav-item">
            <a href="/dashboard" class="nav-link text-dark">
                <i class="bi bi-house-door me-2"></i> Dashboard
            </a>
        </li>
        <li class="nav-item">
            <a href="/announcement" class="nav-link text-dark">
                <i class="bi bi-megaphone me-2"></i> Announcements
            </a>
        </li>
    </ul>

    <!-- TOEIC -->
    <small class="text-uppercase text-muted fw-bold mb-2 mt-3">TOEIC</small>
    <ul class="nav nav-pills flex-column mb-3">
        {{--  <li class="nav-item"><a href="/admin/student-register" class="nav-link text-dark"><i
                    class="bi bi-pencil-square me-2"></i> Free Student Registrations</a></li>  --}}
         <li class="nav-item"><a href="/students" class="nav-link text-dark"><i
                    class="bi bi-pencil-square me-2"></i> Free Student Registrations</a></li>
        <li class="nav-item"><a href="/toeic-registration/index" class="nav-link text-dark"><i
                    class="bi bi-pencil-square me-2"></i> Paid Student Registrations</a></li>
        {{--  <li class="nav-item"><a href="/educational-staff-registration" class="nav-link text-dark"><i
                    class="bi bi-pencil-square me-2"></i> Educational Staff Registrations</a></li>  --}}
        <li class="nav-item"><a href="/toeic-scores" class="nav-link text-dark"><i
                    class="bi bi-clipboard-data me-2"></i> Scores</a></li>
    </ul>

    <!-- Academic -->
    <small class="text-uppercase text-muted fw-bold mb-2 mt-3">Academic</small>
    <ul class="nav nav-pills flex-column mb-3">
        <li class="nav-item"><a href="/majors" class="nav-link text-dark"><i class="bi bi-diagram-3 me-2"></i>
                Majors</a></li>
        <li class="nav-item"><a href="/study-programs" class="nav-link text-dark"><i
                    class="bi bi-journal-code me-2"></i> Study Programs</a></li>
    </ul>

    <!-- Users -->
    <small class="text-uppercase text-muted fw-bold mb-2 mt-3">Users</small>
    <ul class="nav nav-pills flex-column mb-3">
        <li class="nav-item"><a href="/profile" class="nav-link text-dark"><i class="bi bi-person me-2"></i> User
                Profile</a></li>
    </ul>

    <!-- Footer -->
    {{--  <div class="mt-auto">
        <ul class="nav nav-pills flex-column">
            <li class="nav-item"><a href="/forgot-password" class="nav-link text-dark"><i
                        class="bi bi-shield-lock me-2"></i> Reset Password</a></li>
            <li class="nav-item"><a href="/settings" class="nav-link text-dark"><i class="bi bi-gear me-2"></i>
                    Settings</a></li>

        </ul>
    </div>  --}}

    <!-- Logout -->
    <small class="text-uppercase text-muted fw-bold mb-2 mt-3">Out</small>
    <ul class="nav nav-pills flex-column">
        <li class="nav-item">
            <a href="/logout" class="nav-link text-dark"
                onclick="event.preventDefault(); document.getElementById('logout-form').submit();">
                <i class="bi bi-box-arrow-right me-2"></i> Logout
            </a>
            {{--  <form id="logout-form" action="{{ route('logout') }}" method="POST" style="display: none;">
                @csrf
            </form>  --}}
        </li>
    </ul>

</div>
