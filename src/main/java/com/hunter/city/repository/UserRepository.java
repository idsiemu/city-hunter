package com.hunter.city.repository;

import com.hunter.city.model.User;
import org.springframework.data.jpa.repository.JpaRepository;


public interface UserRepository extends JpaRepository<User, Integer> {
	int countByUsername(String username);

	int countByEmail(String email);

	boolean existsByUsernameAndPassword(String username, String password);
}
