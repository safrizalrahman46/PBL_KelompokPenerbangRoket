<?php

use App\Http\Controllers\AboutController;
use App\Http\Controllers\AdminController;
use App\Http\Controllers\AnnouncementController;
use App\Http\Controllers\AuthController;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\HomeController;
use App\Http\Controllers\DashboardController;
use App\Http\Controllers\FaqController;
use App\Http\Controllers\ForgotPasswordController;
use App\Http\Controllers\LoginController;
use App\Http\Controllers\ResetPasswordController;
use App\Http\Controllers\SignupController;
use App\Http\Controllers\PaidToeicController;
use App\Http\Controllers\FreeToeicController;
use App\Http\Controllers\AdminRegistrationController;
use App\Http\Controllers\EducationalStaffController;
use App\Http\Controllers\EducationalStaffRegistrationController;
use App\Http\Controllers\MajorController;
use App\Http\Controllers\StudyProgramController;
use App\Http\Controllers\ToeicScoreController;
use App\Http\Controllers\ToeicRegistrationController;
use App\Http\Controllers\StudentUserController;
// use App\Http\Controllers\EducationalStaffController;

use App\Http\Controllers\ProfileController;





Route::get('/', [HomeController::class, 'index'])->name('home');
Route::get('/dashboard', [DashboardController::class, 'index'])->name('dashboard');

Route::get('/dashboard', [DashboardController::class, 'index']);
Route::get('/about', [AboutController::class, 'index'])->name('about');
Route::get('/faq', [FaqController::class, 'index'])->name('faq');
Route::get('/login', [AuthController::class, 'index'])->name('login');
Route::post('/login', [AuthController::class, 'postlogin'])->name('login.post');

Route::get('/signup', [SignupController::class, 'index'])->name('signup.index');
Route::post('/signup', [SignupController::class, 'store'])->name('signup.store');
Route::get('/reset', [ResetPasswordController::class, 'index'])->name('reset');
Route::get('/dashboard', [DashboardController::class, 'index'])->name('dashboard');

// Route::get('/admin/dashboard', [AdminController::class, 'index'])->name('admin.dashboard');
Route::get('/profile', fn() => view('profile'));

Route::get('/free-toeic/register', fn() => view('FreeRegister'))->name('free-toeic.form');
// Route::post('/free-toeic/register', [FreeToeicController::class, 'register'])->name('free-toeic.register');

Route::get('/paid-toeic/register', [PaidToeicController::class, 'create'])->name('paid-toeic.form');
Route::post('/paid-toeic/register', [PaidToeicController::class, 'store'])->name('paid-toeic.register');

// Route::get('/forgot-password', function () {
//     return view('auth.forgot-password'); // Buat file view-nya kalau belum ada
// })->middleware('guest')->name('password.request');
Route::get('/forgot-password', function () {
    return view('auth.forgot-password'); // Pastikan file ini ada di resources/views/auth/
})->name('password.request');


Route::post('/forgot-password', [ForgotPasswordController::class, 'sendResetLink'])
    ->name('password.email');


Route::get('/reset-password/{token}', function ($token) {
    return view('auth.reset-password', ['token' => $token]);
})->name('password.reset');

// Menangani submit form reset password
Route::post('/reset-password', [ResetPasswordController::class, 'reset'])->name('password.update');


// web.php
// Route::resource('/announcements', AnnouncementController::class);
// // Route::resource('announcements', AnnouncementController::class);
// Route::get('/fetch-announcements', [AnnouncementController::class, 'fetch'])->name('announcements.fetch');

// // List semua pengumuman
// Route::get('announcement', [AnnouncementController::class, 'index'])->name('admin.announcement.index');

// // Form tambah pengumuman
// Route::get('announcement/create', [AnnouncementController::class, 'create'])->name('admin.announcement.create');

// // Simpan pengumuman baru
// Route::post('announcement', [AnnouncementController::class, 'store'])->name('admin.announcement.store');

// // Form edit
// Route::get('announcement/{id}/edit', [AnnouncementController::class, 'edit'])->name('admin.announcement.edit');

