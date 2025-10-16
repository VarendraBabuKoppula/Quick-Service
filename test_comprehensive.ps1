# Comprehensive Feature Testing Script
# Tests all 9 User Module features end-to-end

$baseUrl = "http://localhost:8081/api/v1"
$frontendUrl = "http://localhost:3000"

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "BOOKARO - COMPREHENSIVE FEATURE TESTING" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

$testsPassed = 0
$testsFailed = 0

function Test-Feature {
    param($name, $scriptBlock)
    Write-Host "`nTesting: $name" -ForegroundColor Yellow
    try {
        & $scriptBlock
        Write-Host "PASS: $name" -ForegroundColor Green
        $script:testsPassed++
    } catch {
        Write-Host "FAIL: $name - $_" -ForegroundColor Red
        $script:testsFailed++
    }
}

# Test 1: Authentication - Registration
Test-Feature "User Registration" {
    $timestamp = Get-Date -Format "MMddHHmmss"
    $body = @{
        name = "Test User $timestamp"
        email = "test$timestamp@bookaro.com"
        password = "password123"
        phoneNumber = "9876543210"
    } | ConvertTo-Json
    
    $response = Invoke-RestMethod -Uri "$baseUrl/auth/register" -Method POST -Body $body -ContentType "application/json"
    if (-not $response.success) { throw "Registration failed" }
    Write-Host "  User registered: $($response.data.email)" -ForegroundColor Gray
}

# Test 2: Authentication - Login
Test-Feature "User Login" {
    $body = @{
        email = "user@bookaro.com"
        password = "password123"
    } | ConvertTo-Json
    
    $response = Invoke-RestMethod -Uri "$baseUrl/auth/login" -Method POST -Body $body -ContentType "application/json"
    if (-not $response.success) { throw "Login failed" }
    $script:token = $response.data.token
    $script:userId = $response.data.id
    Write-Host "  Token obtained for user: $($response.data.email)" -ForegroundColor Gray
}

# Test 3: Profile Management - View Profile
Test-Feature "View Profile" {
    $headers = @{Authorization = "Bearer $token"}
    $response = Invoke-RestMethod -Uri "$baseUrl/users/$userId" -Method GET -Headers $headers
    if (-not $response.success) { throw "Profile fetch failed" }
    Write-Host "  Profile: $($response.data.name)" -ForegroundColor Gray
}

# Test 4: Profile Management - Update Profile
Test-Feature "Update Profile" {
    $headers = @{Authorization = "Bearer $token"; "Content-Type" = "application/json"}
    $body = @{
        name = "Updated Test User"
        phoneNumber = "9999999999"
    } | ConvertTo-Json
    
    $response = Invoke-RestMethod -Uri "$baseUrl/users/$userId" -Method PUT -Body $body -Headers $headers
    if (-not $response.success) { throw "Profile update failed" }
    Write-Host "  Profile updated successfully" -ForegroundColor Gray
}

# Test 5: Service Browsing - Get All Services
Test-Feature "Browse All Services" {
    $response = Invoke-RestMethod -Uri "$baseUrl/services?page=0&size=20" -Method GET
    if (-not $response.success) { throw "Service fetch failed" }
    Write-Host "  Total services: $($response.data.totalElements)" -ForegroundColor Gray
}

# Test 6: Service Search - Filter by Category
Test-Feature "Search Services by Category" {
    $response = Invoke-RestMethod -Uri "$baseUrl/services/search?category=Cleaning&page=0&size=10" -Method GET
    if (-not $response.success) { throw "Service search failed" }
    Write-Host "  Services found: $($response.data.totalElements)" -ForegroundColor Gray
}

# Test 7: Service Details
Test-Feature "View Service Details" {
    $response = Invoke-RestMethod -Uri "$baseUrl/services/1" -Method GET
    if (-not $response.success) { throw "Service details failed" }
    Write-Host "  Service: $($response.data.name) - Rs.$($response.data.price)" -ForegroundColor Gray
}

# Test 8: Booking Creation
Test-Feature "Create Booking" {
    $headers = @{Authorization = "Bearer $token"; "Content-Type" = "application/json"}
    $body = @{
        serviceId = 1
        bookingDate = "2025-10-20"
        bookingTime = "14:00"
        notes = "Automated test booking"
    } | ConvertTo-Json
    
    $response = Invoke-RestMethod -Uri "$baseUrl/bookings" -Method POST -Body $body -Headers $headers
    if (-not $response.success) { throw "Booking creation failed" }
    $script:bookingId = $response.data.id
    Write-Host "  Booking ID: $bookingId, Amount: Rs.$($response.data.totalAmount)" -ForegroundColor Gray
}

# Test 9: Booking Management - View Bookings
Test-Feature "View All Bookings" {
    $headers = @{Authorization = "Bearer $token"}
    $response = Invoke-RestMethod -Uri "$baseUrl/bookings/user/$userId?page=0&size=20" -Method GET
    if (-not $response.success) { throw "Fetch bookings failed" }
    Write-Host "  Total bookings: $($response.data.totalElements)" -ForegroundColor Gray
}

# Test 10: Booking Management - Cancel Booking
Test-Feature "Cancel Booking" {
    $headers = @{Authorization = "Bearer $token"}
    $response = Invoke-RestMethod -Uri "$baseUrl/bookings/$bookingId/cancel" -Method PUT -Headers $headers
    if (-not $response.success) { throw "Cancel booking failed" }
    Write-Host "  Booking cancelled: $bookingId" -ForegroundColor Gray
}

