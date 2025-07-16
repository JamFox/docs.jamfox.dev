# PC Optimizations

- [Win11Debloat by Raphire](https://github.com/Raphire/Win11Debloat) – for quick and convenient Windows 11 setup.
- If using an AMD CPU, adjust PBO (Precision Boost Overdrive) settings in BIOS to undervolt.
- Disable Game Mode in Windows.
- Turn off Xbox Game Bar, if CPU has multiple CCDs.
- (Optional) In BIOS, disable SVM (Secure Virtual Machine), Memory Integrity
- In BIOS, disable HAGS (Hardware-Accelerated GPU Scheduling).
- Set `Win32PrioritySeparation` to `0x24` (DEC 36) for improved process priority handling.
- In Process Lasso:
  - Exclude core 0 from CPU affinity for games.
  - Set a rule to disable dynamic thread priority boost for games.
