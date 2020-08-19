resx,resy = game.GetResolution()
local wheelY = -resy
local bgFade = 0
local yoff = 0
local lastSelected = 0
local selection = 1
local sortLabels = {}

function render(deltaTime, shown)
    if not shown then
        return
    end
    gfx.Save()
    gfx.ResetTransform()
    resx,resy = game.GetResolution();
    gfx.FillColor(0,0,0,200)
    gfx.FastRect(0,0,resx,resy)
    gfx.BeginPath();
    gfx.LoadSkinFont("NotoSans-Regular.ttf");
    gfx.TextAlign(gfx.TEXT_ALIGN_RIGHT + gfx.TEXT_ALIGN_MIDDLE);
    gfx.FontSize(40);
    for i,f in ipairs(sorts) do
        if not sortLabels[i] then
           sortLabels[i] = gfx.CreateLabel(f, 40, 0)
        end
        if i == selection then
            gfx.FillColor(255,255,255,255)
        else
            gfx.FillColor(255,255,255,128)
        end
        local xpos = resx - 100 + ((i - selection - yoff) ^ 2) * 1
        local ypos = resy/2 + 50  * (i - selection - yoff)
        gfx.DrawLabel(sortLabels[i], xpos, ypos);
    end
    gfx.Restore()
    yoff = yoff * 0.7
end


function set_selection(index)
    selection = index
end