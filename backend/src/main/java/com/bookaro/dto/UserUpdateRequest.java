package com.bookaro.dto;

import lombok.Data;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

@Data
public class UserUpdateRequest {
    
    @Size(min = 2, max = 100, message = "Full name must be between 2 and 100 characters")
    private String fullName;
    
    @Pattern(regexp = "^[0-9]{10}$", message = "Phone number must be 10 digits")
    private String phone;
    
    @Size(max = 200, message = "Address must not exceed 200 characters")
    private String address;
    
    @Size(max = 50, message = "City must not exceed 50 characters")
    private String city;
    
    @Size(max = 50, message = "State must not exceed 50 characters")
    private String state;
    
    @Pattern(regexp = "^[0-9]{6}$", message = "Zip code must be 6 digits")
    private String zipCode;
    
    private Double latitude;
    
    private Double longitude;
}
