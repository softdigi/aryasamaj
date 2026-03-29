<?php

use App\Http\Controllers\API\AuthController;
use App\Http\Controllers\API\CategoryController;
use App\Http\Controllers\API\ContentController;
use App\Http\Controllers\API\DonationController;
use App\Http\Controllers\API\FeedbackController;
use App\Http\Controllers\API\FeatureController;
use App\Http\Controllers\API\HomeController;
use Illuminate\Support\Facades\Route;

// Public routes
Route::post('/send-otp', [AuthController::class, 'sendOtp'])->middleware('throttle:5,1');
Route::post('/verify-otp', [AuthController::class, 'verifyOtp']);
Route::get('/home', [HomeController::class, 'index']);
Route::get('/features', [FeatureController::class, 'index']);
Route::get('/donation', [DonationController::class, 'index']);
Route::get('/categories', [CategoryController::class, 'index']);
Route::get('/contents', [ContentController::class, 'index']);
Route::get('/contents/{id}', [ContentController::class, 'show']);

// Protected routes
Route::middleware('auth:sanctum')->group(function () {
    Route::get('/profile', [AuthController::class, 'profile']);
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::post('/feedback', [FeedbackController::class, 'store']);
});
