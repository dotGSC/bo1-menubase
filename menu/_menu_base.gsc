#include common_scripts\utility;
#include maps\_hud_util;
#include maps\_load_common;
#include maps\_utility;
#include maps\_zombiemode_score;
#include maps\_zombiemode_utility;
#include menu\_menu_config;
#include menu\_menu_editors;
#include menu\_menu_mods;
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

setupMenus()
{
	if (isDefined(self.menu["menu"]["access"]))
		return;

	self.menu["menu"] = [];
	self.menu["menu"]["access"] = true;

	self thread defineMenuOptions();
	self thread setActiveMenu("MAIN_MENU");
	self thread monitorMenuOpenInput();
	self thread menuMainLoop();
}

defineMenuOptions()
{
	menuId = "MAIN_MENU";
	self createMenu(menuId, "MAIN_MENU", undefined);
	self createOption(menuId, "SAMPLE SCRIPTS", ::openSubMenu, undefined, "SAMPLE_SCRIPTS");

	menuId = "SAMPLE_SCRIPTS";
	self createMenu(menuId, "SAMPLE_SCRIPTS", "MAIN_MENU");
	self createOption(menuId, "ENABLE GOD MODE", ::godMode, true);
	self createOption(menuId, "SET PLAYER SPEED", ::valueEditor, undefined, "g_speed", 5, strTok("190;0;1000", ";"));
    self createOption(menuId, "SCROLLING TEST SUB MENU", ::openSubMenu, undefined, "SCROLLING_TEST");

    menuId = "SCROLLING_TEST";
	self createMenu(menuId, "SCROLLING_TEST", "SAMPLE_SCRIPTS");
    for (i = 0; i < 250; i++) self createOption(menuId, "TEST OPTION " + (i+1), ::doNothing, undefined);

}

doNothing()
{
    self iPrintLn("this function does absolutely nothing.");
}

getActiveMenu()
{
	return self.menu["menu"]["currentMenu"];
}

setActiveMenu(menu)
{
	self.menu["menu"]["currentMenu"] = menu;
}

lockMenu(close)
{
	if (isDefined(self.menu["menu"]["open"]) && isDefined(close))
		self closeMenu();

	self.menu["menu"]["locked"] = true;
}

unlockMenu()
{
	if (isDefined(self.menu["menu"]["locked"]))
		self.menu["menu"]["locked"] = undefined;
}

openSubMenu(menu)
{
	self destroyMenuText();
	self thread setActiveMenu(menu);
	self thread refreshMenuSize();
	self thread renderMenuText();
	self thread updateMenuCursor();
	wait 0.4;
}

closeMenu()
{
	self destroyAll(self.menu["hud"]);
	self destroyAll(self.menu["hud"]["toggle"]);
	self.menu["menu"]["open"] = undefined;

	self thread setActiveMenu("MAIN_MENU");
	self notify("menuExit");
	self thread menuMainLoop();
}

updateCursor(cursor)
{
	self.menu["menu"][self getActiveMenu()]["cursor"] = cursor;
	self updateMenuCursor();
}

getCursorIndex()
{
	cursor = self.menu["menu"][self getActiveMenu()]["cursor"];
	options = self.menu["menu"][self getActiveMenu()]["option"];
	optionCount = options.size;
	startIndex = 0;

	if (optionCount > 5 && isDefined(options[cursor - 2]))
	{
		if (isDefined(options[cursor + 2]))
			startIndex = cursor - 2;
		else
			startIndex = optionCount - 5;
	}

	return cursor - startIndex;
}

monitorMenuOpenInput()
{
	self endon("death");
	self endon("disconnect");

	for (;;)
	{
		if (self adsButtonPressed() && self meleeButtonPressed())
			self notify("menuOpen", "MAIN_MENU", self.menu["menu"]["MAIN_MENU"]["cursor"]);

		wait 0.01;
	}
}

