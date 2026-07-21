<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>图书信息管理系统 - 登录</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@500;600;700;800&family=Noto+Sans+SC:wght@400;500;700;800&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <link rel="stylesheet" href="/static/css/style.css">
</head>
<body class="auth-page">
<main class="auth-shell">
    <section class="auth-story" aria-label="系统介绍">
        <div>
            <div class="brand-mark">
                <i class="bi bi-journal-bookmark-fill"></i>
                <span>典藏图书管理</span>
            </div>
            <h1>让每一本书、每一次借阅，都有清晰的位置。</h1>
            <p>面向馆藏、分类、库存与借阅记录的统一工作台。以安静、稳定的界面承载日常管理，让信息检索和流转更有秩序。</p>
        </div>
        <div class="auth-metrics">
            <div class="auth-metric">
                <strong>Books</strong>
                <span>馆藏信息</span>
            </div>
            <div class="auth-metric">
                <strong>Index</strong>
                <span>分类编目</span>
            </div>
            <div class="auth-metric">
                <strong>Flow</strong>
                <span>借阅追踪</span>
            </div>
        </div>
    </section>
    <section class="auth-card" aria-label="登录表单">
        <h2>欢迎回来</h2>
        <p class="auth-subtitle">登录后进入图书信息管理工作台。</p>
        <div class="mb-3">
            <label for="username" class="form-label">用户名</label>
            <input type="text" class="form-control" id="username" placeholder="请输入用户名" autocomplete="username">
        </div>
        <div class="mb-3">
            <label for="password" class="form-label">密码</label>
            <input type="password" class="form-control" id="password" placeholder="请输入密码" autocomplete="current-password">
        </div>
        <div id="loginError" class="alert alert-danger d-none" role="alert"></div>
        <button type="button" class="btn btn-primary w-100 py-2" onclick="login()">
            <i class="bi bi-box-arrow-in-right me-2"></i>登录系统
        </button>
        <div class="text-center mt-4">
            <a href="/register">还没有账号？立即注册</a>
        </div>
    </section>
</main>
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
