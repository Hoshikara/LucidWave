local transitionTimer = 0
local outTimer = 1
local animTimer = 0
local jacket = 0

local played = false
game.LoadSkinSample("start_gameplay")

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
    render_screen(transitionTimer)
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

local jacketBorder = gfx.CreateSkinImage("song_transition/jacket_border.png", 0)

local difficulties = {
    gfx.CreateSkinImage("song_transition/difficulties/novice.png", 0),
    gfx.CreateSkinImage("song_transition/difficulties/advanced.png", 0),
    gfx.CreateSkinImage("song_transition/difficulties/exhaust.png", 0),
    gfx.CreateSkinImage("song_transition/difficulties/maximum.png", 0)
}

local stripesLightPortrait = gfx.CreateSkinImage("song_transition/stripes_light_p.png", 0)
local stripesDarkPortrait = gfx.CreateSkinImage("song_transition/stripes_dark_p.png", 0)
local topLeftDetailPortrait = gfx.CreateSkinImage("song_transition/top_left_detail_p.png", 0)
local bottomRightDetailPortrait = gfx.CreateSkinImage("song_transition/bottom_right_detail_p.png", 0)
local dividerPortrait = gfx.CreateSkinImage("song_transition/divider_p.png", 0)

local stripesLightLandscape = gfx.CreateSkinImage("song_transition/stripes_light_l.png", 0)
local stripesDarkLandscape = gfx.CreateSkinImage("song_transition/stripes_dark_l.png", 0)
local topLeftDetailLandscape = gfx.CreateSkinImage("song_transition/top_left_detail_l.png", 0)
local bottomRightDetailLandscape = gfx.CreateSkinImage("song_transition/bottom_right_detail_l.png", 0)
local dividerLandscape = gfx.CreateSkinImage("song_transition/divider_l.png", 0)

