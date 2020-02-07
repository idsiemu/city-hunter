package com.hunter.city.security;

import com.auth0.jwt.JWT;
import com.hunter.city.model.User;
import com.hunter.city.repository.UserRepository;
import lombok.extern.slf4j.Slf4j;
import lombok.val;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.web.authentication.www.BasicAuthenticationFilter;

import javax.servlet.FilterChain;
import javax.servlet.ServletException;
import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.Arrays;

import static com.auth0.jwt.algorithms.Algorithm.HMAC512;

@Slf4j
public class JwtAuthorizationFilter extends BasicAuthenticationFilter {
    private UserRepository userRepository;

    public JwtAuthorizationFilter(AuthenticationManager authenticationManager, UserRepository userRepository) {
        super(authenticationManager);
        this.userRepository = userRepository;
    }

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain chain) throws IOException, ServletException {
        // Read the Authorization Cookie, where the JWT token should be
        String token = null;
        try {
            token = Arrays.stream(request.getCookies())
                    .filter(cookie -> cookie.getName().equals(JwtProperties.HEADER_STRING)).findFirst().map(Cookie::getValue)
                    .orElse(null);
        }catch (Exception e){

        }

        // If Cookie does not contain BEARER or is null delegate to Spring impl and exit
        if (token != null && token.startsWith(JwtProperties.TOKEN_PREFIX)) {
            // If header is present, try grab user principal from database and perform authorization
            Authentication authentication = null;
            try {
                authentication = authentication = getUsernamePasswordAuthentication(request);
            }catch (Exception e){
                Cookie cookie = new Cookie(JwtProperties.HEADER_STRING, null);
                cookie.setMaxAge(0);
                response.addCookie(cookie);
            }
//            Authentication authentication = getUsernamePasswordAuthentication(request);
            SecurityContextHolder.getContext().setAuthentication(authentication);
        }
        // Continue filter execution
        chain.doFilter(request, response);
    }

    private Authentication getUsernamePasswordAuthentication(HttpServletRequest request) {
        String token = Arrays.stream(request.getCookies())
                .filter(cookie -> cookie.getName().equals(JwtProperties.HEADER_STRING)).findFirst().map(Cookie::getValue)
                .orElse(null).replace(JwtProperties.TOKEN_PREFIX,"");
        if (token != null) {
            // parse the token and validate it
            String userName = JWT.require(HMAC512(JwtProperties.SECRET.getBytes()))
                    .build()
                    .verify(token)
                    .getSubject();
            // Search in the DB if we find the user by token subject (username)
            // If so, then grab user details and create spring auth token using username, pass, authorities/roles
            if (userName != null) {
                User user = userRepository.findByUsername(userName);
                UserPrincipal principal = new UserPrincipal(user);
                UsernamePasswordAuthenticationToken auth = new UsernamePasswordAuthenticationToken(userName, null, principal.getAuthorities());
                return auth;
            }
            return null;
        }
        return null;
    }
}
