package com.hunter.city.repository;

import com.hunter.city.model.Organization;
import com.hunter.city.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;


public interface UserRepository extends JpaRepository<User, Integer> {
	int countByUsername(String username);

	int countByEmail(String email);

	User findByUsername(String username);


}
