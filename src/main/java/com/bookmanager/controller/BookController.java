package com.bookmanager.controller;

import com.bookmanager.common.Result;
import com.bookmanager.entity.Book;
import com.bookmanager.service.BookService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/books")
public class BookController {

    @Autowired
    private BookService bookService;

    @GetMapping
    public Result<List<Book>> list(
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) Integer categoryId) {
        List<Book> list = bookService.findAll(keyword, categoryId);
        return Result.success(list);
    }

    @PostMapping
    public Result<Void> add(@RequestBody Book book) {
        if (book.getTitle() == null || book.getTitle().trim().isEmpty()) {
            return Result.error(400, "书名不能为空");
        }
        if (book.getAuthor() == null || book.getAuthor().trim().isEmpty()) {
            return Result.error(400, "作者不能为空");
        }
        if (book.getStock() == null) {
            book.setStock(0);
        }
        bookService.insert(book);
        return Result.success("添加成功", null);
    }

    @PutMapping("/{id}")
    public Result<Void> update(@PathVariable Integer id, @RequestBody Book book) {
        book.setId(id);
        bookService.update(book);
        return Result.success("修改成功", null);
    }

    @DeleteMapping("/{id}")
    public Result<Void> delete(@PathVariable Integer id) {
        bookService.deleteById(id);
        return Result.success("删除成功", null);
    }

    @DeleteMapping("/batch")
    public Result<Void> deleteBatch(@RequestBody Integer[] ids) {
        bookService.deleteBatch(ids);
        return Result.success("批量删除成功", null);
    }
}
