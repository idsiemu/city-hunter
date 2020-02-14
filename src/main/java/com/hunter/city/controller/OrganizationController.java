package com.hunter.city.controller;

import com.auth0.jwt.JWT;
import com.hunter.city.model.Organization;
import com.hunter.city.model.User;
import com.hunter.city.repository.UserRepository;
import com.hunter.city.security.JwtProperties;
import com.hunter.city.security.UserPrincipal;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServletRequest;
import java.util.Arrays;
import java.util.List;

import static com.auth0.jwt.algorithms.Algorithm.HMAC512;

@Slf4j
@Controller
public class OrganizationController {

    @Autowired
    private UserRepository userRepository;

    @PostMapping("/getPlace")
    @ResponseBody
    public List<Organization> getPlace(HttpServletRequest request) {
        try {
            String username = null;
            String token = Arrays.stream(request.getCookies())
                    .filter(cookie -> cookie.getName().equals(JwtProperties.HEADER_STRING)).findFirst().map(Cookie::getValue)
                    .orElse(null).replace(JwtProperties.TOKEN_PREFIX,"");
            if (token != null) {
                username = JWT.require(HMAC512(JwtProperties.SECRET.getBytes()))
                        .build()
                        .verify(token)
                        .getSubject();
            }
            List<Organization> list = userRepository.findByUsername(username).getOrganization();
            return list;
        }catch (Exception e){
            e.printStackTrace();
            return null;
        }
    }
}
