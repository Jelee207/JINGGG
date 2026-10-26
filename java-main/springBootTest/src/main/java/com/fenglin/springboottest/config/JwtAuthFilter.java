package com.fenglin.springboottest.config;

import com.fenglin.springboottest.common.JwtBlacklist;
import com.fenglin.springboottest.common.JwtUtil;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

/**
 * JWT 鉴权过滤器：对所有 /api/** 请求（白名单除外）校验 Bearer 令牌，
 * 无效或已注销（黑名单）则返回 401。校验通过后把用户名写入请求属性供后续使用。
 */
@Component
public class JwtAuthFilter extends OncePerRequestFilter {

    private final JwtBlacklist blacklist;

    private static final List<String> WHITELIST = List.of(
            "/api/captcha", "/api/login", "/api/auth/register", "/api/admin/login",
            "/api/home/feed", "/api/search");

    public JwtAuthFilter(JwtBlacklist blacklist) {
        this.blacklist = blacklist;
    }

    @Override
    protected boolean shouldNotFilter(HttpServletRequest request) {
        String path = request.getServletPath();
        if (!path.startsWith("/api")) {
            return true; // 非 API 路径不拦截
        }
        if ("OPTIONS".equalsIgnoreCase(request.getMethod())) {
            return true; // 放行 CORS 预检
        }
        return WHITELIST.contains(path);
    }

    @Override
    protected void doFilterInternal(HttpServletRequest request,
                                    HttpServletResponse response,
                                    FilterChain filterChain) throws ServletException, IOException {
        String auth = request.getHeader("Authorization");
        String token = (auth != null && auth.startsWith("Bearer "))
                ? auth.substring(7).trim() : null;

        if (token == null || !JwtUtil.validate(token) || blacklist.contains(token)) {
            response.setStatus(HttpStatus.UNAUTHORIZED.value());
            response.setContentType("application/json;charset=UTF-8");
            response.getWriter().write("{\"code\":1,\"message\":\"未登录或登录已过期\",\"data\":null}");
            return;
        }

        request.setAttribute("username", JwtUtil.parseUsername(token));
        filterChain.doFilter(request, response);
    }
}
