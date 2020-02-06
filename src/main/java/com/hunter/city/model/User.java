package com.hunter.city.model;

import com.fasterxml.jackson.annotation.JsonIgnore;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;

import javax.persistence.*;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

@Data //lombok
@Entity //JPA -> ORM
@NoArgsConstructor
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int id; // 시퀀스

    @Column(length = 50, nullable = false, unique = true)
    private String username; // 사용자 아이디

    @JsonIgnore
    @Column(length = 200, nullable = false)
    private String password; // 암호화된 패스워드

    @Column(length = 50)
    private String name; // 사용자 이름

    @Column(length = 50)
    private String website; // 홈페이지 주소

    @Column(length = 50)
    private String bio; // 자기 소개

    @Column(length = 50, nullable = false, unique = true)
    private String email;

    @Column(length = 32)
    private String phone;

    @Column(length = 16)
    private String gender;

    private String profileImage; //프로파일 사진 경로+이름

    @Column(length = 16)
    private String provider; // kakao, google, facebook

    @Column(length = 50)
    private String providerId;

    private int active;

    @Column(length = 32)
    private String roles;

    @CreationTimestamp // 자동으로 현재 시간이 세팅
    private Timestamp createDate;
    @CreationTimestamp // 자동으로 현재 시간이 세팅
    private Timestamp updateDate;

    public User(String username, String password, String roles){
        this.username = username;
        this.password = password;
        this.roles = roles;
        this.active = 1;
    }

    public List<String> getRoleList(){
        if(this.roles.length() > 0){
            return Arrays.asList(this.roles.split(","));
        }
        return new ArrayList<>();
    }
}