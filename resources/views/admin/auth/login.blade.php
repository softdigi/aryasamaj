<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Arya Samaj Admin Login</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.2/dist/css/bootstrap.min.css">
    <style>
        body {
            background: linear-gradient(135deg, #FF6B00 0%, #1A5C2E 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        .login-card {
            width: 100%;
            max-width: 400px;
            border-radius: 12px;
            box-shadow: 0 8px 32px rgba(0,0,0,0.3);
        }
        .login-logo {
            font-size: 2.5rem;
            text-align: center;
            padding: 20px 0 10px;
            color: #FF6B00;
        }
        .login-logo span {
            display: block;
            font-size: 1.1rem;
            color: #555;
            font-weight: 600;
        }
        .btn-saffron {
            background-color: #FF6B00;
            border-color: #FF6B00;
            color: #fff;
        }
        .btn-saffron:hover {
            background-color: #e05d00;
            border-color: #e05d00;
            color: #fff;
        }
    </style>
</head>
<body>
    <div class="login-card card">
        <div class="card-body p-4">
            <div class="login-logo">
                🕉
                <span>Arya Samaj Admin</span>
            </div>

            @if($errors->any())
                <div class="alert alert-danger">
                    {{ $errors->first() }}
                </div>
            @endif

            <form method="POST" action="{{ route('admin.login.post') }}">
                @csrf
                <div class="form-group">
                    <label for="mobile">Mobile Number / Email</label>
                    <input type="text" class="form-control @error('mobile') is-invalid @enderror"
                        id="mobile" name="mobile" value="{{ old('mobile') }}"
                        placeholder="Enter mobile or email" autofocus required>
                    @error('mobile')
                        <span class="invalid-feedback">{{ $message }}</span>
                    @enderror
                </div>
                <div class="form-group">
                    <label for="password">Password</label>
                    <input type="password" class="form-control" id="password" name="password"
                        placeholder="Enter password" required>
                </div>
                <button type="submit" class="btn btn-saffron btn-block mt-3">
                    <i class="fas fa-sign-in-alt mr-1"></i> Login
                </button>
            </form>
        </div>
    </div>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">
</body>
</html>
