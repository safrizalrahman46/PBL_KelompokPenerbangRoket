<?php

namespace Tests\Feature;

use Tests\TestCase;
use App\Models\User;
use App\Filament\Resources\OrderResource;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Auth;

class OrderResourceTest extends TestCase
{
    use RefreshDatabase;

    /** @test */
    public function it_tests_order_resource_login_and_access_logic()
    {
        /** ✅ 1. CLASS TERDAFTAR */
        $this->assertTrue(class_exists(OrderResource::class));

        /** ✅ 2. GUEST TIDAK BISA VIEW */
        Auth::logout();
        $this->assertFalse(OrderResource::canViewAny());
        $this->assertFalse(OrderResource::canCreate());

        /** ✅ 3. USER BIASA DITOLAK */
        $user = User::factory()->create([
            'role' => 'user',
        ]);
        Auth::login($user);

        $this->assertFalse(OrderResource::canViewAny());
        $this->assertFalse(OrderResource::canCreate());

        /** ✅ 4. KITCHEN BISA VIEW, TIDAK BISA CREATE */
        $kitchen = User::factory()->create([
            'role' => 'kitchen',
        ]);
        Auth::login($kitchen);

        $this->assertTrue(OrderResource::canViewAny());
        $this->assertFalse(OrderResource::canCreate());

        /** ✅ 5. CASHIER BISA VIEW & CREATE */
        $cashier = User::factory()->create([
            'role' => 'cashier',
        ]);
        Auth::login($cashier);

        $this->assertTrue(OrderResource::canViewAny());
        $this->assertTrue(OrderResource::canCreate());

        /** ✅ 6. ADMIN BISA SEMUA */
        $admin = User::factory()->create([
            'role' => 'admin',
        ]);
        Auth::login($admin);

        $this->assertTrue(OrderResource::canViewAny());
        $this->assertTrue(OrderResource::canCreate());
    }
}
