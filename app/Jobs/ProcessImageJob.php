<?php

namespace App\Jobs;

use App\Models\UserImage;
use App\Models\User;
use App\Services\ImageResizeService;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Http\UploadedFile;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Storage;

/**
 * Processes (resizes) an uploaded image off the HTTP request cycle.
 *
 * The caller should save the raw file to a temp location first and pass the
 * temp path, so the job can be queued without holding the HTTP process open.
 *
 * Supported modes: 'profile' (400×400 crop) | 'gallery' (max 1200 + thumb).
 *
 * Dispatch example (gallery):
 *   $tmpPath = $file->store('tmp', 'local');
 *   ProcessImageJob::dispatch($user->id, $tmpPath, 'gallery', $sortOrder);
 *
 * Dispatch example (profile):
 *   $tmpPath = $file->store('tmp', 'local');
 *   ProcessImageJob::dispatch($user->id, $tmpPath, 'profile');
 */
class ProcessImageJob implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    public int $tries = 2;
    public int $timeout = 120;

    public function __construct(
        private readonly int    $userId,
        private readonly string $tmpPath,  // relative path within 'local' disk
        private readonly string $mode,     // 'profile' | 'gallery'
        private readonly int    $sortOrder = 0,
    ) {}

    public function handle(ImageResizeService $imageService): void
    {
        $user = User::find($this->userId);

        if (! $user) {
            Log::warning("ProcessImageJob: user {$this->userId} not found.");
            return;
        }

        $fullTmpPath = Storage::disk('local')->path($this->tmpPath);

        if (! file_exists($fullTmpPath)) {
            Log::warning("ProcessImageJob: temp file not found at {$fullTmpPath}");
            return;
        }

        // Wrap in a pseudo UploadedFile so ImageResizeService can read it
        $file = new UploadedFile($fullTmpPath, basename($fullTmpPath), null, null, true);
        $baseName = pathinfo(basename($fullTmpPath), PATHINFO_FILENAME);

        if ($this->mode === 'profile') {
            $filename = $imageService->resizeProfile($file, 'private_uploads', 'profiles', $baseName);
            // Overwrite the old profile image reference
            if ($user->profile_image) {
                Storage::disk('private_uploads')->delete('profiles/' . $user->profile_image);
            }
            $user->update(['profile_image' => $filename]);
        } elseif ($this->mode === 'gallery') {
            $result = $imageService->resizeGallery($file, 'private_uploads', 'user-images', $baseName);
            UserImage::create([
                'user_id'    => $this->userId,
                'image_path' => $result['main'],
                'sort_order' => $this->sortOrder,
            ]);
        }

        // Clean up temp file
        Storage::disk('local')->delete($this->tmpPath);

        Log::info("ProcessImageJob: processed {$this->mode} image for user {$this->userId}");
    }

    public function failed(\Throwable $exception): void
    {
        Log::error("ProcessImageJob failed for user {$this->userId}: {$exception->getMessage()}");
        // Clean up temp file on failure too
        Storage::disk('local')->delete($this->tmpPath);
    }
}
