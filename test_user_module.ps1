# Bookaro User Module Feature Testing Script
# This script tests all User Module features

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "BOOKARO USER MODULE FEATURE TESTING" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$baseUrl = "http://localhost:8081/api/v1"
$token = ""

# Wait for server to start
Write-Host "Waiting for backend to start..." -ForegroundColor Yellow
Start-Sleep -Seconds 10

# Test 1: User Registration
Write-Host "`n[TEST 1] User Registration & Validation" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
try {
    $registerData = @{
        fullName = "Test Customer"
        email = "testcustomer$(Get-Random)@bookaro.com"
        password = "Test@123"
        phone = "9876543210"
        role = "CUSTOMER"
        address = "123 Test Street, Andheri"
        city = "Mumbai"
        state = "Maharashtra"
        zipCode = "400053"
    } | ConvertTo-Json
    
    $registerResponse = Invoke-RestMethod -Uri "$baseUrl/auth/register" -Method POST -Body $registerData -ContentType "application/json"
    Write-Host "✅ Registration successful!" -ForegroundColor Green
    Write-Host "User ID: $($registerResponse.userId)" -ForegroundColor White
    Write-Host "Email: $($registerResponse.email)" -ForegroundColor White
    $testEmail = ($registerData | ConvertFrom-Json).email
} catch {
    Write-Host "❌ Registration failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 2: User Login
Write-Host "`n[TEST 2] User Login" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
try {
    $loginData = @{
        email = $testEmail
        password = "Test@123"
    } | ConvertTo-Json
    
    $loginResponse = Invoke-RestMethod -Uri "$baseUrl/auth/login" -Method POST -Body $loginData -ContentType "application/json"
    $token = $loginResponse.token
    Write-Host "✅ Login successful!" -ForegroundColor Green
    Write-Host "Token: $($token.Substring(0, 50))..." -ForegroundColor White
    Write-Host "User: $($loginResponse.fullName)" -ForegroundColor White
} catch {
    Write-Host "❌ Login failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 3: Profile Management
Write-Host "`n[TEST 3] Profile Management" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
try {
    $headers = @{
        "Authorization" = "Bearer $token"
        "Content-Type" = "application/json"
    }
    
    # Get profile
    $profile = Invoke-RestMethod -Uri "$baseUrl/users/profile" -Method GET -Headers $headers
    Write-Host "✅ Get Profile successful!" -ForegroundColor Green
    Write-Host "Name: $($profile.fullName)" -ForegroundColor White
    Write-Host "Email: $($profile.email)" -ForegroundColor White
    Write-Host "Location: $($profile.city), $($profile.state)" -ForegroundColor White
    
    # Update profile
    $updateData = @{
        fullName = "Updated Test Customer"
        phone = "9876543211"
        address = "456 Updated Street, Bandra"
        city = "Mumbai"
        state = "Maharashtra"
        zipCode = "400050"
    } | ConvertTo-Json
    
    $updatedProfile = Invoke-RestMethod -Uri "$baseUrl/users/profile" -Method PUT -Headers $headers -Body $updateData
    Write-Host "✅ Update Profile successful!" -ForegroundColor Green
    Write-Host "Updated Name: $($updatedProfile.fullName)" -ForegroundColor White
} catch {
    Write-Host "❌ Profile management failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 4: Search Services by Type
Write-Host "`n[TEST 4] Search Services by Type" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
try {
    $services = Invoke-RestMethod -Uri "$baseUrl/services?category=Plumbing" -Method GET
    Write-Host "✅ Search by service type successful!" -ForegroundColor Green
    Write-Host "Found $($services.content.Count) Plumbing services" -ForegroundColor White
    if ($services.content.Count -gt 0) {
        Write-Host "Sample: $($services.content[0].serviceName) - ₹$($services.content[0].price)" -ForegroundColor White
    }
} catch {
    Write-Host "❌ Service search failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 5: Search Services by Location
Write-Host "`n[TEST 5] Search Services by Location" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
try {
    $services = Invoke-RestMethod -Uri "$baseUrl/services?city=Mumbai" -Method GET
    Write-Host "✅ Search by location successful!" -ForegroundColor Green
    Write-Host "Found $($services.content.Count) services in Mumbai" -ForegroundColor White
} catch {
    Write-Host "❌ Location search failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 6: View Service Provider Details
Write-Host "`n[TEST 6] View Service Provider Details" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
try {
    $allServices = Invoke-RestMethod -Uri "$baseUrl/services" -Method GET
    if ($allServices.content.Count -gt 0) {
        $serviceId = $allServices.content[0].id
        $serviceDetails = Invoke-RestMethod -Uri "$baseUrl/services/$serviceId" -Method GET
        Write-Host "✅ View service details successful!" -ForegroundColor Green
        Write-Host "Service: $($serviceDetails.serviceName)" -ForegroundColor White
        Write-Host "Category: $($serviceDetails.category)" -ForegroundColor White
        Write-Host "Cost: ₹$($serviceDetails.price)" -ForegroundColor White
        Write-Host "Duration: $($serviceDetails.durationMinutes) minutes" -ForegroundColor White
        Write-Host "Available: $($serviceDetails.isAvailable)" -ForegroundColor White
        Write-Host "Rating: $($serviceDetails.averageRating) ($($serviceDetails.totalReviews) reviews)" -ForegroundColor White
        Write-Host "Provider: Vendor ID $($serviceDetails.vendorId)" -ForegroundColor White
    }
} catch {
    Write-Host "❌ View service details failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 7: Book a Service
Write-Host "`n[TEST 7] Book a Service (with date/time)" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
try {
    $headers = @{
        "Authorization" = "Bearer $token"
        "Content-Type" = "application/json"
    }
    
    $allServices = Invoke-RestMethod -Uri "$baseUrl/services" -Method GET
    if ($allServices.content.Count -gt 0) {
        $serviceId = $allServices.content[0].id
        
        $bookingData = @{
            serviceId = $serviceId
            scheduledDate = (Get-Date).AddDays(2).ToString("yyyy-MM-dd")
            scheduledTime = "10:00:00"
            notes = "Test booking for feature verification"
        } | ConvertTo-Json
        
        $booking = Invoke-RestMethod -Uri "$baseUrl/bookings" -Method POST -Headers $headers -Body $bookingData
        Write-Host "✅ Booking created successfully!" -ForegroundColor Green
        Write-Host "Booking ID: $($booking.id)" -ForegroundColor White
        Write-Host "Service: $($booking.serviceName)" -ForegroundColor White
        Write-Host "Scheduled: $($booking.scheduledDate) at $($booking.scheduledTime)" -ForegroundColor White
        Write-Host "Status: $($booking.status)" -ForegroundColor White
        Write-Host "Total Cost: ₹$($booking.totalCost)" -ForegroundColor White
        $bookingId = $booking.id
    }
} catch {
    Write-Host "❌ Booking failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 8: Track Booking Status
Write-Host "`n[TEST 8] Track Booking Status" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
try {
    $headers = @{
        "Authorization" = "Bearer $token"
    }
    
    $bookings = Invoke-RestMethod -Uri "$baseUrl/bookings" -Method GET -Headers $headers
    Write-Host "✅ Track bookings successful!" -ForegroundColor Green
    Write-Host "Total bookings: $($bookings.Count)" -ForegroundColor White
    
    foreach ($booking in $bookings) {
        Write-Host "`nBooking #$($booking.id):" -ForegroundColor Cyan
        Write-Host "  Service: $($booking.serviceName)" -ForegroundColor White
        Write-Host "  Status: $($booking.status)" -ForegroundColor White
        Write-Host "  Date: $($booking.scheduledDate)" -ForegroundColor White
    }
} catch {
    Write-Host "❌ Tracking bookings failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 9: Rate and Review Service
Write-Host "`n[TEST 9] Rate and Review Service" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
try {
    $headers = @{
        "Authorization" = "Bearer $token"
        "Content-Type" = "application/json"
    }
    
    # First, update booking status to COMPLETED (simulate completed service)
    # Note: This would normally be done by the vendor, but for testing we'll try
    
    # Create a review
    $allServices = Invoke-RestMethod -Uri "$baseUrl/services" -Method GET
    if ($allServices.content.Count -gt 0) {
        $serviceId = $allServices.content[0].id
        
        $reviewData = @{
            serviceId = $serviceId
            rating = 5
            comment = "Excellent service! Very professional and punctual. Highly recommended!"
        } | ConvertTo-Json
        
        $review = Invoke-RestMethod -Uri "$baseUrl/reviews" -Method POST -Headers $headers -Body $reviewData
        Write-Host "✅ Review submitted successfully!" -ForegroundColor Green
        Write-Host "Review ID: $($review.id)" -ForegroundColor White
        Write-Host "Rating: $($review.rating)/5 stars" -ForegroundColor White
        Write-Host "Comment: $($review.comment)" -ForegroundColor White
    }
} catch {
    Write-Host "❌ Review submission failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Summary
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "TEST SUMMARY" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "All User Module features have been tested." -ForegroundColor Yellow
Write-Host "✅ = Feature Working" -ForegroundColor Green
Write-Host "❌ = Feature Failed" -ForegroundColor Red
Write-Host "`nPlease review the results above." -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Cyan
