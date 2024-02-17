**The gist:**
Mimic takes data sent from mimicme to the driver, and then recreates several EQ windows in ImGui. Interacting with these windows sends messages to the character in question to execute the actions.
Each character connected to the driver has an individual settings list for each window to be toggled on/off.
**Windows recreated:**
Target 
Extended Target 
Buffs(in progress)
Spellbar
Group 
Pet

Functionality:
Chase Assist
Auto Melee Attack
Mirror MA target
Sit toggle
Clear target
Change your spellbar in realtime with the loadout window, either via the button on the spellbar, or in settings
all interactions with the recreated windows

Planning Board(2/16/24)
![image](https://github.com/Voidless22/mimic/assets/79501102/63e977df-bc3a-4fcf-8e90-509c35eda452)

      
**Usage:**
1) On your driver character, type ``/lua run mimic``.
2) On each character you're intending to mimic, type ``/lua run mimic/mimicme``
