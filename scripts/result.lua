local jacket = nil
local gradeImg
local gradear = 1
local resx, resy = game.GetResolution()
local desw = 720
local desh = 1280
local scale = resy / desh
local portrait = resy > resx
local landscape = resx > resy

local backgroundImage = gfx.CreateSkinImage("song_select/results_bg.jpg", 0)
local bgFill = gfx.CreateSkinImage("bg_fill.png", 0)

local novice = gfx.CreateSkinImage("song_select/level/novice.png", 0)
local advanced = gfx.CreateSkinImage("song_select/level/advanced.png", 0)
local exhaust = gfx.CreateSkinImage("song_select/level/exhaust.png", 0)
local maximum = gfx.CreateSkinImage("song_select/level/maximum.png", 0)

local difficulties = {novice, advanced, exhaust, maximum}

local shotTimer = 0
local shotPath = ""

local played = false

game.LoadSkinSample("result")
game.LoadSkinSample("shutter")

render = function(deltaTime, showStats)
    if (result.badge > 1) and not played then
		game.PlaySample("result", true)
		played = true
	end

	if game.GetButton(game.BUTTON_STA) then
		game.StopSample("result")
	elseif game.GetButton(game.BUTTON_BCK) then
		game.StopSample("result")
    end
   
	-- LANDSCAPE FILL
	gfx.BeginPath()
	gfx.FillColor(255, 255, 255)
	gfx.ImageRect(0, 0, resx, resy, bgFill, 1, 0)
	 
	gfx.Scale(scale, scale)

	-- DRAW BACKGROUND (LANDSCAPE)
	if landscape then
		local xshift = (resx - desw * scale) / 2
		local yshift = (resy - desh * scale) / 2

		gfx.Scale(1/scale, 1/scale)
		gfx.Translate(xshift, yshift)
		gfx.Scale(scale, scale)

		gfx.BeginPath()
		gfx.FillColor(255, 255, 255)
		gfx.ImageRect(0, 0, desw, desh, backgroundImage, 1, 0)
		gfx.Fill()

	end

	-- DRAW BACKGROUND (PORTRAIT)
	if portrait then
		gfx.Scale(1/scale, 1/scale)

		gfx.BeginPath()
		gfx.FillColor(255, 255, 255)
		gfx.ImageRect(0, 0, resx, resy, backgroundImage, 1, 0)
		gfx.Fill()

		gfx.Scale(scale, scale)
	end

	-- JACKET FILL
	if jacket == nil then
        jacket = gfx.CreateImage(result.jacketPath, 0)
    end

	-- DRAW JACKET
	if jacket then
		gfx.BeginPath()
		gfx.FillColor(0, 0, 0, 0)
		gfx.StrokeColor(245, 65, 125)
		gfx.StrokeWidth(6)
		gfx.Rect((desw / 3.16)-2, 25, 265, 265)
		gfx.Fill()
		gfx.Stroke()

		gfx.BeginPath()
		gfx.FillColor(0, 0, 0, 0)
		gfx.StrokeColor(15, 225, 225)
		gfx.StrokeWidth(6)
		gfx.Rect((desw / 3.16) + 2, 29, 265, 265)
		gfx.Fill()
		gfx.Stroke()

		gfx.BeginPath()
		gfx.FillColor(0, 0, 0, 0)
		gfx.StrokeColor(25, 25, 25)
		gfx.StrokeWidth(6)
		gfx.Rect((desw / 3.16), 27, 265, 265)
		gfx.Fill()
		gfx.Stroke()

        gfx.ImageRect((desw / 3.16), 27, 265, 265, jacket, 1, 0)
    end

	-- DRAW TITLE AND ARTIST
    gfx.LoadSkinFont("arial.ttf")
	gfx.TextAlign(gfx.TEXT_ALIGN_CENTER)

	local title = gfx.CreateLabel(result.title, 24, 0)
	local artist = gfx.CreateLabel(result.artist, 19, 0)

	gfx.FillColor(245, 65, 125)
	gfx.DrawLabel(title, (desw / 2)+0.3, (desh / 4) - 14.8, 460)
	gfx.DrawLabel(artist, (desw / 2)+0.3, (desh / 4) + 31.2, 460)

	gfx.FillColor(25, 25, 25)
	gfx.DrawLabel(title, (desw / 2), (desh / 4) - 15, 460)
	gfx.DrawLabel(artist, (desw / 2), (desh / 4) + 31, 460)

	-- DRAW DIFFICULTY BADGE
	gfx.BeginPath()
	gfx.FillColor(255, 255, 255)
	gfx.ImageRect((desw / 2) + 14, (desh/3) - 7, 97, 71, difficulties[result.difficulty + 1], 1, 0)
	gfx.Fill()
	
	gfx.BeginPath()
	gfx.LoadSkinFont("slant.ttf")
	gfx.TextAlign(gfx.TEXT_ALIGN_CENTER)
	gfx.FontSize(38)
	gfx.FillColor(255, 255, 255)

	if result.level >= 10 then
		gfx.Text(string.format("%02d", result.level), (desw / 2)+61, (desh/3)+35)
	else
		gfx.Text(string.format("%02d", result.level), (desw / 2)+64, (desh/3)+35)
	end

	-- DRAW SCORE
	gfx.BeginPath()
    gfx.LoadSkinFont("avantgarde.ttf")
    gfx.TextAlign(gfx.TEXT_ALIGN_CENTER + gfx.TEXT_ALIGN_RIGHT)

	scoreString = string.format("%08d", result.score)
	
	gfx.FillColor(245, 65, 125)
	gfx.FontSize(72)
	gfx.Text(string.sub(scoreString, 1, 4), (desw/2)+198, (desh/2)-65)
	gfx.FontSize(58)
	gfx.Text(string.sub(scoreString, -4), (desw/2)+326, (desh/2)-65)

	gfx.FillColor(25, 25, 25)
	gfx.FontSize(72)
	gfx.Text(string.sub(scoreString, 1, 4), (desw/2)+197, (desh/2)-66)
	gfx.FontSize(58)
	gfx.Text(string.sub(scoreString, -4), (desw/2)+325, (desh/2)-66)

	-- GRADE IMAGE
	if not gradeImg then
        gradeImg = gfx.CreateSkinImage(string.format("score/%s.png", result.grade),0)
        local gradeW, gradeH = gfx.ImageSize(gradeImg)
        gradear = gradeW / gradeH
    end

	-- DRAW PERFORMANCE GRAPH
	drawGraph((desw / 2) + 34, (desh / 2) - 40, 294, 74)

	-- DRAW GRADE
    gfx.BeginPath()
    gfx.ImageRect((desw / 2) + 38, (desh / 2) - 38, 25 * gradear, 25, gradeImg, 1, 0)

	-- DRAW RESULT PERCENTAGE
    gfx.BeginPath()
	gfx.LoadSkinFont("avantgarde.ttf")
	gfx.FontSize(18)
	gfx.FillColor(0, 0, 0)
    gfx.TextAlign(gfx.TEXT_ALIGN_CENTER, gfx.TEXT_ALIGN_RIGHT)
    gfx.Text(string.format("%d%%", math.floor(result.gauge * 100)), (desw / 2) + 293,(desh / 2) + 57)

	-- DRAW STATS
	gfx.BeginPath()
	gfx.TextAlign(gfx.TEXT_ALIGN_CENTER, gfx.TEXT_ALIGN_RIGHT)
	gfx.FillColor(255, 255, 255)

	gfx.Text(string.format("%04d", result.perfects), desw-112, (desh/2)+83)
	gfx.Text(string.format("%04d", result.goods), desw-112, (desh/2)+108)

	gfx.Text(string.format("%04d", result.earlies), desw-190, (desh/2)+134)
	gfx.Text(string.format("%04d", result.lates), desw-75, (desh/2)+134)

	gfx.Text(string.format("%04d", result.misses), desw-112, (desh/2)+160)
	gfx.Text(string.format("%04d", result.maxCombo), desw-112, (desh/2)+185)

	gfx.Text(string.format("%.1f ms", result.medianHitDelta), desw-112, (desh/2)+211)
	gfx.Text(string.format("%.1f ms", result.meanHitDelta), desw-112, (desh/2)+237)

	drawHighscores()

	gfx.LoadSkinFont("avantgarde.ttf")
    shotTimer = math.max(shotTimer - deltaTime, 0)
    if shotTimer > 1 then
        draw_shotnotif(desw/2+65, desh-320);
    end
