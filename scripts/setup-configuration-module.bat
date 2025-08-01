@echo off
REM Configuration Module Setup Script
REM This script sets up the configuration module with proper permissions and sample data
chcp 65001 >nul

echo 🔧 Configuration Module Setup
echo =============================

REM Check if we're in the right directory
if not exist "go.mod" (
    echo ❌ Error: Please run this script from the project root directory
    exit /b 1
)

REM Step 1: Check database connection
echo 🔍 Step 1: Checking database connection...
go run scripts\test-database-connection.go >nul 2>&1
if errorlevel 1 (
    echo ❌ Error: Cannot connect to database. Please check your .env configuration
    echo 💡 Run this for detailed error info:
    echo    go run scripts\test-database-connection.go
    echo 💡 Make sure:
    echo    - Database server is running
    echo    - .env file exists with correct database settings
    echo    - Database credentials are correct
    exit /b 1
)
echo ✅ Database connection successful

REM Step 2: Set up permissions
echo 🔒 Step 2: Setting up configuration permissions...
go run scripts\add-admin-only-configuration-permissions.go >nul 2>&1

if errorlevel 1 (
    echo ⚠️  Permission setup may need attention
) else (
    echo ✅ Configuration permissions verified
)

REM Step 3: Seed sample data
echo.
set /p seedData="Do you want to add sample configuration data? (y/N): "

if /i "%seedData%"=="y" (
    echo 🌱 Step 3: Seeding sample configuration data...
    go run scripts\seed-sample-configurations.go
    
    if errorlevel 1 (
        echo ❌ Failed to seed sample data
    ) else (
        echo ✅ Sample data seeded successfully
    )
) else (
    echo ℹ️  Skipping sample data seeding
)

echo.
echo 🎉 Configuration Module Setup Complete!
echo =======================================

echo 📋 What was set up:
echo    ✅ Configuration module with key-value structure
echo    ✅ Admin-only permissions for configuration access
echo    ✅ Sample configuration data ^(if selected^)
echo    ✅ Updated Swagger documentation

echo 🔗 Available Endpoints:
echo    📄 GET    /v1/configurations           - List all configurations
echo    📄 POST   /v1/configurations           - Create new configuration
echo    📄 GET    /v1/configurations/{id}      - Get configuration by ID
echo    📄 GET    /v1/configurations/key/{key} - Get configuration by key
echo    📄 PUT    /v1/configurations/{id}      - Update configuration
echo    📄 DELETE /v1/configurations/{id}      - Delete configuration

echo 🔒 Security:
echo    ✅ Only Admin users can access configuration endpoints
echo    ✅ All endpoints require authentication
echo    ✅ Rate limiting applied

echo 🧪 Test the API:
echo    curl -X GET "http://localhost:3000/v1/configurations"
echo      -H "Authorization: Bearer admin-api-key-789"

echo.
echo Configuration module is ready to use! 🚀