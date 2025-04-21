## Earthquakes

An app to visualise on a 3D Earth model (texture from NASA Visible Earth catalog) all earthquakes detected by the U.S. Geological Survey (USGS) (https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/all_day.geojson) in the past 24h, week, or month, along with historical ones (magnitude superior or equal to 8.5 since 1900).

<img width="1443" alt="Main plain view (past 24h and historical)" src="https://github.com/user-attachments/assets/6d386292-b9cb-44e1-9200-6cb881b90271" />

<img width="1472" alt="Sidebar popover view (past 24h and historical)" src="https://github.com/user-attachments/assets/e21258cc-b124-47c0-b79e-500061cbd268" /> 

<img width="1443" alt="Sidebar historical popover view" src="https://github.com/user-attachments/assets/826fd20e-8135-4914-a63a-327a7ca8f286" />

## Install

1. Download the dmg from the [latest release](https://github.com/Thinkr1/Earthquakes/releases)
2. As I don't have a paid developer account, I cannot direcly notarize the app and you'll be presented with an alert saying it cannot be opened directly. Here are two options:

a) You can run the following command and then open the app normally: 

```sh
sudo xattr -rd com.apple.quarantine /path/to/app/folder/Earthquakes.app
```

b) You can allow the app to be opened in *System Settings > Privacy & Security* by clicking "Open Anyway" for Earthquakes.app:

<img width="458" alt="Screenshot 2025-04-21 at 4 50 00 PM" src="https://github.com/user-attachments/assets/8d5af613-f042-4da9-8558-2f8a72a1e4ac" />
