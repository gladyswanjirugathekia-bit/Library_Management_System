package com.bookmanager.mapper;

import com.bookmanager.entity.Category;
import org.apache.ibatis.annotations.Param;
import java.util.List;

public interface CategoryMapper {
    List<Category> findAll(@Param("keyword") String keyword);
    Category findById(Integer id);
    int insert(Category category);
    int update(Category category);
    int deleteById(Integer id);
    int deleteBatch(@Param("ids") Integer[] ids);
    int countBookByCategoryId(Integer categoryId);
}
