<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use Illuminate\Support\Facades\DB;

/**
 * Removes stale Sanctum personal access tokens.
 *
 * A token is considered stale when:
 *   - It was created more than 30 days ago, OR
 *   - last_used_at is NULL and it was created more than 30 days ago.
 *
 * Schedule: daily at midnight (see routes/console.php).
 */
class TokensCleanup extends Command
{
    protected $signature   = 'tokens:cleanup {--days=30 : Delete tokens older than N days}';
    protected $description = 'Delete old or unused Sanctum personal access tokens';

    public function handle(): int
    {
        $days = (int) $this->option('days');

        $deleted = DB::table('personal_access_tokens')
            ->where(function ($q) use ($days) {
                // Tokens that have never been used and are older than $days
                $q->whereNull('last_used_at')
                  ->where('created_at', '<', now()->subDays($days));
            })
            ->orWhere(function ($q) use ($days) {
                // Tokens last used more than $days ago
                $q->whereNotNull('last_used_at')
                  ->where('last_used_at', '<', now()->subDays($days));
            })
            ->delete();

        $this->info("Deleted {$deleted} stale personal access tokens.");
        return 0;
    }
}
