<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>图书信息管理系统</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@500;600;700;800&family=Noto+Sans+SC:wght@400;500;700;800&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <link rel="stylesheet" href="/static/css/style.css">
</head>
<body>
<div class="app-shell">
    <aside class="sidebar d-flex flex-column">
        <div class="sidebar-brand">
            <div class="brand-icon"><i class="bi bi-journal-bookmark-fill"></i></div>
            <div>
                <strong>图书管理系统</strong>
                <span>Library Console</span>
            </div>
        </div>
        <nav class="nav flex-column" aria-label="主导航">
            <a class="nav-link active" href="#" data-module="book">
                <i class="bi bi-bookshelf"></i><span>图书管理</span>
            </a>
            <a class="nav-link" href="#" data-module="category">
                <i class="bi bi-bookmarks"></i><span>分类管理</span>
            </a>
            <a class="nav-link" href="#" data-module="borrow">
                <i class="bi bi-arrow-left-right"></i><span>借阅记录</span>
            </a>
        </nav>
        <div class="sidebar-foot">
            典藏、分类、流转记录集中维护，让馆藏状态清楚可查。
        </div>
    </aside>

    <main class="workspace">
        <header class="user-info d-flex justify-content-between align-items-center">
            <div class="user-chip">
                <i class="bi bi-person-circle"></i>
                <span>欢迎，<strong id="currentUser"></strong></span>
            </div>
            <button class="btn btn-sm btn-outline-danger" onclick="logout()">
                <i class="bi bi-box-arrow-right me-1"></i>注销
            </button>
        </header>

        <div class="main-content">
            <section class="page-title">
                <div>
                    <h1>馆藏工作台</h1>
                    <p>管理图书、分类与借阅状态，保持每条记录清晰可追踪。</p>
                </div>
            </section>

            <section id="module-book" class="module-content active">
                <div class="library-panel">
                    <div class="panel-header">
                        <div class="panel-title">
                            <i class="bi bi-book"></i>
                            <div>
                                <h2>图书信息管理</h2>
                                <p>检索馆藏、维护库存、更新图书基础资料。</p>
                            </div>
                        </div>
                    </div>
                    <div class="toolbar">
                        <input type="text" class="form-control" id="bookKeyword" placeholder="书名 / 作者 / ISBN">
                        <select class="form-select" id="bookCategoryFilter">
                            <option value="">全部分类</option>
                        </select>
                        <div class="toolbar-actions">
                            <button class="btn btn-primary" onclick="loadBooks()">
                                <i class="bi bi-search me-1"></i>搜索
                            </button>
                            <button class="btn btn-success" onclick="showAddBookModal()">
                                <i class="bi bi-plus-lg me-1"></i>添加图书
                            </button>
                        </div>
                        <div class="toolbar-actions justify-content-end">
                            <button class="btn btn-danger btn-sm" onclick="batchDeleteBooks()">
                                <i class="bi bi-trash3 me-1"></i>批量删除
                            </button>
                        </div>
                    </div>
                    <div class="table-wrap">
                        <table class="table table-hover">
                            <thead>
                                <tr>
                                    <th width="48"><input type="checkbox" id="bookSelectAll" aria-label="选择全部图书"></th>
                                    <th>ID</th><th>书名</th><th>作者</th><th>ISBN</th>
                                    <th>分类</th><th>出版社</th><th>价格</th><th>库存</th>
                                    <th>操作</th>
                                </tr>
                            </thead>
                            <tbody id="bookTableBody"></tbody>
                        </table>
                    </div>
                </div>
            </section>

            <section id="module-category" class="module-content">
                <div class="library-panel">
                    <div class="panel-header">
                        <div class="panel-title">
                            <i class="bi bi-bookmarks"></i>
                            <div>
                                <h2>分类管理</h2>
                                <p>维护馆藏分类，让检索和编目更稳定。</p>
                            </div>
                        </div>
                    </div>
                    <div class="toolbar toolbar-simple">
                        <input type="text" class="form-control" id="categoryKeyword" placeholder="分类名称">
                        <div class="toolbar-actions">
                            <button class="btn btn-primary" onclick="loadCategories()">
                                <i class="bi bi-search me-1"></i>搜索
                            </button>
                            <button class="btn btn-success" onclick="showAddCategoryModal()">
                                <i class="bi bi-plus-lg me-1"></i>添加分类
                            </button>
                        </div>
                        <div class="toolbar-actions justify-content-end">
                            <button class="btn btn-danger btn-sm" onclick="batchDeleteCategories()">
                                <i class="bi bi-trash3 me-1"></i>批量删除
                            </button>
                        </div>
                    </div>
                    <div class="table-wrap">
                        <table class="table table-hover">
                            <thead>
                                <tr>
                                    <th width="48"><input type="checkbox" id="categorySelectAll" aria-label="选择全部分类"></th>
                                    <th>ID</th><th>名称</th><th>描述</th><th>操作</th>
                                </tr>
                            </thead>
                            <tbody id="categoryTableBody"></tbody>
                        </table>
                    </div>
                </div>
            </section>

            <section id="module-borrow" class="module-content">
                <div class="library-panel">
                    <div class="panel-header">
                        <div class="panel-title">
                            <i class="bi bi-arrow-left-right"></i>
                            <div>
                                <h2>借阅记录管理</h2>
                                <p>追踪借出、归还和记录状态，保持流转清楚。</p>
                            </div>
                        </div>
                    </div>
                    <div class="toolbar">
                        <input type="text" class="form-control" id="borrowKeyword" placeholder="用户名 / 书名">
                        <select class="form-select" id="borrowStatusFilter">
                            <option value="">全部状态</option>
                            <option value="0">借出中</option>
                            <option value="1">已归还</option>
                        </select>
                        <div class="toolbar-actions">
                            <button class="btn btn-primary" onclick="loadBorrows()">
                                <i class="bi bi-search me-1"></i>搜索
                            </button>
                            <button class="btn btn-success" onclick="showAddBorrowModal()">
                                <i class="bi bi-plus-lg me-1"></i>新增借阅
                            </button>
                        </div>
                        <div class="toolbar-actions justify-content-end">
                            <button class="btn btn-danger btn-sm" onclick="batchDeleteBorrows()">
                                <i class="bi bi-trash3 me-1"></i>批量删除
                            </button>
                        </div>
                    </div>
                    <div class="table-wrap">
                        <table class="table table-hover">
                            <thead>
                                <tr>
                                    <th width="48"><input type="checkbox" id="borrowSelectAll" aria-label="选择全部借阅记录"></th>
                                    <th>ID</th><th>用户</th><th>书名</th><th>借出时间</th>
                                    <th>归还时间</th><th>状态</th><th>操作</th>
                                </tr>
                            </thead>
                            <tbody id="borrowTableBody"></tbody>
                        </table>
                    </div>
                </div>
            </section>
        </div>
    </main>
