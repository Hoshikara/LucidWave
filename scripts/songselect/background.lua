local backgroundImage = gfx.CreateSkinImage("song_select/bg.jpg", 0)
local bgFill = gfx.CreateSkinImage("bg_fill.png", 0)

render = function(deltaTime)
    gfx.ResetTransform()

    local resx, resy = game.GetResolution()
    local desw = 720
    local desh = 1280
    local scale = resy / desh

	gfx.BeginPath()
	gfx.FillColor(255, 255, 255)
	gfx.ImageRect(0, 0, resx, resy, bgFill, 1, 0)

    local xshift = (resx - desw * scale) / 2
    local yshift = (resy - desh * scale) / 2

    gfx.Translate(xshift, yshift)
    gfx.Scale(scale, scale)

    gfx.BeginPath()
    gfx.ImageRect(0, 0, desw, desh, backgroundImage, 1, 0)
end
