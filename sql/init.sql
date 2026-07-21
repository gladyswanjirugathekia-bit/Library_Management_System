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
('zhangsan', '123456', 'zhangsan@example.com', '13800000001'),
('lisi', '123456', 'lisi@example.com', '13800000002'),
('wangwu', '123456', 'wangwu@example.com', '13800000003'),
('zhaoliu', '123456', 'zhaoliu@example.com', '13800000004');

INSERT INTO category (name, description) VALUES
('计算机科学', '计算机科学与技术相关书籍'),
('文学小说', '文学、小说类书籍'),
('历史地理', '历史、地理类书籍'),
('自然科学', '数学、物理、化学等自然科学书籍'),
('经济管理', '经济学、管理学相关书籍'),
('哲学心理', '哲学、心理学相关书籍');

INSERT INTO book (title, author, isbn, category_id, publisher, publish_date, price, stock, description) VALUES
('深入理解Java虚拟机', '周志明', '978-7-111-34966-4', 1, '机械工业出版社', '2011-06-01', 79.00, 5, 'JVM深度解析，Java程序员必读'),
('三体', '刘慈欣', '978-7-536-69293-0', 2, '重庆出版社', '2008-01-01', 23.00, 10, '中国科幻文学里程碑之作'),
('人类简史', '尤瓦尔·赫拉利', '978-7-508-64778-4', 3, '中信出版社', '2014-11-01', 68.00, 8, '从认知革命到科学革命的全景历史'),
('算法导论', 'Thomas H.Cormen', '978-7-111-40701-0', 1, '机械工业出版社', '2012-12-01', 128.00, 3, '计算机算法领域经典教材'),
('活着', '余华', '978-7-506-36920-3', 2, '作家出版社', '2012-08-01', 28.00, 15, '余华代表作，讲述一个人的一生'),
('Spring Boot实战', '丁雪丰', '978-7-115-45919-7', 1, '人民邮电出版社', '2016-09-01', 59.00, 6, 'Spring Boot开发实战指南'),
('百年孤独', '加西亚·马尔克斯', '978-7-544-25378-2', 2, '南海出版公司', '2011-06-01', 55.00, 12, '魔幻现实主义文学巅峰之作'),
('时间简史', '史蒂芬·霍金', '978-7-535-73267-3', 4, '湖南科学技术出版社', '2010-04-01', 45.00, 7, '探索宇宙起源与命运'),
('明朝那些事儿', '当年明月', '978-7-513-30615-5', 3, '浙江人民出版社', '2009-04-01', 35.00, 20, '通俗讲述明朝三百年历史'),
('经济学原理', '曼昆', '978-7-301-15024-0', 5, '北京大学出版社', '2012-07-01', 88.00, 4, '经济学入门经典教材'),
('思考快与慢', '丹尼尔·卡尼曼', '978-7-508-63388-6', 6, '中信出版社', '2012-07-01', 69.00, 9, '诺贝尔奖得主解读人类决策心理'),
('Python编程从入门到实践', 'Eric Matthes', '978-7-115-42802-8', 1, '人民邮电出版社', '2016-07-01', 89.00, 11, 'Python零基础入门到项目实战'),
('红楼梦', '曹雪芹', '978-7-020-00220-4', 2, '人民文学出版社', '1996-12-01', 59.70, 18, '中国古典四大名著之首'),
('枪炮病菌与钢铁', '贾雷德·戴蒙德', '978-7-532-73923-4', 3, '上海译文出版社', '2006-04-01', 42.00, 6, '人类社会的命运与文明差异'),
('高等数学', '同济大学', '978-7-040-39663-8', 4, '高等教育出版社', '2014-07-01', 34.80, 25, '高等院校通用数学教材');

INSERT INTO borrow_record (user_id, book_id, borrow_date, return_date, status) VALUES
(2, 1, '2024-01-15 10:30:00', NULL, 0),
(2, 3, '2024-02-20 14:00:00', '2024-03-15 09:00:00', 1),
(3, 5, '2024-03-01 11:20:00', '2024-03-28 16:30:00', 1),
(3, 7, '2024-03-10 09:15:00', NULL, 0),
(4, 2, '2024-04-05 14:00:00', '2024-04-20 10:00:00', 1),
(4, 6, '2024-04-12 13:45:00', NULL, 0),
(5, 8, '2024-05-01 10:00:00', '2024-05-20 11:30:00', 1),
(5, 10, '2024-05-15 15:20:00', NULL, 0),
(2, 12, '2024-06-01 09:30:00', '2024-06-25 14:00:00', 1),
(3, 13, '2024-06-10 11:00:00', NULL, 0),
(4, 9, '2024-07-03 16:00:00', '2024-07-30 09:45:00', 1),
(5, 4, '2024-07-20 10:30:00', NULL, 0),
(2, 14, '2024-08-05 14:15:00', '2024-08-28 13:00:00', 1),
(3, 2, '2024-09-01 08:45:00', NULL, 0),
(4, 11, '2024-09-15 15:30:00', '2024-10-01 10:20:00', 1),
(5, 15, '2024-10-10 09:00:00', NULL, 0);
