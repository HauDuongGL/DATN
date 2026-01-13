# Hướng dẫn khắc phục lỗi Share

## Vấn đề
Khi nhấn nút Share trong app Android, bạn gặp lỗi "Trang này hiện không hoạt động" vì URL tunnel không còn hoạt động.

## Giải pháp

### Bước 1: Khởi động Web app với ngrok

1. Mở PowerShell
2. Di chuyển đến thư mục Web:
   ```powershell
   cd Web
   ```

3. Chạy script:
   ```powershell
   .\start_with_ngrok.ps1
   ```

4. Script sẽ tự động:
   - Khởi động Next.js web app trên port 3000
   - Tạo ngrok tunnel
   - Hiển thị URL công khai (ví dụ: `https://xxxxx.ngrok-free.dev`)

### Bước 2: Cập nhật URL trong Android app

1. Copy URL từ script (sẽ có dạng: `https://xxxxx.ngrok-free.dev`)
2. Mở file: `app/src/main/java/com/example/floweridentifier/utils/Constants.kt`
3. Tìm dòng:
   ```kotlin
   const val WEB_SHARE_URL = "https://c8938fe16d4fa71b-113-160-172-8.serveousercontent.com/upload"
   ```
4. Thay thế bằng URL mới từ ngrok:
   ```kotlin
   const val WEB_SHARE_URL = "https://xxxxx.ngrok-free.dev/upload"
   ```
   (Thay `xxxxx` bằng URL thực tế từ ngrok)

5. Rebuild Android app

### Bước 3: Kiểm tra

1. Đảm bảo Web app đang chạy (script vẫn đang chạy)
2. Mở app Android
3. Nhấn nút Share
4. Nếu vẫn lỗi, kiểm tra:
   - Web app có đang chạy không?
   - URL trong Constants.kt có đúng không?
   - Ngrok tunnel có còn hoạt động không? (kiểm tra tại http://localhost:4040)

## Lưu ý

- URL ngrok sẽ thay đổi mỗi lần khởi động lại (trừ khi dùng ngrok account có domain cố định)
- Nếu ngrok bị dừng, bạn cần chạy lại script và cập nhật URL
- Để URL ổn định hơn, có thể sử dụng ngrok account với domain cố định

## Giải pháp thay thế (cho testing local)

Nếu bạn đang test trên cùng mạng WiFi:

1. Tìm địa chỉ IP local của máy tính:
   - Windows: `ipconfig` (tìm IPv4 Address)
   - Ví dụ: `192.168.1.100`

2. Cập nhật Constants.kt:
   ```kotlin
   const val WEB_SHARE_URL = "http://192.168.1.100:3000/upload"
   ```
   (Thay `192.168.1.100` bằng IP thực tế của bạn)

3. Đảm bảo Web app đang chạy trên port 3000
4. Đảm bảo firewall cho phép kết nối từ mobile device
