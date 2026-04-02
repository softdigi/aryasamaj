<?php

namespace App\Jobs;

use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Facades\Log;

/**
 * Sends a one-time OTP SMS to a mobile number via the configured SMS gateway.
 *
 * Dispatch example:
 *   SendOtpJob::dispatch($mobile, $otp);
 */
class SendOtpJob implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    public int $tries = 3;
    public int $backoff = 10;

    public function __construct(
        private readonly string $mobile,
        private readonly string $otp,
    ) {}

    public function handle(): void
    {
        // TODO: Replace with your SMS provider SDK (Fast2SMS / MSG91 / Twilio).
        // Example using Fast2SMS:
        //
        // $response = Http::withHeaders(['authorization' => config('services.fast2sms.key')])
        //     ->post('https://www.fast2sms.com/dev/bulkV2', [
        //         'variables_values' => $this->otp,
        //         'route'            => 'otp',
        //         'numbers'          => $this->mobile,
        //     ]);
        //
        // if (! $response->successful()) {
        //     throw new \RuntimeException('SMS send failed: ' . $response->body());
        // }

        Log::info("OTP SMS queued for {$this->mobile} (OTP: {$this->otp})");
    }

    public function failed(\Throwable $exception): void
    {
        Log::error("SendOtpJob failed for {$this->mobile}: {$exception->getMessage()}");
    }
}
