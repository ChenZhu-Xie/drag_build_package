# Sublime Packager

A lightweight batch script to **package Sublime Text plugins** into `.sublime-package` files.  
Simply drag one or more plugin folders onto the `.bat` file, and it will output the packaged files in the same directory as the script.

## ✨ Features

- Drag-and-drop support (multiple plugin folders at once)  
- Automatically generates `.sublime-package` (ZIP format)  
- Reads `.gitignore` to exclude unnecessary files  
- Supports saving the `7z.exe` path to Windows PATH

## 📦 Usage

1. Download or clone this repository  
2. Place `drag_build_package.bat` anywhere  
3. Drag plugin folders (e.g., `MyPlugin/`) onto the `.bat` file  
4. The script will generate: alongside the `.bat`

## ⚙️ 7-Zip Path Configuration

- The script defaults to `7z.exe` path: C:\Program Files\PeaZip\res\7z\7z.exe
- If not found, it will prompt you to enter a path (either a folder containing `7z.exe` or the full executable path)  
- Once verified, the path will be saved to the registry:
- On subsequent runs, this saved path will be used automatically  

## 🧹 Exclusion Rules

The script excludes the following files/directories automatically:

- `.git`
- `.gitignore`
- Rules from the project’s `.gitignore` (ignores comments starting with `#`)  

## 🚀 Example

Given a folder structure:
```
Packages/
├── MyPlugin/
|   ├── Main.py
|   ├── MyPlugin.sublime-settings
|   └── .git/
└── drag_build_package.bat
```

Drag `MyPlugin/` onto `drag_build_package.bat`.  
The output will look like this: `Packages/MyPlugin.sublime-package`
```
Packages/
├── MyPlugin/
|   ├── Main.py
|   ├── MyPlugin.sublime-settings
|   └── .git/
└── drag_build_package.bat
└── MyPlugin.sublime-package  // generated file
```

## 📄 License

MIT License  
You are free to use, modify, and distribute this script.