// // Update pengumuman
// Route::put('announcement/{id}', [AnnouncementController::class, 'update'])->name('admin.announcement.update');

// // Hapus pengumuman
// Route::delete('announcement/{id}', [AnnouncementController::class, 'destroy'])->name('admin.announcement.destroy');

Route::prefix('students')->name('students.')->group(function () {
    Route::get('/', [StudentUserController::class, 'index'])->name('index');
    Route::get('/create', [StudentUserController::class, 'create'])->name('create');
    Route::post('/', [StudentUserController::class, 'store'])->name('store');
    Route::get('/{id}', [StudentUserController::class, 'show'])->name('show');
    Route::get('/{id}/edit', [StudentUserController::class, 'edit'])->name('edit');
    Route::put('/{id}', [StudentUserController::class, 'update'])->name('update');
    Route::delete('/{id}', [StudentUserController::class, 'destroy'])->name('destroy');
});

Route::prefix('announcement')->group(function () {
    Route::get('/', [AnnouncementController::class, 'index'])->name('announcement.index');
    Route::get('/create', [AnnouncementController::class, 'create'])->name('announcement.create');
    Route::post('/', [AnnouncementController::class, 'store'])->name('announcement.store');
    Route::get('/{announcement}', [AnnouncementController::class, 'show'])->name('announcement.show');
    Route::get('/{announcement}/edit', [AnnouncementController::class, 'edit'])->name('announcement.edit');
    Route::put('/{announcement}', [AnnouncementController::class, 'update'])->name('announcement.update');
    Route::delete('/{announcement}', [AnnouncementController::class, 'destroy'])->name('announcement.destroy');
});

// Index (list semua mahasiswa)
Route::get('/admin/student-register', [AdminRegistrationController::class, 'index'])->name('admin.student.register');

// Form tambah mahasiswa
Route::get('/admin/student-register/create', [AdminRegistrationController::class, 'create'])->name('admin.student.register.create');

// Simpan mahasiswa baru
Route::post('/admin/student-register', [AdminRegistrationController::class, 'store'])->name('admin.student.register.store');

// Route::get('/toeic-scores', [ToeicScoreController::class, 'index'])->name('toeic.scores.index');
Route::prefix('toeic-scores')->name('toeic-scores.')->group(function () {
    Route::get('/', [ToeicScoreController::class, 'index'])->name('index');
    Route::get('/create', [ToeicScoreController::class, 'create'])->name('create');
    Route::post('/store', [ToeicScoreController::class, 'store'])->name('store');
    Route::get('/{id}', [ToeicScoreController::class, 'show'])->name('show');
    Route::get('/{id}/edit', [ToeicScoreController::class, 'edit'])->name('edit');
    Route::put('/{id}', [ToeicScoreController::class, 'update'])->name('update');
    Route::delete('/{id}', [ToeicScoreController::class, 'destroy'])->name('destroy');
});

// Route::resource('/majors', MajorController::class);

Route::prefix('majors')->name('majors.')->group(function () {
    Route::get('/', [MajorController::class, 'index'])->name('index');
    Route::get('/create', [MajorController::class, 'create'])->name('create');
    Route::post('/store', [MajorController::class, 'store'])->name('store');
    Route::get('/{id}', [MajorController::class, 'show'])->name('show');
    Route::get('/{id}/edit', [MajorController::class, 'edit'])->name('edit');
    Route::put('/{id}', [MajorController::class, 'update'])->name('update');
    Route::delete('/{id}', [MajorController::class, 'destroy'])->name('destroy');
});

