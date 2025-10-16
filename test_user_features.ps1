# Bookaro User Module Feature Testing Script - CORRECTED VERSION
# Tests all User Module features with proper API calls

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "BOOKARO USER MODULE FEATURE TESTING" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$baseUrl = "http://localhost:8081/api/v1"
$token = ""
$testEmail = "testuser$(Get-Random)@bookaro.com"

# Test 1: User Registration
Write-Host "[TEST 1] User Registration & Validation" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
try {
    $registerData = @{
        email = $testEmail
        password = "Test@1234"  # At least 8 characters
        name = "Test Customer"
        contact = "9876543210"
        location = "Andheri, Mumbai, Maharashtra"
    } | ConvertTo-Json
    
    $registerResponse = Invoke-RestMethod -Uri "$baseUrl/auth/register" -Method POST -Body $registerData -ContentType "application/json"
    Write-Host "âœ… Registration successful!" -ForegroundColor Green
    Write-Host "Status: $($registerResponse.status)" -ForegroundColor White
    Write-Host "Message: $($registerResponse.message)" -ForegroundColor White
    if ($registerResponse.data) {
        Write-Host "User: $($registerResponse.data.name)" -ForegroundColor White
        Write-Host "Email: $($registerResponse.data.email)" -ForegroundColor White
    }
} catch {
    Write-Host "âŒ Registration failed: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.ErrorDetails) {
        Write-Host "Details: $($_.ErrorDetails.Message)" -ForegroundColor Yellow
    }
}

# Test 2: User Login
Write-Host "`n[TEST 2] User Login" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
try {
    $loginData = @{
        email = $testEmail
        password = "Test@1234"
    } | ConvertTo-Json
    
    $loginResponse = Invoke-RestMethod -Uri "$baseUrl/auth/login" -Method POST -Body $loginData -ContentType "application/json"
    $token = $loginResponse.data.token
    Write-Host "âœ… Login successful!" -ForegroundColor Green
    Write-Host "Status: $($loginResponse.status)" -ForegroundColor White
    Write-Host "Token: $($token.Substring(0, [Math]::Min(50, $token.Length)))..." -ForegroundColor White
    Write-Host "User: $($loginResponse.data.name)" -ForegroundColor White
} catch {
    Write-Host "âŒ Login failed: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.ErrorDetails) {
        Write-Host "Details: $($_.ErrorDetails.Message)" -ForegroundColor Yellow
    }
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
    $profileResponse = Invoke-RestMethod -Uri "$baseUrl/users/profile" -Method GET -Headers $headers
    Write-Host "âœ… Get Profile successful!" -ForegroundColor Green
    Write-Host "Name: $($profileResponse.fullName)" -ForegroundColor White
    Write-Host "Email: $($profileResponse.email)" -ForegroundColor White
    Write-Host "Phone: $($profileResponse.phone)" -ForegroundColor White
    Write-Host "Location: $($profileResponse.city), $($profileResponse.state)" -ForegroundColor White
    
    # Update profile
    $updateData = @{
        fullName = "Updated Test Customer"
        phone = "9876543211"
        address = "456 Updated Street"
        city = "Mumbai"
        state = "Maharashtra"
        zipCode = "400050"
    } | ConvertTo-Json
    
    $updatedProfile = Invoke-RestMethod -Uri "$baseUrl/users/profile" -Method PUT -Headers $headers -Body $updateData
    Write-Host "âœ… Update Profile successful!" -ForegroundColor Green
    Write-Host "Updated Name: $($updatedProfile.fullName)" -ForegroundColor White
    Write-Host "Updated Phone: $($updatedProfile.phone)" -ForegroundColor White
} catch {
    Write-Host "âŒ Profile management failed: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.ErrorDetails) {
        Write-Host "Details: $($_.ErrorDetails.Message)" -ForegroundColor Yellow
    }
}

