# SuperThai 🇹🇭

**SuperThai** เป็นแอปพลิเคชันสำหรับเรียนรู้ภาษาไทยที่ออกแบบมาให้ใช้งานง่าย สนุก และมีประสิทธิภาพ ช่วยให้คุณเก่งภาษาไทยได้ตั้งแต่ระดับพื้นฐานจนถึงระดับสื่อสารได้จริง

---

## ✨ คุณสมบัติเด่น (Key Features)

- 📚 **บทเรียนที่เป็นระบบ (Structured Lessons):** แผนการเรียนรู้ที่แบ่งตามหมวดหมู่และระดับความยาก
- 🗂️ **บัตรคำศัพท์อัจฉริยะ (Smart Flashcards):** เรียนรู้คำศัพท์พร้อมภาพประกอบ คำอ่าน (Phonetics) และตัวอย่างประโยค
- 🗣️ **การฝึกออกเสียงและฟัง (Speech & Listening):**
  - ระบบ **Text-to-Speech (TTS)** สำหรับฟังการออกเสียงที่ถูกต้อง
  - ระบบ **Speech-to-Text (STT)** สำหรับฝึกพูดและประเมินความถูกต้อง
- 💬 **บทสนทนาจำลอง (Interactive Conversations):** ฝึกโต้ตอบผ่านสถานการณ์จำลองในรูปแบบ Chat
- 🔍 **ค้นหาและสำรวจ (Discover):** ติดตามข่าวสาร บทความ หรือแหล่งความรู้เพิ่มเติมเกี่ยวกับภาษาไทย
- ☁️ **ระบบคลาวด์และโปรไฟล์ (Cloud & Profile):** บันทึกความก้าวหน้าและคำศัพท์ส่วนตัวผ่าน Firebase

---

## 🛠️ เทคโนโลยีที่ใช้ (Tech Stack)

- **Framework:** [Flutter](https://flutter.dev/) (Cross-platform)
- **State Management:** [Provider](https://pub.dev/packages/provider)
- **Backend:** [Firebase](https://firebase.google.com/) (Auth, Firestore)
- **Core Libraries:**
  - `flutter_tts` & `speech_to_text`: สำหรับระบบเสียงและการพูด
  - `audioplayers`: สำหรับเล่นไฟล์เสียงประกอบบทเรียน
  - `shared_preferences`: สำหรับเก็บข้อมูลการตั้งค่าในเครื่อง
  - `cached_network_image`: เพื่อการโหลดรูปภาพที่มีประสิทธิภาพ

---

## 📂 โครงสร้างโปรเจกต์ (Project Structure)

```text
lib/
├── core/             # แกนหลักของแอป (Business Logic)
│   ├── models/       # Data models (WordEntry, LessonPlan, etc.)
│   ├── services/     # Firebase, API, Local Storage services
│   ├── viewmodels/   # Logic สำหรับจัดการ State ของแต่ละหน้า
│   └── utils/        # Function ช่วยเหลือต่างๆ
├── ui/               # ส่วนติดต่อผู้ใช้งาน (UI)
│   ├── screens/      # หน้าหลักต่างๆ ของแอป
│   ├── widgets/      # UI components ที่ใช้ซ้ำได้
│   └── theme/        # การตั้งค่าสีและ Font (Material Design 3)
├── question_type/    # Logic เฉพาะสำหรับประเภทคำถามต่างๆ
└── main.dart         # จุดเริ่มต้นของแอปพลิเคชัน
```

---

## 🚀 เริ่มต้นใช้งาน (Getting Started)

### ความต้องการพื้นฐาน
- Flutter SDK (เวอร์ชันล่าสุด)
- Android Studio / VS Code
- บัญชี Firebase (สำหรับตั้งค่า Backend)

### ขั้นตอนการติดตั้ง
1. Clone โปรเจกต์นี้
   ```bash
   git clone https://github.com/your-username/superthai.git
   ```
2. ติดตั้ง Dependencies
   ```bash
   flutter pub get
   ```
3. ตั้งค่า Firebase
   - สร้างโปรเจกต์ใน [Firebase Console](https://console.firebase.google.com/)
   - เพิ่มไฟล์ `google-services.json` (สำหรับ Android) และ `GoogleService-Info.plist` (สำหรับ iOS)
4. รันแอปพลิเคชัน
   ```bash
   flutter run
   ```

---

## 📸 ภาพตัวอย่าง (Screenshots)

*(กำลังอัปเดต...)*

---

## 🤝 การมีส่วนร่วม (Contributing)

หากคุณมีข้อเสนอแนะหรือพบปัญหา สามารถเปิด Issue หรือส่ง Pull Request มาได้เสมอครับ!

---

## 📄 ใบอนุญาต (License)

Distributed under the MIT License. See `LICENSE` for more information.
