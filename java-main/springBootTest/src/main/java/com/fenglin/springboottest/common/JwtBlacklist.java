package com.fenglin.springboottest.common;

import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;
import org.springframework.stereotype.Component;

/**
 * JWT 黑名单（注销令牌）。
 * 当前为内存实现，重启即失效；令牌会持续累积，生产环境应改用 Redis 并以 TTL = 令牌剩余有效期自动清理。
 */
@Component
public class JwtBlacklist {

    private final Set<String> banned = ConcurrentHashMap.newKeySet();

    public void add(String token) {
        if (token != null) banned.add(token);
    }

    public boolean contains(String token) {
        return token != null && banned.contains(token);
    }
}