# Test 4: Search Services by Type/Category
Write-Host "`n[TEST 4] Search Services by Type (Category)" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
try {
    # Try different categories
    $categories = @("Plumbing", "Cleaning", "Electrical", "Carpentry")
    $found = $false
    
    foreach ($cat in $categories) {
        $services = Invoke-RestMethod -Uri "$baseUrl/services?search=$cat" -Method GET
        if ($services.content -and $services.content.Count -gt 0) {
            Write-Host "âœ… Search by service type successful!" -ForegroundColor Green
            Write-Host "Found $($services.content.Count) services for '$cat'" -ForegroundColor White
            Write-Host "Sample: $($services.content[0].serviceName) - â‚¹$($services.content[0].price)" -ForegroundColor White
            Write-Host "Provider: Vendor ID $($services.content[0].vendorId)" -ForegroundColor White
            $found = $true
            break
        }
    }
    
    if (-not $found) {
        Write-Host "âš  No services found for any category" -ForegroundColor Yellow
    }
} catch {
    Write-Host "âŒ Service search failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 5: Search Services by Location
Write-Host "`n[TEST 5] Search Services by Location" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
try {
    $services = Invoke-RestMethod -Uri "$baseUrl/services?search=Mumbai" -Method GET
    Write-Host "âœ… Search by location successful!" -ForegroundColor Green
    Write-Host "Found $($services.content.Count) services in/near Mumbai" -ForegroundColor White
    if ($services.content.Count -gt 0) {
        Write-Host "Sample locations:" -ForegroundColor Cyan
        $services.content[0..2] | ForEach-Object {
            Write-Host "  - $($_.serviceName) in $($_.city)" -ForegroundColor White
        }
    }
} catch {
    Write-Host "âŒ Location search failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 6: View Service Provider Details
Write-Host "`n[TEST 6] View Service Provider Details" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
try {
    $allServices = Invoke-RestMethod -Uri "$baseUrl/services" -Method GET
    if ($allServices.content.Count -gt 0) {
        $serviceId = $allServices.content[0].id
        $serviceDetails = Invoke-RestMethod -Uri "$baseUrl/services/$serviceId" -Method GET
        Write-Host "âœ… View service details successful!" -ForegroundColor Green
        Write-Host "Service Name: $($serviceDetails.serviceName)" -ForegroundColor Cyan
        Write-Host "Category: $($serviceDetails.category)" -ForegroundColor White
        Write-Host "Cost: â‚¹$($serviceDetails.price)" -ForegroundColor White
        Write-Host "Duration: $($serviceDetails.durationMinutes) minutes" -ForegroundColor White
        Write-Host "Available: $($serviceDetails.isAvailable)" -ForegroundColor White
        Write-Host "Average Rating: $($serviceDetails.averageRating)/5.0 - $($serviceDetails.totalReviews) reviews" -ForegroundColor White
        Write-Host "Provider ID: $($serviceDetails.vendorId)" -ForegroundColor White
        Write-Host "Location: $($serviceDetails.city), $($serviceDetails.state)" -ForegroundColor White
        Write-Host "Description: $($serviceDetails.description)" -ForegroundColor White
    } else {
        Write-Host "âš  No services available to view" -ForegroundColor Yellow
    }
} catch {
    Write-Host "âŒ View service details failed: $($_.Exception.Message)" -ForegroundColor Red
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
        
        $futureDate = (Get-Date).AddDays(3)
        $bookingData = @{
            serviceId = $serviceId
            scheduledDate = $futureDate.ToString("yyyy-MM-dd")
            scheduledTime = "14:30:00"
            notes = "Automated test booking - User Module feature verification"
        } | ConvertTo-Json
        
        $booking = Invoke-RestMethod -Uri "$baseUrl/bookings" -Method POST -Headers $headers -Body $bookingData
        Write-Host "âœ… Booking created successfully!" -ForegroundColor Green
        Write-Host "Booking ID: $($booking.id)" -ForegroundColor Cyan
        Write-Host "Service: $($booking.serviceName)" -ForegroundColor White
        Write-Host "Scheduled: $($booking.scheduledDate) at $($booking.scheduledTime)" -ForegroundColor White
        Write-Host "Status: $($booking.status)" -ForegroundColor White
        Write-Host "Total Cost: â‚¹$($booking.totalCost)" -ForegroundColor White
        $global:testBookingId = $booking.id
    } else {
        Write-Host "âš  No services available to book" -ForegroundColor Yellow
    }
} catch {
    Write-Host "âŒ Booking failed: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.ErrorDetails) {
        Write-Host "Details: $($_.ErrorDetails.Message)" -ForegroundColor Yellow
    }
}

