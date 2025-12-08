<?php

namespace Tests\Feature;

use Tests\TestCase;
use App\Models\Category;
use App\Models\Menu;
use Illuminate\Foundation\Testing\RefreshDatabase;

class ApiCategoryControllerTest extends TestCase
{
    use RefreshDatabase;

    /** @test */
    public function category_api_index_returns_categories_with_menu_count()
    {
        /** ✅ 1. SIAPKAN DATA */
        $category = Category::factory()->create([
            'name' => 'Makanan',
        ]);

        Menu::factory()->count(3)->create([
            'category_id' => $category->id,
        ]);

        /** ✅ 2. HIT API */
        $response = $this->getJson('/api/v1/categories');

        /** ✅ 3. ASSERT RESPONSE */
        $response->assertStatus(200);

        $response->assertJsonStructure([
            [
                'id',
                'name',
                'menus_count',
                'created_at',
                'updated_at',
            ]
        ]);

        /** ✅ 4. ASSERT LOGIC withCount JALAN */
        $this->assertEquals(3, $response->json()[0]['menus_count']);
    }

    /** @test */
    public function controller_class_exists()
    {
        $this->assertTrue(
            class_exists(\App\Http\Controllers\Api\V1\CategoryController::class)
        );
    }
}
