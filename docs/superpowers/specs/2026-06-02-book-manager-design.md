# 图书信息管理系统 — 设计文档

## 1. 项目概述

基于 Spring Boot + MyBatis + MySQL 构建的图书信息管理系统，前端使用 Bootstrap + jQuery，通过 AJAX + JSON 实现前后端数据交互。系统提供图书信息、图书分类、借阅记录三个核心管理模块，以及用户登录/注册功能。

## 2. 技术栈

| 层级 | 技术 |
|------|------|
| 后端框架 | Spring Boot 2.7.x |
| ORM | MyBatis（XML 映射文件） |
| 数据库 | MySQL 8.x |
| 前端 | Bootstrap 5 + jQuery 3.x |
| 构建工具 | Maven |
| 前后端交互 | AJAX + JSON（RESTful API） |
| 模板引擎 | JSP |

## 3. 数据库设计

### 3.1 用户表 `user`

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| id | INT | PK, 自增 | 用户ID |
| username | VARCHAR(50) | 唯一, 非空 | 用户名 |
| password | VARCHAR(100) | 非空 | 密码 |
| email | VARCHAR(100) | | 邮箱 |
| phone | VARCHAR(20) | | 手机号 |
| create_time | DATETIME | | 注册时间 |

### 3.2 图书分类表 `category`

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| id | INT | PK, 自增 | 分类ID |
| name | VARCHAR(50) | 唯一, 非空 | 分类名称 |
| description | VARCHAR(200) | | 分类描述 |

### 3.3 图书信息表 `book`

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| id | INT | PK, 自增 | 图书ID |
| title | VARCHAR(100) | 非空 | 书名 |
| author | VARCHAR(50) | 非空 | 作者 |
| isbn | VARCHAR(20) | | ISBN编号 |
| category_id | INT | FK → category.id | 关联分类 |
| publisher | VARCHAR(100) | | 出版社 |
| publish_date | DATE | | 出版日期 |
| price | DECIMAL(10,2) | | 价格 |
| stock | INT | 默认 0 | 库存数量 |
| description | TEXT | | 图书简介 |
| create_time | DATETIME | | 入库时间 |

### 3.4 借阅记录表 `borrow_record`

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| id | INT | PK, 自增 | 记录ID |
| user_id | INT | FK → user.id, 非空 | 关联用户 |
| book_id | INT | FK → book.id, 非空 | 关联图书 |
| borrow_date | DATETIME | 非空 | 借出时间 |
| return_date | DATETIME | | 归还时间 |
| status | TINYINT | 默认 0 | 0-借出中, 1-已归还 |

### 3.5 关联映射

- Book → Category：多对一（通过 `<association>` 映射）
- BorrowRecord → User：多对一（通过 `<association>` 映射）
- BorrowRecord → Book：多对一（通过 `<association>` 映射）
- Category → Book：一对多（通过 `<collection>` 映射，用于展示分类下的图书数量）

## 4. 功能模块

### 4.1 用户登录/注册

- 登录页面：输入用户名和密码登录，提供注册链接
- 注册页面：填写用户名、密码、邮箱、手机号完成注册
- 登录成功后跳转至主页面
- 主页面顶部显示用户信息和注销按钮
- 使用 Session 保持登录状态

### 4.2 图书信息管理

- 图书列表：分页表格展示所有图书信息（含分类名称，通过关联查询获取）
- 模糊查询：按书名、作者、ISBN 进行模糊搜索
- 精确查询：按分类ID精确筛选
- 添加图书：表单填写图书信息，分类通过下拉框选择
- 修改图书：点击编辑按钮，弹窗修改图书信息
- 删除图书：单条删除 + 多选批量删除
- 借阅关联：图书借出时库存自动减1，归还时库存自动加1

### 4.3 图书分类管理

- 分类列表：表格展示所有分类信息
- 模糊查询：按分类名称模糊搜索
- 添加分类：填写分类名称和描述
- 修改分类：编辑分类名称和描述
- 删除分类：单条删除 + 多选批量删除
- 删除保护：如果分类下仍有图书，提示不可删除

### 4.4 借阅记录管理

- 借阅列表：表格展示所有借阅记录（关联显示用户名和书名）
- 查询：按用户名、书名模糊搜索，按状态精确筛选
- 新增借阅：选择用户（下拉框）和图书（下拉框），自动记录借出时间
- 归还操作：点击归还按钮，更新状态为已归还并记录归还时间
- 删除记录：单条删除 + 多选批量删除

## 5. API 设计

### 5.1 统一响应格式

```json
{
  "code": 200,
  "message": "操作成功",
  "data": {}
}
```

### 5.2 API 列表

**用户相关：**
| 方法 | 路径 | 说明 |
|------|------|------|
| POST | /api/user/login | 用户登录 |
| POST | /api/user/register | 用户注册 |
| POST | /api/user/logout | 用户注销 |

