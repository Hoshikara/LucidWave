local mposx = 0
local mposy = 0
local hovered = nil
local cursorIndex = 1
local label = -1
local buttonWidth = 0
local buttonHeight = 0

local backgroundPT = gfx.CreateSkinImage("song_select/title_bg_pt.jpg", 0)
local backgroundLS = gfx.CreateSkinImage("song_select/title_bg_ls.png", 0)

local cursorYs = {}
local buttons = nil

local resx, resy = game.GetResolution()
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

view_update = function()
    if package.config:sub(1,1) == '\\' then
        updateUrl, updateVersion = game.UpdateAvailable()
        os.execute("start " .. updateUrl)
    else
        os.execute("xdg-open " .. updateUrl)
    end
end

function mouseClipped(x, y, w, h)
    return (mposx > x) and (mposy > y) and (mposx < x+w) and (mposy < y+h)
end

function drawButton(button, x, y)
	local name = button[1]
    local rx = x - (buttonWidth / 2)
    local ty = y - (buttonHeight / 2)
	local buttonBorder = portrait and (2 * scale) or (1.4 * scale)

	if mouseClipped(rx, ty, buttonWidth, buttonHeight) then
		hovered = button[2]
    end

	gfx.BeginPath()
	gfx.StrokeColor(245, 245, 245)
	gfx.StrokeWidth(2 * scale)

	if name == "START" then
		gfx.FillColor(30, 200, 200)
	elseif name == "FRIENDS" then
		gfx.FillColor(250, 200, 130)
	elseif name == "NAUTICA" then
		gfx.FillColor(145, 215, 125)
	elseif name == "SETTINGS" then
		gfx.FillColor(210, 170, 240)
	elseif name == "EXIT" then
		gfx.FillColor(190, 90, 120)
	else
		gfx.FillColor(100, 100, 100)
	end

    gfx.RoundedRect(rx, ty - buttonBorder, buttonWidth, buttonHeight, portrait and 22 * scale or 16 * scale)
	gfx.Fill()
	gfx.Stroke()

	local shift = 1 * scale

    gfx.BeginPath()
    gfx.TextAlign(gfx.TEXT_ALIGN_CENTER + gfx.TEXT_ALIGN_MIDDLE)
	gfx.FontSize(portrait and math.floor(36 * scale) or math.floor (24 * scale))
	gfx.FillColor(125, 125, 125)
    gfx.Text(name, portrait and x + shift or (x + shift / 2), portrait and y + shift or (y + shift / 2))
	gfx.Fill()
	gfx.FillColor(255, 255, 255)
    gfx.Text(name, x, y)
	gfx.Fill()

	return buttonHeight + (2 * scale)
end

function setButtons()
	if (buttons == nil) then
		buttons = {}
		buttons[1] = {"START", Menu.Start}
		buttons[2] = {"FRIENDS", Menu.Multiplayer}
		buttons[3] = {"NAUTICA", Menu.DLScreen}
		buttons[4] = {"SETTINGS", Menu.Settings}
		buttons[5] = {"EXIT", Menu.Exit}
	end
end

local renderY = resy / 2

function drawCursor(x, y, deltaTime)
    local rx = x - (buttonWidth / 2)
    local ty = y - (buttonHeight / 2)

	gfx.Save()

	gfx.BeginPath()
	gfx.StrokeColor(200, 200, 200, 255)
	gfx.StrokeWidth(portrait and math.floor(4 * scale) or math.floor(3 * scale))
	gfx.FillColor(0, 0, 0, 0)
	gfx.RoundedRect(rx, ty, buttonWidth, buttonHeight, portrait and 22 * scale or 16 * scale)
	gfx.Fill()
	gfx.Stroke()

	gfx.StrokeColor(255, 220, 100, 255)
	gfx.StrokeWidth(portrait and math.floor(3 * scale) or math.floor(2 * scale))
	gfx.FillColor(0, 0, 0, 0)
	gfx.RoundedRect(rx, ty, buttonWidth, buttonHeight, portrait and 22 * scale or 16 * scale)
	gfx.Fill()
	gfx.Stroke()

	gfx.Restore()
end

function roundToZero(x)
	if (x < 0) then return math.ceil(x)
	elseif (x > 0) then return math.floor(x)
	else return 0 end
