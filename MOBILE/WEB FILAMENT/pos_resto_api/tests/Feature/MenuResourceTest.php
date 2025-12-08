<?php

namespace Tests\Feature;

use Tests\TestCase;
use App\Models\User;
use App\Filament\Resources\MenuResource;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Auth;

class MenuResourceTest extends TestCase
{
    use RefreshDatabase;

    /** @test */
    public function it_tests_login_and_menu_resource_access_logic()
    {
        /** ✅ 1. CLASS MENU RESOURCE ADA */
        $this->assertTrue(class_exists(MenuResource::class));

        /** ✅ 2. GUEST TIDAK BISA AKSES */
        Auth::logout();
        $this->assertFalse(MenuResource::canViewAny());

        /** ✅ 3. USER BIASA TIDAK BISA AKSES */
        $user = User::factory()->create([
            'role' => 'user',
        ]);
        Auth::login($user);

        $this->assertFalse(MenuResource::canViewAny());

        /** ✅ 4. CASHIER BISA AKSES */
        $cashier = User::factory()->create([
            'role' => 'cashier',
        ]);
        Auth::login($cashier);

        $this->assertTrue(MenuResource::canViewAny());

        /** ✅ 5. ADMIN BISA AKSES */
        $admin = User::factory()->create([
            'role' => 'admin',
        ]);
        Auth::login($admin);

        $this->assertTrue(MenuResource::canViewAny());
    }
}
