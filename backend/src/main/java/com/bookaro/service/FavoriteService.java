package com.bookaro.service;

import com.bookaro.dto.ServiceDto;
import com.bookaro.exception.ResourceNotFoundException;
import com.bookaro.model.Favorite;
import com.bookaro.model.Service;
import com.bookaro.model.User;
import com.bookaro.repository.FavoriteRepository;
import com.bookaro.repository.ServiceRepository;
import com.bookaro.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@org.springframework.stereotype.Service
@RequiredArgsConstructor
@Transactional
public class FavoriteService {

    private final FavoriteRepository favoriteRepository;
    private final ServiceRepository serviceRepository;
    private final UserRepository userRepository;

    public List<ServiceDto> getFavoriteServices(String userEmail) {
        User user = userRepository.findByEmail(userEmail)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));

        return favoriteRepository.findFavoriteServicesByUser(user)
                .stream()
                .map(ServiceDto::fromEntity)
                .collect(Collectors.toList());
    }

    public ServiceDto addToFavorites(String userEmail, Long serviceId) {
        User user = userRepository.findByEmail(userEmail)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));

        Service service = serviceRepository.findById(serviceId)
                .orElseThrow(() -> new ResourceNotFoundException("Service not found"));

        // Check if already favorited
        if (favoriteRepository.existsByUserAndService(user, service)) {
            throw new IllegalStateException("Service already in favorites");
        }

        Favorite favorite = Favorite.builder()
                .user(user)
                .service(service)
                .build();

        favoriteRepository.save(favorite);
        return ServiceDto.fromEntity(service);
    }

    public void removeFromFavorites(String userEmail, Long serviceId) {
        User user = userRepository.findByEmail(userEmail)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));

        Service service = serviceRepository.findById(serviceId)
                .orElseThrow(() -> new ResourceNotFoundException("Service not found"));

        favoriteRepository.deleteByUserAndService(user, service);
    }

    public boolean isFavorite(String userEmail, Long serviceId) {
        User user = userRepository.findByEmail(userEmail)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));

        Service service = serviceRepository.findById(serviceId)
                .orElseThrow(() -> new ResourceNotFoundException("Service not found"));

        return favoriteRepository.existsByUserAndService(user, service);
    }
}
