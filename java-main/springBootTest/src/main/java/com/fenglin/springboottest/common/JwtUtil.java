package com.fenglin.springboottest.common;

import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import java.util.Date;
import javax.crypto.SecretKey;

/**
 * JWT 工具类（HS256）。
 * 开发环境使用固定密钥；生产环境务必改为配置项/环境变量，且长度 ≥ 256 bit。
 */
public class JwtUtil {

    // 开发用固定密钥；生产请替换为强随机密钥并外置
    private static final String SECRET = "aurelia-jwt-secret-key-please-change-in-production-2024";
    private static final SecretKey KEY = Keys.hmacShaKeyFor(SECRET.getBytes());
    private static final long EXPIRATION_MS = 2 * 60 * 60 * 1000L; // 2 小时

    /** 生成令牌，subject 为用户名 */
    public static String generate(String username) {
        Date now = new Date();
        Date exp = new Date(now.getTime() + EXPIRATION_MS);
        return Jwts.builder()
                .subject(username)
                .issuedAt(now)
                .expiration(exp)
                .signWith(KEY)
                .compact();
    }

    /** 解析用户名；令牌非法或过期则抛异常 */
    public static String parseUsername(String token) {
        return Jwts.parser()
                .verifyWith(KEY)
                .build()
                .parseSignedClaims(token)
                .getPayload()
                .getSubject();
    }

    /** 校验令牌是否合法且未过期 */
    public static boolean validate(String token) {
        try {
            parseUsername(token);
            return true;
        } catch (Exception e) {
            return false;
        }
    }
}
