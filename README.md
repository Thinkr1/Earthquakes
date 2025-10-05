<p align="center">
  <img alt="GitHub Release" src="https://img.shields.io/github/v/release/Thinkr1/Earthquakes?style=for-the-badge">
  <img alt="GitHub commits since latest release" src="https://img.shields.io/github/commits-since/Thinkr1/Earthquakes/latest?style=for-the-badge">
  <img alt="GitHub last commit" src="https://img.shields.io/github/last-commit/Thinkr1/Earthquakes?style=for-the-badge">
  <img alt="GitHub Downloads (all assets, all releases)" src="https://img.shields.io/github/downloads/Thinkr1/Earthquakes/total?style=for-the-badge">
  <img alt="GitHub License" src="https://img.shields.io/github/license/Thinkr1/Earthquakes?style=for-the-badge">
  <img alt="GitHub repo size" src="https://img.shields.io/github/repo-size/Thinkr1/Earthquakes?style=for-the-badge">
</p>

## Earthquakes

A macOS app for exploring seismic activity on an interactive 3D globe.
Visualise earthquake data from the [U.S. Geological Survey (USGS)](https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/all_day.geojson), showing events from the past **24 hours, week, or month**, as well as major historical earthquakes (**magnitude ≥ 8.5 since 1900**).  

The Earth texture comes from the NASA Visible Earth catalog.

<img width="1349" height="901" alt="Presentation (search, popover, 3D map)" src="https://github.com/user-attachments/assets/30982ddf-45c6-4db4-b7a6-3b7bd05e67c2" />

---

### Features
- Interactive **3D Earth model** with high-quality NASA texture  
- Live USGS earthquake feeds (daily, weekly, monthly)  
- Historical earthquakes back to 1900 (magnitude ≥ 8.5)  
- Search and detailed popovers for individual events  

---

## Installation

Download the app in **.zip** or **.dmg** format from the [latest release page »](https://github.com/Thinkr1/Earthquakes/releases/latest)

> **Note**: The app is not notarized (yet) due to the lack of a paid Apple Developer account. macOS will show an alert when opening the app for the first time saying it cannot be opened directly. Here are two options to open it:

### Option A – Command line

```sh
sudo xattr -rd com.apple.quarantine /path/to/Earthquakes.app
```

Then open it normally.

### Option B – macOS Security Settings

1. Go to **System Settings > Privacy & Security**
2. Scroll down to the **Security** section
3. Click **"Open Anyway"** for `Earthquakes.app`

<p align="center">
  <img width="458" alt="Screenshot 2025-04-21 at 4 50 00 PM" src="https://github.com/user-attachments/assets/8d5af613-f042-4da9-8558-2f8a72a1e4ac" />
</p>

---

### Verify File Integrity

You can verify that your download hasn’t been tampered with by checking its SHA-256 checksum.

1. Download the matching .sha256 file:

From the release page, download:

- Earthquakes.dmg.sha256 if you downloaded the `.dmg`
- Earthquakes.zip.sha256 if you downloaded the `.zip`

2. Verify the file integrity through the command line *(make sure the downloaded dmg or zip is in the same folder as the checksum)*:

```sh
# For the DMG
shasum -a 256 -c Earthquakes.dmg.sha256

# For the ZIP
shasum -a 256 -c Earthquakes.zip.sha256
```

## Contributions

Pull requests are welcome! Whether it's a bug fix, feature suggestion, or just a cool idea—[open an issue](https://github.com/Thinkr1/Earthquakes/issues) or submit a PR.

## License

This project is released under the [MIT License](LICENSE).
