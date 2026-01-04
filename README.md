\# BSS Quest Macro



An open-source AutoHotkey V1.1 macro for Bee Swarm Simulator that automates questing and field gathering.



\## ⚠️ Requirements

\- \*\*Monitor Resolution\*\*: 1440p (2560x1440) at 100% scale

\- \*\*Note\*\*: 1080p support is not currently available - contributions to add this are welcome!



\## 🚀 Getting Started



\### Installation

1\. Clone or download this repository

2\. Make sure all files are in the same directory

3\. Run `MacroSettings.ahk` to start the macro



\### Recommended Setup

\- \*\*VS Code\*\* is recommended for editing and configuring the scripts

\- All scripts work together - they need each other to function properly



\## 📁 File Structure



\### Core Scripts



\*\*MacroSettings.ahk\*\* (Main File)

\- The central configuration hub

\- Configure booleans and checks for field gathering

\- Customize the GUI

\- Add/modify stored information



\*\*MacroScripts.ahk\*\* (Speed Detection)

\- Automatically detects your movement speed

\- Opens settings menu in game and searches for movespeed value

\- Uses the detected value to calculate walk distances

\- ⚠️ \*\*NOT PERFECT\*\* - Please edit and adjust as needed!



\*\*Reset\_To\_Hive.ahk\*\*

\- Checks for Shift Lock and disables if active

\- Closes any open menus

\- Confirms you're at the hive and resets

\- Uses `ShiftLockFind.ahk` for Shift Lock detection



\*\*Walk\_To\_Red.ahk\*\*

\- Waits for hive confirmation from Reset\_To\_Hive

\- Once confirmed, walks to the red field



\### Supporting Files



\*\*Images/\*\* folder

\- Contains reference images for in-game detection

\- Used to identify hive, menus, and other UI elements



\*\*Tesseract/\*\*

\- OCR (text reading) tool used by MacroScript for reading in-game text



\##Contributing



This project is \*\*fully open source\*\* and will remain that way forever. Contributions are highly encouraged.



\### Ways to Contribute

\- \*\*Add 1080p support\*\* - This is a major missing feature

\- \*\*Improve speed detection accuracy\*\* in MacroScripts.ahk

\- \*\*Optimize walk distances and timings\*\*

\- \*\*Add new features\*\* or field scripts

\- \*\*Fix bugs\*\* and improve stability

\- \*\*Enhance documentation\*\*



\### How to Experiment Locally

1\. Fork this repository

2\. Clone your fork: `git clone https://github.com/YOUR\_USERNAME/bss-quest-macro.git`

3\. Make your changes and test them

4\. Submit a pull request if you'd like to share your improvements!



\## 🐛 Known Issues

\- Movement speed detection is not 100% accurate

\- Only supports 1440p resolution



\## 💡 Feedback \& Support

\- \*\*Issues\*\*: Open an issue for bug reports or feature requests

\- \*\*Discussions\*\*: Share your modifications and ask questions

\- \*\*Pull Requests\*\*: All improvements are welcome!



\## 📝 License

\[Choose a license - MIT is recommended for open collaboration]



---



\*\*Note\*\*: This macro is a work in progress. Feel free to experiment, break things, and make it better!

