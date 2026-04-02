<?php

namespace App\Services;

use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use Intervention\Image\ImageManager;
use Intervention\Image\Drivers\Gd\Driver as GdDriver;

/**
 * Centralised image processing using Intervention Image v4.
 *
 * Profile photos  : 400×400 crop, saved as JPEG quality 85.
 * Gallery images  : max 1200 px wide, quality 80, plus a 150×150 thumbnail.
 */
class ImageResizeService
{
    private ImageManager $manager;

    public function __construct()
    {
        $this->manager = new ImageManager(new GdDriver());
    }

    /**
     * Process a profile photo: crop to 400×400.
     *
     * @param  UploadedFile  $file
     * @param  string        $storageDisk   e.g. 'private_uploads'
     * @param  string        $directory     e.g. 'profiles'
     * @param  string        $filename      without extension, e.g. 'profile_1_1234567890'
     * @return string        stored filename (with .jpg extension)
     */
    public function resizeProfile(UploadedFile $file, string $storageDisk, string $directory, string $filename): string
    {
        $image = $this->manager->read($file->getPathname());
        $image->cover(400, 400);

        $outFilename = $filename . '.jpg';
        $outPath = $directory . '/' . $outFilename;

        Storage::disk($storageDisk)->put($outPath, $image->toJpeg(85));

        return $outFilename;
    }

    /**
     * Process a gallery image: resize to max 1200 px wide (preserves ratio) + thumbnail.
     *
     * @param  UploadedFile  $file
     * @param  string        $storageDisk
     * @param  string        $directory
     * @param  string        $filename        without extension
     * @return array{main: string, thumb: string}  stored filenames
     */
    public function resizeGallery(UploadedFile $file, string $storageDisk, string $directory, string $filename): array
    {
        $main = $this->manager->read($file->getPathname());

        // Scale down only if wider than 1200 px
        if ($main->width() > 1200) {
            $main->scaleDown(width: 1200);
        }

        $mainFilename  = $filename . '.jpg';
        $thumbFilename = $filename . '_thumb.jpg';

        Storage::disk($storageDisk)->put($directory . '/' . $mainFilename, $main->toJpeg(80));

        // Thumbnail: 150×150 crop
        $thumb = $this->manager->read($file->getPathname());
        $thumb->cover(150, 150);
        Storage::disk($storageDisk)->put($directory . '/' . $thumbFilename, $thumb->toJpeg(80));

        return ['main' => $mainFilename, 'thumb' => $thumbFilename];
    }
}
