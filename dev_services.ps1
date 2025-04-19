# PowerShell script for managing development services

# Function to check if Redis is running
function Check-Redis {
    $redis = Get-Process redis-server -ErrorAction SilentlyContinue
    if ($redis) {
        Write-Host "Redis is running" -ForegroundColor Green
        return $true
    } else {
        Write-Host "Redis is not running" -ForegroundColor Red
        return $false
    }
}

# Function to start Redis
function Start-Redis {
    Write-Host "Starting Redis..." -ForegroundColor Yellow
    if (-not (Check-Redis)) {
        try {
            # Check if Redis is installed
            $redisPath = Get-Command redis-server -ErrorAction SilentlyContinue
            if (-not $redisPath) {
                Write-Host "Redis is not installed. Please install Redis first." -ForegroundColor Red
                Write-Host "Download Redis from https://github.com/microsoftarchive/redis/releases" -ForegroundColor Yellow
                Write-Host "Install and add to PATH" -ForegroundColor Yellow
                exit 1
            }

            # Start Redis
            Start-Process redis-server -WindowStyle Hidden
            Start-Sleep -Seconds 2

            if (Check-Redis) {
                Write-Host "Redis started successfully" -ForegroundColor Green
            } else {
                Write-Host "Failed to start Redis" -ForegroundColor Red
                exit 1
            }
        } catch {
            Write-Host "Error starting Redis: $_" -ForegroundColor Red
            exit 1
        }
    }
}

# Function to stop Redis
function Stop-Redis {
    Write-Host "Stopping Redis..." -ForegroundColor Yellow
    if (Check-Redis) {
        try {
            redis-cli shutdown
            Write-Host "Redis stopped successfully" -ForegroundColor Green
        } catch {
            Write-Host "Error stopping Redis: $_" -ForegroundColor Red
        }
    } else {
        Write-Host "Redis is not running" -ForegroundColor Yellow
    }
}

# Main script
switch ($args[0]) {
    "start" {
        Start-Redis
    }
    "stop" {
        Stop-Redis
    }
    "check" {
        Check-Redis
    }
    default {
        Write-Host "Usage: .\dev_services.ps1 {start|stop|check}"
        exit 1
    }
} 