handleMenuInput()
{
	self endon("death");
	self endon("disconnect");
	self endon("menuExit");

	for (;;)
	{
		if (isDefined(self.menu["menu"]["locked"]) && self.menu["menu"]["locked"])
		{
			wait 0.05;
			continue;
		}

		if (self adsButtonPressed() || self attackButtonPressed())
		{
			self.menu["menu"][self getActiveMenu()]["cursor"] += self attackButtonPressed();
			self.menu["menu"][self getActiveMenu()]["cursor"] -= self adsButtonPressed();

			self thread updateCursor(self.menu["menu"][self getActiveMenu()]["cursor"]);
			self playLocalSound(self.menu["config"]["sounds"]["scroll"]);
			wait 0.1;
		}

		if (self useButtonPressed())
		{
			i = self.menu["menu"][self getActiveMenu()]["cursor"];
			menu = self.menu["menu"][self getActiveMenu()];
			self thread [[menu["function"][i]]](menu["input1"][i], menu["input2"][i], menu["input3"][i]);
			self playLocalSound(self.menu["config"]["sounds"]["activate"]);
			wait 0.2;
		}

		if (self meleeButtonPressed())
		{
			parent = self.menu["menu"][self getActiveMenu()]["parent"];

			if (!isDefined(parent))
			{
				self playLocalSound(self.menu["config"]["sounds"]["close"]);
				self thread closeMenu();
			}
			else
			{
				self playLocalSound(self.menu["config"]["sounds"]["return"]);
				self openSubMenu(parent);
			}
		}

		wait 0.05;
	}
}

monitorPlayerState()
{
	self endon("death");
	self endon("disconnect");

	for (;;)
	{
		if (isDefined(self.reviveTrigger))
		{
			self thread closeMenu();
			break;
		}
		wait 0.05;
	}
}

renderMenuUi()
{
	optionCount = self.menu["menu"][self getActiveMenu()]["option"].size;

	self.menu["hud"] = [];
	self.menu["hud"]["background"] = self CreateRectangle("TOP", "TOP",
		self.menu["config"]["position"]["x"], self.menu["config"]["position"]["y"],
		self.menu["config"]["sizes"]["menu"], optionCount * self.menu["config"]["sizes"]["scroller"], 0,
		self.menu["config"]["colours"]["background"], self.menu["config"]["transparency"]["background"], "white");

	self.menu["hud"]["border"] = self CreateRectangle("TOP", "TOP",
		self.menu["config"]["position"]["x"], self.menu["config"]["position"]["y"] - 2,
		self.menu["hud"]["background"].width + 4, optionCount * self.menu["config"]["sizes"]["scroller"] + 4, -2,
		self.menu["config"]["colours"]["border"], self.menu["config"]["transparency"]["border"], "white");

	self.menu["hud"]["scroller"] = self CreateRectangle("TOP", "TOP",
		self.menu["config"]["position"]["x"], self.menu["config"]["position"]["y"],
		self.menu["config"]["sizes"]["menu"], self.menu["config"]["sizes"]["scroller"], 1,
		self.menu["config"]["colours"]["scroller"], self.menu["config"]["transparency"]["scroller"], "white");

	self.menu["hud"]["optionCounter"] = self createText(getFont(), self.menu["config"]["sizes"]["font"], "RIGHT", "TOP",
		self.menu["hud"]["scroller"].x + 93, self.menu["hud"]["scroller"].y + (self.menu["hud"]["scroller"].height / 2), 2, 
		self.menu["config"]["transparency"]["optionCounter"], " ", self.menu["config"]["colours"]["optionCounter"]);
}

renderMenuText()
{
	self.menu["hud"]["text"] = [];
	for (i = 0; i < 5; i++)
		self.menu["hud"]["text"][i] = self createText(getFont(), self.menu["config"]["sizes"]["font"], "LEFT", "TOP", self.menu["hud"]["background"].x - 97, (i * self.menu["config"]["sizes"]["scroller"]) + self.menu["config"]["position"]["y"] + (self.menu["hud"]["scroller"].height / 2), 2, self.menu["config"]["transparency"]["text"], "", self.menu["config"]["colours"]["text"]);
}

