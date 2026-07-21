package com.bookmanager.controller;

import com.bookmanager.common.Result;
import com.bookmanager.entity.Category;
import com.bookmanager.service.CategoryService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/categories")
public class CategoryController {

    @Autowired
    private CategoryService categoryService;

    @GetMapping
    public Result<List<Category>> list(@RequestParam(required = false) String keyword) {
        List<Category> list = categoryService.findAll(keyword);
        return Result.success(list);
    }

    @PostMapping
    public Result<Void> add(@RequestBody Category category) {
        if (category.getName() == null || category.getName().trim().isEmpty()) {
            return Result.error(400, "分类名称不能为空");
        }
        categoryService.insert(category);
        return Result.success("添加成功", null);
    }

    @PutMapping("/{id}")
    public Result<Void> update(@PathVariable Integer id, @RequestBody Category category) {
        category.setId(id);
        if (category.getName() == null || category.getName().trim().isEmpty()) {
            return Result.error(400, "分类名称不能为空");
        }
        categoryService.update(category);
        return Result.success("修改成功", null);
    }

    @DeleteMapping("/{id}")
    public Result<Void> delete(@PathVariable Integer id) {
        if (categoryService.hasBooks(id)) {
            return Result.error(400, "该分类下尚有图书，无法删除");
        }
        categoryService.deleteById(id);
        return Result.success("删除成功", null);
    }

    @DeleteMapping("/batch")
    public Result<Void> deleteBatch(@RequestBody Integer[] ids) {
        for (Integer id : ids) {
            if (categoryService.hasBooks(id)) {
                return Result.error(400, "存在分类下尚有图书，无法删除");
            }
        }
        categoryService.deleteBatch(ids);
        return Result.success("批量删除成功", null);
    }
}