**图书管理：**
| 方法 | 路径 | 说明 |
|------|------|------|
| GET | /api/books | 图书列表（支持分页和搜索参数） |
| POST | /api/books | 添加图书 |
| PUT | /api/books/{id} | 修改图书 |
| DELETE | /api/books/{id} | 删除图书 |
| DELETE | /api/books/batch | 批量删除图书 |

**分类管理：**
| 方法 | 路径 | 说明 |
|------|------|------|
| GET | /api/categories | 分类列表（支持搜索参数） |
| POST | /api/categories | 添加分类 |
| PUT | /api/categories/{id} | 修改分类 |
| DELETE | /api/categories/{id} | 删除分类 |
| DELETE | /api/categories/batch | 批量删除分类 |

**借阅记录：**
| 方法 | 路径 | 说明 |
|------|------|------|
| GET | /api/borrows | 借阅列表（支持分页和搜索参数） |
| POST | /api/borrows | 新增借阅 |
| PUT | /api/borrows/{id}/return | 归还操作 |
| DELETE | /api/borrows/{id} | 删除记录 |
| DELETE | /api/borrows/batch | 批量删除记录 |

## 6. 页面设计

### 6.1 页面布局

采用左右布局结构：

```
┌─────────────────────────────────────────┐
│          图书信息管理系统                  │
├──────────┬──────────────────────────────┤
│          │  欢迎, admin  | [注销]        │
│ 图书管理  ├──────────────────────────────┤
│ 分类管理  │                              │
│ 借阅记录  │   [表格/操作区域]              │
│          │                              │
│          │   [搜索] [添加] [批量删除]      │
│          │   ┌───┬───┬───┬───┐          │
│          │   │   │   │   │   │          │
│          │   └───┴───┴───┴───┘          │
└──────────┴──────────────────────────────┘
```

### 6.2 页面列表

- `login.jsp`：登录页面（含注册链接）
- `register.jsp`：注册页面
- `main.jsp`：主页面（左右布局，左侧菜单，右侧内容区通过 AJAX 动态加载各模块页面内容）

## 7. 项目目录结构

```
book-manager/
├── src/main/java/com/bookmanager/
│   ├── BookManagerApplication.java
│   ├── config/
│   │   └── WebMvcConfig.java
│   ├── interceptor/
│   │   └── LoginInterceptor.java
│   ├── controller/
│   │   ├── PageController.java
│   │   ├── UserController.java
│   │   ├── BookController.java
│   │   ├── CategoryController.java
│   │   └── BorrowRecordController.java
│   ├── service/
│   │   ├── UserService.java
│   │   ├── BookService.java
│   │   ├── CategoryService.java
│   │   └── BorrowRecordService.java
│   ├── mapper/
│   │   ├── UserMapper.java
│   │   ├── BookMapper.java
│   │   ├── CategoryMapper.java
│   │   └── BorrowRecordMapper.java
│   ├── entity/
│   │   ├── User.java
│   │   ├── Book.java
│   │   ├── Category.java
│   │   └── BorrowRecord.java
│   └── common/
│       └── Result.java
├── src/main/resources/
│   ├── application.yml
│   └── mapper/
│       ├── UserMapper.xml
│       ├── BookMapper.xml
│       ├── CategoryMapper.xml
│       └── BorrowRecordMapper.xml
├── src/main/webapp/
│   ├── static/
│   │   ├── css/style.css
│   │   └── js/main.js
│   └── WEB-INF/views/
│       ├── login.jsp
│       ├── register.jsp
│       └── main.jsp
├── sql/
│   └── init.sql
└── pom.xml
```

## 8. 关键实现要点

### 8.1 MyBatis 关联映射

BookMapper.xml 中通过 `<association>` 实现图书与分类的关联查询：

```xml
<resultMap id="bookWithCategory" type="Book">
    <id property="id" column="id"/>
    <result property="title" column="title"/>
    <association property="category" javaType="Category">
        <id property="id" column="category_id"/>
        <result property="name" column="category_name"/>
    </association>
</resultMap>
```

BorrowRecordMapper.xml 中通过多个 `<association>` 实现借阅记录关联用户和图书：

```xml
<resultMap id="borrowDetail" type="BorrowRecord">
    <id property="id" column="id"/>
    <association property="user" javaType="User">
        <id property="id" column="user_id"/>
        <result property="username" column="username"/>
    </association>
    <association property="book" javaType="Book">
        <id property="id" column="book_id"/>
        <result property="title" column="book_title"/>
    </association>
</resultMap>
```

### 8.2 登录拦截器

通过 `LoginInterceptor` 实现：未登录用户访问管理页面时重定向到登录页，登录和注册页面本身不受拦截。

### 8.3 JSON 数据交互

所有 CRUD 操作通过 jQuery `$.ajax()` 调用后端 RESTful API，后端 Controller 使用 `@RestController` 注解，返回统一的 `Result` 对象。前端根据返回的 `code` 判断操作是否成功，动态更新页面内容。

### 8.4 批量删除

前端通过复选框多选，将选中的 ID 数组通过 AJAX 发送到后端的批量删除接口。后端接收 ID 数组，通过 MyBatis 的 `<foreach>` 标签生成批量删除 SQL。