end

get_capture_rect = function()
	local x = (resx - desw * scale) / 2
	local y = (resy - desh * scale) / 2
	local w = desw * scale
	local h = desh * scale

    return x,y,w,h
end

screenshot_captured = function(path)
    shotTimer = 5
	shotPath = path
    game.PlaySample("shutter")
end

draw_shotnotif = function(x,y)
    gfx.Save()
    gfx.Translate(x,y)
    gfx.TextAlign(gfx.TEXT_ALIGN_LEFT + gfx.TEXT_ALIGN_TOP)
    gfx.BeginPath()
	gfx.RoundedRectVarying(-10, -40, 300, 40, 10, 10, 10, 10)
    gfx.FillColor(0, 0, 0, 190)
    gfx.StrokeColor(245, 65, 125)
    gfx.Fill()
    gfx.Stroke()
    gfx.FillColor(255, 255, 255)
    gfx.FontSize(15)
    gfx.Text("Screenshot saved to:", -4, -35)
	    gfx.Text(shotPath, -4, -17)
    gfx.Restore()
end

drawGraph = function(x, y, w, h)
    gfx.BeginPath()
    gfx.Rect(x, y, w, h)
    gfx.FillColor(0, 0, 0, 255)
    gfx.Fill()    
    gfx.BeginPath()
    gfx.MoveTo(x, y + h - h * result.gaugeSamples[1])

    for i = 2, #result.gaugeSamples do
        gfx.LineTo(x + i * w / #result.gaugeSamples,y + h - h * result.gaugeSamples[i])
    end

	if result.flags & 1 ~= 0 then
		gfx.StrokeWidth(2)
		gfx.StrokeColor(245, 65, 125)
		gfx.Stroke()
	else
		gfx.StrokeWidth(2)
		gfx.StrokeColor(15, 255, 255)
		gfx.Scissor(x, y + h * 0.3, w, h * 0.7)
		gfx.Stroke()
		gfx.ResetScissor()
		gfx.Scissor(x, y, w, h*0.3)
		gfx.StrokeColor(255, 0, 255)
		gfx.Stroke()
		gfx.ResetScissor()
	end
end

drawHighscores = function()
    gfx.TextAlign(gfx.TEXT_ALIGN_LEFT)
    gfx.LoadSkinFont("avantgarde.ttf")

    for i,s in ipairs(result.highScores) do
        gfx.TextAlign(gfx.TEXT_ALIGN_LEFT)
        gfx.BeginPath()

        local ypos = (desh / 3) + 13 + (i - 1) * 86
		
        gfx.RoundedRectVarying(35, ypos - 30, 280, 70, 11, 11, 11, 11)
        gfx.FillColor(0, 0, 0, 190)
        gfx.StrokeColor(245, 65, 125)
        gfx.StrokeWidth(1)
        gfx.Fill()
        gfx.Stroke()
        gfx.BeginPath()
        gfx.FontSize(25)
		gfx.FillColor(245, 65, 125)
        gfx.Text(string.format("%d", i), 10.5, ypos - 9.5)
		gfx.FillColor(25, 25, 25)
        gfx.Text(string.format("%d",i), 10, ypos - 10)

		scoreString1 = string.format("%08d", s.score)

		gfx.FillColor(245, 65, 125)
        gfx.FontSize(65)
        gfx.Text(string.sub(scoreString1, 1, 4), 43.3, ypos+32.3)
		gfx.FontSize(52)
		gfx.Text(string.sub(scoreString1, -4), 191.3, ypos+32.3)

		gfx.FillColor(255, 255, 255)
        gfx.FontSize(65)
        gfx.Text(string.sub(scoreString1, 1, 4), 42, ypos+31)
		gfx.FontSize(52)
		gfx.Text(string.sub(scoreString1, -4), 190, ypos+31)

        gfx.FontSize(14)
		gfx.FillColor(255, 255, 255, 75)
		gfx.TextAlign(gfx.TEXT_ALIGN_RIGHT)
        if s.timestamp > 0 then
            gfx.Text(os.date("%m-%d-%Y", s.timestamp), 305, ypos - 14)
        end

		if i == 5 then
			break
		end
    end
end
