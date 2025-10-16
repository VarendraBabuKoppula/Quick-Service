package com.bookaro.service;

import com.bookaro.dto.RegisterRequest;
import com.bookaro.dto.AuthResponse;
import com.bookaro.dto.ApiResponse;
import com.bookaro.dto.LoginRequest;
import com.bookaro.model.User;
import com.bookaro.repository.UserRepository;
import com.bookaro.security.JwtUtil;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Service
public class AuthService {
    private static final Logger logger = LoggerFactory.getLogger(AuthService.class);
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtUtil jwtUtil;
    private final AuthenticationManager authenticationManager;

    public AuthService(UserRepository userRepository, PasswordEncoder passwordEncoder,
                      JwtUtil jwtUtil, AuthenticationManager authenticationManager) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
        this.jwtUtil = jwtUtil;
        this.authenticationManager = authenticationManager;
    }

    public ApiResponse<AuthResponse> register(RegisterRequest request) {
        if (userRepository.existsByEmail(request.getEmail())) {
            return ApiResponse.error("Email already exists");
        }

        User user = new User();
        user.setEmail(request.getEmail());
        user.setPassword(passwordEncoder.encode(request.getPassword()));
        user.setFullName(request.getName());
        user.setPhone(request.getContact() != null ? request.getContact() : "");
        user.setAddress(request.getLocation() != null ? request.getLocation() : "");
        user.setRole(User.UserRole.USER);
        user.setIsActive(true);

        User savedUser = userRepository.save(user);

        AuthResponse authResponse = new AuthResponse();
        authResponse.setToken(jwtUtil.generateToken(org.springframework.security.core.userdetails.User
                .withUsername(savedUser.getEmail())
                .password(savedUser.getPassword())
                .authorities("ROLE_" + savedUser.getRole().name())
                .build()));
        authResponse.setId(savedUser.getId());
        authResponse.setEmail(savedUser.getEmail());
        authResponse.setFirstName(savedUser.getFirstName());
        authResponse.setLastName(savedUser.getLastName());
        authResponse.setRole(savedUser.getRole().name());

        return ApiResponse.success("Registration successful", authResponse);
    }

    public ApiResponse<AuthResponse> login(LoginRequest request) {
        try {
            logger.info("Login attempt for email: {}", request.getEmail());

            // Try to authenticate
            Authentication authentication = authenticationManager.authenticate(
                    new UsernamePasswordAuthenticationToken(request.getEmail(), request.getPassword())
            );

            UserDetails userDetails = (UserDetails) authentication.getPrincipal();
            String token = jwtUtil.generateToken(userDetails);

            // Try to get user from database
            User user = userRepository.findByEmail(request.getEmail()).orElse(null);

            AuthResponse authResponse = new AuthResponse();
            authResponse.setToken(token);

            // Use hardcoded data if user not in database
            if (user == null) {
                logger.warn("User not in database, using hardcoded data for response: {}", request.getEmail());
                authResponse.setId(1L);
                authResponse.setEmail(request.getEmail());

                if ("user@bookaro.com".equals(request.getEmail())) {
                    authResponse.setFirstName("Test");
                    authResponse.setLastName("User");
                    authResponse.setRole("USER");
                } else if ("vendor@bookaro.com".equals(request.getEmail())) {
                    authResponse.setFirstName("Test");
                    authResponse.setLastName("Vendor");
                    authResponse.setRole("VENDOR");
                } else if ("admin@bookaro.com".equals(request.getEmail())) {
                    authResponse.setFirstName("Admin");
                    authResponse.setLastName("User");
                    authResponse.setRole("ADMIN");
                }
            } else {
                logger.debug("User found in database: {}", request.getEmail());
                authResponse.setId(user.getId());
                authResponse.setEmail(user.getEmail());
                authResponse.setFirstName(user.getFirstName());
                authResponse.setLastName(user.getLastName());
                authResponse.setRole(user.getRole().name());
            }

            logger.info("Login successful for: {}", request.getEmail());
            return ApiResponse.success("Login successful", authResponse);
        } catch (BadCredentialsException e) {
            logger.warn("Bad credentials for: {}", request.getEmail());
            return ApiResponse.error("Incorrect password. Please try again");
        } catch (UsernameNotFoundException e) {
            logger.warn("User not found: {}", request.getEmail());
            return ApiResponse.error("No account found with this email address");
        } catch (AuthenticationException e) {
            logger.error("Authentication failed for {}: {}", request.getEmail(), e.getMessage());
            return ApiResponse.error("Authentication failed: " + e.getMessage());
        } catch (Exception e) {
            logger.error("Login error for {}", request.getEmail(), e);
            return ApiResponse.error("Login failed: " + e.getMessage());
        }
    }
}
