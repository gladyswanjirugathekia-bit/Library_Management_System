package com.bookmanager.service;

import com.bookmanager.entity.Book;
import com.bookmanager.entity.BorrowRecord;
import com.bookmanager.entity.User;
import com.bookmanager.mapper.BorrowRecordMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Date;
import java.util.List;

@Service
public class BorrowRecordService {

    @Autowired
    private BorrowRecordMapper borrowRecordMapper;

    @Autowired
    private BookService bookService;

    @Autowired
    private UserService userService;

    public List<BorrowRecord> findAll(String keyword, Integer status) {
        return borrowRecordMapper.findAll(keyword, status);
    }

    public boolean insert(BorrowRecord record) {
        Book book = bookService.findById(record.getBookId());
        if (book == null || book.getStock() <= 0) {
            return false;
        }
        bookService.updateStock(book.getId(), book.getStock() - 1);
        return borrowRecordMapper.insert(record) > 0;
    }

    public boolean returnBook(Integer id) {
        BorrowRecord record = borrowRecordMapper.findById(id);
        if (record == null || record.getStatus() == 1) {
            return false;
        }
        Book book = bookService.findById(record.getBookId());
        bookService.updateStock(book.getId(), book.getStock() + 1);
        return borrowRecordMapper.updateStatus(id, 1, new Date()) > 0;
    }

    public boolean deleteById(Integer id) {
        return borrowRecordMapper.deleteById(id) > 0;
    }

    public boolean deleteBatch(Integer[] ids) {
        return borrowRecordMapper.deleteBatch(ids) > 0;
    }
}
