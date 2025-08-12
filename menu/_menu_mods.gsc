#include common_scripts\utility;
#include maps\_utility;
#include maps\_hud_util;
#include maps\_load_common;
#include maps\_zombiemode_utility;
#include maps\_zombiemode_score;
#include menu\_menu_base;
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

godMode()
{
    self.godMode = !isDefined(self.godMode) || !self.godMode;
    if (self.godMode) self enableInvulnerability(); else self disableInvulnerability();
    self thread setToggleState(self getActiveMenu(), self.menu["menu"][self getActiveMenu()]["cursor"], self.godMode);
}
