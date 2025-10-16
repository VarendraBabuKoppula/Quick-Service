package com.bookaro.controller;

import com.bookaro.dto.ApiResponse;
import com.bookaro.dto.AuthResponse;
import com.bookaro.dto.LoginRequest;
import com.bookaro.dto.RegisterRequest;
import com.bookaro.service.AuthService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

/**
 * Authentication Controller - Handles user registration and login
 */
@RestController
@RequestMapping("/auth")
public class AuthController {

    private final AuthService authService;

    public AuthController(AuthService authService) {
        this.authService = authService;
    }

    /**
     * Register a new user
     * POST /auth/register
     */
    @PostMapping("/register")
    public ResponseEntity<ApiResponse<AuthResponse>> register(@Valid @RequestBody RegisterRequest request) {
        ApiResponse<AuthResponse> response = authService.register(request);
        return new ResponseEntity<>(response, HttpStatus.CREATED);
    }

    /**
     * Login user
     * POST /auth/login
     */
    @PostMapping("/login")
    public ResponseEntity<ApiResponse<AuthResponse>> login(@Valid @RequestBody LoginRequest request) {
        ApiResponse<AuthResponse> response = authService.login(request);
        return ResponseEntity.ok(response);
    }
}
