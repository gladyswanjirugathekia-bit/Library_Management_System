package com.bookmanager.service;

import com.bookmanager.entity.Book;
import com.bookmanager.mapper.BookMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class BookService {

    @Autowired
    private BookMapper bookMapper;

    public List<Book> findAll(String keyword, Integer categoryId) {
        return bookMapper.findAll(keyword, categoryId);
    }

    public Book findById(Integer id) {
        return bookMapper.findById(id);
    }

    public boolean insert(Book book) {
        return bookMapper.insert(book) > 0;
    }

    public boolean update(Book book) {
        return bookMapper.update(book) > 0;
    }

    public boolean deleteById(Integer id) {
        return bookMapper.deleteById(id) > 0;
    }

    public boolean deleteBatch(Integer[] ids) {
        return bookMapper.deleteBatch(ids) > 0;
    }

    public boolean updateStock(Integer id, Integer stock) {
        return bookMapper.updateStock(id, stock) > 0;
    }
}
