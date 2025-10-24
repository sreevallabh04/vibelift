@echo off
echo ========================================
echo VibeLift Setup Script
echo ========================================
echo.

echo [1/4] Installing dependencies...
call flutter pub get
if %errorlevel% neq 0 (
    echo ERROR: Failed to install dependencies
    pause
    exit /b 1
)
echo Dependencies installed successfully!
echo.

echo [2/4] Generating database code...
call flutter pub run build_runner build --delete-conflicting-outputs
if %errorlevel% neq 0 (
    echo ERROR: Failed to generate database code
    pause
    exit /b 1
)
echo Database code generated successfully!
echo.

echo [3/4] Creating platform files...
call flutter create --platforms android,web,windows .
if %errorlevel% neq 0 (
    echo WARNING: Some platforms may not have been created
)
echo Platform files created!
echo.

echo [4/4] Checking setup...
call flutter doctor
echo.

echo ========================================
echo Setup Complete!
echo ========================================
echo.
echo Next steps:
echo 1. Run: flutter run
echo 2. Or run: flutter run -d chrome
echo 3. Read QUICK_START.md for more info
echo.
echo Enjoy VibeLift! 💪
echo.
pause