refreshMenuSize()
{
	optionCount = self.menu["menu"][self getActiveMenu()]["option"].size;
	if (optionCount > 5) optionCount = 5;
	self.menu["hud"]["background"] thread hudSetHeight(optionCount * self.menu["config"]["sizes"]["scroller"]);
	self.menu["hud"]["background"].height = optionCount * self.menu["config"]["sizes"]["scroller"];
	self.menu["hud"]["border"] thread hudSetHeight((optionCount * self.menu["config"]["sizes"]["scroller"]) + 4);
	self.menu["hud"]["border"].height = (optionCount * self.menu["config"]["sizes"]["scroller"]) + 4;
}

updateMenuCursor()
{
	menu = self getActiveMenu();
	options = self.menu["menu"][menu]["option"];
	optionCount = options.size;
	cursor = self.menu["menu"][menu]["cursor"];

	if (cursor < 0) cursor = optionCount - 1;
	if (cursor >= optionCount) cursor = 0;
	self.menu["menu"][menu]["cursor"] = cursor;

	visible = self.menu["hud"]["text"];
	scroller = self.menu["hud"]["scroller"];
	baseY = self.menu["config"]["position"]["y"];
	textColor = self.menu["config"]["colours"]["text"];
	highlightFactor = self.menu["config"]["colours"]["highlightFactor"];

	lineHeight = scroller.height;
	visibleCount = visible.size;

	startIndex = 0;
	if (optionCount > visibleCount && isDefined(options[cursor - 2]))
	{
		if (isDefined(options[cursor + 2]))
			startIndex = cursor - 2;
		else
			startIndex = optionCount - visibleCount;
	}

	for (i = 0; i < visibleCount; i++)
	{
		index = startIndex + i;
		if (isDefined(options[index]))
		{
			visible[i] SetText(options[index]);
			visible[i].color = (index == cursor) * textColor + (index != cursor) * (textColor[0] * highlightFactor, textColor[1] * highlightFactor, textColor[2] * highlightFactor);
		}
		else
		{
			visible[i] SetText("");
		}
	}

	if (startIndex == 0)
		scroller.y = lineHeight * cursor + baseY;
	else if (startIndex == cursor - 2)
		scroller.y = baseY + (lineHeight * 2);
	else
		scroller.y = lineHeight * (cursor - optionCount + visibleCount) + baseY;

	optionCounter = self.menu["hud"]["optionCounter"];
	optionCounter setPoint("RIGHT", "TOP", scroller.x + self.menu["config"]["sizes"]["menu"] / 2 - 4, scroller.y + (lineHeight / 2));
	optionCounter setText((cursor + 1) + "/" + optionCount);
	self thread refreshTogglesDisplay();
}

refreshTogglesDisplay()
{
	self DestroyAll(self.menu["hud"]["toggle"]);

	menu = self getActiveMenu();
	menuData = self.menu["menu"][menu];
	options = menuData["option"];
	toggles = menuData["toggle"];
	toggleColors = menuData["toggleColour"];
	visibleLines = self.menu["hud"]["text"];
	baseY = self.menu["config"]["position"]["y"];
	optionCount = options.size;
	cursor = menuData["cursor"];
	highlightFactor = self.menu["config"]["colours"]["highlightFactor"];

	startIndex = 0;
	if (optionCount > 5 && isDefined(options[cursor - 2]))
	{
		if (isDefined(options[cursor + 2]))
			startIndex = cursor - 2;
		else
			startIndex = optionCount - 5;
	}

	for (i = 0; i < 5; i++)
	{
		actualIndex = startIndex + i;
		if (!isDefined(options[actualIndex]))
			continue;

		if (isDefined(toggles[actualIndex]) && toggles[actualIndex])
		{
			color = toggleColors[actualIndex];
			if (actualIndex != cursor)
				color = (color[0] * highlightFactor, color[1] * highlightFactor, color[2] * highlightFactor);

			scrollBarHeight = int(self.menu["hud"]["scroller"].height - 8);
			rect = self CreateRectangle(
				"LEFT", "TOP",
				self.menu["hud"]["background"].x - (self.menu["hud"]["background"].width / 2 - 4),
				visibleLines[i].y,
				scrollBarHeight, scrollBarHeight, 5,
				color, self.menu["config"]["transparency"]["toggle"], "white"
			);

			self.menu["hud"]["toggle"][i] = rect;
			visibleLines[i].x = self.menu["hud"]["background"].x - (self.menu["hud"]["background"].width / 2 - 4) + rect.width + 4;
		}
		else
		{
			visibleLines[i].x = self.menu["hud"]["background"].x - (self.menu["hud"]["background"].width / 2 - 4);
		}
	}
}

