# 📱 Ứng Dụng Quản Lý Cửa Hàng Online (Flutter + Firebase)

> **Môn học:** Lập trình Mobile  
> **Sinh viên thực hiện:** [Nguyễn Văn Khiếu]  
> **Mã Sinh Viên:** 2351060455  
> **Lớp:** [65CNCTT]

---

## 📝 Giới Thiệu
Dự án là bài thi kết thúc học phần, xây dựng một ứng dụng thương mại điện tử hoàn chỉnh trên nền tảng **Flutter** kết nối với **Firebase Firestore**.

Ứng dụng cho phép người dùng đóng vai trò khách hàng để: Đăng ký/Đăng nhập, tìm kiếm sản phẩm, thêm vào giỏ hàng, đặt hàng trực tuyến và theo dõi lịch sử đơn hàng theo thời gian thực.

## 🛠 Công Nghệ Sử Dụng
* **Frontend:** Flutter (Dart SDK >= 3.0)
* **Backend:** Firebase Firestore (NoSQL Database)
* **State Management:** Provider
* **Local Storage:** SharedPreferences (Lưu phiên đăng nhập)
* **Architecture:** MVVM (Model - View - ViewModel/Provider) + Repository Pattern

## ✨ Tính Năng Đã Hoàn Thiện

### 1. Xác thực & Người dùng (Authentication)
- [x] Đăng ký tài khoản mới (Lưu vào collection `customers`).
- [x] Đăng nhập bằng Email (Kiểm tra dữ liệu thực từ Firestore).
- [x] Tự động đăng nhập lại khi mở app (Auto Login).

### 2. Sản phẩm (Products)
- [x] Hiển thị danh sách sản phẩm Real-time.
- [x] **Tìm kiếm:** Tìm theo tên sản phẩm.
- [x] **Bộ lọc danh mục:** Filter theo Category (Electronics, Clothing, Food...).
- [x] **Bộ lọc giá:** Lọc sản phẩm theo khoảng giá Min - Max.
- [x] Chi tiết sản phẩm: Xem ảnh, mô tả, đánh giá, và tình trạng kho hàng (Stock).
- [x] Badge cảnh báo "Hết hàng" nếu số lượng = 0.

### 3. Giỏ hàng & Đặt hàng (Cart & Order)
- [x] Thêm/Xóa/Sửa số lượng sản phẩm trong giỏ.
- [x] **Quy trình Checkout:** - Sử dụng BottomSheet để nhập thông tin giao hàng.
    - Chọn phương thức thanh toán.
    - Tự động tính tổng tiền + Phí vận chuyển ($30).
- [x] **Xử lý Transaction:** Đảm bảo tính nhất quán dữ liệu (Trừ kho an toàn khi nhiều người cùng đặt).

### 4. Quản lý Đơn hàng (Order History)
- [x] Xem danh sách đơn hàng đã đặt.
- [x] Hiển thị trạng thái màu sắc trực quan (Pending, Delivered, Cancelled...).
- [x] **Hủy đơn hàng:** Chỉ cho phép hủy khi đơn ở trạng thái `pending`.
- [x] **Hoàn kho:** Tự động cộng lại số lượng tồn kho khi khách hủy đơn.

---

## 🚀 Hướng Dẫn Cài Đặt & Chạy

### 1. Yêu cầu hệ thống
- Flutter SDK đã được cài đặt và cấu hình path.
- Một thiết bị giả lập (Android Emulator) hoặc trình duyệt Chrome.

### 2. Cài đặt thư viện
Mở terminal tại thư mục gốc dự án và chạy:
```bash
flutter pub get