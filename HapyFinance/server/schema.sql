-- 极简记账 数据库建表脚本
-- 在 Navicat 中创建数据库 jijian_jizhang 后执行此脚本

CREATE DATABASE IF NOT EXISTS jijian_jizhang DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE jijian_jizhang;

-- 用户表
CREATE TABLE users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  phone VARCHAR(11) NOT NULL UNIQUE,
  token VARCHAR(64) DEFAULT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  last_login_at DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- 资产账户表
CREATE TABLE accounts (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  name VARCHAR(50) NOT NULL,
  type VARCHAR(20) NOT NULL COMMENT 'cash/bank/virtual',
  balance DECIMAL(12,2) NOT NULL DEFAULT 0,
  initial_balance DECIMAL(12,2) NOT NULL,
  icon VARCHAR(50) DEFAULT 'wallet',
  created_at DATETIME NOT NULL,
  updated_at DATETIME NOT NULL,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- 分类表（预设数据，全局共享）
CREATE TABLE categories (
  id INT PRIMARY KEY,
  name VARCHAR(20) NOT NULL,
  type VARCHAR(10) NOT NULL COMMENT 'expense/income',
  icon VARCHAR(50) NOT NULL,
  sort_order INT DEFAULT 0
) ENGINE=InnoDB;

-- 交易记录表
CREATE TABLE transactions (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  type VARCHAR(10) NOT NULL COMMENT 'expense/income',
  amount DECIMAL(12,2) NOT NULL,
  category_id INT NOT NULL,
  account_id INT NOT NULL,
  date DATE NOT NULL,
  time TIME NOT NULL,
  note VARCHAR(200) DEFAULT '',
  created_at DATETIME NOT NULL,
  updated_at DATETIME NOT NULL,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (category_id) REFERENCES categories(id),
  FOREIGN KEY (account_id) REFERENCES accounts(id) ON DELETE CASCADE,
  INDEX idx_date (date),
  INDEX idx_user_date (user_id, date),
  INDEX idx_account (account_id),
  INDEX idx_category (category_id)
) ENGINE=InnoDB;

-- 插入预设分类
INSERT INTO categories (id, name, type, icon, sort_order) VALUES
-- 支出分类 (1-10)
(1, '餐饮', 'expense', 'restaurant', 1),
(2, '交通', 'expense', 'directions_car', 2),
(3, '购物', 'expense', 'shopping_bag', 3),
(4, '住房', 'expense', 'home', 4),
(5, '娱乐', 'expense', 'movie', 5),
(6, '医疗', 'expense', 'local_hospital', 6),
(7, '教育', 'expense', 'school', 7),
(8, '人情', 'expense', 'people', 8),
(9, '日用', 'expense', 'lightbulb', 9),
(10, '其他', 'expense', 'more_horiz', 10),
-- 收入分类 (11-16)
(11, '工资', 'income', 'work', 1),
(12, '奖金', 'income', 'card_giftcard', 2),
(13, '兼职', 'income', 'handyman', 3),
(14, '理财', 'income', 'trending_up', 4),
(15, '退款', 'income', 'money_off', 5),
(16, '其他', 'income', 'more_horiz', 6);
