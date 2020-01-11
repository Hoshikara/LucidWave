local transitionTimer = 0
local outTimer = 1
local animTimer = 0
local jacket = 0

local played = false
game.LoadSkinSample("boot_song")

local resx, resy
local portrait
local desw, desh
local scale

function ResetLayoutInformation()
    resx, resy = game.GetResolution()
    portrait = resy > resx
    desw = portrait and 720 or 1280 
    desh = desw * (resy / resx)
    scale = resx / desw
end

function render(deltaTime)
    render_screen()
    transitionTimer = transitionTimer + deltaTime
    transitionTimer = math.min(transitionTimer, 1)
    if song.jacket == 0 and jacket == 0 then
        jacket = gfx.CreateSkinImage("song_select/jacket_loading.png", 0)
    elseif jacket == 0 then
        jacket = song.jacket
    end
    return transitionTimer >= 1
end

function render_out(deltaTime)
    outTimer = outTimer + deltaTime * 2
    outTimer = math.min(outTimer, 2)
    render_screen(outTimer)
    return outTimer >= 2
end

local bgPortrait = gfx.CreateSkinImage("song_transition/bg_portrait.png", 0)
local bgLandscape = gfx.CreateSkinImage("song_transition/bg_landscape.png", 0)
local jacketBorder = gfx.CreateSkinImage("song_transition/jacket_border.png", 0)

function render_screen()

	ResetLayoutInformation()

	if portrait then
		if not played then
			game.PlaySample("boot_song")
			played = true
		end

		animTimer = transitionTimer * 2 - outTimer

		gfx.Save()
		gfx.BeginPath()
		gfx.ImageRect(0, 0, resx, resy, bgPortrait, animTimer, 0)

		gfx.Translate((resx / 2), (resy / 2))

		local jBgX = -213 * scale
		local jBgY = (-264 - animTimer * 100) * scale
		local jBgW, jBgH = 426 * scale, 426 * scale

		local jX = -210 * scale
		local jY = (-261 - animTimer * 100) * scale
		local jW, jH = 420 * scale, 420 * scale

		gfx.FillColor(255, 255, 255)

		gfx.BeginPath()
		gfx.ImageRect(jBgX, jBgY, jBgW, jBgH, jacketBorder, animTimer, 0)

		gfx.BeginPath()
		gfx.ImageRect(jX, jY, jW, jH, jacket, animTimer, 0)

		local title = gfx.CreateLabel(song.title, math.floor(30 * scale), 0)
		local artist = gfx.CreateLabel(song.artist, math.floor(24 * scale), 0)
	
		gfx.LoadSkinFont("arial.ttf")

		if (math.floor(animTimer) == 1) then
			gfx.TextAlign(gfx.TEXT_ALIGN_CENTER + gfx.TEXT_ALIGN_MIDDLE)

			gfx.BeginPath()
			gfx.FillColor(55, 255, 255)
			gfx.DrawLabel(title, 0, (145 * scale), (385 * scale))
			gfx.FillColor(255, 255, 255)
			gfx.DrawLabel(title, 0, (144 * scale), (385 * scale))

			gfx.BeginPath()
			gfx.FillColor(55, 255, 255)
			gfx.DrawLabel(artist, 0, (189 * scale), (385 * scale))
			gfx.FillColor(255, 255, 255)
			gfx.DrawLabel(artist, 0, (188 * scale), (385 * scale))
		end

		gfx.Restore()
	else
		if not played then
			game.PlaySample("boot_song")
			played = true
		end

		animTimer = transitionTimer * 2 - outTimer

		gfx.Save()

		gfx.BeginPath()
		gfx.ImageRect(0, 0, resx, resy, bgLandscape, animTimer, 0)

		gfx.Translate((resx / 2), (resy / 2))

		local jBgX = (-213 * 0.8) * scale
		local jBgY = ((-163 * 0.8) - animTimer * 100) * scale
		local jBgW, jBgH = (426 * 0.8) * scale, (426 * 0.8) * scale

		local jX = (-210 * 0.8) * scale
		local jY = ((-160 * 0.8) - animTimer * 100) * scale
		local jW, jH = (420 * 0.8) * scale, (420 * 0.8) * scale

		gfx.FillColor(255, 255, 255)

		gfx.BeginPath()
		gfx.ImageRect(jBgX, jBgY, jBgW, jBgH, jacketBorder, animTimer, 0)

		gfx.BeginPath()
		gfx.ImageRect(jX, jY, jW, jH, jacket, animTimer, 0)

		local title = gfx.CreateLabel(song.title, math.floor(30 * scale), 0)
		local artist = gfx.CreateLabel(song.artist, math.floor(24 * scale), 0)
	
		gfx.LoadSkinFont("arial.ttf")

		if (math.floor(animTimer) == 1) then
			gfx.TextAlign(gfx.TEXT_ALIGN_CENTER + gfx.TEXT_ALIGN_MIDDLE)

			gfx.BeginPath()
			gfx.FillColor(55, 255, 255)
			gfx.DrawLabel(title, 0, (173 * scale), (420 * scale))
			gfx.FillColor(255, 255, 255)
			gfx.DrawLabel(title, 0, (172 * scale), (420 * scale))

			gfx.BeginPath()
			gfx.FillColor(55, 255, 255)
			gfx.DrawLabel(artist, 0, (217 * scale), (420 * scale))
			gfx.FillColor(255, 255, 255)
			gfx.DrawLabel(artist, 0, (216 * scale), (420 * scale))
		end

		gfx.Restore()
	end
end