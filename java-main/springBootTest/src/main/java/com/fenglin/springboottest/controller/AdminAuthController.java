package com.fenglin.springboottest.controller;

import com.fenglin.springboottest.common.JwtBlacklist;
import com.fenglin.springboottest.common.JwtUtil;
import com.fenglin.springboottest.common.Result;
import com.fenglin.springboottest.dto.AdminLoginRequest;
import com.fenglin.springboottest.entity.SysAdmin;
import com.fenglin.springboottest.service.AdminService;
import java.util.LinkedHashMap;
import java.util.Map;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * 后台管理系统鉴权接口。
 * 与前台会员登录（/api/login）相互独立：独立账号表 sys_admin、独立角色 ADMIN、且不需要验证码。
 */
@RestController
@RequestMapping("/api/admin")
public class AdminAuthController {

    private final AdminService adminService;
    private final JwtBlacklist blacklist;

    public AdminAuthController(AdminService adminService, JwtBlacklist blacklist) {
        this.adminService = adminService;
        this.blacklist = blacklist;
    }

    /**
     * 后台登录：POST /api/admin/login
     * 请求体 { username, password }，无需验证码；成功返回 { token, username, nickname, role }
     */
    @PostMapping("/login")
    public ResponseEntity<Result<Map<String, String>>> login(@RequestBody AdminLoginRequest req) {
        if (req == null || req.username() == null || req.username().isBlank()) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(Result.error("请输入账号"));
        }
        if (req.password() == null || req.password().isBlank()) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(Result.error("请输入密码"));
        }
        try {
            SysAdmin admin = adminService.login(req.username().trim(), req.password());
            String token = JwtUtil.generate(admin.getUsername(), JwtUtil.ROLE_ADMIN);
            Map<String, String> data = new LinkedHashMap<>();
            data.put("token", token);
            data.put("username", admin.getUsername());
            data.put("nickname", admin.getNickname() == null ? admin.getUsername() : admin.getNickname());
            data.put("role", JwtUtil.ROLE_ADMIN);
            return ResponseEntity.ok(Result.success(data));
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(Result.error(e.getMessage()));
        }
    }

    /** 当前管理员信息：GET /api/admin/me（Authorization: Bearer <admin token>） */
    @GetMapping("/me")
    public ResponseEntity<Result<Map<String, String>>> me(
            @RequestHeader(value = "Authorization", required = false) String auth) {
        String token = extractToken(auth);
        if (token == null || !JwtUtil.validate(token) || blacklist.contains(token)
                || !JwtUtil.ROLE_ADMIN.equals(JwtUtil.parseRole(token))) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(Result.error("未登录或登录已过期"));
        }
        String username = JwtUtil.parseUsername(token);
        SysAdmin admin = adminService.lambdaQuery().eq(SysAdmin::getUsername, username).one();
        Map<String, String> data = new LinkedHashMap<>();
        data.put("username", username);
        data.put("nickname", admin == null || admin.getNickname() == null ? username : admin.getNickname());
        data.put("role", JwtUtil.ROLE_ADMIN);
        return ResponseEntity.ok(Result.success(data));
    }

    /** 退出登录：POST /api/admin/logout，令牌加入黑名单 */
    @PostMapping("/logout")
    public ResponseEntity<Result<Void>> logout(
            @RequestHeader(value = "Authorization", required = false) String auth) {
        String token = extractToken(auth);
        if (token != null) {
            blacklist.add(token);
        }
        return ResponseEntity.ok(Result.success());
    }

    private String extractToken(String auth) {
        if (auth == null || !auth.startsWith("Bearer ")) {
            return null;
        }
        return auth.substring(7).trim();
    }
}
