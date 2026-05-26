# 小账本 — 大学生记账 App MVP

## 技术栈

React 18 + TypeScript + Vite + Tailwind CSS + Supabase

## 项目结构

```
src/
├── pages/        # 页面：登录、首页、记账、统计
├── components/   # 组件：底部导航、账单条目、分类选择、金额输入
├── hooks/        # useAuth（认证）、useRecords（账单CRUD）
├── types.ts      # 类型 + 预设分类
└── supabase.ts   # Supabase 客户端
```

## 启动

```bash
npm install
cp .env.example .env     # 填入 Supabase 项目信息
npm run dev
```

## Supabase 配置

1. 在 [supabase.com](https://supabase.com) 创建项目
2. 在 SQL Editor 执行 `supabase-schema.sql`
3. 在 Authentication → Providers 中开启 Phone Auth
4. 将 `SUPABASE_URL` 和 `SUPABASE_ANON_KEY` 填入 `.env`

## 构建

```bash
npm run build    # 输出到 dist/
npm run preview  # 预览构建结果
```
