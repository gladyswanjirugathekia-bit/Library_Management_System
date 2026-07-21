<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>图书信息管理系统 - 注册</title>
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
            <h1>建立账号，开始维护一座有秩序的数字书库。</h1>
            <p>注册后可进入后台管理图书、分类和借阅记录。界面以清晰层级和稳定控件帮助你快速完成日常维护。</p>
        </div>
        <div class="auth-metrics">
            <div class="auth-metric">
                <strong>Secure</strong>
                <span>账号访问</span>
            </div>
            <div class="auth-metric">
                <strong>Manage</strong>
                <span>馆藏维护</span>
            </div>
            <div class="auth-metric">
                <strong>Record</strong>
                <span>借阅记录</span>
            </div>
        </div>
    </section>
    <section class="auth-card" aria-label="注册表单">
        <h2>创建账号</h2>
        <p class="auth-subtitle">填写基础信息后即可返回登录。</p>
        <div class="mb-3">
            <label for="username" class="form-label">用户名</label>
            <input type="text" class="form-control" id="username" placeholder="请输入用户名" autocomplete="username">
        </div>
        <div class="mb-3">
            <label for="password" class="form-label">密码</label>
            <input type="password" class="form-control" id="password" placeholder="请输入密码" autocomplete="new-password">
        </div>
        <div class="mb-3">
            <label for="email" class="form-label">邮箱</label>
            <input type="email" class="form-control" id="email" placeholder="请输入邮箱" autocomplete="email">
        </div>
        <div class="mb-3">
            <label for="phone" class="form-label">手机号</label>
            <input type="text" class="form-control" id="phone" placeholder="请输入手机号" autocomplete="tel">
        </div>
        <div id="regMessage" class="alert d-none" role="alert"></div>
        <button type="button" class="btn btn-primary w-100 py-2" onclick="register()">
            <i class="bi bi-person-plus me-2"></i>创建账号
        </button>
        <div class="text-center mt-4">
            <a href="/login">已有账号？返回登录</a>
        </div>
    </section>
</main>
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
