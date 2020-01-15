local transitionTimer = 0
local outTimer = 1
local animTimer = 0

local played = false
game.LoadSkinSample("exit_gameplay")

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
    return transitionTimer >= 1
end

function render_out(deltaTime)
    outTimer = outTimer + deltaTime * 2
    outTimer = math.min(outTimer, 2)
    render_screen(outTimer)
    return outTimer >= 2
end

local stripesLightPortrait = gfx.CreateSkinImage("song_transition/stripes_light_p.png", 0)
local stripesDarkPortrait = gfx.CreateSkinImage("song_transition/stripes_dark_p.png", 0)
local topLeftDetailPortrait = gfx.CreateSkinImage("song_transition/top_left_detail_p.png", 0)
local bottomRightDetailPortrait = gfx.CreateSkinImage("song_transition/bottom_right_detail_p.png", 0)
local placeholderPortrait= gfx.CreateSkinImage("song_transition/placeholder_p.png", 0)

local stripesLightLandscape = gfx.CreateSkinImage("song_transition/stripes_light_l.png", 0)
local stripesDarkLandscape = gfx.CreateSkinImage("song_transition/stripes_dark_l.png", 0)
local topLeftDetailLandscape = gfx.CreateSkinImage("song_transition/top_left_detail_l.png", 0)
local bottomRightDetailLandscape = gfx.CreateSkinImage("song_transition/bottom_right_detail_l.png", 0)
local placeholderLandscape = gfx.CreateSkinImage("song_transition/placeholder_l.png", 0)

function render_screen()

	ResetLayoutInformation()

	animTimer = transitionTimer * 2 - outTimer

	if portrait then
		if not played then
			game.PlaySample("exit_gameplay")
			played = true
		end

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
		gfx.Translate(0, (resy / 2))
		gfx.Scissor(0, -(resy / 2), ((animTimer * 2) * 600) * scale, resy)
		gfx.Translate(0, -(resy / 2))
		gfx.BeginPath()
		gfx.FillColor(255, 255, 255)
		gfx.ImageRect(0, 0, resx, resy, placeholderPortrait, 1, 0)
		gfx.ResetScissor()
		gfx.Restore()
	else
		if not played then
			game.PlaySample("exit_gameplay")
			played = true
		end

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
		gfx.Translate(0, (resy / 2))
		gfx.Scissor(0, -(resy / 2), ((animTimer * 2) * 1000) * scale, resy)
		gfx.Translate(0, -(resy / 2))
		gfx.BeginPath()
		gfx.FillColor(255, 255, 255)
		gfx.ImageRect(0, 0, resx, resy, placeholderLandscape, 1, 0)
		gfx.ResetScissor()
		gfx.Restore()
	end
end