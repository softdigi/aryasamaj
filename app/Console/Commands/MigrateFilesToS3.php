<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use Illuminate\Support\Facades\Storage;

/**
 * Migrates all files from the local private_uploads and public_uploads disks
 * to the S3 / Cloudflare R2 object storage disk.
 *
 * Usage:
 *   php artisan files:migrate-to-s3
 *   php artisan files:migrate-to-s3 --disk=r2   # target a specific disk
 *   php artisan files:migrate-to-s3 --dry-run    # preview only
 */
class MigrateFilesToS3 extends Command
{
    protected $signature = 'files:migrate-to-s3
                            {--disk=r2 : Target storage disk (r2 or s3)}
                            {--dry-run : List files that would be migrated without uploading}';

    protected $description = 'Migrate local uploads (private_uploads + public_uploads) to S3 / Cloudflare R2';

    public function handle(): int
    {
        $targetDisk = $this->option('disk');
        $dryRun     = $this->option('dry-run');

        $sources = [
            'private_uploads' => 'private_uploads',
            'public_uploads'  => 'public_uploads',
        ];

        $totalMigrated = 0;
        $totalSkipped  = 0;
        $totalErrors   = 0;

        foreach ($sources as $label => $sourceDisk) {
            $this->info("Processing disk: {$label}");

            $files = Storage::disk($sourceDisk)->allFiles();

            foreach ($files as $file) {
                // Skip system files
                if (str_starts_with(basename($file), '.')) {
                    continue;
                }

                if ($dryRun) {
                    $this->line("[DRY-RUN] Would migrate: {$label}/{$file}");
                    $totalMigrated++;
                    continue;
                }

                // Skip if already exists on target
                if (Storage::disk($targetDisk)->exists($file)) {
                    $this->line("  Skipping (already exists): {$file}");
                    $totalSkipped++;
                    continue;
                }

                try {
                    $stream = Storage::disk($sourceDisk)->readStream($file);
                    Storage::disk($targetDisk)->writeStream($file, $stream);
                    $this->line("  ✓ Migrated: {$label}/{$file}");
                    $totalMigrated++;
                } catch (\Throwable $e) {
                    $this->error("  ✗ Failed:   {$label}/{$file} — {$e->getMessage()}");
                    $totalErrors++;
                }
            }
        }

        $this->newLine();
        $this->info("Migration complete — Migrated: {$totalMigrated}, Skipped: {$totalSkipped}, Errors: {$totalErrors}");

        return $totalErrors > 0 ? 1 : 0;
    }
}
