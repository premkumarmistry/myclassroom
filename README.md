# MyClassroom

## 📌 Project Overview
MyClassroom is a **dynamic educational platform** that provides students, teachers, and HODs with seamless access to study materials, announcements, and academic modules. The platform ensures **role-based access**, where users can interact with content based on their permissions.

## 🚀 Features
### **Student Dashboard**
- 📚 **View Study Materials** (Dropdown-based selection)
- 📢 **Announcements** (News ticker for important updates)
- 🔐 **Logout Option**

### **Teacher Dashboard**
- 📂 **Upload & Manage Study Materials** (Fully dynamic Firebase Storage structure)
- 🗂 **Create Folders Dynamically** inside assigned subjects
- 🔍 **View & Download Materials**
- 📝 **Assigned Modules (e.g., Attendance, Feedback, Marks Entry)**
- 🎯 **Access Control System** (Only assigned modules are visible)

### **HOD Dashboard**
- ✅ **Assign Subjects to Teachers** (Dynamic Firestore structure)
- 📁 **Manage Study Materials**
- 🏫 **Manage Announcements** (Enable/Disable important updates)

## 🛠️ Tech Stack
- **Frontend:** Flutter (Dart)
- **Backend:** Firebase (Firestore, Storage, Authentication)
- **Authentication:** Firebase Auth (Role-based access control)
- **Database:** Firestore (Real-time database for dynamic data handling)

## 🎯 How to Run the Project
### **Step 1: Clone the Repository**
```sh
git clone https://github.com/premkumarmistry/MyClassroom.git
cd MyClassroom
```
### **Step 2: Setup Firebase**
1. Create a Firebase project at [Firebase Console](https://console.firebase.google.com/).
2. Add an Android & iOS app and download the `google-services.json` (Android) & `GoogleService-Info.plist` (iOS).
3. Place the JSON/Plist files inside `android/app/` and `ios/Runner/` respectively.
4. Enable **Firestore**, **Firebase Storage**, and **Authentication** in Firebase.

### **Step 3: Install Dependencies**
```sh
flutter pub get
```

### **Step 4: Run the Application**
```sh
flutter run
```

## 📌 Future Enhancements
- ✅ **Student Progress Tracking**
- ✅ **Live Chat for Doubt Clearing**
- ✅ **Assignment Submission System**

## 🤝 Contributing
Pull requests are welcome! For major changes, please open an issue first to discuss the improvements.

## 📄 License
This project is licensed under the **MIT License**.

---
### 📧 Contact
For queries, reach out via **premsahebrajmistry@gmail.com** or open an issue on GitHub.

**🔥 Let's revolutionize education with MyClassroom! 🚀**

