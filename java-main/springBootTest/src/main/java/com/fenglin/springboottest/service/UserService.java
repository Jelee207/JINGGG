package com.fenglin.springboottest.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.fenglin.springboottest.entity.User;

public interface UserService extends IService<User> {

    /** 注册：用户名唯一校验后，明文存储，权限默认 1（默认会员） */
    void register(String username, String password);

    /** 前台登录：校验用户名与密码（明文），成功返回用户实体 */
    User login(String username, String password);

    /** 后台管理员登录：仅 permission=0 的账号可登录，明文校验 */
    User adminLogin(String username, String password);
}
