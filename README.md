# pc_simulator_win_codeblocks
PC simulator project for LittlevGL embedded GUI Library for Windows in Codeblocks

This requires the MinGW version of **CodeBlocks 20.03 or newer** to be installed.

## How to use this:

###  Tutorial for Windows
1) Download and intall [Git](https://git-scm.com/downloads) 
2) Download [CodeBlocks](https://www.codeblocks.org/downloads/) in latest version (recommended version with MinGW)
3) Clone this repository. 
- Open **Command prompt (Win key + R -> cmd -> Enter)** or **PowerShell (Win key + R -> powershell -> Enter)** (if you want different folder than _C:/Users/username_ you have to navigate to it) and type: **git clone https://github.com/lvgl/lv_sim_codeblocks_win.git**
- In that folder type: **cd lv_sim_codeblocks_win** and press _Enter_. Here type: **git submodule update --init --recursive** and press Enter. This should download files to **lvgl, lv_examples and lv_drivers** folders.   
4) Open **CodeBlocks** and select **Open an existing project**. Navigate to folder with this simulator and select **LittlevGL.cbp**. 
5) Click on **Build and Run** or press **F9**. 
6) If everything goes well, you should see your simulator running.  

