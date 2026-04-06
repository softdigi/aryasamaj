<?php

namespace Database\Seeders;

use App\Models\MemberCategory;
use Illuminate\Database\Seeder;
use Illuminate\Support\Str;

class MemberCategorySeeder extends Seeder
{
    public function run(): void
    {
        $roles = [
            'आर्यवीर',
            'शाखा नायक',
            'उपाध्याय शिक्षक',
            'व्यायाम शिक्षक',
            'आर्य रंगीला',
            'शाखा नायिका',
            'उप साधिका',
            'व्यायाम शिक्षिका',
            'आचार्य',
            'शास्त्री',
            'स्वयं सेवक',
            'वैदिक विद्वान',
            'भजन उपदेशक',
            'प्रचारक',
            'कार्यकर्ता',
            'पुरोहित',
            'अन्य',
        ];

        $orgs = [
            'आर्य समाज',
            'गुरुकुल',
            'कन्या गुरुकुल',
            'विद्यालय',
            'वैदिक केंद्र',
        ];

        foreach ($roles as $idx => $name) {
            MemberCategory::firstOrCreate(['name' => $name], [
                'slug'       => Str::slug($name) ?: 'role-' . ($idx + 1),
                'group'      => 'role',
                'sort_order' => $idx + 1,
                'status'     => 'active',
            ]);
        }

        foreach ($orgs as $idx => $name) {
            MemberCategory::firstOrCreate(['name' => $name], [
                'slug'       => Str::slug($name) ?: 'org-' . ($idx + 1),
                'group'      => 'org',
                'sort_order' => $idx + 1,
                'status'     => 'active',
            ]);
        }
    }
}
