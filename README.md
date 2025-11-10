# 🕒 Flutter Alarm Clock App

A simple and elegant **Alarm Clock App** built with **Flutter**.  
It allows users to set multiple alarms, receive **local notifications**, and wake up with **custom alarm sounds** — all running smoothly even when the app is closed.

---

## ✨ Features

- ⏰ **Set Multiple Alarms** — Create, edit, and delete alarms with ease.  
- 🔔 **Local Notifications** — Works offline using the `flutter_local_notifications` plugin.  
- 🎵 **Custom Alarm Sounds** — Choose your own tone or use the default one.  
- 🌙 **Smooth and Minimal UI** — Built using Material Design components.  
- 🔄 **Repeating Alarms** — Supports daily and one-time alarms.  
- ⚙️ **Runs in Background** — Notifications trigger even when the app isn’t open.  

---

## 🧰 Tech Stack

| Component | Description |
|------------|--------------|
| **Framework** | Flutter |
| **Language** | Dart |
| **Local Notifications** | `flutter_local_notifications` |
| **Local Storage** | `SharedPreferences` / `Hive` |
| **Platform Support** | Android (tested), iOS (coming soon) |

---

📂 Folder Structure
```bash
Alarm_Clock_App_with_Local_Notifications/
│
├── android/               # Android native code
├── ios/                   # iOS native code
├── lib/                   # Main Flutter code
│   ├── main.dart          # App entry point
│   ├── screens/           # UI screens
│   ├── widgets/           # Reusable components
│   ├── services/          # Notification & alarm logic
│   └── models/            # Data models
│
├── web/                   # Web app support files (index.html, icons, manifest.json)
├── windows/               # Windows platform support
├── test/                  # Unit and widget tests
│
├── pubspec.yaml           # Project configuration
├── analysis_options.yaml  # Linting and code style
├── .gitignore             # Ignored files
└── README.md              # Project documentation

```

## 🚀 Getting Started

### 1️⃣ Clone the repository
```bash
git clone https://github.com/your-username/alarm-clock-app.git
cd alarm-clock-app
```

### 2️⃣ Install dependencies
```bash
flutter pub get
```
### 3️⃣ Run the app
```bash
flutter run
```

🌟 Future Improvements

📱 iOS & Web compatibility
☁️ Cloud alarm backup and sync
🌓 Dark mode support
🧠 Smart alarm suggestions
🎨 Multiple alarm tones
🤝 Contributing

Pull requests are welcome!
If you'd like to improve the app or fix bugs, feel free to fork this repo and open a pull request.

## 👨‍💻 Author

**Priyansh Singhal**  
📧 singhalpriyansh2005@gmail.com  
🔗 [GitHub](https://github.com/p-singhal-0011/) • [LinkedIn](https://www.linkedin.com/in/priyanshsinghal1/)


📜 License

This project is licensed under the MIT License.
See the LICENSE
 file for more details.

💙 Made with ❤️ using Flutter

