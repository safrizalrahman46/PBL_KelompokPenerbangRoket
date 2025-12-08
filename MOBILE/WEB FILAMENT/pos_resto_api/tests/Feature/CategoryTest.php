<?php

namespace Tests\Feature\Api;

use Tests\TestCase;
use Illuminate\Foundation\Testing\RefreshDatabase;
use App\Models\Category;
use App\Models\Menu;

class CategoryTest extends TestCase
{
    use RefreshDatabase;

    /** @test */
    public function it_can_get_categories_with_menus_count()
    {
        // ✅ Arrange (Siapkan data)
        $category = Category::factory()->create([
            'name' => 'Makanan'
        ]);

        Menu::factory()->count(2)->create([
            'category_id' => $category->id,
        ]);

        // ✅ Act (Hit API)
        $response = $this->getJson('/api/v1/categories');

        // ✅ Assert (Cek hasil)
        $response->assertStatus(200)
                 ->assertJsonStructure([
                     [
                         'id',
                         'name',
                         'menus_count',
                         'created_at',
                         'updated_at',
                     ]
                 ]);

        $this->assertEquals(2, $response->json()[0]['menus_count']);
    }

    /** @test */
    public function it_returns_empty_array_if_no_category_exists()
    {
        // ✅ Act
        $response = $this->getJson('/api/v1/categories');

        // ✅ Assert
        $response->assertStatus(200)
                 ->assertExactJson([]);
    }
}
