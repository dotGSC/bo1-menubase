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

valueEditor(valueName, multiply, info, menu)
{
    self lockMenu();
    self.menu["hud"]["text"][ getCursorIndex() ].alpha = 0;
    self.menu["hud"]["optionCounter"].alpha = 0;

    defaultVal = float(info[0]);
    minVal = float(info[1]);
    maxVal = float(info[2]);

    if (!isDefined(multiply))
        multiply = 1;

    isVarEdit = isSubStr(valueName, "value:");
    varPath = "";

    if (isVarEdit)
    {
        varPath = strTok(valueName, ":")[1];
        if (!isDefined( getVariableFromString(self, varPath)))
            setVariableFromString(self, varPath, defaultVal);
        currentVal = getVariableFromString(self, varPath);
    }
    else
    {
        currentVal = getDvarFloat(valueName);
    }

    steps = int((maxVal - minVal) / multiply + 0.5);
    loopWait = getLoopWaitTime( steps, 0.05, 0.2, 5, 100 );

    cursor = int((currentVal - minVal) / multiply + 0.5);
    cursor = clamp(cursor, 0, steps);

    sliderWidth = self.menu["hud"]["scroller"].width  - 4;
    sliderHeight = self.menu["hud"]["scroller"].height - 4;
    sliderX = self.menu["hud"]["scroller"].x;
    sliderY = self.menu["hud"]["scroller"].y + 2;

    barWidth = sliderHeight - 4;
    barHeight = sliderHeight - 4;
    padding = 4;

    sliderBase = self createRectangle("TOP", "TOP", sliderX, sliderY, sliderWidth, sliderHeight, 2, (0,0,0), 1, "white");
    sliderBar = self createRectangle("TOP", "TOP", 0, sliderY + 2, barWidth, barHeight, 3, (1,1,1), 1, "white");
    sliderBase thread editorFlashElem();
    sliderBar  thread editorFlashElem();

    percent = cursor / float(steps);
    usableWidth = sliderWidth - barWidth - padding;
    sliderBar.x = sliderX - (sliderWidth/2) + (padding/2) + (percent*usableWidth) + (barWidth/2);
    newVal = (cursor*multiply ) + minVal;
    if ( isVarEdit ) setVariableFromString(self, varPath, newVal); else self setClientDvar(valueName, newVal);

    wait 0.2;

    for (;;)
    {
        if (self adsButtonPressed() || self attackButtonPressed())
        {
            cursor -= self adsButtonPressed();
            cursor += self attackButtonPressed();
            cursor = clamp(cursor, 0, steps);
            percent = cursor / float(steps);
            sliderBar moveOverTime( 0.05 );
            sliderBar.x = sliderX - (sliderWidth/2) + (padding/2) + (percent*usableWidth) + (barWidth/2);
            newVal = (cursor*multiply) + minVal;
            if ( isVarEdit ) setVariableFromString(self, varPath, newVal); else self setClientDvar(valueName, newVal);
            wait loopWait;
            continue;
        }

        if (self meleeButtonPressed())
        {
            cursor = int((defaultVal - minVal) / multiply + 0.5);
            percent = cursor / float(steps);
            sliderBar moveOverTime( 0.05 );
            sliderBar.x = sliderX - (sliderWidth/2) + (padding/2) + (percent*usableWidth) + (barWidth/2);
            if ( isVarEdit ) setVariableFromString(self, varPath, defaultVal); else self setClientDvar(valueName, defaultVal);
        }

        if (self useButtonPressed())
            break;

        wait 0.05;
    }

    sliderBase destroy();
    sliderBar  destroy();

    self.menu["hud"]["optionCounter"].alpha = self.menu["config"]["transparency"]["optionCounter"];
    self.menu["hud"]["text"][getCursorIndex()].alpha= self.menu["config"]["transparency"]["text"];

    wait 0.2;
    self unlockMenu();
}

getLoopWaitTime(steps, minWait, maxWait, lowSteps, highSteps)
{
    if (steps <= lowSteps)
        return maxWait;
    if (steps >= highSteps)
        return minWait;
    frac = (steps - lowSteps) / float(highSteps - lowSteps);
    return maxWait - frac * (maxWait - minWait);
}

getVariableFromString(entity, varName)
{
    if (varName == "EntityDistance")
        return entity.EntityDistance;
    if (varName == "mySpeed")
        return entity.mySpeed;
    return 0;
}

setVariableFromString(entity, varName, val)
{
    if (varName == "EntityDistance")
        entity.EntityDistance = val;
    if (varName == "mySpeed")
        entity.mySpeed = val;
}

editorFlashElem()
{
    self endon("death");
    self endon("flash_over");
    alpha = self.alpha;
    for(;;)
    {
        self fadeOverTime(.2);
        self.alpha = .5;
        wait .2;
        self fadeOverTime(.2);
        self.alpha = alpha;
        wait .2;
    }
}