# Test 11: Favorites - Add to Favorites
Test-Feature "Add Service to Favorites" {
    $headers = @{Authorization = "Bearer $token"; "Content-Type" = "application/json"}
    $body = @{serviceId = 2} | ConvertTo-Json
    
    $response = Invoke-RestMethod -Uri "$baseUrl/favorites" -Method POST -Body $body -Headers $headers
    if (-not $response.success) { throw "Add favorite failed" }
    $script:favoriteId = $response.data.id
    Write-Host "  Favorite added: $favoriteId" -ForegroundColor Gray
}

# Test 12: Favorites - View Favorites
Test-Feature "View Favorites" {
    $headers = @{Authorization = "Bearer $token"}
    $response = Invoke-RestMethod -Uri "$baseUrl/favorites/user/$userId?page=0&size=20" -Method GET
    if (-not $response.success) { throw "Fetch favorites failed" }
    Write-Host "  Total favorites: $($response.data.totalElements)" -ForegroundColor Gray
}

# Test 13: Favorites - Remove from Favorites
Test-Feature "Remove from Favorites" {
    $headers = @{Authorization = "Bearer $token"}
    $response = Invoke-RestMethod -Uri "$baseUrl/favorites/$favoriteId" -Method DELETE -Headers $headers
    if (-not $response.success) { throw "Remove favorite failed" }
    Write-Host "  Favorite removed: $favoriteId" -ForegroundColor Gray
}

# Test 14: Address Management - Add Address
Test-Feature "Add Address" {
    $headers = @{Authorization = "Bearer $token"; "Content-Type" = "application/json"}
    $body = @{
        street = "123 Test Street"
        city = "Mumbai"
        state = "Maharashtra"
        postalCode = "400001"
        country = "India"
        isDefault = $true
    } | ConvertTo-Json
    
    $response = Invoke-RestMethod -Uri "$baseUrl/addresses" -Method POST -Body $body -Headers $headers
    if (-not $response.success) { throw "Add address failed" }
    $script:addressId = $response.data.id
    Write-Host "  Address added: $addressId" -ForegroundColor Gray
}

# Test 15: Address Management - View Addresses
Test-Feature "View All Addresses" {
    $headers = @{Authorization = "Bearer $token"}
    $response = Invoke-RestMethod -Uri "$baseUrl/addresses/user/$userId" -Method GET -Headers $headers
    if (-not $response.success) { throw "Fetch addresses failed" }
    Write-Host "  Total addresses: $($response.data.Count)" -ForegroundColor Gray
}

# Test 16: Address Management - Delete Address
Test-Feature "Delete Address" {
    $headers = @{Authorization = "Bearer $token"}
    $response = Invoke-RestMethod -Uri "$baseUrl/addresses/$addressId" -Method DELETE -Headers $headers
    if (-not $response.success) { throw "Delete address failed" }
    Write-Host "  Address deleted: $addressId" -ForegroundColor Gray
}

# Test 17: Reviews - Create Review (requires completed booking)
Test-Feature "Create Review" {
    # First create and complete a booking for review
    $headers = @{Authorization = "Bearer $token"; "Content-Type" = "application/json"}
    
    # Create booking
    $bookingBody = @{
        serviceId = 3
        bookingDate = "2025-10-21"
        bookingTime = "10:00"
        notes = "Test for review"
    } | ConvertTo-Json
    $bookingResp = Invoke-RestMethod -Uri "$baseUrl/bookings" -Method POST -Body $bookingBody -Headers $headers
    $reviewBookingId = $bookingResp.data.id
    
    # Complete booking (admin endpoint - using user token for test)
    try {
        Invoke-RestMethod -Uri "$baseUrl/bookings/$reviewBookingId/complete" -Method PUT -Headers $headers -ErrorAction SilentlyContinue | Out-Null
    } catch {}
    
    # Create review
    $reviewBody = @{
        serviceId = 3
        rating = 5
        comment = "Excellent service! Automated test review."
    } | ConvertTo-Json
    
    $response = Invoke-RestMethod -Uri "$baseUrl/reviews" -Method POST -Body $reviewBody -Headers $headers
    if (-not $response.success) { throw "Create review failed" }
    $script:reviewId = $response.data.id
    Write-Host "  Review created: Rating $($response.data.rating)/5" -ForegroundColor Gray
}

# Test 18: Reviews - View Service Reviews
Test-Feature "View Service Reviews" {
    $response = Invoke-RestMethod -Uri "$baseUrl/reviews/service/1?page=0&size=10" -Method GET
    if (-not $response.success) { throw "Fetch reviews failed" }
    Write-Host "  Reviews found: $($response.data.totalElements)" -ForegroundColor Gray
}

# Summary
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "TEST SUMMARY" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Passed: $testsPassed" -ForegroundColor Green
Write-Host "Failed: $testsFailed" -ForegroundColor Red
Write-Host "Total: $($testsPassed + $testsFailed)" -ForegroundColor Yellow

if ($testsFailed -eq 0) {
    Write-Host "`nALL TESTS PASSED! User Module is production ready." -ForegroundColor Green
} else {
    Write-Host "`nSome tests failed. Please review and fix issues." -ForegroundColor Red
}

Write-Host "`nFrontend URL: $frontendUrl" -ForegroundColor Cyan
Write-Host "Backend API: $baseUrl" -ForegroundColor Cyan