function render_screen()

	ResetLayoutInformation()

	local title = gfx.CreateLabel(song.title, math.floor(30 * scale), 0)
	local artist = gfx.CreateLabel(song.artist, math.floor(24 * scale), 0)
	local effector = gfx.CreateLabel(song.effector, math.floor(18 * scale), 0)
	local illustrator = gfx.CreateLabel(song.illustrator, math.floor(18 * scale), 0)

	local dW, dH = gfx.ImageSize(difficulties[1])

	if portrait then
		if not played then
			game.PlaySample("start_gameplay")
			played = true
		end

		animTimer = transitionTimer * 2 - outTimer 

		gfx.Save()

		gfx.Save()
		gfx.Translate(0, resy)
		gfx.Rotate(math.rad(-138))
		gfx.Scissor(-1000 * scale, 0, 2000 * scale, ((animTimer * 2) * 1000) * scale)
		gfx.Rotate(-math.rad(-138))
		gfx.Translate(0, -resy)
		gfx.BeginPath()
		gfx.FillColor(255, 255, 255)
		gfx.ImageRect(0, 0, resx, resy, stripesLightPortrait, 1, 0)
		gfx.ResetScissor()
		gfx.Restore()

		gfx.Save()
		gfx.Translate(resx, 0)
		gfx.Rotate(math.rad(42))
		gfx.Scissor(-1000 * scale, 0, 2000 * scale, ((animTimer * 2) * 1000) * scale)
		gfx.Rotate(-math.rad(42))
		gfx.Translate(-resx, 0)
		gfx.BeginPath()
		gfx.FillColor(255, 255, 255)
		gfx.ImageRect(0, 0, resx, resy, stripesDarkPortrait, 1, 0)
		gfx.ResetScissor()
		gfx.Restore()

		gfx.Save()
		gfx.Rotate(math.rad(-48))
		gfx.Scissor(-1000 * scale, 0, 2000 * scale, ((animTimer * 2) * 600) * scale)
		gfx.Rotate(-math.rad(-48))
		gfx.BeginPath()
		gfx.FillColor(255, 255, 255)
		gfx.ImageRect(0, 0, resx, resy, topLeftDetailPortrait, 1, 0)
		gfx.ResetScissor()
		gfx.Restore()

		gfx.Save()
		gfx.Translate(resx, resy)
		gfx.Rotate(math.rad(132))
		gfx.Scissor(-1000 * scale, 0, 2000 * scale, ((animTimer * 2) * 700) * scale)
		gfx.Rotate(-math.rad(132))
		gfx.Translate(-resx, -resy)
		gfx.BeginPath()
		gfx.FillColor(255, 255, 255)
		gfx.ImageRect(0, 0, resx, resy, bottomRightDetailPortrait, 1, 0)
		gfx.ResetScissor()
		gfx.Restore()

		gfx.Save()
		gfx.Translate(resx / 2, resy)
		gfx.Rotate(math.rad(180))
		gfx.Scissor(-1000 * scale, 0, 2000 * scale, (0 + (animTimer * 2) * 450) * scale)
		gfx.Rotate(-math.rad(180))
		gfx.Translate(-(resx / 2), -resy)
		gfx.BeginPath()
		gfx.FillColor(255, 255, 255)
		gfx.ImageRect(0, 0, resx, resy, dividerPortrait, 1, 0)
		gfx.ResetScissor()
		gfx.Restore()

		gfx.Translate((resx / 2), (resy / 2))

		local jBgX = -213 * scale
		local jBgY = (-284 - animTimer * 100) * scale
		local jBgW, jBgH = 426 * scale, 426 * scale

		local jX = -210 * scale
		local jY = (-281 - animTimer * 100) * scale
		local jW, jH = 420 * scale, 420 * scale

		gfx.FillColor(255, 255, 255)

		gfx.BeginPath()
		gfx.ImageRect(194 * scale, (40 - animTimer * 100) * scale, (dW * 0.35) * scale, (dH * 0.35) * scale, difficulties[song.difficulty + 1], animTimer, 0) --55

		gfx.BeginPath()
		gfx.ImageRect(jBgX, jBgY, jBgW, jBgH, jacketBorder, animTimer, 0)

		gfx.BeginPath()
		gfx.ImageRect(jX, jY, jW, jH, jacket, animTimer, 0)

		if (math.floor(animTimer) == 1) then
			local tX = 0

			if (song.level < 10) then
				tX = 261 * scale
			else
				tX = 260 * scale
			end

			gfx.TextAlign(gfx.TEXT_ALIGN_CENTER + gfx.TEXT_ALIGN_MIDDLE)

			gfx.LoadSkinFont("slant.ttf")

			gfx.BeginPath()
			gfx.FontSize(math.floor(40 * scale))
			gfx.FillColor(245, 65, 125)
			gfx.Text(string.format("%02d", song.level), tX, (-14 * scale) + 1)
			gfx.FillColor(55, 255, 255)
			gfx.Text(string.format("%02d", song.level), tX + 1, (-14 * scale))
			gfx.FillColor(255, 255, 255)
			gfx.Text(string.format("%02d", song.level), tX, (-14 * scale))

			gfx.BeginPath()
			gfx.FontSize(math.floor(20 * scale))
			gfx.FillColor(245, 65, 125)
			gfx.Text(song.bpm, (260 * scale), (24 * scale) + 1)
			gfx.FillColor(55, 255, 255)
			gfx.Text(song.bpm, (260 * scale) + 1, (24 * scale))
			gfx.FillColor(255, 255, 255)
			gfx.Text(song.bpm, (260 * scale), (24 * scale))

			gfx.LoadSkinFont("arial.ttf")

			gfx.BeginPath()
			gfx.FillColor(55, 255, 255)
			gfx.DrawLabel(title, 0, (125 * scale), (385 * scale))
			gfx.FillColor(255, 255, 255)
			gfx.DrawLabel(title, 0, (124 * scale), (385 * scale))

			gfx.BeginPath()
			gfx.FillColor(55, 255, 255)
			gfx.DrawLabel(artist, 0, (168 * scale), (385 * scale))
			gfx.FillColor(255, 255, 255)
			gfx.DrawLabel(artist, 0, (167 * scale), (385 * scale))

			gfx.BeginPath()
			gfx.FillColor(55, 255, 255)
			gfx.DrawLabel(effector, 0, (225 * scale), (420 * scale))
			gfx.FillColor(255, 255, 255)
			gfx.DrawLabel(effector, 0, (224 * scale), (420 * scale))

			gfx.BeginPath()
			gfx.FillColor(55, 255, 255)
			gfx.DrawLabel(illustrator, 0, (277 * scale), (420 * scale))
			gfx.FillColor(255, 255, 255)
			gfx.DrawLabel(illustrator, 0, (276 * scale), (420 * scale))
		end

		gfx.Restore()
	else
		if not played then
			game.PlaySample("start_gameplay")
			played = true
		end

		animTimer = transitionTimer * 2 - outTimer

		gfx.Save()

		gfx.Save()
		gfx.Translate(0, resy)
		gfx.Rotate(math.rad(-138))
		gfx.Scissor(-1000 * scale, 0, 2000 * scale, ((animTimer * 2) * 1000) * scale)
		gfx.Rotate(-math.rad(-138))
		gfx.Translate(0, -resy)
		gfx.BeginPath()
		gfx.FillColor(255, 255, 255)
		gfx.ImageRect(0, 0, resx, resy, stripesLightLandscape, 1, 0)
		gfx.ResetScissor()
		gfx.Restore()

		gfx.Save()
		gfx.Translate(resx, 0)
		gfx.Rotate(math.rad(42))
		gfx.Scissor(-1000 * scale, 0, 2000 * scale, ((animTimer * 2) * 1000) * scale)
		gfx.Rotate(-math.rad(42))
		gfx.Translate(-resx, 0)
		gfx.BeginPath()
		gfx.FillColor(255, 255, 255)
		gfx.ImageRect(0, 0, resx, resy, stripesDarkLandscape, 1, 0)
		gfx.ResetScissor()
		gfx.Restore()

		gfx.Save()
		gfx.Rotate(math.rad(-48))
		gfx.Scissor(-1000 * scale, 0, 2000 * scale, ((animTimer * 2) * 400) * scale)
		gfx.Rotate(-math.rad(-48))
		gfx.BeginPath()
		gfx.FillColor(255, 255, 255)
		gfx.ImageRect(0, 0, resx, resy, topLeftDetailLandscape, 1, 0)
		gfx.ResetScissor()
		gfx.Restore()

		gfx.Save()
		gfx.Translate(resx, resy)
		gfx.Rotate(math.rad(132))
		gfx.Scissor(-1000 * scale, 0, 2000 * scale, ((animTimer * 2) * 500) * scale)
		gfx.Rotate(-math.rad(132))
		gfx.Translate(-resx, -resy)
		gfx.BeginPath()
		gfx.FillColor(255, 255, 255)
		gfx.ImageRect(0, 0, resx, resy, bottomRightDetailLandscape, 1, 0)
		gfx.ResetScissor()
		gfx.Restore()

		gfx.Save()
		gfx.Translate(resx / 2, resy)
		gfx.Rotate(math.rad(180))
		gfx.Scissor(-1000 * scale, 0, 2000 * scale, (0 + (animTimer * 2) * 500) * scale)
		gfx.Rotate(-math.rad(180))
		gfx.Translate(-(resx / 2), -resy)
		gfx.BeginPath()
		gfx.FillColor(255, 255, 255)
		gfx.ImageRect(0, 0, resx, resy, dividerLandscape, 1, 0)
		gfx.ResetScissor()
		gfx.Restore()

		gfx.Translate((resx / 2), (resy / 2))

		local jBgX = (-213 * 0.8) * scale
		local jBgY = ((-183 * 0.8) - animTimer * 100) * scale
		local jBgW, jBgH = (426 * 0.8) * scale, (426 * 0.8) * scale

		local jX = (-210 * 0.8) * scale
		local jY = ((-180 * 0.8) - animTimer * 100) * scale
		local jW, jH = (420 * 0.8) * scale, (420 * 0.8) * scale

		gfx.FillColor(255, 255, 255)

		gfx.BeginPath()
		gfx.ImageRect(152 * scale, (92 - animTimer * 100) * scale, (dW * 0.35) * scale, (dH * 0.35) * scale, difficulties[song.difficulty + 1], animTimer, 0)

		gfx.BeginPath()
		gfx.ImageRect(jBgX, jBgY, jBgW, jBgH, jacketBorder, animTimer, 0)

		gfx.BeginPath()
		gfx.ImageRect(jX, jY, jW, jH, jacket, animTimer, 0)

		if (math.floor(animTimer) == 1) then
			local tX = 0

			if (song.level < 10) then
				tX = 219 * scale
			else
				tX = 218 * scale
			end

			gfx.TextAlign(gfx.TEXT_ALIGN_CENTER + gfx.TEXT_ALIGN_MIDDLE)

			gfx.LoadSkinFont("slant.ttf")

			gfx.BeginPath()
			gfx.FontSize(math.floor(40 * scale))
			gfx.FillColor(245, 65, 125)
			gfx.Text(string.format("%02d", song.level), tX, (38 * scale) + 1)
			gfx.FillColor(55, 255, 255)
			gfx.Text(string.format("%02d", song.level), tX + 1, (38 * scale))
			gfx.FillColor(255, 255, 255)
			gfx.Text(string.format("%02d", song.level), tX, (38 * scale))

			gfx.BeginPath()
			gfx.FontSize(math.floor(20 * scale))
			gfx.FillColor(245, 65, 125)
			gfx.Text(song.bpm, (218 * scale), (75 * scale) + 1)
			gfx.FillColor(55, 255, 255)
			gfx.Text(song.bpm, (218 * scale) + 1, (75 * scale))
			gfx.FillColor(255, 255, 255)
			gfx.Text(song.bpm, (218 * scale), (75 * scale))

			gfx.LoadSkinFont("arial.ttf")

			gfx.BeginPath()
			gfx.FillColor(55, 255, 255)
			gfx.DrawLabel(title, 0, (153 * scale), (420 * scale))
			gfx.FillColor(255, 255, 255)
			gfx.DrawLabel(title, 0, (152 * scale), (420 * scale))

			gfx.BeginPath()
			gfx.FillColor(55, 255, 255)
			gfx.DrawLabel(artist, 0, (197 * scale), (420 * scale))
			gfx.FillColor(255, 255, 255)
			gfx.DrawLabel(artist, 0, (196 * scale), (420 * scale))

			gfx.BeginPath()
			gfx.FillColor(55, 255, 255)
			gfx.DrawLabel(effector, 0, (254 * scale), (420 * scale))
			gfx.FillColor(255, 255, 255)
			gfx.DrawLabel(effector, 0, (253 * scale), (420 * scale))

			gfx.BeginPath()
			gfx.FillColor(55, 255, 255)
			gfx.DrawLabel(illustrator, 0, (306 * scale), (420 * scale))
			gfx.FillColor(255, 255, 255)
			gfx.DrawLabel(illustrator, 0, (305 * scale), (420 * scale))
		end

		gfx.Restore()
	end
end