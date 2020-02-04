package com.hunter.city.repository;

import com.hunter.city.model.User;
import org.springframework.data.jpa.repository.JpaRepository;


public interface UserRepository extends JpaRepository<User, Integer> {
	User findByUsername(String username);
	
	User findByProviderAndProviderId(String provider, String providerId);
}
