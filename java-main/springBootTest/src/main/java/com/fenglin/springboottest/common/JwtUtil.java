package com.fenglin.springboottest.common;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import java.util.Date;
import javax.crypto.SecretKey;

/**
 * JWT 工具类（HS256）。
 * 开发环境使用固定密钥；生产环境务必改为配置项/环境变量，且长度 ≥ 256 bit。
 *
 * 令牌载荷：subject = 用户名，role = 角色（USER 前台会员 / ADMIN 后台管理员）。
 */
public class JwtUtil {

    // 开发用固定密钥；生产请替换为强随机密钥并外置
    private static final String SECRET = "aurelia-jwt-secret-key-please-change-in-production-2024";
    private static final SecretKey KEY = Keys.hmacShaKeyFor(SECRET.getBytes());
    private static final long EXPIRATION_MS = 2 * 60 * 60 * 1000L; // 2 小时

    private static final String ROLE_CLAIM = "role";
    public static final String ROLE_USER = "USER";
    public static final String ROLE_ADMIN = "ADMIN";

    /** 生成前台会员令牌 */
    public static String generate(String username) {
        return generate(username, ROLE_USER);
    }

    /** 生成令牌，subject 为用户名，并写入角色声明 */
    public static String generate(String username, String role) {
        Date now = new Date();
        Date exp = new Date(now.getTime() + EXPIRATION_MS);
        return Jwts.builder()
                .subject(username)
                .claim(ROLE_CLAIM, role)
                .issuedAt(now)
                .expiration(exp)
                .signWith(KEY)
                .compact();
    }

    /** 解析用户名；令牌非法或过期则抛异常 */
    public static String parseUsername(String token) {
        return claims(token).getSubject();
    }

    /** 解析角色；令牌非法返回 null，未携带角色时默认 USER */
    public static String parseRole(String token) {
        try {
            Object role = claims(token).get(ROLE_CLAIM);
            return role == null ? ROLE_USER : role.toString();
        } catch (Exception e) {
            return null;
        }
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

    private static Claims claims(String token) {
        return Jwts.parser()
                .verifyWith(KEY)
                .build()
                .parseSignedClaims(token)
                .getPayload();
    }
}
