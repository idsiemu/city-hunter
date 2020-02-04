package com.hunter.city.model;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;

import javax.persistence.*;
import java.sql.Timestamp;

@Data
@Entity
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class Likes {
	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	private int id;
	
	@ManyToOne
	@JoinColumn(name = "userId")
	@JsonIgnoreProperties({"images", "password", "name", "website", "bio", "email", "phone", "gender", "createDate", "updateDate", "provider", "providerId"})
	private User user; // id, username, profileImage
	
	@ManyToOne 
	@JoinColumn(name = "imageId")
	@JsonIgnoreProperties({"tags", "user", "likes"})
	private Image image; // 기본 :  image_id
	
	@CreationTimestamp
	private Timestamp createDate;
	@CreationTimestamp
	private Timestamp updateDate;
}
