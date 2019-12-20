resx,resy = game.GetResolution()
local wheelY = -resy
local bgFade = 0
local yoff = 0
local lastSelected = 0

render = function(deltaTime, shown)
    gfx.ResetTransform()
    gfx.BeginPath();
    gfx.LoadSkinFont("arial.ttf");
    gfx.TextAlign(gfx.TEXT_ALIGN_CENTER + gfx.TEXT_ALIGN_MIDDLE);
    gfx.FontSize(40);
    if shown then
        bgFade = math.min(bgFade + deltaTime * 10, 1)
        wheelY = math.min(wheelY + deltaTime * resy * 10, 0)
    else
        wheelY = math.max(wheelY - deltaTime * resy * 10, -resy)
        bgFade = math.max(bgFade - deltaTime * 10, 0)
    end
    gfx.FillColor(0,0,0,math.floor(200 * bgFade))
    gfx.FastRect(0,0,resx,resy)
    gfx.Fill()
    gfx.BeginPath()
    yoff = 0.8 * yoff + (settings.currentSelection - lastSelected)
    lastSelected = settings.currentSelection
    if bgFade > 0 then
        for i,setting in ipairs(settings) do
            if i == settings.currentSelection then
                gfx.FillColor(245, 65, 125)
            else
                gfx.FillColor(255, 255, 255)
            end
            gfx.FastText(string.format("%s: %s", setting.name, setting.value), resx/2, resy/2 + 40 * (i - settings.currentSelection + yoff) + wheelY, 40, gfx.TEXT_ALIGN_CENTER + gfx.TEXT_ALIGN_MIDDLE);
        end
    end
end