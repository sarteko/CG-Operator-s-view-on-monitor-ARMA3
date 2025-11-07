# 🎥 Arma 3 CG-Operator's view on monitor
## 📸 Preview / Anteprima

<img width="1870" height="935" alt="sc1" src="https://github.com/user-attachments/assets/13eda284-b0d7-4682-8175-ece237783497" />

<img width="1712" height="847" alt="sc3" src="https://github.com/user-attachments/assets/4b7b35ef-b2bd-4315-9b36-4b13c34e4144" />

<img width="637" height="358" alt="sc4" src="https://github.com/user-attachments/assets/4530ad3d-c757-4bbc-807f-2223122ffd58" />

![screen](https://github.com/user-attachments/assets/c9884e7c-a15c-4aff-8383-b31c3ce6b78c)


---


### 🧩 Version
FIX V2.5 (01/11/2025)
Added functionality for playing on multiple monitors.
Just set the variable name correctly on the monitors; by default,
operatorcam (master) changes the cams on the (slave) monitors operatorcam1 and operatorcam2, 3, 4, etc., based on how many monitors you want.
The monitors (slaves) can still change cam but if the monitor (master) is changed by someone it will also change on the slaves.

If the script is set up correctly, you can create different groups of monitors, such as splitting by team, for example:
bravocam/alphacam (master)
bravocam/alphacam1 (slave)
bravocam/alphacam2 (slave) 3, 4, 5, etc.


// Format: ["monitor_master", ["monitor_slave_1", "monitor_slave_2", ...]]

["operatorcam", ["operatorcam1", "operatorcam2"]]

// Add other configurations if necessary:

// ,["operatorcam_alpha", ["operatorcam_alpha1", "operatorcam_alpha2"]]

// ,["operatorcam_bravo", ["operatorcam_bravo1"]]
];

BUG:

There's a bug. If I turn off a slave monitor, the other monitors turn off. Can I fix it? I don't know...

**FIX V2.1** (28/11/2025)

- Used element: **Vanilla**
- In case of undercover missions (CIVIL), the operator's name will be in 🟣 **PURPLE**, not 🔵 **BLUE**.
- **Fix:** Camera position adjustment  
- **Graphics requirement:** PiP (Picture-in-Picture) **at least on High**
- Fix for multiplayer

---

### 📝 Description
This **Arma 3 script** allows monitors to be connected to operators equipped with **helmet cameras**, showing their **real-time video feed** on in-game displays.

Ideal for immersive command centers or tactical operations where live visual feedback is required.

---

### ⚙️ Requirements

#### 🔹 Required Mods
- **[CBA_A3](https://steamcommunity.com/workshop/filedetails/?id=450814997)**  
- **[cTab](https://steamcommunity.com/sharedfiles/filedetails/?id=2511318948)**  

> ⚠️ **The script will NOT work without these two mods!**

---

### 🎯 Trigger: [**BLUFORCE to CIVILIAN for Undercover**](https://steamcommunity.com/sharedfiles/filedetails/?id=3595437256)

If you want to easily switch your BLUFORCE unit to a **civilian identity** during undercover missions, you can use this trigger:

**Trigger Name:** `BLUFORCE to CIVILIAN for Undercover`  

This trigger allows operators to change side and appearance dynamically during missions, making covert operations more immersive and functional.  
It can be placed directly in the **Arma 3 Editor**, and combined with the helmet cam script for full tactical control.

---

### 💡 Inspired by
[Live Map (Whiteboard)](https://steamcommunity.com/sharedfiles/filedetails/?id=3018683365)

---

### 🔧 Camera Position Adjustment
Fine-tuned for better alignment and realism.

```sqf
private _adjustedPos = _eyePos vectorAdd ((_eyeDir vectorMultiply 0.08) vectorAdd [-0.162, -0.015, -0.01]);
