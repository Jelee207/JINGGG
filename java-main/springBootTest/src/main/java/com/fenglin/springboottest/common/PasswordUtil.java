package com.fenglin.springboottest.common;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.SecureRandom;

/**
 * 密码工具：随机盐 + SHA-256 哈希（无额外依赖，适合本地演示）。
 * 生产环境建议替换为 BCrypt / Argon2 等自适应哈希算法。
 */
public class PasswordUtil {

    private static final SecureRandom RANDOM = new SecureRandom();

    /** 生成 32 位十六进制随机盐 */
    public static String generateSalt() {
        byte[] salt = new byte[16];
        RANDOM.nextBytes(salt);
        StringBuilder sb = new StringBuilder();
        for (byte b : salt) {
            sb.append(String.format("%02x", b));
        }
        return sb.toString();
    }

    /** 哈希：SHA-256(盐 + 明文密码) */
    public static String hash(String password, String salt) {
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] bytes = md.digest((salt + password).getBytes(StandardCharsets.UTF_8));
            StringBuilder sb = new StringBuilder();
            for (byte b : bytes) {
                sb.append(String.format("%02x", b));
            }
            return sb.toString();
        } catch (Exception e) {
            throw new RuntimeException("密码加密失败", e);
        }
    }

    /** 校验明文密码是否匹配存储的「盐 + 哈希」 */
    public static boolean matches(String rawPassword, String salt, String storedHash) {
        if (rawPassword == null || storedHash == null) {
            return false;
        }
        return hash(rawPassword, salt).equalsIgnoreCase(storedHash);
    }
}
