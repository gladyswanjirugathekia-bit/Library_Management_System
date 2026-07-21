# 图书信息管理系统 — 实施计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 基于 Spring Boot + MyBatis + MySQL + Bootstrap/jQuery 构建图书信息管理系统，包含用户登录注册、图书管理、分类管理、借阅记录管理四大模块。

**Architecture:** 经典三层架构（Controller → Service → Mapper），Spring Boot + MyBatis XML 映射，前端 Bootstrap 5 + jQuery，AJAX + JSON 前后端交互。

**Tech Stack:** Spring Boot 2.7.x, MyBatis, MySQL 8.x, Bootstrap 5, jQuery 3.x, Maven, JSP

---

### Task 1: 项目初始化与基础配置

**Files:**
- Create: `pom.xml`
- Create: `src/main/java/com/bookmanager/BookManagerApplication.java`
- Create: `src/main/resources/application.yml`
- Create: `src/main/java/com/bookmanager/common/Result.java`
- Create: `src/main/java/com/bookmanager/config/WebMvcConfig.java`

- [ ] **Step 1: 创建 Maven 项目 pom.xml**

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0
         http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <parent>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-parent</artifactId>
        <version>2.7.18</version>
    </parent>

    <groupId>com.bookmanager</groupId>
    <artifactId>book-manager</artifactId>
    <version>1.0.0</version>
    <packaging>war</packaging>

    <properties>
        <java.version>1.8</java.version>
    </properties>

    <dependencies>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>
        <dependency>
            <groupId>org.mybatis.spring.boot</groupId>
            <artifactId>mybatis-spring-boot-starter</artifactId>
            <version>2.3.1</version>
        </dependency>
        <dependency>
            <groupId>mysql</groupId>
            <artifactId>mysql-connector-java</artifactId>
            <version>8.0.33</version>
        </dependency>
        <dependency>
            <groupId>org.apache.tomcat.embed</groupId>
            <artifactId>tomcat-embed-jasper</artifactId>
        </dependency>
        <dependency>
            <groupId>javax.servlet</groupId>
            <artifactId>jstl</artifactId>
            <version>1.2</version>
        </dependency>
    </dependencies>

    <build>
        <plugins>
            <plugin>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-maven-plugin</artifactId>
            </plugin>
        </plugins>
    </build>
</project>
```

- [ ] **Step 2: 创建 Spring Boot 启动类**

```java
package com.bookmanager;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
@MapperScan("com.bookmanager.mapper")
public class BookManagerApplication {
    public static void main(String[] args) {
        SpringApplication.run(BookManagerApplication.class, args);
    }
}
```

- [ ] **Step 3: 创建 application.yml 配置文件**

```yaml
server:
  port: 8080
  servlet:
    context-path: /

spring:
  datasource:
    url: jdbc:mysql://localhost:3306/book_manager?useSSL=false&serverTimezone=Asia/Shanghai&characterEncoding=utf-8
    username: root
    password: root
    driver-class-name: com.mysql.cj.jdbc.Driver
  mvc:
    view:
      prefix: /WEB-INF/views/
      suffix: .jsp

