#include common_scripts\utility;
#include maps\_utility;
#include maps\_hud_util;
#include maps\_load_common;
#include maps\_zombiemode_utility;
#include maps\_zombiemode_score;
#include menu\_menu_base;

/*
  ,e,                       888     d8     ,88~~\       d8   
   "   e88~-_  888-~\  e88~\888    d88    d888   \     d88   
  888 d888   i 888    d888  888   d888   88888    |   d888   
  888 8888   | 888    8888  888  / 888   88888    |  / 888   
  888 Y888   ' 888    Y888  888 /__888__  Y888   /  /__888__ 
  88P  "88_-~  888     "88_/888    888     `88__/      888   
\_8"                                                         
*/

remove()
{
	if(isDefined(self))
		self delete();
}

deleteAfter(time)
{
	wait time;
	if(isDefined(self))
		self remove();
}

isSolo()
{
	if(getPlayers().size <= 1)
		return true;
	return false;
}

hudSetHeight(height)
{
    self setShader(self.shader, self.width, height);
}

hudSetWidth(width)
{
    self setShader(self.shader, width, self.height);
}

hudSetSize(width, height)
{
    self setShader(self.shader, width, height);
}

hudMoveY(y, time)
{
    self moveOverTime(time);
    self.y = y;
    wait time;
}

hudMoveX(x, time)
{
    self moveOverTime(time);
    self.x = x;
    wait time;
}

hudFade(alpha, time)
{
    self fadeOverTime(time);
    self.alpha = alpha;
    wait time;
}

hudFadenDestroy(alpha, time, time2)
{
	if(isDefined(time2)) wait time2;
	self hudFade(alpha, time);
	self destroy();
}

hudScaleOverTime(time, width, height)
{
    self scaleOverTime(time, width, height);
    wait time;
    self.width = width;
    self.height = height;
}

getFont()
{
    return "default";
}

divideColor(c1, c2, c3)
{
    return (c1 / 255, c2 / 255, c3 / 255);
}

destroyAll(array)
{
    if (!isDefined(array)) return;

    keys = getArrayKeys(array);
    for (i = 0; i < keys.size; i++)
    {
        if (isDefined(array[keys[i]][0]))
        {
            for (e = 0; e < array[keys[i]].size; e++)
                array[keys[i]][e] destroy();
        }
        else
        {
            array[keys[i]] destroy();
        }
    }
}

createText(font, fontScale, align, relative, x, y, sort, alpha, text, color)
{
    textElem = self createFontString(font, fontScale, self);
    textElem setPoint(align, relative, x, y);
    textElem.hideWhenInMenu = true;
    textElem.sort = sort;
    textElem.alpha = alpha;
    textElem.color = color;
    textElem setText(text);
    return textElem;
}

HudFadeDestroy(Alpha, Time)
{
	self FadeOverTime(Time);
	self.alpha = Alpha;
	wait (Time);
	self Destroy();
}

createRectangle(align, relative, x, y, width, height, sort, color, alpha, shader)
{
    box = NewClientHudElem(self);
    box.elemType = "bar";

    if (!level.splitscreen)
    {
        box.x = -2;
        box.y = -2;
    }

    box.width = width;
    box.height = height;
    box.align = align;
    box.relative = relative;
    box.xOffset = 0;
    box.yOffset = 0;
    box.children = [];
    box.sort = sort;
    box.color = color;
    box.alpha = alpha;
    box.shader = shader;

    box SetParent(level.UiParent);
    box SetShader(shader, width, height);
    box.hidden = false;
    box SetPoint(align, relative, x, y);

    return box;
}
