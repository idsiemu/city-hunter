package com.hunter.city.security;

import com.auth0.jwt.JWT;
import lombok.SneakyThrows;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;

import javax.servlet.FilterChain;
import javax.servlet.ServletException;
import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Date;

import static com.auth0.jwt.algorithms.Algorithm.HMAC512;

//로그인시에 JWT가 작동함. SecurityConfiguration에서 설정!!
@Slf4j
public class JwtAuthenticationFilter extends UsernamePasswordAuthenticationFilter {
    private AuthenticationManager authenticationManager;

    public JwtAuthenticationFilter(AuthenticationManager authenticationManager) {
        this.authenticationManager = authenticationManager;
    }

    /* Trigger when we issue POST request to /login
    We also need to pass in {"username":"dan", "password":"dan123"} in the request body
     */
    @SneakyThrows
    @Override
    public Authentication attemptAuthentication(HttpServletRequest request, HttpServletResponse response) throws AuthenticationException {
        log.info("로그인 실행");
        // Grab credentials and map them to login viewmodel
        try {
            // Create login token
            UsernamePasswordAuthenticationToken authenticationToken = new UsernamePasswordAuthenticationToken(
                    request.getParameter("username"),
                    request.getParameter("password"),
                    new ArrayList<>());

            // Authenticate user
            Authentication auth = authenticationManager.authenticate(authenticationToken);
            return auth;
        } catch (Exception e) {
            PrintWriter out = response.getWriter();
            out.println(0);
        }
        return  null;
    }

    @Override
    protected void successfulAuthentication(HttpServletRequest request, HttpServletResponse response, FilterChain chain, Authentication authResult) throws IOException, ServletException {
        // Grab principal
        UserPrincipal principal = (UserPrincipal) authResult.getPrincipal();
        // Create JWT Token
        String token = JWT.create()
                .withSubject(principal.getUsername())
                .withExpiresAt(new Date(System.currentTimeMillis() + JwtProperties.EXPIRATION_TIME))
                .sign(HMAC512(JwtProperties.SECRET.getBytes()));

        // Add token in response
        PrintWriter out = response.getWriter();
        int authentication = 0;
        for(int i=0;i<principal.getAuthorities().toArray().length;i++){
            String getAuthority = principal.getAuthorities().toArray()[i].toString();
            if(getAuthority.equals("ROLE_ADMIN")){
                authentication = 1;
            }else if(getAuthority.equals("ROLE_CUSTOMER")){
                authentication = 2;
            }else if(getAuthority.equals("ROLE_USER")){
                authentication = 3;
            }else{
                authentication = 0;
            };
        }
        out.println(authentication);
        Cookie cookie = new Cookie(JwtProperties.HEADER_STRING, JwtProperties.TOKEN_PREFIX +  token);
        cookie.setMaxAge(JwtProperties.EXPIRATION_TIME);
        cookie.setPath("/");
        response.addCookie(cookie);
    }
}
