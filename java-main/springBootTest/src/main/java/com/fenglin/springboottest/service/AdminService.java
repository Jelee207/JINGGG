package com.fenglin.springboottest.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.fenglin.springboottest.entity.SysAdmin;

public interface AdminService extends IService<SysAdmin> {

    /** 后台登录：校验账号密码（无验证码），成功后回写最后登录时间 */
    SysAdmin login(String username, String password);
}
