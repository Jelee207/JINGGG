package com.fenglin.springboottest.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.fenglin.springboottest.entity.User;

public interface UserService extends IService<User> {

    /** 注册：校验用户名唯一后，加盐哈希存储 */
    void register(String username, String password);

    /** 登录：校验用户名与密码，成功返回用户实体 */
    User login(String username, String password);
}
