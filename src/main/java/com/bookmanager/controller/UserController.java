package com.bookmanager.controller;

import com.bookmanager.common.Result;
import com.bookmanager.entity.User;
import com.bookmanager.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpSession;

@RestController
@RequestMapping("/api/user")
public class UserController {

    @Autowired
    private UserService userService;

    @PostMapping("/login")
    public Result<User> login(@RequestBody User user, HttpSession session) {
        User loginUser = userService.login(user.getUsername(), user.getPassword());
        if (loginUser != null) {
            loginUser.setPassword(null);
            session.setAttribute("loginUser", loginUser);
            return Result.success("登录成功", loginUser);
        }
        return Result.error(401, "用户名或密码错误");
    }

    @PostMapping("/register")
    public Result<Void> register(@RequestBody User user) {
        if (user.getUsername() == null || user.getUsername().trim().isEmpty()) {
            return Result.error(400, "用户名不能为空");
        }
        if (user.getPassword() == null || user.getPassword().trim().isEmpty()) {
            return Result.error(400, "密码不能为空");
        }
        boolean success = userService.register(user);
        if (success) {
            return Result.success("注册成功", null);
        }
        return Result.error(400, "用户名已存在");
    }

    @PostMapping("/logout")
    public Result<Void> logout(HttpSession session) {
        session.invalidate();
        return Result.success("已注销", null);
    }

    @GetMapping("/current")
    public Result<User> currentUser(HttpSession session) {
        User user = (User) session.getAttribute("loginUser");
        if (user != null) {
            return Result.success(user);
        }
        return Result.error(401, "未登录");
    }
}
