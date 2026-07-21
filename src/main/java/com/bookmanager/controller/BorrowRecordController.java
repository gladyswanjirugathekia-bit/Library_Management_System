package com.bookmanager.controller;

import com.bookmanager.common.Result;
import com.bookmanager.entity.BorrowRecord;
import com.bookmanager.service.BorrowRecordService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/borrows")
public class BorrowRecordController {

    @Autowired
    private BorrowRecordService borrowRecordService;

    @GetMapping
    public Result<List<BorrowRecord>> list(
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) Integer status) {
        List<BorrowRecord> list = borrowRecordService.findAll(keyword, status);
        return Result.success(list);
    }

    @PostMapping
    public Result<Void> add(@RequestBody BorrowRecord record) {
        if (record.getUserId() == null || record.getBookId() == null) {
            return Result.error(400, "用户和图书不能为空");
        }
        boolean success = borrowRecordService.insert(record);
        if (success) {
            return Result.success("借阅成功", null);
        }
        return Result.error(400, "图书库存不足");
    }

    @PutMapping("/{id}/return")
    public Result<Void> returnBook(@PathVariable Integer id) {
        boolean success = borrowRecordService.returnBook(id);
        if (success) {
            return Result.success("归还成功", null);
        }
        return Result.error(400, "归还失败，可能已归还");
    }

    @DeleteMapping("/{id}")
    public Result<Void> delete(@PathVariable Integer id) {
        borrowRecordService.deleteById(id);
        return Result.success("删除成功", null);
    }

    @DeleteMapping("/batch")
    public Result<Void> deleteBatch(@RequestBody Integer[] ids) {
        borrowRecordService.deleteBatch(ids);
        return Result.success("批量删除成功", null);
    }
}
