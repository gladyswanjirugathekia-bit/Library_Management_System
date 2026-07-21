package com.bookmanager.mapper;

import com.bookmanager.entity.Book;
import org.apache.ibatis.annotations.Param;
import java.util.List;

public interface BookMapper {
    List<Book> findAll(@Param("keyword") String keyword,
                       @Param("categoryId") Integer categoryId);
    Book findById(Integer id);
    int insert(Book book);
    int update(Book book);
    int deleteById(Integer id);
    int deleteBatch(@Param("ids") Integer[] ids);
    int updateStock(@Param("id") Integer id, @Param("stock") Integer stock);
}
