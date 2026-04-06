@extends('layouts.admin')

@section('title', 'Change Password')

@section('content')
<div class="row justify-content-center">
    <div class="col-lg-6 col-md-8">
        <div class="card card-primary">
            <div class="card-header">
                <h3 class="card-title"><i class="fas fa-lock mr-2"></i>Change Password</h3>
            </div>
            <form method="POST" action="{{ route('admin.change-password.post') }}">
                @csrf
                <div class="card-body">
                    @if ($errors->any())
                        <div class="alert alert-danger">
                            <ul class="mb-0">
                                @foreach ($errors->all() as $error)
                                    <li>{{ $error }}</li>
                                @endforeach
                            </ul>
                        </div>
                    @endif

                    <div class="form-group">
                        <label for="current_password">Current Password</label>
                        <input type="password" name="current_password" id="current_password"
                               class="form-control @error('current_password') is-invalid @enderror"
                               required>
                        @error('current_password')
                            <span class="invalid-feedback">{{ $message }}</span>
                        @enderror
                    </div>

                    <div class="form-group">
                        <label for="password">New Password</label>
                        <input type="password" name="password" id="password"
                               class="form-control @error('password') is-invalid @enderror"
                               required autocomplete="new-password">
                        <small class="form-text text-muted">
                            Minimum 12 characters with uppercase, lowercase, number, and symbol.
                        </small>
                        @error('password')
                            <span class="invalid-feedback">{{ $message }}</span>
                        @enderror
                    </div>

                    <div class="form-group">
                        <label for="password_confirmation">Confirm New Password</label>
                        <input type="password" name="password_confirmation" id="password_confirmation"
                               class="form-control" required autocomplete="new-password">
                    </div>
                </div>
                <div class="card-footer">
                    <button type="submit" class="btn btn-primary">
                        <i class="fas fa-save mr-1"></i>Update Password
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>
@endsection
