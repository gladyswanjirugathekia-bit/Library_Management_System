package com.bookmanager.mapper;

import com.bookmanager.entity.BorrowRecord;
import org.apache.ibatis.annotations.Param;
import java.util.List;

public interface BorrowRecordMapper {
    List<BorrowRecord> findAll(@Param("keyword") String keyword,
                               @Param("status") Integer status);
    BorrowRecord findById(Integer id);
    int insert(BorrowRecord record);
    int updateStatus(@Param("id") Integer id,
                     @Param("status") Integer status,
                     @Param("returnDate") java.util.Date returnDate);
    int deleteById(Integer id);
    int deleteBatch(@Param("ids") Integer[] ids);
}
