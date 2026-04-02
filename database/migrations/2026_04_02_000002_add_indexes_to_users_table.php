<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * Adds composite and individual indexes to the users table.
 *
 * MembersController::index() filters on: status, profile_complete, state,
 * district, is_verified. Without indexes these columns require full-table
 * scans on every paginated request.
 *
 * Indexes added:
 *   1. (status, profile_complete) — primary filter applied on every listing
 *   2. state                      — geo filter
 *   3. district                   — geo filter
 *   4. is_verified                — badge filter
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::table('users', function (Blueprint $table) {
            // Composite index for the two filters always applied together
            $table->index(['status', 'profile_complete'], 'users_status_profile_complete_idx');

            // Individual geo / badge indexes
            $table->index('state',       'users_state_idx');
            $table->index('district',    'users_district_idx');
            $table->index('is_verified', 'users_is_verified_idx');
        });
    }

    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropIndex('users_status_profile_complete_idx');
            $table->dropIndex('users_state_idx');
            $table->dropIndex('users_district_idx');
            $table->dropIndex('users_is_verified_idx');
        });
    }
};
