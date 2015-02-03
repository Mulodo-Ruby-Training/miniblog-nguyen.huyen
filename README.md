****h1. Hệ thống "Mini Blog"

*Yêu cầu*
Suy nghĩ, thiết kế một hệ thống giống như mini blog, cho phép user login, post bài viết, tìm kiếm bài viết cũng như comment trên các bài viết.

Hệ thống bao gồm 2 thành phần: Front-End (Web Application/Smart Phone Application) và Back-End (API).

*Các chức năng chính*

* Front-End:
 - Login/Logout
 - Trang Top: liệt kê 10 bài post mới nhất 
 - Cập nhật thông tin user
 - Thay đổi password
 - Tìm kiếm user bằng username/firstname/lastname (fulltext search)
 - Tìm kiếm bài post bằng description (fulltext search)
 - Liệt kê tất cả bài post của hệ thống theo thứ tự "Newest On Top"
 - Liệt kê tất cả bài post của một user nào đó (từ kết quả tìm kiếm user) theo thứ tự "Newest On Top"
 - Comment trên một bài post bất kỳ và sửa/xóa comment đó
 - Tạo/sửa/xoá một bài post

* Back-End:
API để thực hiện các chức năng của Front-End.

*Yêu cầu kỹ thuật*
- Front-End (Web Application): Bootstrap (aplly Responsive Web Design) + RoR MVC
- Ngôn ngữ lập trình: Ruby (Rails)
- Cơ sở dữ liệu: MySQL
- OS: Linux CentOS 6.5
- Dùng Redmine để quản lý, báo cáo tasks và tương tác với Trainners
- Dùng Git/Github để quản lý source code
- Dùng chức năng Pull Request của Github để quản lý TODOs cho từng task
- Dùng Astah Community để vẽ Sequence Diagram, Class Diagram

*Công việc phải làm*
- Thiết kế Wireframe (Paper) và Prototype (HTML Markup) dựa trên các chức năng yêu cầu
 (Reference: http://sixrevisions.com/user-experience-ux/wireframes-vs-prototypes-difference/)
- Thiết kế cơ sở dữ liệu (ERD, Table Design)
- Thiết kế API Spec, API Detail Design (Flow)
- Vẽ Sequence Diagram, Class Diagram
- etc..
