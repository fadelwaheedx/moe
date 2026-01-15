# PromptVault

PromptVault is a native macOS application for managing and organizing text prompts, inspired by 1Password's vault system. It allows you to store parameterized prompts and quickly fill in variables before copying them to the clipboard.

## Features

- **Prompt Management**: Create, edit, and delete text prompts.
- **Organization**: Group prompts into custom categories.
- **Favorites**: Quickly access your most used prompts.
- **Variable Injection**: Support for `{{variable}}` syntax. The app automatically detects variables and provides input fields to fill them.
- **Native macOS UI**: Built with SwiftUI for a seamless Mac experience.
- **Local Storage**: All data is stored locally on your device using SwiftData.

## How to Run

Since this project was generated as a Swift Package, you can open it directly in Xcode.

1.  Open **Xcode** on your Mac.
2.  Select **File > Open...**
3.  Navigate to the `PromptVault` folder in this repository and click **Open**.
4.  Xcode will resolve the package dependencies and index the project.
5.  Ensure the `PromptVault` scheme is selected in the top bar.
6.  Click the **Run** button (Play icon) or press `Cmd + R`.

## Requirements

- macOS 14.0 (Sonoma) or later.
- Xcode 15 or later.

## Architecture

- **SwiftUI**: For the user interface.
- **SwiftData**: For local persistence of `Prompt` and `Category` models.
- **MVVM-like**: Separation of Views and Data Models.

## Folder Structure

- `Sources/PromptVault/PromptVaultApp.swift`: App entry point.
- `Sources/PromptVault/Models/`: Data models (`Prompt`, `Category`).
- `Sources/PromptVault/Views/`: UI components (`ContentView`, `SidebarView`, etc.).
- `Sources/PromptVault/Utils/`: Helper logic (`VariableInjector`).
