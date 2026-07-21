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

function escapeHtml(value) {
    if (value === null || value === undefined || value === '') return '-';
    return String(value)
        .replace(/&/g, '&amp;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;')
        .replace(/"/g, '&quot;')
        .replace(/'/g, '&#039;');
}

function emptyRow(colspan, title, description) {
    return '<tr><td colspan="' + colspan + '" class="empty-state">' +
        '<i class="bi bi-journal-text"></i>' +
        '<strong>' + title + '</strong>' +
        '<div>' + description + '</div>' +
        '</td></tr>';
}

function stockBadge(stock) {
    var count = Number(stock || 0);
    var tone = count <= 0 ? 'danger' : (count <= 3 ? 'warning' : 'success');
    var text = count <= 0 ? '无库存' : count + ' 本';
    return '<span class="status-badge ' + tone + '"><i class="bi bi-box-seam"></i>' + text + '</span>';
}

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
                html += '<td class="muted-cell">' + escapeHtml(book.id) + '</td>';
                html += '<td class="book-title-cell">' + escapeHtml(book.title) + '</td>';
                html += '<td>' + escapeHtml(book.author) + '</td>';
                html += '<td class="muted-cell">' + escapeHtml(book.isbn) + '</td>';
                html += '<td>' + escapeHtml(catName) + '</td>';
                html += '<td class="muted-cell">' + escapeHtml(book.publisher) + '</td>';
                html += '<td>' + (book.price === null || book.price === undefined ? '-' : '¥' + escapeHtml(book.price)) + '</td>';
                html += '<td>' + stockBadge(book.stock) + '</td>';
                html += '<td class="btn-group-actions">';
                html += '<button class="btn btn-primary btn-sm" onclick="editBook(' + book.id + ')"><i class="bi bi-pencil-square me-1"></i>编辑</button> ';
                html += '<button class="btn btn-danger btn-sm" onclick="deleteBook(' + book.id + ')"><i class="bi bi-trash3 me-1"></i>删除</button>';
                html += '</td></tr>';
            });
        }
        if (!res.data || res.data.length === 0) {
            html = emptyRow(10, '暂无图书记录', '调整筛选条件，或添加一本新图书。');
        }
        $('#bookTableBody').html(html);
    });
}

function loadCategoriesForFilter() {
    $.get('/api/categories', function(res) {
        if (res.code === 200 && res.data) {
            $('#bookCategoryFilter').html('<option value="">全部分类</option>');
            $('#bookCategoryId').html('');
            $.each(res.data, function(i, cat) {
                $('#bookCategoryFilter').append('<option value="' + cat.id + '">' + escapeHtml(cat.name) + '</option>');
                $('#bookCategoryId').append('<option value="' + cat.id + '">' + escapeHtml(cat.name) + '</option>');
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
                html += '<td class="muted-cell">' + escapeHtml(cat.id) + '</td>';
                html += '<td class="book-title-cell">' + escapeHtml(cat.name) + '</td>';
                html += '<td class="muted-cell">' + escapeHtml(cat.description) + '</td>';
                html += '<td class="btn-group-actions">';
                html += '<button class="btn btn-primary btn-sm" onclick="editCategory(' + cat.id + ')"><i class="bi bi-pencil-square me-1"></i>编辑</button> ';
                html += '<button class="btn btn-danger btn-sm" onclick="deleteCategory(' + cat.id + ')"><i class="bi bi-trash3 me-1"></i>删除</button>';
                html += '</td></tr>';
            });
        }
        if (!res.data || res.data.length === 0) {
            html = emptyRow(5, '暂无分类记录', '添加分类后，图书编目会更清晰。');
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
            if (res.code === 200) {
                $('#categoryModal').modal('hide');
                loadCategories();
                loadCategoriesForFilter();
            }
            else alert(res.message);
        }
    });
}

function deleteCategory(id) {
    if (!confirm('确定删除该分类吗？')) return;
    $.ajax({
        url: '/api/categories/' + id, type: 'DELETE',
        success: function(res) {
            if (res.code === 200) {
                loadCategories();
                loadCategoriesForFilter();
            } else alert(res.message);
        }
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
        success: function(res) {
            if (res.code === 200) {
                loadCategories();
                loadCategoriesForFilter();
            } else alert(res.message);
        }
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
                var statusText = br.status === 0 ?
                    '<span class="status-badge warning"><i class="bi bi-clock-history"></i>借出中</span>' :
                    '<span class="status-badge success"><i class="bi bi-check-circle"></i>已归还</span>';
                html += '<tr>';
                html += '<td><input type="checkbox" class="borrow-checkbox" value="' + br.id + '"></td>';
                html += '<td class="muted-cell">' + escapeHtml(br.id) + '</td>';
                html += '<td>' + escapeHtml(uname) + '</td>';
                html += '<td class="book-title-cell">' + escapeHtml(bname) + '</td>';
                html += '<td class="muted-cell">' + escapeHtml(br.borrowDate) + '</td>';
                html += '<td class="muted-cell">' + escapeHtml(br.returnDate) + '</td>';
                html += '<td>' + statusText + '</td>';
                html += '<td class="btn-group-actions">';
                if (br.status === 0) {
                    html += '<button class="btn btn-success btn-sm" onclick="returnBook(' + br.id + ')"><i class="bi bi-arrow-counterclockwise me-1"></i>归还</button> ';
                }
                html += '<button class="btn btn-danger btn-sm" onclick="deleteBorrow(' + br.id + ')"><i class="bi bi-trash3 me-1"></i>删除</button>';
                html += '</td></tr>';
            });
        }
        if (!res.data || res.data.length === 0) {
            html = emptyRow(8, '暂无借阅记录', '新增借阅后，可在这里追踪流转状态。');
        }
        $('#borrowTableBody').html(html);
    });
}

function showAddBorrowModal() {
    $.get('/api/user/current', function(res) {
        if (res.code === 200) {
            $('#borrowUserId').html('<option value="' + res.data.id + '">' + escapeHtml(res.data.username) + '</option>');
        }
        $.get('/api/books', function(r) {
            if (r.code === 200 && r.data) {
                var opts = '';
                $.each(r.data, function(i, b) {
                    if (b.stock > 0) opts += '<option value="' + b.id + '">' + escapeHtml(b.title) + ' (库存:' + escapeHtml(b.stock) + ')</option>';
                });
                $('#borrowBookId').html(opts || '<option value="">暂无可借图书</option>');
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