mybatis:
  mapper-locations: classpath:mapper/*.xml
  type-aliases-package: com.bookmanager.entity
  configuration:
    map-underscore-to-camel-case: true
```

- [ ] **Step 4: 创建统一响应类 Result.java**

```java
package com.bookmanager.common;

public class Result<T> {
    private int code;
    private String message;
    private T data;

    private Result() {}

    public static <T> Result<T> success(T data) {
        Result<T> r = new Result<>();
        r.code = 200;
        r.message = "操作成功";
        r.data = data;
        return r;
    }

    public static <T> Result<T> success(String message, T data) {
        Result<T> r = new Result<>();
        r.code = 200;
        r.message = message;
        r.data = data;
        return r;
    }

    public static <T> Result<T> error(int code, String message) {
        Result<T> r = new Result<>();
        r.code = code;
        r.message = message;
        r.data = null;
        return r;
    }

    public int getCode() { return code; }
    public void setCode(int code) { this.code = code; }
    public String getMessage() { return message; }
    public void setMessage(String message) { this.message = message; }
    public T getData() { return data; }
    public void setData(T data) { this.data = data; }
}
```

- [ ] **Step 5: 创建 WebMvcConfig 配置类**

```java
package com.bookmanager.config;

import com.bookmanager.interceptor.LoginInterceptor;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
public class WebMvcConfig implements WebMvcConfigurer {

    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        registry.addInterceptor(new LoginInterceptor())
                .addPathPatterns("/**")
                .excludePathPatterns("/", "/login", "/register",
                        "/api/user/login", "/api/user/register",
                        "/static/**", "/css/**", "/js/**", "/lib/**");
    }
}
```

- [ ] **Step 6: 运行 mvn compile 验证项目基础配置正确**

Run: `mvn compile -f pom.xml`
Expected: BUILD SUCCESS

---

### Task 2: 数据库建表与初始化数据

**Files:**
- Create: `sql/init.sql`

- [ ] **Step 1: 编写完整的建表 SQL 和初始数据**

```sql
CREATE DATABASE IF NOT EXISTS book_manager DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE book_manager;

DROP TABLE IF EXISTS borrow_record;
DROP TABLE IF EXISTS book;
DROP TABLE IF EXISTS category;
DROP TABLE IF EXISTS user;

CREATE TABLE user (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(100) NOT NULL,
    email VARCHAR(100),
    phone VARCHAR(20),
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE category (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    description VARCHAR(200)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE book (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(100) NOT NULL,
    author VARCHAR(50) NOT NULL,
    isbn VARCHAR(20),
    category_id INT,
    publisher VARCHAR(100),
    publish_date DATE,
    price DECIMAL(10,2),
    stock INT DEFAULT 0,
    description TEXT,
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES category(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE borrow_record (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    book_id INT NOT NULL,
    borrow_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    return_date DATETIME,
    status TINYINT DEFAULT 0,
    FOREIGN KEY (user_id) REFERENCES user(id),
    FOREIGN KEY (book_id) REFERENCES book(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO user (username, password, email, phone) VALUES
('admin', '123456', 'admin@example.com', '13800000000'),
('zhangsan', '123456', 'zhangsan@example.com', '13800000001');

INSERT INTO category (name, description) VALUES
('计算机科学', '计算机科学与技术相关书籍'),
('文学小说', '文学、小说类书籍'),
('历史地理', '历史、地理类书籍'),
('自然科学', '数学、物理、化学等自然科学书籍');

INSERT INTO book (title, author, isbn, category_id, publisher, publish_date, price, stock, description) VALUES
('深入理解Java虚拟机', '周志明', '978-7-111-34966-4', 1, '机械工业出版社', '2011-06-01', 79.00, 5, 'JVM深度解析'),
('三体', '刘慈欣', '978-7-536-69293-0', 2, '重庆出版社', '2008-01-01', 23.00, 10, '科幻巨作'),
('人类简史', '尤瓦尔·赫拉利', '978-7-508-64778-4', 3, '中信出版社', '2014-11-01', 68.00, 8, '从动物到上帝'),
('算法导论', 'Thomas H.Cormen', '978-7-111-40701-0', 1, '机械工业出版社', '2012-12-01', 128.00, 3, '算法经典教材');

INSERT INTO borrow_record (user_id, book_id, borrow_date, status) VALUES
(2, 1, '2024-01-15 10:30:00', 0),
(2, 3, '2024-02-20 14:00:00', 1);
```

- [ ] **Step 2: 到 MySQL 中执行 init.sql 初始化数据库**

Run: `mysql -u root -p < sql/init.sql`（或使用 Navicat/MySQL Workbench 执行）
Expected: 4 张表创建成功，含初始数据

---

### Task 3: 实体类（Entity）

**Files:**
- Create: `src/main/java/com/bookmanager/entity/User.java`
- Create: `src/main/java/com/bookmanager/entity/Category.java`
- Create: `src/main/java/com/bookmanager/entity/Book.java`
- Create: `src/main/java/com/bookmanager/entity/BorrowRecord.java`

- [ ] **Step 1: 创建 User.java**

```java
package com.bookmanager.entity;

import java.util.Date;

public class User {
    private Integer id;
    private String username;
    private String password;
    private String email;
    private String phone;
    private Date createTime;

    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }
    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }
    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }
    public Date getCreateTime() { return createTime; }
    public void setCreateTime(Date createTime) { this.createTime = createTime; }
}
```

- [ ] **Step 2: 创建 Category.java**

```java
package com.bookmanager.entity;

public class Category {
    private Integer id;
    private String name;
    private String description;

    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
}
```

- [ ] **Step 3: 创建 Book.java（含 Category 关联属性）**

```java
package com.bookmanager.entity;

import java.math.BigDecimal;
import java.util.Date;

public class Book {
    private Integer id;
    private String title;
    private String author;
    private String isbn;
    private Integer categoryId;
    private String publisher;
    private Date publishDate;
    private BigDecimal price;
    private Integer stock;
    private String description;
    private Date createTime;
    private Category category;

    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    public String getAuthor() { return author; }
    public void setAuthor(String author) { this.author = author; }
    public String getIsbn() { return isbn; }
    public void setIsbn(String isbn) { this.isbn = isbn; }
    public Integer getCategoryId() { return categoryId; }
    public void setCategoryId(Integer categoryId) { this.categoryId = categoryId; }
    public String getPublisher() { return publisher; }
    public void setPublisher(String publisher) { this.publisher = publisher; }
    public Date getPublishDate() { return publishDate; }
    public void setPublishDate(Date publishDate) { this.publishDate = publishDate; }
    public BigDecimal getPrice() { return price; }
    public void setPrice(BigDecimal price) { this.price = price; }
    public Integer getStock() { return stock; }
    public void setStock(Integer stock) { this.stock = stock; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public Date getCreateTime() { return createTime; }
    public void setCreateTime(Date createTime) { this.createTime = createTime; }
    public Category getCategory() { return category; }
    public void setCategory(Category category) { this.category = category; }
}
```

- [ ] **Step 4: 创建 BorrowRecord.java（含 User 和 Book 关联属性）**

```java
package com.bookmanager.entity;

import java.util.Date;

public class BorrowRecord {
    private Integer id;
    private Integer userId;
    private Integer bookId;
    private Date borrowDate;
    private Date returnDate;
    private Integer status;
    private User user;
    private Book book;

    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }
    public Integer getUserId() { return userId; }
    public void setUserId(Integer userId) { this.userId = userId; }
    public Integer getBookId() { return bookId; }
    public void setBookId(Integer bookId) { this.bookId = bookId; }
    public Date getBorrowDate() { return borrowDate; }
    public void setBorrowDate(Date borrowDate) { this.borrowDate = borrowDate; }
    public Date getReturnDate() { return returnDate; }
    public void setReturnDate(Date returnDate) { this.returnDate = returnDate; }
    public Integer getStatus() { return status; }
    public void setStatus(Integer status) { this.status = status; }
    public User getUser() { return user; }
    public void setUser(User user) { this.user = user; }
    public Book getBook() { return book; }
    public void setBook(Book book) { this.book = book; }
}
```

- [ ] **Step 5: 运行 mvn compile 验证编译通过**

Run: `mvn compile -f pom.xml`
Expected: BUILD SUCCESS

---

### Task 4: Mapper 层（MyBatis 接口 + XML 映射）

**Files:**
- Create: `src/main/java/com/bookmanager/mapper/UserMapper.java`
- Create: `src/main/resources/mapper/UserMapper.xml`
- Create: `src/main/java/com/bookmanager/mapper/CategoryMapper.java`
- Create: `src/main/resources/mapper/CategoryMapper.xml`
- Create: `src/main/java/com/bookmanager/mapper/BookMapper.java`
- Create: `src/main/resources/mapper/BookMapper.xml`
- Create: `src/main/java/com/bookmanager/mapper/BorrowRecordMapper.java`
- Create: `src/main/resources/mapper/BorrowRecordMapper.xml`

- [ ] **Step 1: 创建 UserMapper.java**

```java
package com.bookmanager.mapper;

import com.bookmanager.entity.User;
import org.apache.ibatis.annotations.Param;

public interface UserMapper {
    User findByUsername(String username);
    User findById(Integer id);
    int insert(User user);
}
```

- [ ] **Step 2: 创建 UserMapper.xml**

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE mapper PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN"
        "http://mybatis.org/dtd/mybatis-3-mapper.dtd">
<mapper namespace="com.bookmanager.mapper.UserMapper">

    <select id="findByUsername" resultType="User">
        SELECT * FROM user WHERE username = #{username}
    </select>

    <select id="findById" resultType="User">
        SELECT * FROM user WHERE id = #{id}
    </select>

    <insert id="insert" parameterType="User" useGeneratedKeys="true" keyProperty="id">
        INSERT INTO user (username, password, email, phone, create_time)
        VALUES (#{username}, #{password}, #{email}, #{phone}, NOW())
    </insert>

</mapper>
```

- [ ] **Step 3: 创建 CategoryMapper.java**

```java
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
```

- [ ] **Step 4: 创建 CategoryMapper.xml**

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE mapper PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN"
        "http://mybatis.org/dtd/mybatis-3-mapper.dtd">
<mapper namespace="com.bookmanager.mapper.CategoryMapper">

    <select id="findAll" resultType="Category">
        SELECT * FROM category
        <where>
            <if test="keyword != null and keyword != ''">
                AND name LIKE CONCAT('%', #{keyword}, '%')
            </if>
        </where>
        ORDER BY id
    </select>

    <select id="findById" resultType="Category">
        SELECT * FROM category WHERE id = #{id}
    </select>

    <insert id="insert" parameterType="Category" useGeneratedKeys="true" keyProperty="id">
        INSERT INTO category (name, description)
        VALUES (#{name}, #{description})
    </insert>

    <update id="update" parameterType="Category">
        UPDATE category SET name = #{name}, description = #{description}
        WHERE id = #{id}
    </update>

    <delete id="deleteById">
        DELETE FROM category WHERE id = #{id}
    </delete>

    <delete id="deleteBatch">
        DELETE FROM category WHERE id IN
        <foreach collection="ids" item="id" open="(" separator="," close=")">
            #{id}
        </foreach>
    </delete>

    <select id="countBookByCategoryId" resultType="int">
        SELECT COUNT(*) FROM book WHERE category_id = #{categoryId}
    </select>

</mapper>
```

- [ ] **Step 5: 创建 BookMapper.java**

```java
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
```

- [ ] **Step 6: 创建 BookMapper.xml（含关联映射 association）**

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE mapper PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN"
        "http://mybatis.org/dtd/mybatis-3-mapper.dtd">
<mapper namespace="com.bookmanager.mapper.BookMapper">

    <resultMap id="bookWithCategory" type="Book">
        <id property="id" column="id"/>
        <result property="title" column="title"/>
        <result property="author" column="author"/>
        <result property="isbn" column="isbn"/>
        <result property="categoryId" column="category_id"/>
        <result property="publisher" column="publisher"/>
        <result property="publishDate" column="publish_date"/>
        <result property="price" column="price"/>
        <result property="stock" column="stock"/>
        <result property="description" column="description"/>
        <result property="createTime" column="create_time"/>
        <association property="category" javaType="Category">
            <id property="id" column="category_id"/>
            <result property="name" column="category_name"/>
        </association>
    </resultMap>

    <select id="findAll" resultMap="bookWithCategory">
        SELECT b.*, c.name AS category_name
        FROM book b
        LEFT JOIN category c ON b.category_id = c.id
        <where>
            <if test="keyword != null and keyword != ''">
                AND (b.title LIKE CONCAT('%', #{keyword}, '%')
                     OR b.author LIKE CONCAT('%', #{keyword}, '%')
                     OR b.isbn LIKE CONCAT('%', #{keyword}, '%'))
            </if>
            <if test="categoryId != null">
                AND b.category_id = #{categoryId}
            </if>
        </where>
        ORDER BY b.id
    </select>

    <select id="findById" resultMap="bookWithCategory">
        SELECT b.*, c.name AS category_name
        FROM book b
        LEFT JOIN category c ON b.category_id = c.id
        WHERE b.id = #{id}
    </select>

    <insert id="insert" parameterType="Book" useGeneratedKeys="true" keyProperty="id">
        INSERT INTO book (title, author, isbn, category_id, publisher,
                          publish_date, price, stock, description, create_time)
        VALUES (#{title}, #{author}, #{isbn}, #{categoryId}, #{publisher},
                #{publishDate}, #{price}, #{stock}, #{description}, NOW())
    </insert>

    <update id="update" parameterType="Book">
        UPDATE book SET title = #{title}, author = #{author}, isbn = #{isbn},
                        category_id = #{categoryId}, publisher = #{publisher},
                        publish_date = #{publishDate}, price = #{price},
                        stock = #{stock}, description = #{description}
        WHERE id = #{id}
    </update>

    <delete id="deleteById">
        DELETE FROM book WHERE id = #{id}
    </delete>

    <delete id="deleteBatch">
        DELETE FROM book WHERE id IN
        <foreach collection="ids" item="id" open="(" separator="," close=")">
            #{id}
        </foreach>
    </delete>

    <update id="updateStock">
        UPDATE book SET stock = #{stock} WHERE id = #{id}
    </update>

</mapper>
```

- [ ] **Step 7: 创建 BorrowRecordMapper.java**

```java
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
```

- [ ] **Step 8: 创建 BorrowRecordMapper.xml（含双关联映射）**

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE mapper PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN"
        "http://mybatis.org/dtd/mybatis-3-mapper.dtd">
<mapper namespace="com.bookmanager.mapper.BorrowRecordMapper">

    <resultMap id="borrowDetail" type="BorrowRecord">
        <id property="id" column="id"/>
        <result property="userId" column="user_id"/>
        <result property="bookId" column="book_id"/>
        <result property="borrowDate" column="borrow_date"/>
        <result property="returnDate" column="return_date"/>
        <result property="status" column="status"/>
        <association property="user" javaType="User">
            <id property="id" column="user_id"/>
            <result property="username" column="username"/>
        </association>
        <association property="book" javaType="Book">
            <id property="id" column="book_id"/>
            <result property="title" column="book_title"/>
        </association>
    </resultMap>

    <select id="findAll" resultMap="borrowDetail">
        SELECT br.*, u.username, b.title AS book_title
        FROM borrow_record br
        LEFT JOIN user u ON br.user_id = u.id
        LEFT JOIN book b ON br.book_id = b.id
        <where>
            <if test="keyword != null and keyword != ''">
                AND (u.username LIKE CONCAT('%', #{keyword}, '%')
                     OR b.title LIKE CONCAT('%', #{keyword}, '%'))
            </if>
            <if test="status != null">
                AND br.status = #{status}
            </if>
        </where>
        ORDER BY br.id DESC
    </select>

    <select id="findById" resultMap="borrowDetail">
        SELECT br.*, u.username, b.title AS book_title
        FROM borrow_record br
        LEFT JOIN user u ON br.user_id = u.id
        LEFT JOIN book b ON br.book_id = b.id
        WHERE br.id = #{id}
    </select>

    <insert id="insert" parameterType="BorrowRecord" useGeneratedKeys="true" keyProperty="id">
        INSERT INTO borrow_record (user_id, book_id, borrow_date, status)
        VALUES (#{userId}, #{bookId}, NOW(), 0)
    </insert>

    <update id="updateStatus">
        UPDATE borrow_record
        SET status = #{status}, return_date = #{returnDate}
        WHERE id = #{id}
    </update>

    <delete id="deleteById">
        DELETE FROM borrow_record WHERE id = #{id}
    </delete>

    <delete id="deleteBatch">
        DELETE FROM borrow_record WHERE id IN
        <foreach collection="ids" item="id" open="(" separator="," close=")">
            #{id}
        </foreach>
    </delete>

</mapper>
```

- [ ] **Step 9: 运行 mvn compile 验证编译通过**

Run: `mvn compile -f pom.xml`
Expected: BUILD SUCCESS

---

### Task 5: Service 层

**Files:**
- Create: `src/main/java/com/bookmanager/service/UserService.java`
- Create: `src/main/java/com/bookmanager/service/CategoryService.java`
- Create: `src/main/java/com/bookmanager/service/BookService.java`
- Create: `src/main/java/com/bookmanager/service/BorrowRecordService.java`

- [ ] **Step 1: 创建 UserService.java**

```java
package com.bookmanager.service;

import com.bookmanager.entity.User;
import com.bookmanager.mapper.UserMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class UserService {

    @Autowired
    private UserMapper userMapper;

    public User login(String username, String password) {
        User user = userMapper.findByUsername(username);
        if (user != null && user.getPassword().equals(password)) {
            return user;
        }
        return null;
    }

    public boolean register(User user) {
        User exist = userMapper.findByUsername(user.getUsername());
        if (exist != null) {
            return false;
        }
        userMapper.insert(user);
        return true;
    }

    public User findById(Integer id) {
        return userMapper.findById(id);
    }
}
```

- [ ] **Step 2: 创建 CategoryService.java**

```java
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
```

- [ ] **Step 3: 创建 BookService.java**

```java
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
```

- [ ] **Step 4: 创建 BorrowRecordService.java**

```java
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
```

- [ ] **Step 5: 运行 mvn compile 验证编译通过**

Run: `mvn compile -f pom.xml`
Expected: BUILD SUCCESS

---

### Task 6: 登录拦截器

**Files:**
- Create: `src/main/java/com/bookmanager/interceptor/LoginInterceptor.java`

- [ ] **Step 1: 创建 LoginInterceptor.java**

```java
package com.bookmanager.interceptor;

import org.springframework.web.servlet.HandlerInterceptor;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

public class LoginInterceptor implements HandlerInterceptor {

    @Override
    public boolean preHandle(HttpServletRequest request,
                             HttpServletResponse response,
                             Object handler) throws Exception {
        HttpSession session = request.getSession();
        Object user = session.getAttribute("loginUser");
        if (user == null) {
            response.sendRedirect("/login");
            return false;
        }
        return true;
    }
}
```

**注意：** WebMvcConfig 已在 Task 1 中创建并注册了此拦截器。

- [ ] **Step 2: 运行 mvn compile 验证编译通过**

Run: `mvn compile -f pom.xml`
Expected: BUILD SUCCESS

---

### Task 7: Controller 层 — 页面跳转与用户登录注册

**Files:**
- Create: `src/main/java/com/bookmanager/controller/PageController.java`
- Create: `src/main/java/com/bookmanager/controller/UserController.java`

- [ ] **Step 1: 创建 PageController.java**

```java
package com.bookmanager.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class PageController {

    @GetMapping({"/", "/login"})
    public String loginPage() {
        return "login";
    }

    @GetMapping("/register")
    public String registerPage() {
        return "register";
    }

    @GetMapping("/main")
    public String mainPage() {
        return "main";
    }
}
```

- [ ] **Step 2: 创建 UserController.java**

```java
package com.bookmanager.controller;

import com.bookmanager.common.Result;
import com.bookmanager.entity.User;
import com.bookmanager.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpSession;

@RestController
@RequestMapping("/api/user")
public class UserController {

    @Autowired
    private UserService userService;

    @PostMapping("/login")
    public Result<User> login(@RequestBody User user, HttpSession session) {
        User loginUser = userService.login(user.getUsername(), user.getPassword());
        if (loginUser != null) {
            loginUser.setPassword(null);
            session.setAttribute("loginUser", loginUser);
            return Result.success("登录成功", loginUser);
        }
        return Result.error(401, "用户名或密码错误");
    }

    @PostMapping("/register")
    public Result<Void> register(@RequestBody User user) {
        if (user.getUsername() == null || user.getUsername().trim().isEmpty()) {
            return Result.error(400, "用户名不能为空");
        }
        if (user.getPassword() == null || user.getPassword().trim().isEmpty()) {
            return Result.error(400, "密码不能为空");
        }
        boolean success = userService.register(user);
        if (success) {
            return Result.success("注册成功", null);
        }
        return Result.error(400, "用户名已存在");
    }

    @PostMapping("/logout")
    public Result<Void> logout(HttpSession session) {
        session.invalidate();
        return Result.success("已注销", null);
    }

    @GetMapping("/current")
    public Result<User> currentUser(HttpSession session) {
        User user = (User) session.getAttribute("loginUser");
        if (user != null) {
            return Result.success(user);
        }
        return Result.error(401, "未登录");
    }
}
```

- [ ] **Step 3: 运行 mvn compile 验证编译通过**

Run: `mvn compile -f pom.xml`
Expected: BUILD SUCCESS

---

### Task 8: Controller 层 — 分类管理 API

**Files:**
- Create: `src/main/java/com/bookmanager/controller/CategoryController.java`

- [ ] **Step 1: 创建 CategoryController.java**

```java
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
```

- [ ] **Step 2: 运行 mvn compile 验证编译通过**

Run: `mvn compile -f pom.xml`
Expected: BUILD SUCCESS

---

### Task 9: Controller 层 — 图书管理 API

**Files:**
- Create: `src/main/java/com/bookmanager/controller/BookController.java`

- [ ] **Step 1: 创建 BookController.java**

```java
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
```

- [ ] **Step 2: 运行 mvn compile 验证编译通过**

Run: `mvn compile -f pom.xml`
Expected: BUILD SUCCESS

---

### Task 10: Controller 层 — 借阅记录 API

**Files:**
- Create: `src/main/java/com/bookmanager/controller/BorrowRecordController.java`

- [ ] **Step 1: 创建 BorrowRecordController.java**

```java
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
```

- [ ] **Step 2: 运行 mvn compile 验证编译通过**

Run: `mvn compile -f pom.xml`
Expected: BUILD SUCCESS

---

### Task 11: 前端页面 — 登录与注册页面

**Files:**
- Create: `src/main/webapp/WEB-INF/views/login.jsp`
- Create: `src/main/webapp/WEB-INF/views/register.jsp`
- Create: `src/main/webapp/static/css/style.css`

- [ ] **Step 1: 创建 login.jsp**

```jsp
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>图书信息管理系统 - 登录</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="/static/css/style.css">
</head>
<body class="bg-light">
<div class="container">
    <div class="row justify-content-center align-items-center vh-100">
        <div class="col-md-4">
            <div class="card shadow">
                <div class="card-body p-5">
                    <h3 class="text-center mb-4">图书信息管理系统</h3>
                    <div class="mb-3">
                        <label for="username" class="form-label">用户名</label>
                        <input type="text" class="form-control" id="username" placeholder="请输入用户名">
                    </div>
                    <div class="mb-3">
                        <label for="password" class="form-label">密码</label>
                        <input type="password" class="form-control" id="password" placeholder="请输入密码">
                    </div>
                    <div id="loginError" class="alert alert-danger d-none" role="alert"></div>
                    <button type="button" class="btn btn-primary w-100" onclick="login()">登录</button>
                    <div class="text-center mt-3">
                        <a href="/register">还没有账号？立即注册</a>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
<script src="https://cdn.jsdelivr.net/npm/jquery@3.7.0/dist/jquery.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
function login() {
    var username = $('#username').val();
    var password = $('#password').val();
    if (!username || !password) {
        $('#loginError').removeClass('d-none').text('用户名和密码不能为空');
        return;
    }
    $.ajax({
        url: '/api/user/login',
        type: 'POST',
        contentType: 'application/json',
        data: JSON.stringify({ username: username, password: password }),
        success: function(res) {
            if (res.code === 200) {
                window.location.href = '/main';
            } else {
                $('#loginError').removeClass('d-none').text(res.message);
            }
        },
        error: function() {
            $('#loginError').removeClass('d-none').text('登录失败，请稍后重试');
        }
    });
}
$(document).keydown(function(e) {
    if (e.keyCode === 13) login();
});
</script>
</body>
</html>
```

- [ ] **Step 2: 创建 register.jsp**

```jsp
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>图书信息管理系统 - 注册</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="/static/css/style.css">
</head>
<body class="bg-light">
<div class="container">
    <div class="row justify-content-center align-items-center vh-100">
        <div class="col-md-4">
            <div class="card shadow">
                <div class="card-body p-5">
                    <h3 class="text-center mb-4">用户注册</h3>
                    <div class="mb-3">
                        <label for="username" class="form-label">用户名</label>
                        <input type="text" class="form-control" id="username" placeholder="请输入用户名">
                    </div>
                    <div class="mb-3">
                        <label for="password" class="form-label">密码</label>
                        <input type="password" class="form-control" id="password" placeholder="请输入密码">
                    </div>
                    <div class="mb-3">
                        <label for="email" class="form-label">邮箱</label>
                        <input type="email" class="form-control" id="email" placeholder="请输入邮箱">
                    </div>
                    <div class="mb-3">
                        <label for="phone" class="form-label">手机号</label>
                        <input type="text" class="form-control" id="phone" placeholder="请输入手机号">
                    </div>
                    <div id="regMessage" class="alert d-none" role="alert"></div>
                    <button type="button" class="btn btn-primary w-100" onclick="register()">注册</button>
                    <div class="text-center mt-3">
                        <a href="/login">已有账号？返回登录</a>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
<script src="https://cdn.jsdelivr.net/npm/jquery@3.7.0/dist/jquery.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
function register() {
    var username = $('#username').val();
    var password = $('#password').val();
    var email = $('#email').val();
    var phone = $('#phone').val();
    if (!username || !password) {
        $('#regMessage').removeClass('d-none alert-success').addClass('alert-danger').text('用户名和密码不能为空');
        return;
    }
    $.ajax({
        url: '/api/user/register',
        type: 'POST',
        contentType: 'application/json',
        data: JSON.stringify({ username: username, password: password, email: email, phone: phone }),
        success: function(res) {
            $('#regMessage').removeClass('d-none');
            if (res.code === 200) {
                $('#regMessage').addClass('alert-success').removeClass('alert-danger').text('注册成功，即将跳转...');
                setTimeout(function() { window.location.href = '/login'; }, 1500);
            } else {
                $('#regMessage').addClass('alert-danger').removeClass('alert-success').text(res.message);
            }
        },
        error: function() {
            $('#regMessage').removeClass('d-none alert-success').addClass('alert-danger').text('注册失败，请稍后重试');
        }
    });
}
</script>
</body>
</html>
```

- [ ] **Step 3: 创建 style.css**

```css
body { font-family: "Microsoft YaHei", sans-serif; }
.sidebar {
    min-height: 100vh;
    background: #343a40;
    padding-top: 20px;
}
.sidebar .nav-link {
    color: rgba(255,255,255,.75);
    padding: 12px 20px;
    border-radius: 0;
}
.sidebar .nav-link:hover,
.sidebar .nav-link.active {
    color: #fff;
    background: rgba(255,255,255,.1);
}
.main-content { padding: 20px; }
.user-info { padding: 10px 20px; border-bottom: 1px solid #dee2e6; }
.module-content { display: none; }
.module-content.active { display: block; }
.card { border-radius: 10px; }
.btn-group-actions .btn { padding: 2px 8px; font-size: 13px; }
```

---

### Task 12: 前端页面 — 主页面（左右布局 + 三个模块）

**Files:**
- Create: `src/main/webapp/WEB-INF/views/main.jsp`
- Create: `src/main/webapp/static/js/main.js`

- [ ] **Step 1: 创建 main.jsp**

```jsp
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>图书信息管理系统</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="/static/css/style.css">
</head>
<body>
<div class="container-fluid">
    <div class="row">
        <div class="col-md-2 sidebar d-flex flex-column p-0">
            <h5 class="text-white text-center py-3 mb-0 border-bottom border-secondary">图书管理系统</h5>
            <nav class="nav flex-column mt-2">
                <a class="nav-link active" href="#" data-module="book">图书管理</a>
                <a class="nav-link" href="#" data-module="category">分类管理</a>
                <a class="nav-link" href="#" data-module="borrow">借阅记录</a>
            </nav>
        </div>
        <div class="col-md-10 p-0">
            <div class="user-info d-flex justify-content-between align-items-center bg-white">
                <span>欢迎，<strong id="currentUser"></strong></span>
                <button class="btn btn-sm btn-outline-danger" onclick="logout()">注销</button>
            </div>
            <div class="main-content">
                <div id="module-book" class="module-content active">
                    <div class="card">
                        <div class="card-body">
                            <h5 class="card-title">图书信息管理</h5>
                            <div class="row mb-3">
                                <div class="col-md-3">
                                    <input type="text" class="form-control" id="bookKeyword" placeholder="书名/作者/ISBN">
                                </div>
                                <div class="col-md-2">
                                    <select class="form-select" id="bookCategoryFilter">
                                        <option value="">全部分类</option>
                                    </select>
                                </div>
                                <div class="col-md-3">
                                    <button class="btn btn-primary" onclick="loadBooks()">搜索</button>
                                    <button class="btn btn-success" onclick="showAddBookModal()">添加图书</button>
                                </div>
                                <div class="col-md-4 text-end">
                                    <button class="btn btn-danger btn-sm" onclick="batchDeleteBooks()">批量删除</button>
                                </div>
                            </div>
                            <table class="table table-bordered table-hover">
                                <thead class="table-dark">
                                    <tr>
                                        <th width="40"><input type="checkbox" id="bookSelectAll"></th>
                                        <th>ID</th><th>书名</th><th>作者</th><th>ISBN</th>
                                        <th>分类</th><th>出版社</th><th>价格</th><th>库存</th>
                                        <th>操作</th>
                                    </tr>
                                </thead>
                                <tbody id="bookTableBody"></tbody>
                            </table>
                        </div>
                    </div>
                </div>

                <div id="module-category" class="module-content">
                    <div class="card">
                        <div class="card-body">
                            <h5 class="card-title">分类管理</h5>
                            <div class="row mb-3">
                                <div class="col-md-3">
                                    <input type="text" class="form-control" id="categoryKeyword" placeholder="分类名称">
                                </div>
                                <div class="col-md-3">
                                    <button class="btn btn-primary" onclick="loadCategories()">搜索</button>
                                    <button class="btn btn-success" onclick="showAddCategoryModal()">添加分类</button>
                                </div>
                                <div class="col-md-6 text-end">
                                    <button class="btn btn-danger btn-sm" onclick="batchDeleteCategories()">批量删除</button>
                                </div>
                            </div>
                            <table class="table table-bordered table-hover">
                                <thead class="table-dark">
                                    <tr>
                                        <th width="40"><input type="checkbox" id="categorySelectAll"></th>
                                        <th>ID</th><th>名称</th><th>描述</th><th>操作</th>
                                    </tr>
                                </thead>
                                <tbody id="categoryTableBody"></tbody>
                            </table>
                        </div>
                    </div>
                </div>

                <div id="module-borrow" class="module-content">
                    <div class="card">
                        <div class="card-body">
                            <h5 class="card-title">借阅记录管理</h5>
                            <div class="row mb-3">
                                <div class="col-md-3">
                                    <input type="text" class="form-control" id="borrowKeyword" placeholder="用户名/书名">
                                </div>
                                <div class="col-md-2">
                                    <select class="form-select" id="borrowStatusFilter">
                                        <option value="">全部状态</option>
                                        <option value="0">借出中</option>
                                        <option value="1">已归还</option>
                                    </select>
                                </div>
                                <div class="col-md-3">
                                    <button class="btn btn-primary" onclick="loadBorrows()">搜索</button>
                                    <button class="btn btn-success" onclick="showAddBorrowModal()">新增借阅</button>
                                </div>
                                <div class="col-md-4 text-end">
                                    <button class="btn btn-danger btn-sm" onclick="batchDeleteBorrows()">批量删除</button>
                                </div>
                            </div>
                            <table class="table table-bordered table-hover">
                                <thead class="table-dark">
                                    <tr>
                                        <th width="40"><input type="checkbox" id="borrowSelectAll"></th>
                                        <th>ID</th><th>用户</th><th>书名</th><th>借出时间</th>
                                        <th>归还时间</th><th>状态</th><th>操作</th>
                                    </tr>
                                </thead>
                                <tbody id="borrowTableBody"></tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<div class="modal fade" id="bookModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="bookModalTitle">添加图书</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <input type="hidden" id="editBookId">
                <div class="mb-2">
                    <label class="form-label">书名</label>
                    <input type="text" class="form-control" id="bookTitle">
                </div>
                <div class="mb-2">
                    <label class="form-label">作者</label>
                    <input type="text" class="form-control" id="bookAuthor">
                </div>
                <div class="mb-2">
                    <label class="form-label">ISBN</label>
                    <input type="text" class="form-control" id="bookIsbn">
                </div>
                <div class="mb-2">
                    <label class="form-label">分类</label>
                    <select class="form-select" id="bookCategoryId"></select>
                </div>
                <div class="mb-2">
                    <label class="form-label">出版社</label>
                    <input type="text" class="form-control" id="bookPublisher">
                </div>
                <div class="mb-2">
                    <label class="form-label">出版日期</label>
                    <input type="date" class="form-control" id="bookPublishDate">
                </div>
                <div class="mb-2">
                    <label class="form-label">价格</label>
                    <input type="number" step="0.01" class="form-control" id="bookPrice">
                </div>
                <div class="mb-2">
                    <label class="form-label">库存</label>
                    <input type="number" class="form-control" id="bookStock" value="0">
                </div>
                <div class="mb-2">
                    <label class="form-label">简介</label>
                    <textarea class="form-control" id="bookDescription" rows="3"></textarea>
                </div>
            </div>
            <div class="modal-footer">
                <button class="btn btn-secondary" data-bs-dismiss="modal">取消</button>
                <button class="btn btn-primary" onclick="saveBook()">保存</button>
            </div>
        </div>
    </div>
</div>

<div class="modal fade" id="categoryModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="categoryModalTitle">添加分类</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <input type="hidden" id="editCategoryId">
                <div class="mb-2">
                    <label class="form-label">分类名称</label>
                    <input type="text" class="form-control" id="categoryName">
                </div>
                <div class="mb-2">
                    <label class="form-label">描述</label>
                    <textarea class="form-control" id="categoryDescription" rows="3"></textarea>
                </div>
            </div>
            <div class="modal-footer">
                <button class="btn btn-secondary" data-bs-dismiss="modal">取消</button>
                <button class="btn btn-primary" onclick="saveCategory()">保存</button>
            </div>
        </div>
    </div>
</div>

<div class="modal fade" id="borrowModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">新增借阅</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <div class="mb-2">
                    <label class="form-label">用户</label>
                    <select class="form-select" id="borrowUserId"></select>
                </div>
                <div class="mb-2">
                    <label class="form-label">图书</label>
                    <select class="form-select" id="borrowBookId"></select>
                </div>
            </div>
            <div class="modal-footer">
                <button class="btn btn-secondary" data-bs-dismiss="modal">取消</button>
                <button class="btn btn-primary" onclick="saveBorrow()">确认借阅</button>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/jquery@3.7.0/dist/jquery.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script src="/static/js/main.js"></script>
</body>
</html>
```

- [ ] **Step 2: 创建 main.js**

```javascript
$(function() {
    loadUserInfo();
    loadBooks();
    loadCategoriesForFilter();

    $('.sidebar .nav-link').click(function(e) {
        e.preventDefault();
        $('.sidebar .nav-link').removeClass('active');
        $(this).addClass('active');
        var module = $(this).data('module');
        $('.module-content').removeClass('active');
        $('#module-' + module).addClass('active');
        if (module === 'book') loadBooks();
        if (module === 'category') loadCategories();
        if (module === 'borrow') loadBorrows();
    });

    $('#bookSelectAll').change(function() {
        $('.book-checkbox').prop('checked', $(this).prop('checked'));
    });
    $('#categorySelectAll').change(function() {
        $('.category-checkbox').prop('checked', $(this).prop('checked'));
    });
    $('#borrowSelectAll').change(function() {
        $('.borrow-checkbox').prop('checked', $(this).prop('checked'));
    });
});

function loadUserInfo() {
    $.get('/api/user/current', function(res) {
        if (res.code === 200) {
            $('#currentUser').text(res.data.username);
        }
    });
}

function logout() {
    $.post('/api/user/logout', function() {
        window.location.href = '/login';
    });
}

function loadBooks() {
    var keyword = $('#bookKeyword').val();
    var categoryId = $('#bookCategoryFilter').val();
    $.get('/api/books', { keyword: keyword, categoryId: categoryId }, function(res) {
        var html = '';
        if (res.code === 200 && res.data) {
            $.each(res.data, function(i, book) {
                var catName = book.category ? book.category.name : '-';
                html += '<tr>';
                html += '<td><input type="checkbox" class="book-checkbox" value="' + book.id + '"></td>';
                html += '<td>' + book.id + '</td>';
                html += '<td>' + book.title + '</td>';
                html += '<td>' + book.author + '</td>';
                html += '<td>' + book.isbn + '</td>';
                html += '<td>' + catName + '</td>';
                html += '<td>' + book.publisher + '</td>';
                html += '<td>' + book.price + '</td>';
                html += '<td>' + book.stock + '</td>';
                html += '<td class="btn-group-actions">';
                html += '<button class="btn btn-primary btn-sm" onclick="editBook(' + book.id + ')">编辑</button> ';
                html += '<button class="btn btn-danger btn-sm" onclick="deleteBook(' + book.id + ')">删除</button>';
                html += '</td></tr>';
            });
        }
        if (!res.data || res.data.length === 0) {
            html = '<tr><td colspan="10" class="text-center">暂无数据</td></tr>';
        }
        $('#bookTableBody').html(html);
    });
}

function loadCategoriesForFilter() {
    $.get('/api/categories', function(res) {
        if (res.code === 200 && res.data) {
            $.each(res.data, function(i, cat) {
                $('#bookCategoryFilter').append('<option value="' + cat.id + '">' + cat.name + '</option>');
                $('#bookCategoryId').append('<option value="' + cat.id + '">' + cat.name + '</option>');
            });
        }
    });
}

function showAddBookModal() {
    $('#bookModalTitle').text('添加图书');
    $('#editBookId').val('');
    $('#bookTitle').val('');
    $('#bookAuthor').val('');
    $('#bookIsbn').val('');
    $('#bookCategoryId').val('');
    $('#bookPublisher').val('');
    $('#bookPublishDate').val('');
    $('#bookPrice').val('');
    $('#bookStock').val(0);
    $('#bookDescription').val('');
    $('#bookModal').modal('show');
}

function editBook(id) {
    $.get('/api/books', function(res) {
        if (res.code === 200 && res.data) {
            var book = res.data.find(function(b) { return b.id === id });
            if (book) {
                $('#bookModalTitle').text('修改图书');
                $('#editBookId').val(book.id);
                $('#bookTitle').val(book.title);
                $('#bookAuthor').val(book.author);
                $('#bookIsbn').val(book.isbn);
                $('#bookCategoryId').val(book.categoryId);
                $('#bookPublisher').val(book.publisher);
                if (book.publishDate) {
                    var d = new Date(book.publishDate);
                    $('#bookPublishDate').val(d.toISOString().split('T')[0]);
                }
                $('#bookPrice').val(book.price);
                $('#bookStock').val(book.stock);
                $('#bookDescription').val(book.description);
                $('#bookModal').modal('show');
            }
        }
    });
}

function saveBook() {
    var id = $('#editBookId').val();
    var data = {
        title: $('#bookTitle').val(),
        author: $('#bookAuthor').val(),
        isbn: $('#bookIsbn').val(),
        categoryId: $('#bookCategoryId').val() ? parseInt($('#bookCategoryId').val()) : null,
        publisher: $('#bookPublisher').val(),
        publishDate: $('#bookPublishDate').val(),
        price: $('#bookPrice').val() ? parseFloat($('#bookPrice').val()) : null,
        stock: parseInt($('#bookStock').val()) || 0,
        description: $('#bookDescription').val()
    };
    var url = id ? '/api/books/' + id : '/api/books';
    var type = id ? 'PUT' : 'POST';
    $.ajax({
        url: url,
        type: type,
        contentType: 'application/json',
        data: JSON.stringify(data),
        success: function(res) {
            if (res.code === 200) {
                $('#bookModal').modal('hide');
                loadBooks();
            } else {
                alert(res.message);
            }
        }
    });
}

function deleteBook(id) {
    if (!confirm('确定删除该图书吗？')) return;
    $.ajax({
        url: '/api/books/' + id,
        type: 'DELETE',
        success: function(res) { if (res.code === 200) loadBooks(); else alert(res.message); }
    });
}

function batchDeleteBooks() {
    var ids = [];
    $('.book-checkbox:checked').each(function() { ids.push(parseInt($(this).val())); });
    if (ids.length === 0) { alert('请选择要删除的图书'); return; }
    if (!confirm('确定删除选中的 ' + ids.length + ' 本图书吗？')) return;
    $.ajax({
        url: '/api/books/batch',
        type: 'DELETE',
        contentType: 'application/json',
        data: JSON.stringify(ids),
        success: function(res) { if (res.code === 200) loadBooks(); else alert(res.message); }
    });
}

function loadCategories() {
    var keyword = $('#categoryKeyword').val();
    $.get('/api/categories', { keyword: keyword }, function(res) {
        var html = '';
        if (res.code === 200 && res.data) {
            $.each(res.data, function(i, cat) {
                html += '<tr>';
                html += '<td><input type="checkbox" class="category-checkbox" value="' + cat.id + '"></td>';
                html += '<td>' + cat.id + '</td>';
                html += '<td>' + cat.name + '</td>';
                html += '<td>' + cat.description + '</td>';
                html += '<td class="btn-group-actions">';
                html += '<button class="btn btn-primary btn-sm" onclick="editCategory(' + cat.id + ')">编辑</button> ';
                html += '<button class="btn btn-danger btn-sm" onclick="deleteCategory(' + cat.id + ')">删除</button>';
                html += '</td></tr>';
            });
        }
        if (!res.data || res.data.length === 0) {
            html = '<tr><td colspan="4" class="text-center">暂无数据</td></tr>';
        }
        $('#categoryTableBody').html(html);
    });
}

function showAddCategoryModal() {
    $('#categoryModalTitle').text('添加分类');
    $('#editCategoryId').val('');
    $('#categoryName').val('');
    $('#categoryDescription').val('');
    $('#categoryModal').modal('show');
}

function editCategory(id) {
    $.get('/api/categories', function(res) {
        if (res.code === 200 && res.data) {
            var cat = res.data.find(function(c) { return c.id === id });
            if (cat) {
                $('#categoryModalTitle').text('修改分类');
                $('#editCategoryId').val(cat.id);
                $('#categoryName').val(cat.name);
                $('#categoryDescription').val(cat.description);
                $('#categoryModal').modal('show');
            }
        }
    });
}

function saveCategory() {
    var id = $('#editCategoryId').val();
    var data = {
        name: $('#categoryName').val(),
        description: $('#categoryDescription').val()
    };
    var url = id ? '/api/categories/' + id : '/api/categories';
    var type = id ? 'PUT' : 'POST';
    $.ajax({
        url: url, type: type, contentType: 'application/json',
        data: JSON.stringify(data),
        success: function(res) {
            if (res.code === 200) { $('#categoryModal').modal('hide'); loadCategories(); }
            else alert(res.message);
        }
    });
}

function deleteCategory(id) {
    if (!confirm('确定删除该分类吗？')) return;
    $.ajax({
        url: '/api/categories/' + id, type: 'DELETE',
        success: function(res) { if (res.code === 200) loadCategories(); else alert(res.message); }
    });
}

function batchDeleteCategories() {
    var ids = [];
    $('.category-checkbox:checked').each(function() { ids.push(parseInt($(this).val())); });
    if (ids.length === 0) { alert('请选择要删除的分类'); return; }
    if (!confirm('确定删除选中的 ' + ids.length + ' 个分类吗？')) return;
    $.ajax({
        url: '/api/categories/batch', type: 'DELETE', contentType: 'application/json',
        data: JSON.stringify(ids),
        success: function(res) { if (res.code === 200) loadCategories(); else alert(res.message); }
    });
}

function loadBorrows() {
    var keyword = $('#borrowKeyword').val();
    var status = $('#borrowStatusFilter').val();
    $.get('/api/borrows', { keyword: keyword, status: status }, function(res) {
        var html = '';
        if (res.code === 200 && res.data) {
            $.each(res.data, function(i, br) {
                var uname = br.user ? br.user.username : '-';
                var bname = br.book ? br.book.title : '-';
                var statusText = br.status === 0 ? '<span class="badge bg-warning text-dark">借出中</span>' : '<span class="badge bg-success">已归还</span>';
                html += '<tr>';
                html += '<td><input type="checkbox" class="borrow-checkbox" value="' + br.id + '"></td>';
                html += '<td>' + br.id + '</td>';
                html += '<td>' + uname + '</td>';
                html += '<td>' + bname + '</td>';
                html += '<td>' + br.borrowDate + '</td>';
                html += '<td>' + (br.returnDate || '-') + '</td>';
                html += '<td>' + statusText + '</td>';
                html += '<td class="btn-group-actions">';
                if (br.status === 0) {
                    html += '<button class="btn btn-warning btn-sm" onclick="returnBook(' + br.id + ')">归还</button> ';
                }
                html += '<button class="btn btn-danger btn-sm" onclick="deleteBorrow(' + br.id + ')">删除</button>';
                html += '</td></tr>';
            });
        }
        if (!res.data || res.data.length === 0) {
            html = '<tr><td colspan="8" class="text-center">暂无数据</td></tr>';
        }
        $('#borrowTableBody').html(html);
    });
}

function showAddBorrowModal() {
    $.get('/api/user/current', function(res) {
        if (res.code === 200) {
            $('#borrowUserId').html('<option value="' + res.data.id + '">' + res.data.username + '</option>');
        }
        $.get('/api/books', function(r) {
            if (r.code === 200 && r.data) {
                var opts = '';
                $.each(r.data, function(i, b) {
                    if (b.stock > 0) opts += '<option value="' + b.id + '">' + b.title + ' (库存:' + b.stock + ')</option>';
                });
                $('#borrowBookId').html(opts);
            }
        });
        $('#borrowModal').modal('show');
    });
}

function saveBorrow() {
    var data = {
        userId: parseInt($('#borrowUserId').val()),
        bookId: parseInt($('#borrowBookId').val())
    };
    $.ajax({
        url: '/api/borrows', type: 'POST', contentType: 'application/json',
        data: JSON.stringify(data),
        success: function(res) {
            if (res.code === 200) { $('#borrowModal').modal('hide'); loadBorrows(); loadBooks(); }
            else alert(res.message);
        }
    });
}

function returnBook(id) {
    if (!confirm('确定归还该书吗？')) return;
    $.ajax({
        url: '/api/borrows/' + id + '/return', type: 'PUT',
        success: function(res) { if (res.code === 200) { loadBorrows(); loadBooks(); } else alert(res.message); }
    });
}

function deleteBorrow(id) {
    if (!confirm('确定删除该记录吗？')) return;
    $.ajax({
        url: '/api/borrows/' + id, type: 'DELETE',
        success: function(res) { if (res.code === 200) loadBorrows(); else alert(res.message); }
    });
}

function batchDeleteBorrows() {
    var ids = [];
    $('.borrow-checkbox:checked').each(function() { ids.push(parseInt($(this).val())); });
    if (ids.length === 0) { alert('请选择要删除的记录'); return; }
    if (!confirm('确定删除选中的 ' + ids.length + ' 条记录吗？')) return;
    $.ajax({
        url: '/api/borrows/batch', type: 'DELETE', contentType: 'application/json',
        data: JSON.stringify(ids),
        success: function(res) { if (res.code === 200) loadBorrows(); else alert(res.message); }
    });
}
```

---

### Task 13: 启动测试与验证

- [ ] **Step 1: 确认 MySQL 数据库已启动并有 `book_manager` 数据库**

Run: `mysql -u root -p -e "SHOW DATABASES;"`

- [ ] **Step 2: 修改 `application.yml` 中的数据库用户名和密码为实际值**

- [ ] **Step 3: 运行 Spring Boot 应用**

Run: `mvn spring-boot:run -f pom.xml`
Expected: Tomcat started on port 8080

- [ ] **Step 4: 浏览器访问 `http://localhost:8080/login`**

验证：
- 登录页面正常显示
- 使用 admin/123456 能成功登录
- 登录后跳转到主页面
- 左侧菜单能切换三个模块
- 图书列表正常展示（含分类名称）
- 分类列表正常展示
- 借阅记录正常展示（含用户名和书名）

- [ ] **Step 5: 测试图书管理模块**

验证：
- 添加图书（选择分类，填写信息）→ 表格刷新显示新记录
- 编辑图书 → 弹窗回显数据 → 修改成功
- 删除图书 → 确认后删除成功
- 批量删除 → 多选后批量删除
- 模糊搜索 → 按书名/作者/ISBN 搜索
- 分类筛选 → 选择分类后只显示该分类图书

- [ ] **Step 6: 测试分类管理模块**

验证：
- 添加分类 → 成功
- 编辑分类 → 成功
- 删除无图书的分类 → 成功
- 删除有图书的分类 → 提示错误
- 批量删除 → 成功

- [ ] **Step 7: 测试借阅记录管理模块**

验证：
- 新增借阅 → 选择用户和图书 → 成功，库存-1
- 归还图书 → 状态变为已归还，库存+1
- 删除记录 → 成功
- 批量删除 → 成功
- 模糊搜索 → 按用户名/书名搜索
- 状态筛选 → 正常

- [ ] **Step 8: 测试用户功能**

验证：
- 注册新用户 → 成功，用新用户登录
- 注销 → 返回登录页
- 未登录直接访问 /main → 跳转到登录页