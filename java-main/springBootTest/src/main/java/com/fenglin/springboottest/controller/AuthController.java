package com.fenglin.springboottest.controller;

import com.fenglin.springboottest.common.JwtBlacklist;
import com.fenglin.springboottest.common.JwtUtil;
import com.fenglin.springboottest.common.Result;
import com.fenglin.springboottest.dto.CaptchaVO;
import com.fenglin.springboottest.dto.LoginRequest;
import com.fenglin.springboottest.dto.RegisterRequest;
import com.fenglin.springboottest.entity.User;
import com.fenglin.springboottest.service.CaptchaService;
import com.fenglin.springboottest.service.UserService;
import com.fenglin.springboottest.service.impl.UserServiceImpl;
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

@RestController
@RequestMapping("/api")
public class AuthController {

    private final UserService userService;
    private final CaptchaService captchaService;
    private final JwtBlacklist blacklist;

    public AuthController(UserService userService, CaptchaService captchaService, JwtBlacklist blacklist) {
        this.userService = userService;
        this.captchaService = captchaService;
        this.blacklist = blacklist;
    }

    /** 获取图形验证码：GET /api/captcha */
    @GetMapping("/captcha")
    public ResponseEntity<Result<CaptchaVO>> captcha() {
        try {
            CaptchaVO vo = captchaService.create();
            return ResponseEntity.ok(Result.success(vo));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Result.error("验证码生成失败"));
        }
    }

    /** 注册：POST /api/auth/register */
    @PostMapping("/auth/register")
    public ResponseEntity<Result<Void>> register(@RequestBody RegisterRequest req) {
        if (!captchaService.validate(req.captchaToken(), req.captcha())) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(Result.error("验证码错误，请重新输入"));
        }
        if (req.username() == null || req.username().isBlank()) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(Result.error("请输入用户名"));
        }
        if (req.password() == null || req.password().length() < 6) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(Result.error("密码至少 6 位"));
        }
        try {
            userService.register(req.username(), req.password());
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(Result.error(e.getMessage()));
        }
        return ResponseEntity.ok(Result.success());
    }

    /** 登录：POST /api/login，成功后返回 JWT（data.token） */
    @PostMapping("/login")
    public ResponseEntity<Result<Map<String, String>>> login(@RequestBody LoginRequest req) {
        if (!captchaService.validate(req.captchaToken(), req.captcha())) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(Result.error("验证码错误，请重新输入"));
        }
        try {
            userService.login(req.username(), req.password());
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(Result.error(e.getMessage()));
        }
        String token = JwtUtil.generate(req.username());
        return ResponseEntity.ok(Result.success(Map.of("token", token)));
    }

    /** 获取当前登录用户：GET /api/user/me（需 Authorization: Bearer <token>）
     *  返回 { username, permission }，permission：0 管理员，1 默认会员 */
    @GetMapping("/user/me")
    public ResponseEntity<Result<Map<String, Object>>> me(
            @RequestHeader(value = "Authorization", required = false) String auth) {
        String token = extractToken(auth);
        if (token == null || !JwtUtil.validate(token)) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(Result.error("未登录或登录已过期"));
        }
        String username = JwtUtil.parseUsername(token);
        User user = userService.lambdaQuery().eq(User::getUsername, username).one();
        Map<String, Object> data = new LinkedHashMap<>();
        data.put("username", username);
        data.put("permission", user != null && user.getPermission() != null
                ? user.getPermission() : UserServiceImpl.PERMISSION_DEFAULT);
        return ResponseEntity.ok(Result.success(data));
    }

    /** 注销：POST /api/logout，将当前令牌加入黑名单 */
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
