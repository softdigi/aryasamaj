<?php

use App\Http\Controllers\API\AuthController;
use App\Http\Controllers\API\CategoryController;
use App\Http\Controllers\API\ContentController;
use App\Http\Controllers\API\DonationController;
use App\Http\Controllers\API\FeedbackController;
use App\Http\Controllers\API\FeatureController;
use App\Http\Controllers\API\HomeController;
use App\Http\Controllers\API\MembersController;
use App\Http\Controllers\API\ProfileController;
use Illuminate\Support\Facades\Route;

// Public routes
Route::post('/send-otp', [AuthController::class, 'sendOtp'])->middleware('throttle:5,1');
Route::post('/verify-otp', [AuthController::class, 'verifyOtp'])->middleware('throttle:5,10');
Route::get('/home', [HomeController::class, 'index']);
Route::get('/features', [FeatureController::class, 'index']);
Route::get('/donation', [DonationController::class, 'index']);
Route::get('/categories', [CategoryController::class, 'index']);
Route::get('/contents', [ContentController::class, 'index']);
Route::get('/contents/{id}', [ContentController::class, 'show']);

// Members (public listing)
Route::get('/members', [MembersController::class, 'index']);
Route::get('/members/{id}', [MembersController::class, 'show']);
Route::get('/member-categories', [MembersController::class, 'categories']);

// Protected routes
Route::middleware('auth:sanctum')->group(function () {
    Route::get('/profile', [AuthController::class, 'profile']);
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::post('/feedback', [FeedbackController::class, 'store']);

    // Profile setup
    Route::get('/my-profile', [ProfileController::class, 'myProfile']);
    Route::post('/save-profile', [ProfileController::class, 'saveProfile']);
    Route::post('/save-categories', [ProfileController::class, 'saveCategories']);
    Route::post('/save-about', [ProfileController::class, 'saveAbout']);
    Route::post('/upload-images', [ProfileController::class, 'uploadImages']);
    Route::delete('/images/{id}', [ProfileController::class, 'deleteImage']);
});
