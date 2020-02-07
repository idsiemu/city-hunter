package com.hunter.city.security;

public class JwtProperties {
    public static final String SECRET = "SomeSecretForJWTGeneration";
    public static final int EXPIRATION_TIME = 1000*60*60; // 1 hour
    public static final String TOKEN_PREFIX = "Bearer";
    public static final String HEADER_STRING = "Authorization";
}
