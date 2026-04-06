<?php

use Illuminate\Foundation\Inspiring;
use Illuminate\Support\Facades\Artisan;
use Illuminate\Support\Facades\Schedule;

Artisan::command('inspire', function () {
    $this->comment(Inspiring::quote());
})->purpose('Display an inspiring quote');

// Flush profile view logs into users.profile_views every night at midnight
Schedule::command('views:flush-profiles')->daily();

// Remove stale Sanctum tokens (unused or last used > 30 days ago)
Schedule::command('tokens:cleanup')->daily();

// Delete OTP log rows older than 24 hours
Schedule::command('otplogs:cleanup')->daily();