end

function sign(x)
  return ((x > 0) and 1) or ((x < 0) and -1) or 0
end

function deltaKnob(delta)
	if (math.abs(delta) > 1.5 * math.pi) then 
		return delta + 2 * math.pi * sign(delta) * -1
	end
	return delta
end

local lastKnobs = nil
local knobProgress = 0

function handleController()
	if lastKnobs == nil then
		lastKnobs = {game.GetKnob(0), game.GetKnob(1)}
	else
		local newKnobs = {game.GetKnob(0), game.GetKnob(1)}
	
		knobProgress = knobProgress - deltaKnob(lastKnobs[1] - newKnobs[1]) * 1.2
		knobProgress = knobProgress - deltaKnob(lastKnobs[2] - newKnobs[2]) * 1.2
		
		lastKnobs = newKnobs
		
		if math.abs(knobProgress) > 1 then
			cursorIndex = (((cursorIndex - 1) + roundToZero(knobProgress)) % #buttons) + 1
			knobProgress = knobProgress - roundToZero(knobProgress)
		end
	end
end

render = function(deltaTime)
	setButtons()

    mposx, mposy = game.GetMousePos()

	ResetLayoutInformation()

	buttonWidth = portrait and 190 * scale or 132 * scale
	buttonHeight = portrait and 45 * scale or 32 * scale

	local desw2 = 720
	local desh2 = 1280
	local scale2 = resy / desh2
	local xshift = (resx - desw * scale) / 2
	local yshift = (resy - desh * scale) / 2


	if portrait then
		gfx.Save()
		gfx.BeginPath()
		gfx.FillColor(255, 255, 255)
		gfx.ImageRect(0, 0, resx, resy, backgroundPT, 1, 0)
		gfx.Restore()
	else
		gfx.Save()
		gfx.Translate(xshift, yshift);
		gfx.Scale(scale, scale);
		--gfx.Translate(xshift, yshift)
		--gfx.Scale(scale2, scale2)
		gfx.BeginPath()
		gfx.ImageRect(0, 0, desw, desh, backgroundLS, 1, 0)
		gfx.Restore()
	end

	gfx.BeginPath()

	cursorGet = 1
    buttonY = (portrait and ((resy / 2) + (17 * scale))) or ((resy / 2) + (7 * scale) + (desw / 10));
    hovered = nil
	
    gfx.LoadSkinFont("slant.ttf")
	
	for i=1, #buttons do
		cursorYs[i] = buttonY
		buttonY = buttonY + drawButton(buttons[i], resx / 2, buttonY)
		buttonY = portrait and buttonY + (27 * scale) or buttonY + (13 * scale)
		if (hovered == buttons[i][2]) then
			cursorIndex = i
		end
	end
	
	handleController()
	
	drawCursor((resx / 2), cursorYs[cursorIndex] - 3, deltaTime)

	local textShift = portrait and (45 * scale) or (30 * scale)
	local rectShift = portrait and (64 * scale) or (39 * scale)
	
    updateUrl, updateVersion = game.UpdateAvailable()
    if updateUrl then
		gfx.BeginPath()
		gfx.FillColor(0, 0, 0, 225)
		gfx.Rect(0, resy - rectShift, resx, rectShift)
		gfx.Fill()
		gfx.TextAlign(gfx.TEXT_ALIGN_BOTTOM + gfx.TEXT_ALIGN_LEFT)
		gfx.FontSize(math.floor(24 * scale))
		gfx.FillColor(255, 255, 255)
		gfx.Text(string.format("A NEW UPDATE IS AVAILABLE!", updateVersion), (5 * scale), 
		resy - buttonHeight + textShift)
		drawButton({"VIEW", view_update}, resx - (buttonWidth / 2) - (5 * scale), (resy - (buttonHeight / 2) - (5 * scale)))
		drawButton({"UPDATE", Menu.Update}, resx - (buttonWidth * 1.5) - (15 * scale), (resy - (buttonHeight / 2) - (5 * scale)))
    end
end

mouse_pressed = function(button)
    if hovered then
        hovered()
    end
    return 0
end

function button_pressed(button)
    if button == game.BUTTON_STA then 
        buttons[cursorIndex][2]()
    elseif button == game.BUTTON_BCK then
        Menu.Exit()
    end
end
