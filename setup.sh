#!/bin/bash

echo "========================================"
echo "VibeLift Setup Script"
echo "========================================"
echo ""

echo "[1/4] Installing dependencies..."
flutter pub get
if [ $? -ne 0 ]; then
    echo "ERROR: Failed to install dependencies"
    exit 1
fi
echo "Dependencies installed successfully!"
echo ""

echo "[2/4] Generating database code..."
flutter pub run build_runner build --delete-conflicting-outputs
if [ $? -ne 0 ]; then
    echo "ERROR: Failed to generate database code"
    exit 1
fi
echo "Database code generated successfully!"
echo ""

echo "[3/4] Creating platform files..."
flutter create --platforms android,ios,web,macos,linux .
if [ $? -ne 0 ]; then
    echo "WARNING: Some platforms may not have been created"
fi
echo "Platform files created!"
echo ""

echo "[4/4] Checking setup..."
flutter doctor
echo ""

echo "========================================"
echo "Setup Complete!"
echo "========================================"
echo ""
echo "Next steps:"
echo "1. Run: flutter run"
echo "2. Or run: flutter run -d chrome"
echo "3. Read QUICK_START.md for more info"
echo ""
echo "Enjoy VibeLift! 💪"
echo ""

