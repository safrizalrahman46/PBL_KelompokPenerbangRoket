<?php

namespace App\Providers\Filament;

use Filament\Http\Middleware\Authenticate;
use Filament\Http\Middleware\DisableBladeIconComponents;
use Filament\Http\Middleware\DispatchServingFilamentEvent;
use Filament\Pages;
use Filament\Panel;
use Filament\PanelProvider;
use Filament\Support\Colors\Color;
use Filament\Widgets;
use Illuminate\Cookie\Middleware\AddQueuedCookiesToResponse;
use Illuminate\Cookie\Middleware\EncryptCookies;
use Illuminate\Foundation\Http\Middleware\VerifyCsrfToken;
use Illuminate\Routing\Middleware\SubstituteBindings;
use Illuminate\Session\Middleware\AuthenticateSession;
use Illuminate\Session\Middleware\StartSession;
use Illuminate\View\Middleware\ShareErrorsFromSession;
use Filament\Forms\Components\TextInput; // Import untuk Registrasi
use Filament\Forms\Components\Select; // Import untuk Registrasi

// 1. IMPORT SEMUA WIDGET ANDA (FIXED)
use App\Filament\Widgets\PosStatsOverview;
use App\Filament\Widgets\PosSalesChart;
use App\Filament\Widgets\RecentOrdersTable;
use App\Filament\Widgets\BestSellingMenusTable; // <-- Ini yang benar (bukan TopSellingMenusChart)
use App\Filament\Widgets\PosCustomersChart;

// use App\Filament\Pages\Auth\Register;
use App\Filament\Auth\Register;

// tambahan baru
// use Filament\Pages\Auth\EditProfile;
// use App\Filament\Pages\Auth\Login;


class AdminPanelProvider extends PanelProvider
{
    public function panel(Panel $panel): Panel
    {
        return $panel
            ->default()
            ->id('admin')
            ->path('admin')
            ->login()
            // ->registration(Register::class)

            // ->login(Login::class)

             // ✅ 1. FITUR EDIT PROFILE & PASSWORD SUDAH DIAKTIFKAN DI SINI
            ->profile() 
            // ->profile(EditProfile::class)

            // 2. AKTIFKAN REGISTRASI PUBLIK
            ->registration(Register::class)

//            ->registration()
// ->registrationForm(function () {
//     return [
//         TextInput::make('name')
//             ->required()
//             ->maxLength(255),

//         TextInput::make('email')
//             ->required()
//             ->email()
//             ->unique('users', 'email')
//             ->maxLength(255),

//         TextInput::make('password')
//             ->password()
//             ->required()
//             ->minLength(8)
//             ->same('passwordConfirmation'),

//         TextInput::make('passwordConfirmation')
//             ->password()
//             ->label('Confirm Password')
//             ->required(),
//     ];
// })



            // 3. ⬇️ PERBAIKAN FINAL DI SINI ⬇️
            // Mengganti registrationForm() menjadi registrationFormSchema()
            // ->registration([
            //     TextInput::make('name')
            //         ->required()
            //         ->maxLength(255),
            //     TextInput::make('email')
            //         ->required()
            //         ->email()
            //         ->unique()
            //         ->maxLength(255),
            //     TextInput::make('password')
            //         ->required()
            //         ->password()
            //         ->minLength(8)
            //         ->confirmed(),
            //     // Kita tidak tambahkan role di sini agar default jadi 'cashier'
            // ])
            ->colors([
                'primary' => Color::Amber,
                'danger' => Color::Red,
                'gray' => Color::Slate,
                'info' => Color::Blue,
                'success' => Color::Emerald,
                'warning' => Color::Orange,
            ])
            ->font('Poppins') // <-- Anda menambahkan ini, bagus!
            ->discoverResources(in: app_path('Filament/Resources'), for: 'App\\Filament\\Resources')
            ->discoverPages(in: app_path('Filament/Pages'), for: 'App\\Filament\\Pages')
            ->pages([
                Pages\Dashboard::class,
                // Register::class,
                // \App\Filament\Pages\Auth\Register::class,

            ])
            ->discoverWidgets(in: app_path('Filament/Widgets'), for: 'App\\Filament\\Widgets')
            ->widgets([
                // 4. DAFTARKAN 4 WIDGET BARU ANDA
                PosStatsOverview::class,
                PosSalesChart::class,
                PosCustomersChart::class, // Safrrizal Update
                RecentOrdersTable::class,
                BestSellingMenusTable::class,

                // 5. HAPUS WIDGET BAWAAN (ANDA SUDAH MELAKUKAN INI, BAGUS!)
                // Widgets\AccountWidget::class,
                // Widgets\FilamentInfoWidget::class,
            ])
            ->middleware([
                EncryptCookies::class,
                AddQueuedCookiesToResponse::class,
                StartSession::class,
                AuthenticateSession::class,
                ShareErrorsFromSession::class,
                VerifyCsrfToken::class,
                SubstituteBindings::class,
                DisableBladeIconComponents::class,
                DispatchServingFilamentEvent::class,
            ])
            ->authMiddleware([
                Authenticate::class,
            ]);
    }
}
