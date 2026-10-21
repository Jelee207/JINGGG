package com.fenglin.springboottest.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.fenglin.springboottest.common.PasswordUtil;
import com.fenglin.springboottest.entity.User;
import com.fenglin.springboottest.mapper.UserMapper;
import com.fenglin.springboottest.service.UserService;
import org.springframework.stereotype.Service;

@Service
public class UserServiceImpl extends ServiceImpl<UserMapper, User> implements UserService {

    @Override
    public void register(String username, String password) {
        long count = lambdaQuery().eq(User::getUsername, username).count();
        if (count > 0) {
            throw new RuntimeException("用户名已存在");
        }
        String salt = PasswordUtil.generateSalt();
        String hash = PasswordUtil.hash(password, salt);
        User user = new User();
        user.setUsername(username);
        user.setSalt(salt);
        user.setPassword(hash);
        save(user);
    }

    @Override
    public User login(String username, String password) {
        User user = lambdaQuery().eq(User::getUsername, username).one();
        if (user == null) {
            throw new RuntimeException("用户名或密码错误");
        }
        if (!PasswordUtil.matches(password, user.getSalt(), user.getPassword())) {
            throw new RuntimeException("用户名或密码错误");
        }
        return user;
    }
}
