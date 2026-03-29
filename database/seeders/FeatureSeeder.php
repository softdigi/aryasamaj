<?php

namespace Database\Seeders;

use App\Models\Feature;
use Illuminate\Database\Seeder;

class FeatureSeeder extends Seeder
{
    public function run(): void
    {
        $features = [
            // Sangathan section
            ['name' => 'Arya Samaj', 'name_hindi' => 'आर्य समाज', 'icon' => 'arya_samaj.png', 'route' => '/arya-samaj', 'section' => 'sangathan', 'sort_order' => 1],
            ['name' => 'Arya Veer Dal', 'name_hindi' => 'आर्य वीर दल', 'icon' => 'arya_veer.png', 'route' => '/arya-veer', 'section' => 'sangathan', 'sort_order' => 2],
            ['name' => 'Arya Virangana Dal', 'name_hindi' => 'आर्य वीरांगना दल', 'icon' => 'virangana.png', 'route' => '/virangana', 'section' => 'sangathan', 'sort_order' => 3],
            ['name' => 'Gurukul', 'name_hindi' => 'गुरुकुल', 'icon' => 'gurukul.png', 'route' => '/gurukul', 'section' => 'sangathan', 'sort_order' => 4],

            // Suvidha section
            ['name' => 'Arya Store', 'name_hindi' => 'आर्य स्टोर', 'icon' => 'store.png', 'route' => '/store', 'section' => 'suvidha', 'sort_order' => 1],
            ['name' => 'Vivah', 'name_hindi' => 'विवाह', 'icon' => 'vivah.png', 'route' => '/vivah', 'section' => 'suvidha', 'sort_order' => 2],
            ['name' => 'Om Bhajan', 'name_hindi' => 'ओ३म्', 'icon' => 'om.png', 'route' => '/om', 'section' => 'suvidha', 'sort_order' => 3],
            ['name' => 'Havan', 'name_hindi' => 'हवन', 'icon' => 'havan.png', 'route' => '/havan', 'section' => 'suvidha', 'sort_order' => 4],
            ['name' => 'Sangeet', 'name_hindi' => 'संगीत', 'icon' => 'sangeet.png', 'route' => '/sangeet', 'section' => 'suvidha', 'sort_order' => 5],
            ['name' => 'Yoga', 'name_hindi' => 'योग', 'icon' => 'yoga.png', 'route' => '/yoga', 'section' => 'suvidha', 'sort_order' => 6],
            ['name' => 'Pustakalay', 'name_hindi' => 'पुस्तकालय', 'icon' => 'library.png', 'route' => '/library', 'section' => 'suvidha', 'sort_order' => 7],
            ['name' => 'Sanskrit', 'name_hindi' => 'संस्कृत', 'icon' => 'sanskrit.png', 'route' => '/sanskrit', 'section' => 'suvidha', 'sort_order' => 8],
            ['name' => 'Video', 'name_hindi' => 'वीडियो', 'icon' => 'video.png', 'route' => '/video', 'section' => 'suvidha', 'sort_order' => 9],
            ['name' => 'Notes', 'name_hindi' => 'नोट्स', 'icon' => 'notes.png', 'route' => '/notes', 'section' => 'suvidha', 'sort_order' => 10],
        ];

        foreach ($features as $f) {
            Feature::updateOrCreate(['route' => $f['route']], array_merge($f, ['status' => 'active']));
        }
    }
}