</div>

<div class="modal fade" id="bookModal" tabindex="-1">
    <div class="modal-dialog modal-lg modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="bookModalTitle">添加图书</h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <input type="hidden" id="editBookId">
                <div class="row g-3">
                    <div class="col-md-6"><label class="form-label">书名</label><input type="text" class="form-control" id="bookTitle"></div>
                    <div class="col-md-6"><label class="form-label">作者</label><input type="text" class="form-control" id="bookAuthor"></div>
                    <div class="col-md-6"><label class="form-label">ISBN</label><input type="text" class="form-control" id="bookIsbn"></div>
                    <div class="col-md-6"><label class="form-label">分类</label><select class="form-select" id="bookCategoryId"></select></div>
                    <div class="col-md-6"><label class="form-label">出版社</label><input type="text" class="form-control" id="bookPublisher"></div>
                    <div class="col-md-6"><label class="form-label">出版日期</label><input type="date" class="form-control" id="bookPublishDate"></div>
                    <div class="col-md-6"><label class="form-label">价格</label><input type="number" step="0.01" class="form-control" id="bookPrice"></div>
                    <div class="col-md-6"><label class="form-label">库存</label><input type="number" class="form-control" id="bookStock" value="0"></div>
                    <div class="col-12"><label class="form-label">简介</label><textarea class="form-control" id="bookDescription" rows="3"></textarea></div>
                </div>
            </div>
            <div class="modal-footer">
                <button class="btn btn-secondary" data-bs-dismiss="modal">取消</button>
                <button class="btn btn-primary" onclick="saveBook()">保存图书</button>
            </div>
        </div>
    </div>
</div>

<div class="modal fade" id="categoryModal" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="categoryModalTitle">添加分类</h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <input type="hidden" id="editCategoryId">
                <div class="mb-3"><label class="form-label">分类名称</label><input type="text" class="form-control" id="categoryName"></div>
                <div class="mb-3"><label class="form-label">描述</label><textarea class="form-control" id="categoryDescription" rows="3"></textarea></div>
            </div>
            <div class="modal-footer">
                <button class="btn btn-secondary" data-bs-dismiss="modal">取消</button>
                <button class="btn btn-primary" onclick="saveCategory()">保存分类</button>
            </div>
        </div>
    </div>
</div>

<div class="modal fade" id="borrowModal" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">新增借阅</h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <div class="mb-3"><label class="form-label">用户</label><select class="form-select" id="borrowUserId"></select></div>
                <div class="mb-3"><label class="form-label">图书</label><select class="form-select" id="borrowBookId"></select></div>
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
