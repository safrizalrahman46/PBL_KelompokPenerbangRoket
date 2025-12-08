<?php

namespace Tests\Feature;

use Tests\TestCase;
use App\Models\User;
use App\Filament\Resources\CategoryResource;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Auth;

class CategoryResourceTest extends TestCase
{
    use RefreshDatabase;

    /** @test */
    public function it_tests_login_and_category_resource_logic()
    {
        /** ✅ 1. CLASS ADA DAN BISA DI-LOAD */
        $this->assertTrue(class_exists(CategoryResource::class));

        /** ✅ 2. GUEST TIDAK BOLEH AKSES */
        Auth::logout();
        $this->assertFalse(CategoryResource::canViewAny());

        /** ✅ 3. USER BIASA TIDAK BOLEH AKSES */
        $user = User::factory()->create([
            'role' => 'user',
        ]);
        Auth::login($user);

        $this->assertFalse(
            CategoryResource::canViewAny()
        );

        /** ✅ 4. ADMIN BOLEH AKSES */
        $admin = User::factory()->create([
            'role' => 'admin',
        ]);
        Auth::login($admin);

        $this->assertTrue(
            CategoryResource::canViewAny()
        );
    }
}
