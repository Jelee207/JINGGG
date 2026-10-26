package com.fenglin.springboottest.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.fenglin.springboottest.common.PasswordUtil;
import com.fenglin.springboottest.entity.SysAdmin;
import com.fenglin.springboottest.mapper.SysAdminMapper;
import com.fenglin.springboottest.service.AdminService;
import java.time.LocalDateTime;
import org.springframework.stereotype.Service;

@Service
public class AdminServiceImpl extends ServiceImpl<SysAdminMapper, SysAdmin> implements AdminService {

    @Override
    public SysAdmin login(String username, String password) {
        SysAdmin admin = lambdaQuery().eq(SysAdmin::getUsername, username).one();
        if (admin == null) {
            throw new RuntimeException("账号或密码错误");
        }
        if (admin.getStatus() != null && admin.getStatus() != 1) {
            throw new RuntimeException("该账号已停用，请联系超级管理员");
        }
        if (!PasswordUtil.matches(password, admin.getSalt(), admin.getPassword())) {
            throw new RuntimeException("账号或密码错误");
        }
        admin.setLastLoginAt(LocalDateTime.now());
        lambdaUpdate()
                .eq(SysAdmin::getId, admin.getId())
                .set(SysAdmin::getLastLoginAt, admin.getLastLoginAt())
                .update();
        return admin;
    }
}
