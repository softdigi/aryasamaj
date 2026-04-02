<?php

namespace App\Jobs;

use App\Models\User;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

/**
 * Sends an FCM push notification to a single user.
 *
 * Dispatch example:
 *   SendPushNotificationJob::dispatch($user, 'New message', 'Hello!', ['type' => 'chat']);
 */
class SendPushNotificationJob implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    public int $tries = 3;
    public int $backoff = 15;

    public function __construct(
        private readonly User $user,
        private readonly string $title,
        private readonly string $body,
        private readonly array $data = [],
    ) {}

    public function handle(): void
    {
        $fcmToken = $this->user->fcm_token;

        if (empty($fcmToken)) {
            return; // User has no registered device
        }

        $serverKey = config('services.fcm.server_key');

        if (empty($serverKey)) {
            Log::warning('FCM server key not configured; skipping push notification.');
            return;
        }

        $payload = [
            'to' => $fcmToken,
            'notification' => [
                'title' => $this->title,
                'body'  => $this->body,
                'sound' => 'default',
            ],
            'data' => $this->data,
        ];

        $response = Http::withHeaders([
            'Authorization' => "key={$serverKey}",
            'Content-Type'  => 'application/json',
        ])->post('https://fcm.googleapis.com/fcm/send', $payload);

        if (! $response->successful()) {
            throw new \RuntimeException("FCM push failed for user {$this->user->id}: " . $response->body());
        }

        Log::info("Push notification sent to user {$this->user->id}");
    }

    public function failed(\Throwable $exception): void
    {
        Log::error("SendPushNotificationJob failed for user {$this->user->id}: {$exception->getMessage()}");
    }
}
