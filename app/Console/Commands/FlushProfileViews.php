<?php

namespace App\Console\Commands;

use App\Models\ProfileViewLog;
use App\Models\User;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\DB;

/**
 * Aggregates profile_view_logs and updates users.profile_views in bulk.
 * Run daily via scheduler instead of per-request increment().
 */
class FlushProfileViews extends Command
{
    protected $signature   = 'views:flush-profiles';
    protected $description = 'Batch-update profile_views from profile_view_logs';

    public function handle(): int
    {
        // Sum all pending log entries grouped by user
        $counts = DB::table('profile_view_logs')
            ->select('user_id', DB::raw('count(*) as cnt'))
            ->groupBy('user_id')
            ->get();

        if ($counts->isEmpty()) {
            $this->info('No profile view logs to flush.');
            return 0;
        }

        DB::transaction(function () use ($counts) {
            foreach ($counts as $row) {
                User::where('id', $row->user_id)
                    ->increment('profile_views', $row->cnt);
            }
            // Truncate processed logs
            DB::table('profile_view_logs')->truncate();
        });

        $this->info("Flushed profile views for {$counts->count()} users.");
        return 0;
    }
}
