<?php

namespace Tests\Feature;

use Tests\TestCase;
use App\Models\User;
use App\Filament\Resources\CategoryResource;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Auth;

class CategoryResourceLogicTest extends TestCase
{
    use RefreshDatabase;

    /** @test */
    public function admin_can_view_category_resource()
    {
        $admin = User::factory()->create([
            'role' => 'admin',
        ]);

        Auth::login($admin);

        $this->assertTrue(
            CategoryResource::canViewAny()
        );
    }

    /** @test */
    public function non_admin_cannot_view_category_resource()
    {
        $user = User::factory()->create([
            'role' => 'user',
        ]);

        Auth::login($user);

        $this->assertFalse(
            CategoryResource::canViewAny()
        );
    }

    /** @test */
    public function guest_cannot_view_category_resource()
    {
        Auth::logout();

        $this->assertFalse(
            CategoryResource::canViewAny()
        );
    }
}