setToggleState(menu, opt, arg)
{
	if (!isDefined(self.menu["menu"][menu]["toggle"][opt]))
		return;

	if (isDefined(arg) && arg)
		color = self.menu["config"]["colours"]["toggleEnabled"];
	else
		color = self.menu["config"]["colours"]["toggleDisabled"];

	self.menu["menu"][menu]["toggleColour"][opt] = color;

	cursor = self.menu["menu"][menu]["cursor"];
	optionCount = self.menu["menu"][menu]["option"].size;
	visibleCount = 5;

	startIndex = 0;
	if (optionCount > visibleCount && isDefined(self.menu["menu"][menu]["option"][cursor - 2]))
	{
		if (isDefined(self.menu["menu"][menu]["option"][cursor + 2]))
			startIndex = cursor - 2;
		else
			startIndex = optionCount - visibleCount;
	}

	visibleIndex = opt - startIndex;
	if (visibleIndex >= 0 && visibleIndex < visibleCount && isDefined(self.menu["hud"]["toggle"][visibleIndex]))
		self.menu["hud"]["toggle"][visibleIndex].color = color;
}

createMenu(menu, title, parent)
{
	self.menu["menu"][menu]["option"] = [];
	self.menu["menu"][menu]["title"] = title;
	self.menu["menu"][menu]["parent"] = parent;
	self.menu["menu"][menu]["cursor"] = 0;
}

createOption(menu, opt, func, toggle, input1, input2, input3, input4)
{
	i = self.menu["menu"][menu]["option"].size;
	self.menu["menu"][menu]["option"][i] = opt;
	self.menu["menu"][menu]["function"][i] = func;
	self.menu["menu"][menu]["input1"][i] = input1;
	self.menu["menu"][menu]["input2"][i] = input2;
	self.menu["menu"][menu]["input3"][i] = input3;
	self.menu["menu"][menu]["input4"][i] = input4;

	if (isDefined(toggle) && toggle)
	{
		self.menu["menu"][menu]["toggle"][i] = true;
		self.menu["menu"][menu]["toggleColour"][i] = self.menu["config"]["colours"]["toggleDisabled"];
	}
}

destroyMenuText()
{
	self destroyAll(self.menu["hud"]["toggle"]);
	self destroyAll(self.menu["hud"]["text"]);
}

menuMainLoop()
{
	for (;;)
	{
		self waittill("menuOpen", menu, curs);
		if (!isDefined(self.menu["menu"]["locked"]) && !isDefined(self.menu["menu"]["open"]) && !isDefined(self.reviveTrigger))
			break;
	}

	self playLocalSound(self.menu["config"]["sounds"]["open"]);
	self.menu["menu"][self getActiveMenu()]["cursor"] = curs;
	self.menu["menu"]["open"] = true;

	self thread renderMenuUi();
	self thread renderMenuText();
	self thread setActiveMenu(menu);
	self thread updateMenuCursor();
	self thread monitorPlayerState();

	wait 0.5;
	self thread handleMenuInput();
}
