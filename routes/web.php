<?php

use App\Http\Controllers\Admin;
use Illuminate\Support\Facades\Route;

Route::get('/', fn() => redirect()->route('admin.login'));

// Admin auth (no middleware)
Route::prefix('admin')->name('admin.')->group(function () {
    Route::get('/login', [Admin\AuthController::class, 'showLogin'])->name('login');
    Route::post('/login', [Admin\AuthController::class, 'login'])->name('login.post');
    Route::post('/logout', [Admin\AuthController::class, 'logout'])->name('logout');

    // Protected admin routes
    Route::middleware('admin')->group(function () {
        Route::get('/dashboard', [Admin\DashboardController::class, 'index'])->name('dashboard');

        Route::resource('categories', Admin\CategoryController::class);
        Route::resource('contents', Admin\ContentController::class);
        Route::resource('features', Admin\FeatureController::class);
        Route::post('features/{feature}/toggle', [Admin\FeatureController::class, 'toggle'])->name('features.toggle');
        Route::post('features/order', [Admin\FeatureController::class, 'updateOrder'])->name('features.order');
        Route::resource('donations', Admin\DonationController::class);
        Route::get('users', [Admin\UserController::class, 'index'])->name('users.index');
        Route::post('users/{user}/toggle', [Admin\UserController::class, 'toggle'])->name('users.toggle');
        Route::get('feedback', [Admin\FeedbackController::class, 'index'])->name('feedback.index');
        Route::resource('events', Admin\EventController::class);
        Route::get('change-password', [Admin\AuthController::class, 'showChangePassword'])->name('change-password');
        Route::post('change-password', [Admin\AuthController::class, 'changePassword'])->name('change-password.post');
    });
});
