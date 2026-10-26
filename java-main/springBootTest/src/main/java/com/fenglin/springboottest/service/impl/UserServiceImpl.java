package com.fenglin.springboottest.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.fenglin.springboottest.entity.User;
import com.fenglin.springboottest.mapper.UserMapper;
import com.fenglin.springboottest.service.UserService;
import org.springframework.stereotype.Service;

@Service
public class UserServiceImpl extends ServiceImpl<UserMapper, User> implements UserService {

    /** 权限常量：0 管理员，1 默认会员 */
    public static final int PERMISSION_ADMIN = 0;
    public static final int PERMISSION_DEFAULT = 1;

    @Override
    public void register(String username, String password) {
        long count = lambdaQuery().eq(User::getUsername, username).count();
        if (count > 0) {
            throw new RuntimeException("用户名已存在");
        }
        // 明文存储，不加密；注册用户默认为「默认会员」权限（1）
        User user = new User();
        user.setUsername(username);
        user.setPassword(password);
        user.setPermission(PERMISSION_DEFAULT);
        save(user);
    }

    @Override
    public User login(String username, String password) {
        User user = lambdaQuery().eq(User::getUsername, username).one();
        if (user == null) {
            throw new RuntimeException("用户名或密码错误");
        }
        // 明文比对
        if (!password.equals(user.getPassword())) {
            throw new RuntimeException("用户名或密码错误");
        }
        return user;
    }

    /**
     * 后台管理员登录：仅允许权限为管理员（permission=0）的账号登录后台。
     * 明文比对密码；权限不符或无账号/密码错误均拒绝。
     */
    @Override
    public User adminLogin(String username, String password) {
        User user = lambdaQuery().eq(User::getUsername, username).one();
        if (user == null) {
            throw new RuntimeException("账号或密码错误");
        }
        if (user.getPermission() == null || user.getPermission() != PERMISSION_ADMIN) {
            throw new RuntimeException("该账号无后台管理权限");
        }
        if (!password.equals(user.getPassword())) {
            throw new RuntimeException("账号或密码错误");
        }
        return user;
    }
}
