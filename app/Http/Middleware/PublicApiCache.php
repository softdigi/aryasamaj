<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

/**
 * Adds Cache-Control: public, max-age=300 to non-personalised API responses.
 * Apply only on public, read-only, unauthenticated routes.
 */
class PublicApiCache
{
    public function handle(Request $request, Closure $next, int $maxAge = 300): Response
    {
        /** @var Response $response */
        $response = $next($request);

        if ($response->isSuccessful()) {
            $response->headers->set('Cache-Control', "public, max-age={$maxAge}");
        }

        return $response;
    }
}
