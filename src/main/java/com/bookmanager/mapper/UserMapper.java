package com.bookmanager.mapper;

import com.bookmanager.entity.User;
import org.apache.ibatis.annotations.Param;

public interface UserMapper {
    User findByUsername(String username);
    User findById(Integer id);
    int insert(User user);
}
