package com.bookmanager.service;

import com.bookmanager.entity.User;
import com.bookmanager.mapper.UserMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class UserService {

    @Autowired
    private UserMapper userMapper;

    public User login(String username, String password) {
        User user = userMapper.findByUsername(username);
        if (user != null && user.getPassword().equals(password)) {
            return user;
        }
        return null;
    }

    public boolean register(User user) {
        User exist = userMapper.findByUsername(user.getUsername());
        if (exist != null) {
            return false;
        }
        userMapper.insert(user);
        return true;
    }

    public User findById(Integer id) {
        return userMapper.findById(id);
    }
}
