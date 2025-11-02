
Hisaan ERP — Flutter Wrapper (Android + iOS)
===========================================
This project wraps https://erp.hisaaninternational.com using flutter_inappwebview so you can
ship Android & iOS apps with:
- window.print() → native Print dialog (Save as PDF)
- Popup print previews (window.open / target=_blank)
- File downloads (opens in the device browser / download manager)
- Back button navigation and pull-to-refresh

Cloud build (Codemagic)
-----------------------
1) Create a GitHub repo and upload all files from this folder.
2) Go to https://codemagic.io and connect your GitHub.
3) Add the repo to Codemagic; it will detect codemagic.yaml.
4) Run workflow **Android Debug APK** → download artifact app-debug.apk.
5) For Play Store, run **Android Release AAB (unsigned)** and add signing in Codemagic.
6) For iOS, you'll need an Apple Developer account; run **iOS Debug** (no codesign) or set up
   code signing in Codemagic to ship to TestFlight.
