package com.bookmanager.service;

import com.bookmanager.entity.Category;
import com.bookmanager.mapper.CategoryMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class CategoryService {

    @Autowired
    private CategoryMapper categoryMapper;

    public List<Category> findAll(String keyword) {
        return categoryMapper.findAll(keyword);
    }

    public boolean insert(Category category) {
        return categoryMapper.insert(category) > 0;
    }

    public boolean update(Category category) {
        return categoryMapper.update(category) > 0;
    }

    public boolean deleteById(Integer id) {
        return categoryMapper.deleteById(id) > 0;
    }

    public boolean deleteBatch(Integer[] ids) {
        return categoryMapper.deleteBatch(ids) > 0;
    }

    public boolean hasBooks(Integer categoryId) {
        return categoryMapper.countBookByCategoryId(categoryId) > 0;
    }
}
