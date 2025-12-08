<?php

namespace Tests\Feature;

use Tests\TestCase;
use App\Models\Category;
use App\Models\Menu;
use Illuminate\Foundation\Testing\RefreshDatabase;

class ApiCategoryTest extends TestCase
{
    use RefreshDatabase;

    /** ✅ TEST ROUTE & LOGIC INDEX ✅ */
    public function test_public_can_access_categories_api()
    {
        /** ARRANGE */
        $category = Category::factory()->create([
            'name' => 'Minuman'
        ]);

        Menu::factory()->count(2)->create([
            'category_id' => $category->id,
        ]);

        /** ACT */
        $response = $this->getJson('/api/v1/categories');

        /** ASSERT */
        $response->assertStatus(200);

        $response->assertJsonStructure([
            [
                'id',
                'name',
                'menus_count',
                'created_at',
                'updated_at'
            ]
        ]);

        $this->assertEquals(2, $response->json()[0]['menus_count']);
    }

    /** ✅ TEST CLASS CONTROLLER ADA ✅ */
    public function test_category_controller_class_exists()
    {
        $this->assertTrue(
            class_exists(\App\Http\Controllers\Api\V1\CategoryController::class)
        );
    }
}
