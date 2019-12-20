local backgroundImage = gfx.CreateSkinImage("song_select/bg.jpg", 1)

render = function(deltaTime)
    gfx.ResetTransform()

    local resx, resy = game.GetResolution()
    local desw = 720
    local desh = 1280
    local scale = resy / desh

	gfx.BeginPath()
	gfx.FillColor(255, 255, 255)
	gfx.Rect(0, 0, resx, resy)
	gfx.Fill()

    local xshift = (resx - desw * scale) / 2
    local yshift = (resy - desh * scale) / 2

    gfx.Translate(xshift, yshift)
    gfx.Scale(scale, scale)

    gfx.BeginPath()
    gfx.ImageRect(0, 0, desw, desh, backgroundImage, 1, 0)
end
