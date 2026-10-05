# SuperThai

**SuperThai** เป็นแอปพลิเคชันสำหรับเรียนรู้ภาษาไทยที่ออกแบบมาให้ใช้งานง่าย สนุก และมีประสิทธิภาพ ช่วยให้ผู้เรียนเก่งภาษาไทยได้ตั้งแต่ระดับพื้นฐานจนถึงระดับสื่อสารได้จริง พร้อมระบบสร้างและจัดการบทเรียนสำหรับผู้สอน (Admin/Creator Mode)

---

## คุณสมบัติเด่น (Key Features)

### 1. ระบบการเรียนรู้และแบบฝึกหัดหลากหลาย (Interactive Learning & Question Types)
แอปพลิเคชันรองรับรูปแบบการฝึกฝนถึง 12 ประเภท:
- **Flashcard:** บัตรคำศัพท์พร้อมภาพประกอบ คำอ่าน (Phonetics) และความหมาย
- **Four Choice:** คำถามแบบปรนัย 4 ตัวเลือก
- **Complete Sentence:** เติมคำในประโยคที่ขาดหายไป
- **Meaning:** แปลความหมายและพิมพ์คำศัพท์
- **Speaking:** ฝึกออกเสียงพร้อมระบบประเมินความถูกต้อง (Speech-to-Text)
- **Listening:** ฝึกฟังเสียงและระบุคำศัพท์
- **Listening Choice:** ฟังเสียงและเลือกคำตอบจาก 4 ตัวเลือก
- **Sentence Order:** เรียงลำดับคำในประโยคให้ถูกต้อง
- **Vowel Fill:** เติมสระหรือพยัญชนะที่ขาดหาย
- **Info Note:** หน้าข้อมูลพร้อมรูปภาพและข้อความอธิบายรายละเอียด
- **Conversation:** บทสนทนาจำลองโต้ตอบในรูปแบบแชท
- **Sentence Example:** ตัวอย่างประโยคและการใช้งาน

### 2. ฟีเจอร์หลักอื่นๆ (App Features)
- **ระบบเสียงสมบูรณ์แบบ:** รองรับ Text-to-Speech (TTS) และเสียงเอฟเฟกต์ (Audio Players) สำหรับคำตอบถูกต้อง/ผิด
- **บทเรียนและหมวดหมู่ (Lessons & Categories):** แผนการเรียนรู้ที่แบ่งตามหมวดหมู่และระดับความยาก (เช่น Level 1, Level 2)
- **รายการโปรด (Favorites):** บันทึกคำศัพท์หรือบทเรียนที่สนใจเพื่อกลับมาทบทวน
- **โหมดผู้สร้างบทเรียน (Creator / Admin Tools):** หน้าจอสร้างและจัดการบทเรียน แก้ไขเนื้อหา รองรับ Markdown Editor
- **ระบบคลาวด์และโปรไฟล์ (Cloud & Profile):** บันทึกความก้าวหน้าและข้อมูลผู้ใช้ผ่าน Firebase Auth & Firestore

---

## เทคโนโลยีที่ใช้ (Tech Stack)

- **Framework:** [Flutter](https://flutter.dev/) (Cross-platform - Android / iOS)
- **State Management:** [Provider](https://pub.dev/packages/provider)
- **Backend & Database:** [Firebase](https://firebase.google.com/) (Authentication, Cloud Firestore)
- **Core Packages:**
  - `flutter_tts` & `speech_to_text`: ระบบสังเคราะห์เสียงพูดและการแปลงเสียงพูดเป็นข้อความ
  - `audioplayers`: เล่นเสียงประกอบการเรียนรู้ (Correct / Wrong sound effects)
  - `shared_preferences`: จัดเก็บบันทึกการตั้งค่าภายในเครื่อง
  - `cached_network_image`: โหลดและแคชรูปภาพได้อย่างมีประสิทธิภาพ
  - `flutter_markdown`: แสดงผลบทความและเนื้อหาในรูปแบบ Markdown

---

## โครงสร้างโปรเจกต์ (Project Structure)

```text
lib/
├── core/                  # แกนหลักของแอปพลิเคชัน (Business Logic)
│   ├── enums/             # Enums เช่น QuestionType, UserRole
│   ├── models/            # Data models (Lesson, WordEntry, Question, etc.)
│   ├── services/          # Firebase, Auth, Data, Sound, Progress services
│   ├── viewmodels/        # ViewModel สำหรับจัดการ State ในแต่ละหน้า
│   └── utils/             # ฟังก์ชันช่วยเหลือและ Error Handler
├── ui/                    # ส่วนติดต่อผู้ใช้งาน (User Interface)
│   ├── screens/           # หน้าจอหลักต่างๆ (Home, Lesson, Discover, Favorites, Settings, Create, etc.)
│   ├── widgets/           # UI Components ที่ใช้ซ้ำได้ทั่วแอป
│   └── theme/             # การตั้งค่าธีมสีและ Typography (Material Design 3)
├── question_type/         # ตรรกะและหน้าจอเฉพาะของแต่ละประเภทคำถาม (Controllers & Pages)
│   ├── controllers/       # Controller จัดการ Logic ของแต่ละคำถาม
│   └── pages/             # หน้าจอ Take (ทำแบบฝึกหัด) และ Create (สร้างคำถาม)
└── main.dart              # จุดเริ่มต้นของแอปพลิเคชันและการตั้งค่า Providers
```

---

## เริ่มต้นใช้งาน (Getting Started)

### ความต้องการพื้นฐาน
- Flutter SDK (เวอร์ชันล่าสุด)
- Android Studio / VS Code พร้อม Flutter & Dart Plugins
- บัญชี Firebase สำหรับเชื่อมต่อ Backend

### ขั้นตอนการติดตั้ง
1. Clone โปรเจกต์นี้มายังเครื่องของคุณ
   ```bash
   git clone <repository-url>
   ```
2. ติดตั้ง Dependencies ทั้งหมด
   ```bash
   flutter pub get
   ```
3. ตั้งค่า Firebase
   - สร้างโปรเจกต์ใน [Firebase Console](https://console.firebase.google.com/)
   - เปิดใช้งาน Authentication และ Cloud Firestore
   - นำไฟล์ `google-services.json` ไปวางไว้ที่ `android/app/` และไฟล์ `GoogleService-Info.plist` ไว้ที่ `ios/Runner/`
4. รันแอปพลิเคชัน
   ```bash
   flutter run
   ```
