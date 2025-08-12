#include common_scripts\utility;
#include maps\_utility;
#include maps\_hud_util;
#include maps\_load_common;
#include maps\_zombiemode_utility;
#include maps\_zombiemode_score;

#include menu\_menu_utilities;

/*
  ,e,                       888     d8     ,88~~\       d8   
   "   e88~-_  888-~\  e88~\888    d88    d888   \     d88   
  888 d888   i 888    d888  888   d888   88888    |   d888   
  888 8888   | 888    8888  888  / 888   88888    |  / 888   
  888 Y888   ' 888    Y888  888 /__888__  Y888   /  /__888__ 
  88P  "88_-~  888     "88_/888    888     `88__/      888   
\_8"                                                         
*/

config()
{

    self.menu["config"] = [];

    self.menu["config"]["position"] = [];
    self.menu["config"]["position"]["x"] = 0;
    self.menu["config"]["position"]["y"] = 90;

    self.menu["config"]["colours"] = [];        
    self.menu["config"]["colours"]["border"] = divideColor(0, 0, 0);
    self.menu["config"]["colours"]["background"] = divideColor(0, 0, 0);
    self.menu["config"]["colours"]["text"] = divideColor(255, 255, 255);
    self.menu["config"]["colours"]["scroller"] = divideColor(90, 90, 90);
    self.menu["config"]["colours"]["toggleEnabled"] = divideColor(74, 177, 88);
    self.menu["config"]["colours"]["toggleDisabled"] = divideColor(222, 63, 73);
    self.menu["config"]["colours"]["optionCounter"] = divideColor(255, 255, 255);
    self.menu["config"]["colours"]["highlightFactor"] = 0.35;

    self.menu["config"]["transparency"] = [];
    self.menu["config"]["transparency"]["border"] = 0.5;
    self.menu["config"]["transparency"]["background"] = 0.5;
    self.menu["config"]["transparency"]["text"] = 1;
    self.menu["config"]["transparency"]["scroller"] = 0.5;
    self.menu["config"]["transparency"]["toggle"] = 1;
    self.menu["config"]["transparency"]["optionCounter"] = 1;

    self.menu["config"]["sizes"] = [];
    self.menu["config"]["sizes"]["menu"] = 256;
    self.menu["config"]["sizes"]["scroller"] = 16;
    self.menu["config"]["sizes"]["font"] = 1;

    self.menu["config"]["sounds"] = [];
    self.menu["config"]["sounds"]["open"] = "";
    self.menu["config"]["sounds"]["close"] = "";
    self.menu["config"]["sounds"]["scroll"] = "";
    self.menu["config"]["sounds"]["activate"] = "";
    self.menu["config"]["sounds"]["return"] = "";
}
