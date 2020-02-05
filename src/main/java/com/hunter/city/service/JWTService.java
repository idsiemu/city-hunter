package com.hunter.city.service;

import com.hunter.city.model.User;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.util.Date;
import java.util.HashMap;
import java.util.Map;


@Service
public class JWTService {
    // application.properties 에 secret 설정, 대충 원하는 문자열 10~20글자정도?
    @Value("${security.jwt.token.secret-key}")
    private String secret;

    public String createToken(User user) {
        Map<String, Object> headers = new HashMap<>();
        headers.put("typ", "JWT");
        headers.put("alg", "HS256");

        Map<String, Object> payloads = new HashMap<>();
        long expiredTime = 1000*60;
        Date now = new Date();
        now.setTime(now.getTime() + expiredTime);
        payloads.put("username", user.getUsername());

        String jwt = Jwts.builder()
                .setHeader(headers)
                .setClaims(payloads)
                .signWith(SignatureAlgorithm.HS256, secret.getBytes())
                .compact();
        return jwt;
    }

    public String verify(String jwt) throws InterruptedException{
        Claims claims = Jwts.parser()
                .setSigningKey(secret.getBytes())
                .parseClaimsJws(jwt)
                .getBody();

        String username = claims.get("username", String.class);
        return username;
    }

}