// Route::resource('/study-programs', StudyProgramController::class);
Route::prefix('study-programs')->name('study-programs.')->group(function () {
    Route::get('/', [StudyProgramController::class, 'index'])->name('index');
    Route::get('/create', [StudyProgramController::class, 'create'])->name('create');
    Route::post('/store', [StudyProgramController::class, 'store'])->name('store');
    Route::get('/{id}', [StudyProgramController::class, 'show'])->name('show');
    Route::get('/{id}/edit', [StudyProgramController::class, 'edit'])->name('edit');
    Route::put('/{id}', [StudyProgramController::class, 'update'])->name('update');
    Route::delete('/{id}', [StudyProgramController::class, 'destroy'])->name('destroy');
});

    Route::get('/educational-staff', [EducationalStaffController::class, 'index'])->name('educational-staff.index');
    Route::get('/educational-staff/create', [EducationalStaffController::class, 'create'])->name('educational-staff.create');
    Route::post('/educational-staff', [EducationalStaffController::class, 'store'])->name('educational-staff.store');
    Route::get('/educational-staff/{id}', [EducationalStaffController::class, 'show'])->name('educational-staff.show');
    Route::get('/educational-staff/{id}/edit', [EducationalStaffController::class, 'edit'])->name('educational-staff.edit');
    Route::put('/educational-staff/{id}', [EducationalStaffController::class, 'update'])->name('educational-staff.update');
    Route::delete('/educational-staff/{id}', [EducationalStaffController::class, 'destroy'])->name('educational-staff.destroy');


    Route::get('/toeic-scores', [ToeicScoreController::class, 'index'])->name('toeic-scores.index');
Route::get('/toeic-scores/create', [ToeicScoreController::class, 'create'])->name('toeic-scores.create');
Route::post('/toeic-scores', [ToeicScoreController::class, 'store'])->name('toeic-scores.store');
Route::get('/toeic-scores/{id}', [ToeicScoreController::class, 'show'])->name('toeic-scores.show');
Route::get('/toeic-scores/{id}/edit', [ToeicScoreController::class, 'edit'])->name('toeic-scores.edit');
Route::post('/toeic-scores/{id}', [ToeicScoreController::class, 'update'])->name('toeic-scores.update');
Route::delete('/toeic-scores/{id}', [ToeicScoreController::class, 'destroy'])->name('toeic-scores.destroy');


Route::get('/toeic-registration/index', [ToeicRegistrationController::class, 'index'])->name('toeic-registration.index');
Route::get('/toeic-registration', [ToeicRegistrationController::class, 'create'])->name('toeic-registration.create');
Route::post('/toeic-registration', [ToeicRegistrationController::class, 'store'])->name('toeic-registration.store');
Route::get('/toeic-registration/success/{id}', [ToeicRegistrationController::class, 'success'])->name('toeic-registration.success');

Route::middleware('auth')->group(function () {
    Route::get('/profile', [ProfileController::class, 'show'])->name('profile.show');
    Route::get('/profile/edit', [ProfileController::class, 'edit'])->name('profile.edit');
    Route::put('/profile/update', [ProfileController::class, 'update'])->name('profile.update');
    Route::get('/profile/change-password', [ProfileController::class, 'editPassword'])->name('profile.change-password');
    Route::put('/profile/update-password', action: [ProfileController::class, 'updatePassword'])->name('profile.update-password');
});

Route::prefix('educational-staff-registration')->group(function () {
    Route::get('/', [EducationalStaffRegistrationController::class, 'index'])->name('educational-staff-registration.index');
    Route::get('/create', [EducationalStaffRegistrationController::class, 'create'])->name('educational-staff-registration.create');
    Route::post('/', [EducationalStaffRegistrationController::class, 'store'])->name('educational-staff-registration.store');
    Route::get('/{id}/success', [EducationalStaffRegistrationController::class, 'success'])->name('educational-staff-registration.success');
    Route::get('/{id}', [EducationalStaffRegistrationController::class, 'show'])->name('educational-staff-registration.show');
    Route::get('/{id}/edit', [EducationalStaffRegistrationController::class, 'edit'])->name('educational-staff-registration.edit');
    Route::put('/{id}', [EducationalStaffRegistrationController::class, 'update'])->name('educational-staff-registration.update');
    Route::delete('/{id}', [EducationalStaffRegistrationController::class, 'destroy'])->name('educational-staff-registration.destroy');
});
