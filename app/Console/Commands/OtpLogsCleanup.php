<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use Illuminate\Support\Facades\DB;

/**
 * Removes OTP log rows that are older than 24 hours (used or expired).
 *
 * Schedule: daily (see routes/console.php).
 */
class OtpLogsCleanup extends Command
{
    protected $signature   = 'otplogs:cleanup {--hours=24 : Delete logs older than N hours}';
    protected $description = 'Delete old OTP log rows (used or expired)';

    public function handle(): int
    {
        $hours = (int) $this->option('hours');

        $deleted = DB::table('otp_logs')
            ->where('created_at', '<', now()->subHours($hours))
            ->delete();

        $this->info("Deleted {$deleted} old OTP log rows.");
        return 0;
    }
}