# Test 8: Track Booking Status
Write-Host "`n[TEST 8] Track Booking Status" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
try {
    $headers = @{
        "Authorization" = "Bearer $token"
    }
    
    $bookings = Invoke-RestMethod -Uri "$baseUrl/bookings" -Method GET -Headers $headers
    Write-Host "âœ… Track bookings successful!" -ForegroundColor Green
    Write-Host "Total bookings: $($bookings.Count)" -ForegroundColor Cyan
    
    if ($bookings.Count -gt 0) {
        Write-Host "`nYour Bookings:" -ForegroundColor Cyan
        foreach ($booking in $bookings) {
            Write-Host "`nBooking #$($booking.id):" -ForegroundColor Yellow
            Write-Host "  Service: $($booking.serviceName)" -ForegroundColor White
            Write-Host "  Status: $($booking.status)" -ForegroundColor White
            Write-Host "  Scheduled: $($booking.scheduledDate) at $($booking.scheduledTime)" -ForegroundColor White
            Write-Host "  Cost: â‚¹$($booking.totalCost)" -ForegroundColor White
        }
    } else {
        Write-Host "No bookings found" -ForegroundColor Yellow
    }
} catch {
    Write-Host "âŒ Tracking bookings failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 9: Rate and Review Service
Write-Host "`n[TEST 9] Rate and Review Service (After Completion)" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
try {
    $headers = @{
        "Authorization" = "Bearer $token"
        "Content-Type" = "application/json"
    }
    
    $allServices = Invoke-RestMethod -Uri "$baseUrl/services" -Method GET
    if ($allServices.content.Count -gt 0) {
        $serviceId = $allServices.content[0].id
        
        $reviewData = @{
            serviceId = $serviceId
            rating = 5
            comment = "Excellent service! The provider was very professional and punctual. Highly recommend this service to others. Great value for money!"
        } | ConvertTo-Json
        
        $review = Invoke-RestMethod -Uri "$baseUrl/reviews" -Method POST -Headers $headers -Body $reviewData
        Write-Host "âœ… Review submitted successfully!" -ForegroundColor Green
        Write-Host "Review ID: $($review.id)" -ForegroundColor Cyan
        Write-Host "Rating: $($review.rating)/5 â­â­â­â­â­" -ForegroundColor White
        Write-Host "Comment: $($review.comment)" -ForegroundColor White
        Write-Host "Created: $($review.createdAt)" -ForegroundColor White
    } else {
        Write-Host "âš  No services available to review" -ForegroundColor Yellow
    }
} catch {
    Write-Host "âŒ Review submission failed: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.ErrorDetails) {
        Write-Host "Details: $($_.ErrorDetails.Message)" -ForegroundColor Yellow
    }
}

# Final Summary
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "TEST SUMMARY - USER MODULE FEATURES" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Legend:" -ForegroundColor White
Write-Host "  âœ… = Feature Working Correctly" -ForegroundColor Green
Write-Host "  âŒ = Feature Failed/Error" -ForegroundColor Red
Write-Host "  âš  = Warning/Partial Success" -ForegroundColor Yellow
Write-Host ""
Write-Host "Features Tested:" -ForegroundColor Cyan
Write-Host "1. User Registration with validation" -ForegroundColor White
Write-Host "2. User Login" -ForegroundColor White
Write-Host "3. Profile Management (view/update)" -ForegroundColor White
Write-Host "4. Search by Service Type/Category" -ForegroundColor White
Write-Host "5. Search by Location" -ForegroundColor White
Write-Host "6. View Service Provider Details" -ForegroundColor White
Write-Host "7. Book a Service (date/time selection)" -ForegroundColor White
Write-Host "8. Track Booking Status" -ForegroundColor White
Write-Host "9. Rate and Review Service" -ForegroundColor White
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Testing Complete!" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
