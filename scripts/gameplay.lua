local RECT_FILL = "fill"
local RECT_STROKE = "stroke"
local RECT_FILL_STROKE = RECT_FILL .. RECT_STROKE

gfx._ImageAlpha = 1

if (gfx._FillColor == nil) then
	gfx._FillColor = gfx.FillColor
	gfx._StrokeColor = gfx.StrokeColor
	gfx._SetImageTint = gfx.SetImageTint
end

gfx.SetImageTint = nil

function gfx.FillColor(r, g, b, a)
    r = math.floor(r or 255)
    g = math.floor(g or 255)
    b = math.floor(b or 255)
    a = math.floor(a or 255)

    gfx._ImageAlpha = a / 255
    gfx._FillColor(r, g, b, a)
    gfx._SetImageTint(r, g, b)
end

function gfx.StrokeColor(r, g, b)
    r = math.floor(r or 255)
    g = math.floor(g or 255)
    b = math.floor(b or 255)

    gfx._StrokeColor(r, g, b)
end

function gfx.DrawRect(kind, x, y, w, h)
    local doFill = kind == RECT_FILL or kind == RECT_FILL_STROKE
    local doStroke = kind == RECT_STROKE or kind == RECT_FILL_STROKE

    local doImage = not (doFill or doStroke)

    gfx.BeginPath()

    if doImage then
        gfx.ImageRect(x, y, w, h, kind, gfx._ImageAlpha, 0)
    else
        gfx.Rect(x, y, w, h)
        if doFill then gfx.Fill() end
        if doStroke then gfx.Stroke() end
    end
end

local buttonStates = { }
local buttonsInOrder = 
{
    game.BUTTON_BTA,
    game.BUTTON_BTB,
    game.BUTTON_BTC,
    game.BUTTON_BTD,
    
    game.BUTTON_FXL,
    game.BUTTON_FXR,

    game.BUTTON_STA,
}

function UpdateButtonStatesAfterProcessed()
    for i = 1, 6 do
        local button = buttonsInOrder[i]
        buttonStates[button] = game.GetButton(button)
    end
end

game.GetButtonPressed = function(button)
    return game.GetButton(button) and not buttonStates[button]
end
                                         
local resx, resy 
local portrait
local landscape
local desw, desh 
local scale 

if (introTimer == nil) then
	introTimer = 2
	outroTimer = 0
end

local genericTimer = 0
local fadeTimer = 0

local score = 0
local combo = 0
local maxCombo = 0
local randBinary = math.random(0, 1)
local jacket = nil
local critLinePos = {0.95, 0.73}
local late = false
local title = nil
local artist = nil
local diffNames = {"NOVICE", "ADVANCED", "EXHAUST", "MAXIMUM"}
local clearTexts = {"TRACK CRASH", "TRACK COMPLETE", "TRACK COMPLETE", "ULTIMATE CHAIN", "PERFECT"}

local displayChain = game.GetSkinSetting("display_chain")

function IsUserInputActive(lane)
    if (lane < 7) then
        return game.GetButton(buttonsInOrder[lane])
    end

    return gameplay.IsLaserHeld(lane - 7)
end
                                           
function SetFillToLaserColor(index, alpha)
    alpha = math.floor(alpha or 255)
    local r, g, b = game.GetLaserColor(index - 1)
    gfx.FillColor(r, g, b, alpha)
end
                               
function ResetLayoutInformation()
    resx, resy = game.GetResolution()
    portrait = resy > resx
	landscape = resx > resy
    desw = portrait and 720 or 1280 
    desh = desw * (resy / resx)
    scale = resx / desw
end

function render(deltaTime)
    gfx.ResetTransform()

    gfx.Scale(scale, scale)
    local yshift = 0

    if portrait then 
		yshift = DrawBanner(deltaTime) 
	end

    gfx.Translate(0, yshift)
    drawTrackInfo(deltaTime)
    drawScore(deltaTime)
    gfx.Translate(0, -yshift)

    drawGauge(deltaTime)
    drawEarlate(deltaTime)

	if (displayChain == true) then
		drawCombo(deltaTime)
	end

    drawAlerts(deltaTime)
	drawPassEffect(deltaTime)

	genericTimer = genericTimer + deltaTime
	fadeTimer = math.abs(0.5 * math.cos(genericTimer * 10))
	randBinary = math.random(0, 1)
end
                                           
function SetUpCritTransform()
    gfx.ResetTransform()
   
    gfx.Translate(gameplay.critLine.x, gameplay.critLine.y)
    gfx.Rotate(-gameplay.critLine.rotation)
end

function GetCritLineCenteringOffset()
	return gameplay.critLine.xOffset * 10;
end


local critBarAnim = gfx.CreateSkinImage("gameplay/crit_bar/crit_anim.png", 0)
local critBar = gfx.CreateSkinImage("gameplay/crit_bar/crit_bar.png", 0)
local critBarGlow = gfx.CreateSkinImage("gameplay/crit_bar/crit_bar_glow.png", 0)
local critConsole = gfx.CreateSkinImage("gameplay/crit_bar/crit_console.png", 0)

local critBarAnimTimer = 0

function render_crit_base(deltaTime)
    ResetLayoutInformation()

    critBarAnimTimer = critBarAnimTimer + deltaTime

    SetUpCritTransform()

    local xOffset = GetCritLineCenteringOffset()
    gfx.Translate(xOffset, 0)
	
	-- BOTTOM FILL
	if portrait then
		gfx.FillColor(0, 0, 0, 200)
		gfx.DrawRect(RECT_FILL, -resx, -1, resx * 2, resy)
		gfx.FillColor(255, 255, 255)
	else
		gfx.FillColor(0, 0, 0, 200)
		gfx.DrawRect(RECT_FILL, -resx, -1, resx * 2, resy)
		gfx.FillColor(255, 255, 255)
	end

    local critWidth = resx * (portrait and 1.5 or 1.6)

    local clw, clh = gfx.ImageSize(critBarAnim)
    local critBarAnimHeight = 9 * scale
    local critBarAnimWidth = critBarAnimHeight * (clw / clh)

    local cbw, cbh = gfx.ImageSize(critBar)
    local critBarHeight = critBarAnimHeight * (cbh / clh)
    local critBarWidth = critBarHeight * (cbw / cbh)


    do
        local animWidth = critWidth * 0.65
        local numPieces = 1 + math.ceil(animWidth / (critBarAnimWidth * 2))
        local startOffset = critBarAnimWidth * ((critBarAnimTimer * 0.15) % 1)

		gfx.Save()
	    gfx.GlobalCompositeOperation(gfx.BLEND_OP_LIGHTER)

        gfx.Scissor(-animWidth / 2, -critBarAnimHeight, (animWidth / 2), (critBarAnimHeight * 2))

        for i = 1, numPieces do
            gfx.DrawRect(critBarAnim, (-startOffset - critBarAnimWidth * (i - 1)), (-critBarAnimHeight / 1), critBarAnimWidth, critBarAnimHeight)
        end

        gfx.ResetScissor()

        gfx.Scissor(0, -critBarAnimHeight, (animWidth / 2), (critBarAnimHeight * 2))

        for i = 1, numPieces do
            gfx.DrawRect(critBarAnim, (-critBarAnimWidth + startOffset + critBarAnimWidth * (i - 1)), -critBarAnimHeight, critBarAnimWidth, critBarAnimHeight)
        end

        gfx.ResetScissor()
	    gfx.Restore()
    end

    -- CRIT BAR
    gfx.DrawRect(critBar, (-critWidth / 2), (-critBarHeight / 2 + 6 * scale), critWidth, critBarHeight)
	gfx.GlobalCompositeOperation(gfx.BLEND_OP_LIGHTER)
	gfx.ImageRect((-critWidth / 2), (-critBarHeight / 2 + 6 * scale), critWidth, critBarHeight, critBarGlow, 0.7, 0)
	gfx.GlobalCompositeOperation(gfx.BLEND_OP_SOURCE_OVER)

    -- CRIT CONSOLE
    if portrait then
		gfx.Scale((1 * 0.6), (1 * 0.6))
        local ccw, cch = gfx.ImageSize(critConsole)
        local critConsoleHeight = 125 * scale
        local critConsoleWidth = critConsoleHeight * (ccw / cch)

        local critConsoleY = 110 * scale
        gfx.DrawRect(critConsole, (-critConsoleWidth / 2), (-critConsoleHeight / 4 + critConsoleY), critConsoleWidth, critConsoleHeight)
		gfx.Scale((1 / 0.6), (1 / 0.6))
    end

    gfx.FillColor(255, 255, 255)
    gfx.ResetTransform()
end

-- HIT ANIMATIONS
	local hitLane = 0
	
	function hitAnimationTransform(hitLane)
		local n = hitLane + 0.5
		local x = gameplay.critLine.line.x1 + (gameplay.critLine.line.x2 - gameplay.critLine.line.x1) * (n / 6)
		local y = gameplay.critLine.line.y1 + (gameplay.critLine.line.y2 - gameplay.critLine.line.y1) * (n / 6)
		gfx.Translate(x, y)
		gfx.Rotate(-gameplay.critLine.rotation)
		gfx.Scale((scale * 0.9), (scale * 0.9))
	end

	-- HOLD ANIMATION FUNCTIONS
		function loadHoldAnimFrames(path)
			local frames = {}

			for i = 0, 81 do
				frames[i]  = gfx.CreateSkinImage(string.format("%s/%03d.png", path, i), 0)
			end

			return frames
		end

		function loadHoldInnerAnimFrames(path)
			local frames = {}

			for i = 0, 13 do
				frames[i]  = gfx.CreateSkinImage(string.format("%s/%03d.png", path, i), 0)
			end

			return frames
		end

		function loadHoldCriticalAnimFrames(path)
			local frames = {}

			for i = 0, 152 do
				frames[i]  = gfx.CreateSkinImage(string.format("%s/%04d.png", path, i), 0)
			end

			return frames
		end

		function loadHoldEndAnimFrames(path)
			local frames = {}

			for i = 0, 7 do
				frames[i]  = gfx.CreateSkinImage(string.format("%s/%03d.png", path, i), 0)
			end   

			return frames
		end

		local holdInnerAnimFrames = loadHoldInnerAnimFrames("gameplay/hit_animation_frames/hold_inner")

		local holdDomeAnimFrames = loadHoldAnimFrames("gameplay/hit_animation_frames/hold_dome")

		local holdCriticalAnimFrames = loadHoldCriticalAnimFrames("gameplay/hit_animation_frames/hold_critical")

		local holdEndAnimFrames = loadHoldEndAnimFrames("gameplay/hit_animation_frames/hold_end")

		local holdAnimTimer = {0, 0, 0, 0, 0, 0}

		local holdInnerAnimTimer = {0, 0, 0, 0, 0, 0}

		local holdCriticalAnimTimer = {0, 0, 0, 0, 0, 0}

		local holdAnimIndex = {1, 1, 1, 1, 1, 1}

		local holdInnerAnimIndex = {1, 1, 1, 1, 1, 1}

		local holdCriticalAnimIndex = {1, 1, 1, 1, 1, 1}

		local holdEndAnimTimer = {0, 0, 0, 0, 0, 0}

		local holdEndAnimIndex = {1, 1, 1, 1, 1, 1}

		local delayCriticalStart = {0, 0, 0, 0, 0, 0}

		local startEndAnim = {false, false, false, false, false, false}

		-- HOLD
		function holdAnim(deltaTime, i)
			gfx.Save()

			if (i == 1) then hitLane = 1 elseif (i == 2) then hitLane = 2
			elseif (i == 3) then hitLane = 3 elseif (i == 4) then hitLane = 4
			elseif (i == 5) then hitLane = 1.5 elseif (i == 6) then hitLane = 3.5
			end
			
			hitAnimationTransform(hitLane)

			gfx.BeginPath()
			gfx.FillColor(255, 255, 255)

			holdAnimTimer[i] = holdAnimTimer[i] + deltaTime

			holdInnerAnimTimer[i] = holdInnerAnimTimer[i] + deltaTime

			delayCriticalStart[i] = delayCriticalStart[i] + deltaTime

			if (delayCriticalStart[i] > (1.0 / 6.0)) then
				holdCriticalAnimTimer[i] = holdCriticalAnimTimer[i] + deltaTime
			end

			if (holdAnimTimer[i] > (1.0 / 30.0)) then
				holdAnimTimer[i] = 0
				holdAnimIndex[i] = holdAnimIndex[i] + 1
			end

			if (holdInnerAnimTimer[i] > (1.0 / 30.0)) then
				holdInnerAnimTimer[i] = 0
				holdInnerAnimIndex[i] = holdInnerAnimIndex[i] + 1
			end

			if (holdCriticalAnimTimer[i] > (1.0 / 59.0)) then
				holdCriticalAnimTimer[i] = 0
				holdCriticalAnimIndex[i] = holdCriticalAnimIndex[i] + 1
			end

			if (holdInnerAnimTimer[i] < (1.0 / 30.0)) then
				gfx.GlobalCompositeOperation(gfx.BLEND_OP_LIGHTER)
				gfx.ImageRect(-213, -219, 426, 426, holdInnerAnimFrames[holdInnerAnimIndex[i]], 4, 0)
			end

			if (holdAnimTimer[i] < (1.0 / 30.0)) then
				gfx.GlobalCompositeOperation(gfx.BLEND_OP_LIGHTER)
				gfx.ImageRect(-213, -219, 426, 426, holdDomeAnimFrames[holdAnimIndex[i]], 1.5, 0)
			end

			if (holdCriticalAnimTimer[i] < (1.0 / 59.0)) then
				gfx.GlobalCompositeOperation(gfx.BLEND_OP_SOURCE_OVER)
				gfx.ImageRect(-213, -219, 426, 426, holdCriticalAnimFrames[holdCriticalAnimIndex[i]], 1.5, 0)
			end

			if (holdInnerAnimIndex[i] == 13) then
				holdInnerAnimIndex[i] = 9
			end

			if (holdAnimIndex[i] == 81) then
				holdAnimIndex[i] = 9
			end

			if (holdCriticalAnimIndex[i] == 152) then
				holdCriticalAnimIndex[i] = 8
			end

			gfx.Restore()
		end

		-- HOLD END
		function holdEndAnim(deltaTime, i)
			gfx.Save()
		
			if (i == 1) then hitLane = 1 elseif (i == 2) then hitLane = 2
			elseif (i == 3) then hitLane = 3 elseif (i == 4) then hitLane = 4
			elseif (i == 5) then hitLane = 1.5 elseif (i == 6) then hitLane = 3.5
			end

			hitAnimationTransform(hitLane)

			gfx.BeginPath()
			gfx.FillColor(255, 255, 255)

			holdEndAnimTimer[i] = holdEndAnimTimer[i] + deltaTime

			if (holdEndAnimTimer[i] > (1.0 / 30.0)) then
				holdEndAnimTimer[i] = 0
				holdEndAnimIndex[i] = holdEndAnimIndex[i] + 1
			end

			if (holdEndAnimTimer[i] < (1.0 / 30.0)) then
				gfx.GlobalCompositeOperation(gfx.BLEND_OP_LIGHTER)
				gfx.ImageRect(-213, -219, 426, 426, holdEndAnimFrames[holdEndAnimIndex[i]], 1.5, 0)
			end

			if (holdEndAnimIndex[i] == 7) then
				holdEndAnimIndex[i] = 1
				startEndAnim[i] = false
			end

			gfx.Restore()
		end

	-- CRIT ANIMATION FUNCTIONS
		function loadCritAnimFrames(path)
			local frames = {}

			for i = 0, 17 do
				frames[i]  = gfx.CreateSkinImage(string.format("%s/%03d.png", path, i), 0)
			end

			return frames
		end

		local critAnimFramesBT = loadCritAnimFrames("gameplay/hit_animation_frames/critical_bt")

		local critAnimTimerBT = {{}, {}, {}, {}}

		local critAnimIndexBT = {{}, {}, {}, {}}

		local startCritAnimBT = {{}, {}, {}, {}}

		for i = 1, 4 do
			for j = 1, 6 do
				critAnimTimerBT[i][j] = 0
				critAnimIndexBT[i][j] = 1
				startCritAnimBT[i][j] = false
			end
		end

		local critAnimFramesFX = loadCritAnimFrames("gameplay/hit_animation_frames/critical_fx")

		local critAnimTimerFX = {0, 0}

		local critAnimIndexFX = {1, 1}

		local startCritAnimFX = {false, false}

		function critAnimBT(deltaTime, i, j)
			gfx.Save()

			if (i == 1) then hitLane = 1 elseif (i == 2) then hitLane = 2 
			elseif (i == 3) then hitLane = 3 elseif (i == 4) then hitLane = 4 
			end

			hitAnimationTransform(hitLane)

			gfx.BeginPath()
			gfx.FillColor(255, 255, 255)

			critAnimTimerBT[i][j] = critAnimTimerBT[i][j] + deltaTime

			if (critAnimTimerBT[i][j] > (1.0 / 56.0)) then
				critAnimTimerBT[i][j] = 0
				critAnimIndexBT[i][j] = critAnimIndexBT[i][j] + 1
			end

			if (critAnimTimerBT[i][j] < (1.0 / 56.0)) then
				gfx.ImageRect(-200, -205, 400, 400, critAnimFramesBT[critAnimIndexBT[i][j]], 1.2, 0)
			end

			if (critAnimIndexBT[i][j] == 17) then
				startCritAnimBT[i][j] = false
				critAnimTimerBT[i][j] = 0
				critAnimIndexBT[i][j] = 1
			end

			gfx.Restore()
		end

		function critAnimFX(deltaTime, i)
			gfx.Save()

			if (i == 1) then hitLane = 1.5 elseif (i == 2) then hitLane = 3.5 end

			hitAnimationTransform(hitLane)

			gfx.BeginPath()
			gfx.FillColor(255, 255, 255)

			critAnimTimerFX[i] = critAnimTimerFX[i] + deltaTime

			if (critAnimTimerFX[i] > (1.0 / 56.0)) then
				critAnimTimerFX[i] = 0
				critAnimIndexFX[i] = critAnimIndexFX[i] + 1
			end

			if (critAnimTimerFX[i] < (1.0 / 56.0)) then
				gfx.ImageRect(-200, -205, 400, 400, critAnimFramesFX[critAnimIndexFX[i]], 1.2, 0)
			end

			if (critAnimIndexFX[i] == 17) then
				startCritAnimFX[i] = false
				critAnimTimerFX[i] = 0
				critAnimIndexFX[i] = 1
			end

			gfx.Restore()
		end

	-- NEAR ANIMATION FUNCTIONS
		function loadNearAnimFrames(path)
			local frames = {}

			for i = 0, 21 do
				frames[i]  = gfx.CreateSkinImage(string.format("%s/%03d.png", path, i), 0)
			end

			return frames
		end

		local nearAnimFramesBT = loadNearAnimFrames("gameplay/hit_animation_frames/near_bt")

		local nearAnimTimerBT = {{}, {}, {}, {}, {}, {}}

		local nearAnimIndexBT = {{}, {}, {}, {}, {}, {}}

		local startNearAnimBT = {{}, {}, {}, {}, {}, {}}

		for i = 1, 4 do
			for j = 1, 6 do
				nearAnimTimerBT[i][j] = 0
				nearAnimIndexBT[i][j] = 1
				startNearAnimBT[i][j] = false
			end
		end

		local nearAnimFramesFX = loadNearAnimFrames("gameplay/hit_animation_frames/near_fx")

		local nearAnimTimerFX = {0, 0}

		local nearAnimIndexFX = {1, 1}

		local startNearAnimFX = {false, false}

		function nearAnimBT(deltaTime, i, j)
			gfx.Save()

			if (i == 1) then hitLane = 1 elseif (i == 2) then hitLane = 2
			elseif (i == 3) then hitLane = 3 elseif (i == 4) then hitLane = 4
			end

			hitAnimationTransform(hitLane)

			gfx.BeginPath()
			gfx.FillColor(255, 255, 255)

			nearAnimTimerBT[i][j] = nearAnimTimerBT[i][j] + deltaTime

			if (nearAnimTimerBT[i][j] > (1.0 / 58.0)) then
				nearAnimTimerBT[i][j] = 0
				nearAnimIndexBT[i][j] = nearAnimIndexBT[i][j] + 1
			end

			if (nearAnimTimerBT[i][j] < (1.0 / 58.0)) then
				gfx.ImageRect(-200, -205, 400, 400, nearAnimFramesBT[nearAnimIndexBT[i][j]], 1.2, 0)
			end

			if (nearAnimIndexBT[i][j] == 21) then
				nearAnimTimerBT[i][j] = 0
				nearAnimIndexBT[i][j] = 1
				startNearAnimBT[i][j] = false
			end
	
			gfx.Restore()
		end

		function nearAnimFX(deltaTime, i)
			gfx.Save()

			if (i == 1) then hitLane = 1.5 elseif (i == 2) then hitLane = 3.5 end

			hitAnimationTransform(hitLane)

			gfx.BeginPath()
			gfx.FillColor(255, 255, 255)

			nearAnimTimerFX[i] = nearAnimTimerFX[i] + deltaTime

			if (nearAnimTimerFX[i] > (1.0 / 58.0)) then
				nearAnimTimerFX[i] = 0
				nearAnimIndexFX[i] = nearAnimIndexFX[i] + 1
			end

			if (nearAnimTimerFX[i] < (1.0 / 58.0)) then
				gfx.ImageRect(-200, -205, 400, 400, nearAnimFramesFX[nearAnimIndexFX[i]], 1.2, 0)
			end

			if (nearAnimIndexFX[i] == 21) then
				nearAnimTimerFX[i] = 0
				nearAnimIndexFX[i] = 1
				startNearAnimFX[i] = false
			end
	
			gfx.Restore()
		end

	-- LASER END ANIMATION FUNCTIONS
		function loadLaserEndAnimFrames(path)
			local frames = {}

			for i = 0, 12 do
				frames[i]  = gfx.CreateSkinImage(string.format("%s/%03d.png", path, i), 0)
			end

			return frames
		end

		local laserEndAnimInnerFrames = {{}, {}}

		local laserEndAnimOuterFrames = {{}, {}}

		laserEndAnimInnerFrames[1] = loadLaserEndAnimFrames("gameplay/hit_animation_frames/laser_end_l_inner")
		laserEndAnimInnerFrames[2] = loadLaserEndAnimFrames("gameplay/hit_animation_frames/laser_end_r_inner")

		laserEndAnimOuterFrames[1] = loadLaserEndAnimFrames("gameplay/hit_animation_frames/laser_end_l_outer")
		laserEndAnimOuterFrames[2] = loadLaserEndAnimFrames("gameplay/hit_animation_frames/laser_end_r_outer")

		local laserEndAnimTimer = {{}, {}}

		local laserEndAnimIndex = {{}, {}}

		local startLaserEndAnim = {{}, {}}

		for i = 1, 2 do
			for j = 1, 6 do
				laserEndAnimTimer[i][j] = 0
				laserEndAnimIndex[i][j] = 1
				startLaserEndAnim[i][j] = false
			end
		end

		local laserEndPos = {0, 0}

		function laserEndAnim(deltaTime, pos, i, j)
			gfx.Save()

			gfx.BeginPath()
			gfx.FillColor(255, 255, 255)

			local lEXY = 200 * (scale * 0.875)
			local lEWH = 400 * (scale * 0.875)

			local lEXY2 = 250 * (scale * 0.875)
			local lEWH2 = 500 * (scale * 0.875)

			laserEndAnimTimer[i][j] = laserEndAnimTimer[i][j] + deltaTime

			if (laserEndAnimTimer[i][j] > (1.0 / 48.0)) then
				laserEndAnimTimer[i][j] = 0
				laserEndAnimIndex[i][j] = laserEndAnimIndex[i][j] + 1
			end

			if (laserEndAnimTimer[i][j] < (1.0 / 48.0)) then
				gfx.GlobalCompositeOperation(gfx.BLEND_OP_SOURCE_OVER)
				gfx.ImageRect(pos - lEXY2, -lEXY2, lEWH2, lEWH2, laserEndAnimInnerFrames[i][laserEndAnimIndex[i][j]], 2, 0)
				gfx.GlobalCompositeOperation(gfx.BLEND_OP_LIGHTER)
				gfx.ImageRect(pos - lEXY, -lEXY, lEWH, lEWH, laserEndAnimOuterFrames[i][laserEndAnimIndex[i][j]], 1, 0)
			end

			if (laserEndAnimIndex[i][j] == 12) then
				laserEndAnimTimer[i][j] = 0
				laserEndAnimIndex[i][j] = 1
				startLaserEndAnim[i][j] = false
			end

			gfx.Restore()
		end

	function laserCritical(i)
		for j = 1, 6 do
			if (startLaserEndAnim[i][j] == false) then
				startLaserEndAnim[i][j] = true
				break
			end
		end
	end

	function buttonCriticalBT(i)
		for j = 1, 4 do
			if (startCritAnimBT[i][j] == false) then
				startCritAnimBT[i][j] = true
				break
			end
		end
	end

	function buttonNearBT(i)
		for j = 1, 4 do
			if (startNearAnimBT[i][j] == false) then
				startNearAnimBT[i][j] = true
				break
			end
		end
	end

	function button_hit(button, rating, delta)
		if ((button == game.BUTTON_BTA) and (rating == 2)) then
			buttonCriticalBT(1)
		end
		if ((button == game.BUTTON_BTB) and (rating == 2)) then
			buttonCriticalBT(2)
		end
		if ((button == game.BUTTON_BTC) and (rating == 2)) then
			buttonCriticalBT(3)
		end
		if ((button == game.BUTTON_BTD) and (rating == 2)) then
			buttonCriticalBT(4)
		end
		if ((button == game.BUTTON_FXL) and (rating == 2)) then
			startCritAnimFX[1] = true
			critAnimTimerFX[1] = 0
			critAnimIndexFX[1] = 1
		end
		if ((button == game.BUTTON_FXR) and (rating == 2)) then
			startCritAnimFX[2] = true
			critAnimTimerFX[2] = 0
			critAnimIndexFX[2] = 1
		end

		if ((button == game.BUTTON_BTA) and (rating == 1)) then
			buttonNearBT(1)
		end
		if ((button == game.BUTTON_BTB) and (rating == 1)) then
			buttonNearBT(2)
		end
		if ((button == game.BUTTON_BTC) and (rating == 1)) then
			buttonNearBT(3)
		end
		if ((button == game.BUTTON_BTD) and (rating == 1)) then
			buttonNearBT(4)
		end
		if ((button == game.BUTTON_FXL) and (rating == 1)) then
			startNearAnimFX[1] = true
			nearAnimTimerFX[1] = 0
			nearAnimIndexFX[1] = 1
		end
		if ((button == game.BUTTON_FXR) and (rating == 1)) then
			startNearAnimFX[2] = true
			nearAnimTimerFX[2] = 0
			nearAnimIndexFX[2] = 1
		end
	end

local consolePortrait = gfx.CreateSkinImage("gameplay/console/console_p.png", 0)
local consoleLandscape = gfx.CreateSkinImage("gameplay/console/console_l.png", 0)

local laserCursor = gfx.CreateSkinImage("gameplay/laser/pointer.png", 0)
local laserCursorOverlay = gfx.CreateSkinImage("gameplay/laser/pointer_overlay.png", 0)

local laserAnimDome = {
	gfx.LoadSkinAnimation("gameplay/hit_animation_frames/laser_l_dome", (1.0 / 30.0)),
	gfx.LoadSkinAnimation("gameplay/hit_animation_frames/laser_r_dome", (1.0 / 30.0))
}

local laserAnimCritical = {
	gfx.LoadSkinAnimation("gameplay/hit_animation_frames/laser_critical", (1.0 / 59.0)),
	gfx.LoadSkinAnimation("gameplay/hit_animation_frames/laser_critical", (1.0 / 59.0))
}

local laserCursorTail = {
	gfx.CreateSkinImage("gameplay/laser/laser_cursor_tail_l.png", 0),
	gfx.CreateSkinImage("gameplay/laser/laser_cursor_tail_r.png", 0)
}

local insertFunction = {false, false}

function render_crit_overlay(deltaTime)

	-- HIT ANIMATIONS
		-- CRITICAL
			for i = 1, 4 do
				for j = 1, 6 do
					if (startCritAnimBT[i][j] == true) then
						critAnimBT(deltaTime, i, j)
					end
				end
			end

			for i = 1, 2 do
				if (startCritAnimFX[i] == true) then
					critAnimFX(deltaTime, i)
				end
			end
		
		-- NEAR
			for i = 1, 4 do
				for j = 1, 6 do
					if (startNearAnimBT[i][j] == true) then
						nearAnimBT(deltaTime, i, j)
					end
				end
			end

			for i = 1, 2 do
				if (startNearAnimFX[i] == true) then
					nearAnimFX(deltaTime, i)
				end
			end

		-- HOLD
			for i = 1, 6 do
				if (gameplay.noteHeld[i]) then
					holdAnim(deltaTime, i)
					startEndAnim[i] = true
				else
					holdAnimIndex[i] = 1
					holdInnerAnimIndex[i] = 1
					holdCriticalAnimIndex[i] = 1
					delayCriticalStart[i] = 0
				end
			end

		-- HOLD END
			for i = 1, 6 do
				if (gameplay.noteHeld[i] == false) then
					if (startEndAnim[i] == true) then
						holdEndAnim(deltaTime, i)
					else
						holdEndAnimIndex[i] = 1
					end
				end
			end
    
	-- MAIN CRIT OVERLAY
		SetUpCritTransform()

		local xOffset = GetCritLineCenteringOffset()

		gfx.Save()
		gfx.Translate(xOffset * 0.5, 0)

		local bfw, bfh = gfx.ImageSize(consolePortrait)

		local distBetweenKnobs = 0.446
		local distCritVertical = -0.014

		local ioFillTx = bfw / 2
		local ioFillTy = bfh * distCritVertical

		local io_x, io_y, io_w, io_h = -ioFillTx, -ioFillTy, bfw, bfh

		local consoleFillScale = (resx * 0.555) / (bfw * distBetweenKnobs)
		gfx.Scale(consoleFillScale, consoleFillScale)

		-- CONSOLE FILL
			if portrait then
				gfx.Scale((1 * 0.95), (1 * 0.95))
				gfx.FillColor(255, 255, 255)
				gfx.DrawRect(consolePortrait, io_x, io_y, io_w, io_h)
				gfx.Scale((1 / 0.95), (1 / 0.95))
			else
				gfx.Scale((1 * 0.85), (1 * 0.85))
				gfx.FillColor(255, 255, 255)
				gfx.DrawRect(consoleLandscape, io_x, (io_y - 90), io_w, io_h)
				gfx.Scale((1 / 0.85), (1 / 0.85))
			end

			gfx.Restore()

			local cw, ch = gfx.ImageSize(laserCursor)
			local cursorWidth = 40 * scale
			local cursorHeight = cursorWidth * (ch / cw)

			local lCXY = 200 * (scale * 0.875)
			local lCWH = 400 * (scale * 0.875)

		-- LASER CURSORS
			for i = 1, 2 do
				local cursor = gameplay.critLine.cursors[i - 1]
				local pos, skew = cursor.pos, cursor.skew

				-- LASER END ANIMATION
					for j = 1, 2 do
						if ((i == j) and (gameplay.laserActive[j] == false)) then
							for k = 1, 6 do
								if (startLaserEndAnim[j][k] == true) then
									laserEndAnim(deltaTime, laserEndPos[j], j, k)
									insertFunction[j] = false
								end
							end
						end
					end

				-- LASER CURSOR DOME
					if (i == 1 and gameplay.laserActive[1]) then
						gfx.Save()

						gfx.FillColor(255, 255, 255)
						gfx.GlobalCompositeOperation(gfx.BLEND_OP_LIGHTER)
						gfx.BeginPath()
						gfx.ImageRect(pos - lCXY, -lCXY, lCWH, lCWH, laserAnimDome[1], 1.5, 0)
						gfx.TickAnimation(laserAnimDome[1], deltaTime)

						gfx.GlobalCompositeOperation(gfx.BLEND_OP_SOURCE_OVER)
						gfx.BeginPath()
						gfx.FillColor(255, 255, 255)
						gfx.ImageRect(pos - lCXY, -lCXY, lCWH, lCWH, laserAnimCritical[1], 1.5, 0)
						gfx.TickAnimation(laserAnimCritical[1], deltaTime)

						gfx.Restore()

						laserEndPos[1] = pos

						if (insertFunction[1] == false) then
							laserCritical(1)
							insertFunction[1] = true
						end
					end

					if (i == 2 and gameplay.laserActive[2]) then
						gfx.Save()

						gfx.FillColor(255, 255, 255)
						gfx.GlobalCompositeOperation(gfx.BLEND_OP_LIGHTER)
						gfx.BeginPath()
						gfx.ImageRect(pos - lCXY, -lCXY, lCWH, lCWH, laserAnimDome[2], 1.5, 0)
						gfx.TickAnimation(laserAnimDome[2], deltaTime)

						gfx.GlobalCompositeOperation(gfx.BLEND_OP_SOURCE_OVER)
						gfx.BeginPath()
						gfx.FillColor(255, 255, 255)
						gfx.ImageRect(pos - lCXY, -lCXY, lCWH, lCWH, laserAnimCritical[2], 1.5, 0)
						gfx.TickAnimation(laserAnimCritical[2], deltaTime)

						gfx.Restore()

						laserEndPos[2] = pos
	
						if (insertFunction[2] == false) then
							laserCritical(2)
							insertFunction[2] = true
						end
					end

				gfx.SkewX(skew)

				-- LASER CURSOR TAIL
					if (i == 1 and gameplay.laserActive[1]) then
						gfx.Save()

						gfx.GlobalCompositeOperation(gfx.BLEND_OP_LIGHTER)
						gfx.BeginPath()
						gfx.FillColor(255, 255, 255)
						gfx.ImageRect(pos - lCXY, -lCXY, lCWH, lCWH, laserCursorTail[1], 1, 0)
						
						gfx.Restore()
					end

					if (i == 2 and gameplay.laserActive[2]) then
						gfx.Save()

						gfx.GlobalCompositeOperation(gfx.BLEND_OP_LIGHTER)
						gfx.BeginPath()
						gfx.FillColor(255, 255, 255)
						gfx.ImageRect(pos - lCXY, -lCXY, lCWH, lCWH, laserCursorTail[2], 1, 0)

						gfx.Restore()

					end

				gfx.GlobalCompositeOperation(gfx.BLEND_OP_SOURCE_OVER)
				SetFillToLaserColor(i, cursor.alpha * 255)
				gfx.BeginPath()
				gfx.DrawRect(laserCursor, pos - cursorWidth / 2, -cursorHeight / 2, cursorWidth, cursorHeight)
				gfx.FillColor(255, 255, 255, cursor.alpha * 255)
				gfx.DrawRect(laserCursorOverlay, pos - cursorWidth / 2, -cursorHeight / 2, cursorWidth, cursorHeight)
				gfx.SkewX(-skew)
			end

			gfx.FillColor(255, 255, 255)
			gfx.ResetTransform()
end


local topFillPortrait = gfx.CreateSkinImage("gameplay/banner/top_fill_p.png", 0)
local topFillLandscape = gfx.CreateSkinImage("gameplay/banner/top_fill_l.png", 0)
local scan = gfx.CreateSkinImage("gameplay/banner/scan.png", 0)
local scanGlow = gfx.CreateSkinImage("gameplay/banner/scan_glow.png", 0)

local visualizer = gfx.LoadSkinAnimation("gameplay/banner/visualizer_frames", (1.0 / 20.0))

local scanStartTimer = 0
local scanAnimTimer = 1
local scanAlpha = 0
local scanGlowTimer = 0

function DrawBanner(deltaTime)
    local bannerWidth, bannerHeight = gfx.ImageSize(topFillPortrait)
    local actualHeight = desw * (bannerHeight / bannerWidth)

    gfx.FillColor(255, 255, 255)
    gfx.DrawRect(topFillPortrait, 0, 0, desw, actualHeight)

	scanGlowTimer = scanGlowTimer + deltaTime

	if (scanGlowTimer > 2) then
		scanGlowTimer = 0
	end

	gfx.Save()
	gfx.BeginPath()
	gfx.FillColor(255, 255, 255)
	gfx.GlobalCompositeOperation(gfx.BLEND_OP_LIGHTER)
	gfx.Scissor(0, (470 - (scanGlowTimer * 3) * 120), desw, (actualHeight / 6))
	gfx.ImageRect(0, 0, desw, actualHeight, scanGlow, 1.15, 0)
	gfx.ResetScissor()
	gfx.Restore()
	
	scanStartTimer = scanStartTimer + deltaTime

	if (scanStartTimer > 2) then
		scanStartTimer = 0
		scanAnimTimer = 1
		scanAlpha = 0
	end

	if (scanStartTimer > 1) then
		scanAnimTimer = scanAnimTimer - (deltaTime * 4)
		scanAlpha = math.min(scanAlpha + (deltaTime * 4), 1)

		local scanShift = 100 * scanAnimTimer

		gfx.Save()
		gfx.BeginPath()
		gfx.Translate(0, scanShift)
		gfx.FillColor(255, 255, 255)
		gfx.GlobalCompositeOperation(gfx.BLEND_OP_LIGHTER)
		gfx.ImageRect(0, 0, desw, actualHeight, scan, scanAlpha, 0)
		gfx.Restore()
	end

	local vW, vH = gfx.ImageSize(visualizer)

	gfx.Save()
	gfx.BeginPath()
	gfx.GlobalCompositeOperation(gfx.BLEND_OP_LIGHTER)
	gfx.ImageRect(159, 92, (vW * 0.5), (vH * 0.5), visualizer, 1.2, 0)
	gfx.TickAnimation(visualizer, deltaTime)
	gfx.Restore()

    return actualHeight
end

local jacketFallback = gfx.CreateSkinImage("song_select/jacket_loading.png", 0)

local trackinfoBack = gfx.CreateSkinImage("gameplay/track_info/track_info_back.png", 0)
local progressFill = gfx.CreateSkinImage("gameplay/track_info/progress_fill.png", 0)
local progressArrow = gfx.CreateSkinImage("gameplay/track_info/progress_arrow.png", 0)

local difficulties = {
	gfx.CreateSkinImage("gameplay/track_info/difficulties/novice.png", 0),
	gfx.CreateSkinImage("gameplay/track_info/difficulties/advanced.png", 0),
	gfx.CreateSkinImage("gameplay/track_info/difficulties/exhaust.png", 0),
	gfx.CreateSkinImage("gameplay/track_info/difficulties/maximum.png", 0)
}

local userBack = gfx.CreateSkinImage("gameplay/user_panel/user_panel_back.png", 0)
local appealCard = gfx.CreateSkinImage("gameplay/user_panel/appeal_card.png", 0)
local volforce = gfx.CreateSkinImage("gameplay/user_panel/volforce.png", 0)

local dan = {
	gfx.CreateSkinImage("gameplay/user_panel/dan/none.png", 0),
	gfx.CreateSkinImage("gameplay/user_panel/dan/1.png", 0),
	gfx.CreateSkinImage("gameplay/user_panel/dan/2.png", 0),
	gfx.CreateSkinImage("gameplay/user_panel/dan/3.png", 0),
	gfx.CreateSkinImage("gameplay/user_panel/dan/4.png", 0),
	gfx.CreateSkinImage("gameplay/user_panel/dan/5.png", 0),
	gfx.CreateSkinImage("gameplay/user_panel/dan/6.png", 0),
	gfx.CreateSkinImage("gameplay/user_panel/dan/7.png", 0),
	gfx.CreateSkinImage("gameplay/user_panel/dan/8.png", 0),
	gfx.CreateSkinImage("gameplay/user_panel/dan/9.png", 0),
	gfx.CreateSkinImage("gameplay/user_panel/dan/10.png", 0),
	gfx.CreateSkinImage("gameplay/user_panel/dan/11.png", 0),
	gfx.CreateSkinImage("gameplay/user_panel/dan/inf.png", 0)
}

local userName = game.GetSkinSetting("username")
local skillLevel = game.GetSkinSetting("skill_level")
local displayScoreDiff = game.GetSkinSetting("display_score_diff")
local displayUserInfo = game.GetSkinSetting("display_user_info")
local displayVolforce = game.GetSkinSetting("display_volforce")

function drawTrackInfo(deltaTime)
    if ((jacket == nil) or (jacket == jacketFallback)) then
        jacket = gfx.LoadImageJob(gameplay.jacketPath, jacketFallback)
    end

    gfx.Save()
    gfx.LoadSkinFont("slant.ttf")
	
	if portrait then
		gfx.Translate(20, 0)
	elseif landscape then
		gfx.Translate(20, 30)
	end

	-- TRACK INFO BACK
	gfx.BeginPath()
	gfx.FillColor(255, 255, 255)
	gfx.ImageRect(0, -19, 250, 133, trackinfoBack, 1, 0)

	-- TRACK PROGRESS FILL
	gfx.BeginPath()
	gfx.FillColor(255, 255, 255)
	if (gameplay.progress < 0.2) then
		gfx.ImageRect(95, 42, (146 * (gameplay.progress * 1.2)), 3, progressFill, 0.6, 0)
	else
		gfx.ImageRect(95, 42, (146 * gameplay.progress), 3, progressFill, 0.6, 0)
	end

	-- TRACK PROGRESS ARROW
	gfx.BeginPath()
	gfx.FillColor(255, 255, 255)
	if (gameplay.progress == 0) then
		gfx.ImageRect(95 + (137 * gameplay.progress), 37.3, 0, (28 * 0.5), progressArrow, 1, 0)
	else
		gfx.ImageRect(95 + (137 * gameplay.progress), 37.3, (21 * 0.5), (28 * 0.44), progressArrow, 1, 0)
	end

	-- TRACK DIFFICULTY
	gfx.BeginPath()
	gfx.FillColor(255, 255, 255)
	gfx.ImageRect(0, -19, 250, 133, difficulties[gameplay.difficulty + 1], 1, 0)

	-- TRACK DIFFICULTY LEVEL
	gfx.BeginPath()
	gfx.FontSize(20)
	gfx.FillColor(245, 65, 125)
	gfx.Text(string.format("%02d", gameplay.level), 59, 101.8)
	gfx.FillColor(55, 255, 255)
	gfx.Text(string.format("%02d", gameplay.level), 59.8, 101)
	gfx.FillColor(255, 255, 255)
	gfx.Text(string.format("%02d", gameplay.level), 59, 101)


	-- JACKET
	gfx.BeginPath()
	gfx.FillColor(255, 255, 255)
	gfx.ImageRect(10, 4, 72.5, 72.5, jacket, 1 ,0)

	-- BPM AND HI-SPEED
	gfx.TextAlign(gfx.TEXT_ALIGN_RIGHT)
	gfx.FontSize(20)
	gfx.FillColor(245, 65, 125)
	gfx.Text(string.format("%.0f", gameplay.bpm), 243, 77.8)
	gfx.FillColor(55, 255, 255)
	gfx.Text(string.format("%.0f", gameplay.bpm), 243.8, 77)
	gfx.FillColor(255, 255, 255)
	gfx.Text(string.format("%.0f", gameplay.bpm), 243, 77)
	gfx.FillColor(245, 65, 125)
	gfx.Text(string.format("%.1f", gameplay.hispeed), 243, 105.8)
	gfx.FillColor(55, 255, 255)
	gfx.Text(string.format("%.1f", gameplay.hispeed), 243.8, 105)
	gfx.FillColor(255, 255, 255)
	gfx.Text(string.format("%.1f", gameplay.hispeed), 243, 105)

	-- TRACK TITLE
	gfx.LoadSkinFont("arial.ttf")
	gfx.TextAlign(gfx.TEXT_ALIGN_TOP + gfx.TEXT_ALIGN_CENTER)

	local tW, tH = gfx.ImageSize(topFillLandscape)

	if portrait then
		local trackTitle = gfx.CreateLabel(gameplay.title .. " / " .. gameplay.artist, 16, 0)
		gfx.FillColor(105, 105, 105)
		gfx.DrawLabel(trackTitle, ((desw / 2) - 19.3), -122.8, 435)
		gfx.FillColor(255, 255, 255)
		gfx.DrawLabel(trackTitle, ((desw / 2) - 20), -123.5, 435)
	else
		gfx.BeginPath()
		gfx.ImageRect((desw / 5) + 25, -31, tW/4, tH/4, topFillLandscape, 1, 0)
		local trackTitle = gfx.CreateLabel(gameplay.title .. " / " .. gameplay.artist, 16, 0)
		gfx.FillColor(105, 105, 105)
		gfx.DrawLabel(trackTitle, ((desw / 2) - 19.3), -28.3, 415)
		gfx.FillColor(255, 255, 255)
		gfx.DrawLabel(trackTitle, ((desw / 2) - 20), -29, 415)
	end

    gfx.LoadSkinFont("slant.ttf")

	-- USER INFO
	if (displayUserInfo == true) then

		-- USER INFO BACK
		gfx.BeginPath()
		gfx.FillColor(255, 255, 255)
		gfx.ImageRect(-20, 256, 225, 131, userBack, 1, 0)

		-- APPEAL CARD
        gfx.BeginPath()
		gfx.FillColor(255, 255, 255)
		gfx.ImageRect(-18, 271, 82, 104, appealCard, 1, 0)

		if (skillLevel == "none") then
			skillLevel = 1
		elseif (skillLevel == "1") then
			skillLevel = 2
		elseif (skillLevel == "2") then
			skillLevel = 3
		elseif (skillLevel == "3") then
			skillLevel = 4
		elseif (skillLevel == "4") then
			skillLevel = 5
		elseif (skillLevel == "5") then
			skillLevel = 6
		elseif (skillLevel == "6") then
			skillLevel = 7
		elseif (skillLevel == "7") then
			skillLevel = 8
		elseif (skillLevel == "8") then
			skillLevel = 9
		elseif (skillLevel == "9") then
			skillLevel = 10
		elseif (skillLevel == "10") then
			skillLevel = 11
		elseif (skillLevel == "11") then
			skillLevel = 12
		elseif (skillLevel == "inf") then
			skillLevel = 13
		end

		-- VOLFORCE AND DAN
		if (displayVolforce == true) then
			gfx.BeginPath()
			gfx.FillColor(255, 255, 255)
			gfx.ImageRect(66, 325, 75, 32, volforce, 1, 0)

			gfx.BeginPath()
			gfx.FillColor(255, 255, 255)
			gfx.ImageRect(66, 360, 69, 20, dan[skillLevel], 1, 0)
		else
			gfx.BeginPath()
			gfx.FillColor(255, 255, 255)
			gfx.ImageRect(66, 325, 69, 20, dan[skillLevel], 1, 0)
		end

		local displayUser = gfx.CreateLabel(string.upper(userName), 24, 0)

		-- USERNAME
		gfx.TextAlign(gfx.TEXT_ALIGN_LEFT)
		gfx.FillColor(245, 65, 125)
		gfx.DrawLabel(displayUser, 75, 266.8, 126)
		gfx.FillColor(55, 255, 255)
		gfx.DrawLabel(displayUser, 75.8, 266, 126)
		gfx.FillColor(255, 255, 255)
		gfx.DrawLabel(displayUser, 75, 266, 126)
		gfx.FontSize(24)

		-- SCORE DIFFERENCE
		if (displayScoreDiff == true) then
			drawBestDiff(deltaTime, 206, 285)
		end
	end

    -- CHANGE HI-SPEED
    if game.GetButton(game.BUTTON_STA) then
		gfx.FontSize(24)
		gfx.FillColor(255, 255, 255)
		gfx.TextAlign(gfx.TEXT_ALIGN_RIGHT)
		gfx.Text(string.format("%.0f x %.1f =", gameplay.bpm, gameplay.hispeed), 199, 135)
		gfx.FillColor(0, 255, 0)
		gfx.Text(string.format("%.0f", (gameplay.bpm * gameplay.hispeed)), 250, 135)
    end

    gfx.Restore()
end

function drawBestDiff(deltaTime, x, y)
    if not gameplay.scoreReplays[1] then 
        return 
    end

    gfx.BeginPath()

    difference = score - gameplay.scoreReplays[1].currentScore

	diffString = string.format("%08d", math.abs(difference))

    local prefix = "+ "

    gfx.FillColor(170, 160, 255)

    if difference < 0 then 
        scorerank = false
        gfx.FillColor(255, 90, 70)
        prefix = "- "
    elseif difference > 0 then
        scorerank = true
    end

	local subStartPos = 0
	local subEndPos = 0
	local smallSubPos = 0

	if ((math.abs(difference) >= 10000) and (math.abs(difference) < 100000)) then 
		subStartPos = 4 subEndPos = 4
	elseif ((math.abs(difference) >= 100000) and (math.abs(difference) < 1000000)) then 
		subStartPos = 3 subEndPos = 4
	elseif (math.abs(difference) >= 1000000) then 
		subStartPos = 2 subEndPos = 4
	end

	if (math.abs(difference) == 0) then 
		smallSubPos = -1 
	else 
		smallSubPos = -4 
	end

    gfx.TextAlign(gfx.TEXT_ALIGN_RIGHT)
    gfx.FontSize(24)
	gfx.Text(prefix, (x - 115), (y + 27))
	gfx.FontSize(28)
	gfx.Text(string.sub(diffString, subStartPos, subEndPos), (x - 59), (y + 31))
	gfx.FontSize(28 * 0.77)
	gfx.Text(string.sub(diffString, smallSubPos), (x - 4), (y + 31))
end


function drawScoreLarge(x, y, alpha, num, digits, image, is_dim)
    local tw, th = gfx.ImageSize(image[1])
    x = x + (tw * (digits - 1)) / 2
    y = y - th / 2
    for i = 1, digits do
        local mul = 10 ^ (i - 1)
        local digit = math.floor(num / mul) % 10
        local a = alpha
        if is_dim and num < mul then
            a = 0
        end
        gfx.BeginPath()
        gfx.ImageRect((x / 4), (y / 4), (tw / 4), (th / 4), image[digit + 1], a, 0)
        x = x - tw
    end
end

function drawScoreSmall(x, y, alpha, num, digits, image, is_dim)
    local tw, th = gfx.ImageSize(image[1])
    x = x + (tw * (digits - 1)) / 2
    y = y - th / 2
    for i = 1, digits do
        local mul = 10 ^ (i - 1)
        local digit = math.floor(num / mul) % 10
        local a = alpha
        if is_dim and num < mul then
            a = 0
        end
        gfx.BeginPath()
        gfx.ImageRect((x / 4), (y / 4), (tw / 4), (th / 4), image[digit + 1], a, 0)
        x = x - tw
    end
end

function loadNumberImages(path)
    local image = {}
    for i = 0, 9 do
        image[i + 1] = gfx.CreateSkinImage(string.format("%s/%d.png", path, i), 0)
    end
    return image
end

local scoreBack = gfx.CreateSkinImage("gameplay/score/score_back.png", 0)
local scoreFront = gfx.CreateSkinImage("gameplay/score/score_front.png", 0)
local scoreArrowsAnim = gfx.LoadSkinAnimation("gameplay/score/score_arrows_frames", (1.0 / 44.0))
local logoAnim = gfx.LoadSkinAnimation("gameplay/score/logo_frames", (1.0 / 60.0))

local scoreNumberLarge = loadNumberImages("gameplay/score/score_l")
local scoreNumberSmall = loadNumberImages("gameplay/score/score_s")

local scoreEffective = 0
local scoreSmall = 0
local duration = 0.30
local maxChain = 0

function drawScore(deltaTime)
	gfx.Save()

    gfx.LoadSkinFont("slant.ttf")

	if portrait then
		gfx.Translate(-42, 0)
	elseif landscape then
		gfx.Translate(-42, 30)
	end

	-- SCORE BACK
	gfx.BeginPath()
	gfx.FillColor(255, 255, 255)
	gfx.ImageRect((desw - 228), -19, 250, 128, scoreBack, 1, 0)

	-- SCORE ARROW ANIMATION
	gfx.BeginPath()
	gfx.ImageRect((desw - 228), -19, 250, 128, scoreArrowsAnim, 1, 0)
	gfx.TickAnimation(scoreArrowsAnim, deltaTime)

	-- SCORE FRONT
	gfx.BeginPath()
	gfx.FillColor(255, 255, 255)
	gfx.ImageRect((desw - 228), -19, 250, 128, scoreFront, 1, 0)

	-- SCORE COUNT ANIMATION
	scoreLarge = math.floor(score / 10000)

    local scoreOffset = (scoreLarge - scoreEffective) / duration

	if (scoreEffective < scoreLarge) then
		scoreEffective = scoreEffective + scoreOffset * deltaTime
	end
	  
	if (math.ceil(scoreEffective) < scoreLarge) then
		scoreSmall = math.random(0, 9999)
	else
		scoreSmall = score
	end

	-- SCORE
	gfx.BeginPath()
    gfx.FillColor(255, 255, 255)

    drawScoreLarge(((desw * 4) - 700), 172, 1.0, math.ceil(scoreEffective), 4, scoreNumberLarge, false)
	drawScoreSmall(((desw * 4) - 190), 185, 1.0, scoreSmall, 4, scoreNumberSmall, false)

	-- LOGO ANIMATION
	local lW, lH = gfx.ImageSize(logoAnim)
	gfx.BeginPath()
	gfx.FillColor(255, 255, 255)
	gfx.ImageRect((desw - 37), -21, (lW * 0.6), (lH * 0.6), logoAnim, 1, 0)
	gfx.TickAnimation(logoAnim, deltaTime)

	-- MAXIMUM CHAIN
	if combo > maxChain then
		maxChain = combo
	end

	gfx.TextAlign(gfx.TEXT_ALIGN_RIGHT + gfx.TEXT_ALIGN_TOP)
	gfx.FontSize(22)
	gfx.FillColor(245, 65, 125)
	gfx.Text(string.format("%04d", maxChain), (desw - 168), 79.8)
	gfx.FillColor(55, 255, 255)
	gfx.Text(string.format("%04d", maxChain), (desw - 167.2), 79)
	gfx.FillColor(255, 255, 255)
	gfx.Text(string.format("%04d", maxChain), (desw - 168), 79)

	gfx.Restore()
end


local gaugeEffBack = gfx.CreateSkinImage("gameplay/gauge/effective/gauge_back.png", 0)
local gaugeEffFillNormalAnim = gfx.LoadSkinAnimation("gameplay/gauge/effective/fill_normal_frames", (1.0 / 48.0))
local gaugeEffFillPassAnim = gfx.LoadSkinAnimation("gameplay/gauge/effective/fill_pass_frames", (1.0 / 48.0))
local gaugeExcBack = gfx.CreateSkinImage("gameplay/gauge/excessive/gauge_back.png", 0)
local gaugeExcFillNormal = gfx.CreateSkinImage("gameplay/gauge/excessive/gauge_fill.png", 0)
local gaugeExcFillPass = gfx.CreateSkinImage("gameplay/gauge/excessive/gauge_fill.png", 0)
local gaugePercentBack = gfx.CreateSkinImage("gameplay/gauge/gauge_percent_back.png", 0)

function drawGauge(deltaTime)
	local gauge;

	if (gameplay.gaugeType) then
		gauge = { type = gameplay.gaugeType, value = gameplay.gauge };
	else
		gauge = { type = gameplay.gauge.type, value = gameplay.gauge.value };
	end
	
	gfx.Save()

	if portrait then
		gfx.Translate(10, 0)
		gfx.Scale((1 * 0.95), (1 * 0.95))
	end

    local height = 1024 * (scale * 0.35)
    local width = 512 * (scale * 0.35)
    local posy = (resy / 2) - (height / 2)
    local posx = resx - (resx / 16) - width

    if portrait then
        width = width * 0.7
        height = height * 0.7
        posy = posy - 30
        posx = resx - width
    end

    local ratePercentage = math.floor(gauge.value * 100)

    local gaugeEffBackW = 58
    local gaugeEffBackH = 362
    local gaugeEffFillW = 29
    local gaugeEffFillH = (687 / 2)
    local gaugeImgHighNoClear = 1 - 0.3207
    local gaugeImgLowClear = 0.3353
    local xOffset = 155

    if portrait then 
        xOffset = 40 
    end

    local posxgauge = desw - gaugeEffBackW - xOffset
    local yOffset = 0

    if portrait then 
        yOffset = 60 
    end

    local posygauge = (desh / 2) - (gaugeEffBackH / 2) - yOffset
    local posxfill = posxgauge + 6
    local posyfill = posygauge + 9
    local fillyscissor = posyfill + gaugeEffFillH - (gaugeEffFillH * math.min(gaugeImgHighNoClear, gauge.value))
    local fillhscissor = gaugeEffFillH * gauge.value
    local fillyscissorClear = posyfill + gaugeEffFillH - (gaugeEffFillH * gauge.value)
    local fillhscissorClear = math.max(0, gaugeEffFillH * (gauge.value - (1 - gaugeImgLowClear)))

    -- GAUGE BACK
    gfx.BeginPath()

    if (gauge.type == 0) then
        gfx.ImageRect(posxgauge, posygauge, gaugeEffBackW, gaugeEffBackH, gaugeEffBack, 1, 0)
    elseif (gauge.type == 1) then
        gfx.ImageRect(posxgauge, posygauge, gaugeEffBackW, gaugeEffBackH, gaugeExcBack, 1, 0)
    end

    gfx.Fill()

    -- GAUGE FILL
    gfx.BeginPath()
    
    local gaugeFill = gaugeEffFillNormal

    if (gauge.type == 0) then
        if (ratePercentage < 70) then
            gaugeFill = gaugeEffFillNormalAnim
        else
            gaugeFill = gaugeEffFillPassAnim
        end
    elseif (gauge.type == 1) then
        posxfill = posxgauge + 19.2
        posyfill = (posygauge + 9)
		gaugeEffFillW = 29
		gaugeEffFillH = (687 / 2)
        gaugeFill = gaugeExcFillPass
    end

	if (gauge.type == 0) then
		if (ratePercentage < 70) then
			gfx.Scissor(posxfill, math.min(fillyscissor, fillyscissorClear), gaugeEffFillW, math.max(fillhscissor, fillhscissorClear))
			gfx.ImageRect(posxfill, posyfill, gaugeEffFillW, gaugeEffFillH, gaugeFill, 1, 0)
			gfx.TickAnimation(gaugeFill, deltaTime)
		else
			gfx.Scissor(posxfill, math.min(fillyscissor, fillyscissorClear), gaugeEffFillW, math.max(fillhscissor, fillhscissorClear))
			gfx.ImageRect(posxfill, posyfill, gaugeEffFillW, gaugeEffFillH, gaugeFill, 1, 0)
			gfx.TickAnimation(gaugeFill, deltaTime)
		end
	else
		gfx.Scissor(posxfill, math.min(fillyscissor, fillyscissorClear), gaugeEffFillW, math.max(fillhscissor, fillhscissorClear))
		gfx.ImageRect(posxfill, posyfill, gaugeEffFillW, gaugeEffFillH, gaugeFill, 1, 0)
	end
	
	gfx.ResetScissor()

	-- DRAW GAUGE % LABEL
    posx = posx / scale
    posx = posx + (100 * 0.35) 
    height = 880 * 0.35
    posy = posy / scale * 1.2

    if portrait then
        height = height * 0.7
        posx = posx - 21
    end
	
    posy = posy + (70 * 0.35) + height - height * gauge.value
    posy = math.min(fillyscissor, fillyscissorClear)

	local gpW, gpH = gfx.ImageSize(gaugePercentBack)

	gfx.BeginPath()
	gfx.FillColor(255, 255, 255)
	gfx.ImageRect((posx - 46), (posy - 17.3), (gpW * 0.3), (gpH * 0.3), gaugePercentBack, 1, 0)

    local gaugePercent = "00%"

    if (gauge.value < 0.1) then
        gaugePercent = string.format("%02d%%", ratePercentage)
    else
        gaugePercent = string.format("%d%%", ratePercentage)
    end

	gfx.LoadSkinFont("slant.ttf")
    gfx.TextAlign(gfx.TEXT_ALIGN_RIGHT + gfx.TEXT_ALIGN_MIDDLE)
	gfx.FontSize(16)
	gfx.FillColor(245, 65, 125)
	gfx.Text(gaugePercent, (posx - 1.6), (posy - 6.3))
	gfx.FillColor(55, 255, 255)
	gfx.Text(gaugePercent, (posx - 0.6), (posy - 6.3))
	gfx.FillColor(255, 255, 255)
	gfx.Text(gaugePercent, (posx - 1), (posy - 6.3))

	gfx.Restore()
end


local comboDigits = loadNumberImages("gameplay/chain/normal")
local comboDigits_uc = loadNumberImages("gameplay/chain/uc")
local chainText = gfx.CreateSkinImage("gameplay/chain/normal/chain.png", 0)
local chainTextUC = gfx.CreateSkinImage("gameplay/chain/uc/chain_uc.png", 0)

local comboTimer = 0
local comboScale = 1
local comboScaleTrigger = false
local comboAlpha = 0
local comboBurstValue = 100

function drawCombo(deltaTime)
    if (combo == 0) then
        return
    end

	gfx.Save()

	comboTimer = math.max(comboTimer - deltaTime,0)

    if ((comboTimer == 0) and (game.GetButton(game.BUTTON_STA) == false)) then 
        return
    end

    local randAlpha = 0
    local randPos = 0

    local posx = desw / 2
    local posy = desh * critLinePos[1] - 150

    if portrait then 
        posy = desh * critLinePos[2] - 180
    end

	gfx.FillColor(255, 255, 255)

	local fadeTimer2 = 0.5 * math.cos(genericTimer * 8 % 4)

	alpha = fadeTimer2 + 0.2

	local combox = (300 / 8)

	local cW, cH = (300 / 8), (488 / 8)

	if (gameplay.comboState == 2) or (gameplay.comboState == 1) then
		gfx.BeginPath()
		gfx.ImageRect(posx - (503 / 19), posy - (92 / 2.2), (503 / (19/2)), (92 / (19/2)), chainTextUC, 0.4, 0)
	else
		gfx.BeginPath()
		gfx.ImageRect(posx - (503 / 19), posy - (92 / 2.2), (503 / (19/2)), (92 / (19/2)), chainText, 0.4, 0)
	end

	local posx = (desw - 1) / 2 + randBinary

	if (gameplay.comboState == 2) or (gameplay.comboState == 1) then
		local digit = combo % 10

		gfx.BeginPath()
		gfx.ImageRect(posx + combox, posy - (cH / 2), cW, cH, comboDigits_uc[digit + 1], 1, 0)
		gfx.ImageRect(posx + combox, posy - (cH / 2), cW, cH, comboDigits[digit + 1], alpha, 0)

		digit = math.floor(combo / 10) % 10
		gfx.BeginPath()
		gfx.ImageRect(posx, posy - (cH / 2), cW, cH, comboDigits_uc[digit + 1], combo >= 10 and 1 or 0.1, 0)
		gfx.ImageRect(posx, posy - (cH / 2), cW, cH, comboDigits[digit + 1], combo >= 10 and alpha or 0.1, 0)

		digit = math.floor(combo / 100) % 10
		gfx.BeginPath()
		gfx.ImageRect(posx - combox, posy - (cH / 2), cW, cH, comboDigits_uc[digit + 1], combo >= 100 and 1 or 0.1, 0)
		gfx.ImageRect(posx - combox, posy - (cH / 2), cW, cH, comboDigits[digit + 1], combo >= 100 and alpha or 0.1, 0)

		digit = math.floor(combo / 1000) % 10
		gfx.BeginPath()
		gfx.ImageRect(posx - (combox * 2), posy - (cH / 2), cW, cH, comboDigits_uc[digit + 1], combo >= 1000 and 1 or 0.1, 0)
		gfx.ImageRect(posx - (combox * 2), posy - (cH / 2), cW, cH, comboDigits[digit + 1], combo >= 1000 and alpha or 0.1, 0)

		cW, cH = (300 / 8) * comboScale, (488 / 8) * comboScale
		combox = (300 / 8) * comboScale

		if (combo >= comboBurstValue) then
			comboBurstValue = comboBurstValue + 100
			if (comboScaleTrigger == false) then
				comboAlpha = 1
			end
			comboScaleTrigger = true
		end
	
		if combo < 100 then
			comboBurstValue = 100
		end
	
		if ((comboScaleTrigger == true) and (comboScale < 3)) then
			comboScale = comboScale + deltaTime * 6
			comboAlpha = math.max(comboAlpha - deltaTime * 5, 0)
		else
			comboScale = 1
			comboAlpha = 0
			comboScaleTrigger = false
		end

		gfx.BeginPath()
		gfx.ImageRect(posx + combox, posy - (cH / 2), cW, cH, comboDigits_uc[digit + 1], comboAlpha, 0)

		digit = math.floor(combo / 10) % 10
		gfx.BeginPath()
		gfx.ImageRect(posx, posy - (cH / 2), cW, cH, comboDigits_uc[digit + 1], comboAlpha, 0)

		digit = math.floor(combo / 100) % 10
		gfx.BeginPath()
		gfx.ImageRect(posx - combox, posy - (cH / 2), cW, cH, comboDigits_uc[digit + 1], comboAlpha, 0)

		digit = math.floor(combo / 1000) % 10
		gfx.BeginPath()
		gfx.ImageRect(posx - (combox * 2), posy - (cH / 2), cW, cH, comboDigits_uc[digit + 1], comboAlpha, 0)

	else
		local digit = combo % 10

		gfx.BeginPath()
		gfx.ImageRect(posx + combox, posy - (cH / 2), cW, cH, comboDigits[digit + 1], 1, 0)

		digit = math.floor(combo / 10) % 10
		gfx.BeginPath()
		gfx.ImageRect(posx, posy - (cH / 2), cW, cH, comboDigits[digit + 1], combo >= 10 and 1 or 0.1, 0)

		digit = math.floor(combo / 100) % 10
		gfx.BeginPath()
		gfx.ImageRect(posx - combox, posy - (cH / 2), cW, cH, comboDigits[digit + 1], combo >= 100 and 1 or 0.1, 0)

		digit = math.floor(combo / 1000) % 10
		gfx.BeginPath()
		gfx.ImageRect(posx - (combox * 2), posy - (cH / 2), cW, cH, comboDigits[digit + 1], combo >= 1000 and 1 or 0.1, 0)
	end

	gfx.Restore()
end

local earlatePos = game.GetSkinSetting("earlate_position")

local earlateTimer = 0

function drawEarlate(deltaTime)
	gfx.Save()

    earlateTimer = math.max(earlateTimer - deltaTime, 0)

    if ((earlateTimer == 0) and (game.GetButton(game.BUTTON_STA) == false)) then 
		return nil 
	end

    local alpha = math.floor(earlateTimer * 40) % 4
    alpha = alpha * 200 + 55
	
    gfx.BeginPath()
    gfx.FontSize(24)
    gfx.LoadSkinFont("slant.ttf")
    gfx.TextAlign(gfx.TEXT_ALIGN_CENTER, gfx.TEXT_ALIGN_MIDDLE)

    local ypos = desh * critLinePos[1] - 150    

	local earlateHeight = 0

	if (earlatePos == "Bottom") then
		if portrait then
			earlateHeight = 30
		else
			earlateHeight = 60
		end
	elseif (earlatePos == "Middle") then
		if portrait then
			earlateHeight = 190
		else
			earlateHeight = 220
		end
	elseif (earlatePos == "Upper") then
		if portrait then
			earlateHeight = 310
		else
			earlateHeight = 360
		end
	elseif (earlatePos == "Upper+") then
		if portrait then
			earlateHeight = 420
		else
			earlateHeight = 470
		end
	elseif (earlatePos == "Off") then
		earlateHeight = 3000
	end

	if portrait then 
		ypos = desh * critLinePos[2] - 220
	end

	if late then
        gfx.FillColor(55, 55, 55, 155)
		gfx.Text("> LATE <", (desw / 2), (ypos - earlateHeight + 1))
        gfx.FillColor(55, 255, 255, alpha)
		gfx.Text("> LATE <", (desw / 2), (ypos - earlateHeight))
	else
        gfx.FillColor(55, 55, 55, 155)
		gfx.Text("> EARLY <", (desw / 2), (ypos - earlateHeight + 1))
        gfx.FillColor(255, 85, 255, alpha)
		gfx.Text("> EARLY <", (desw / 2), (ypos - earlateHeight))
    end

	gfx.Restore()
end

local startAlert = {false, false}

laser_alert = function(isRight) 
    if isRight then
		startAlert[2] = true
    else
		startAlert[1] = true
    end
end

function loadAlertFrames(path)
	local frames = {}

	for i = 0, 29 do
		frames[i]  = gfx.CreateSkinImage(string.format("%s/%03d.png", path, i), 0)
	end

	return frames
end

local alertFrames = {{}, {}}

alertFrames[1] = loadAlertFrames("gameplay/laser_alert_frames/left")

alertFrames[2] = loadAlertFrames("gameplay/laser_alert_frames/right")

local alertTimer = {0, 0}

local alertIndex = {1, 1}

local alertFlashLoop = {0, 0}

function drawAlerts(deltaTime)
	if startAlert[1] == true then
        gfx.Save()

        local posx = desw / 2 - 300
        local posy = desh * critLinePos[1] - 100

        if portrait then 
            posy = desh * critLinePos[2] - 140
            posx = 65
        end

		gfx.Translate(posx, posy)

		alertTimer[1] = alertTimer[1] + deltaTime

		if (alertTimer[1] > (1.0 / 45.0)) then
			alertTimer[1] = 0
			alertIndex[1] = alertIndex[1] + 1
		end

        gfx.BeginPath()
		gfx.FillColor(255, 255, 255)
		
		if (alertTimer[1] < (1.0 / 45.0)) then
			gfx.ImageRect(-58, -56, 116, 112, alertFrames[1][alertIndex[1]], 1, 0)
		end

		if alertIndex[1] == 29 then
			startAlert[1] = false
		end

		if alertFlashLoop[1] == 5 then
			alertIndex[1] = 24
			alertFlashLoop[1] = 0
		elseif (alertIndex[1] == 23) then
			alertIndex[1] = 10
			alertFlashLoop[1] = alertFlashLoop[1] + 1
		end

        gfx.Restore()
	else
		alertTimer[1] = 0
		alertIndex[1] = 1
	end

	if startAlert[2] == true then
        gfx.Save()

        local posx = desw / 2 + 300
        local posy = desh * critLinePos[1] - 100

        if portrait then 
            posy = desh * critLinePos[2] - 140
            posx = desw - 65
        end

		gfx.Translate(posx, posy)

		alertTimer[2] = alertTimer[2] + deltaTime

		if (alertTimer[2] > (1.0 / 45.0)) then
			alertTimer[2] = 0
			alertIndex[2] = alertIndex[2] + 1
		end

        gfx.BeginPath()
		gfx.FillColor(255, 255, 255)
		
		if (alertTimer[2] < (1.0 / 45.0)) then
			gfx.ImageRect(-58, -56, 116, 112, alertFrames[2][alertIndex[2]], 1, 0)
		end

		if alertIndex[2] == 29 then
			startAlert[2] = false
		end

		if alertFlashLoop[2] == 5 then
			alertIndex[2] = 24
			alertFlashLoop[2] = 0
		elseif (alertIndex[2] == 23) then
			alertIndex[2] = 10
			alertFlashLoop[2] = alertFlashLoop[2] + 1
		end

        gfx.Restore()
	else
		alertTimer[2] = 0
		alertIndex[2] = 1
	end
end

local passEffect = gfx.CreateSkinImage("gameplay/pass_effect.png", 0)

local clearEffect = game.GetSkinSetting("clear_effect")

local effectScale = 1
local effectAlpha = 1
local playEffect = true

function drawPassEffect(deltaTime)
	if (clearEffect == true) then
		local gauge;

		if (gameplay.gaugeType) then
			gauge = { type = gameplay.gaugeType, value = gameplay.gauge };
		else
			gauge = { type = gameplay.gauge.type, value = gameplay.gauge.value };
		end

		if (gauge.value >= 0.7) then
			if playEffect == true then

				effectScale = effectScale + (deltaTime / 1.35) * 30
				effectAlpha = math.max(effectAlpha - (deltaTime * 4), 0)
				local eXY = -101 * effectScale
				local eWH = 202 * effectScale

				gfx.Save()
				gfx.GlobalCompositeOperation(gfx.BLEND_OP_LIGHTER)
				if portrait then
					gfx.Translate((desw / 2), (desh / 2) - 110)
				else
					gfx.Translate((desw / 2), (desh / 2) - 35)
				end
				gfx.BeginPath()
				gfx.FillColor(255, 255, 255)
				gfx.ImageRect(eXY, eXY, eWH, eWH, passEffect, effectAlpha, 0)
				gfx.Restore()
				if (effectAlpha == 0) then
					playEffect = false
				end
			end
		end
	end
end

render_intro = function(deltaTime)
    if (not game.GetButton(game.BUTTON_STA)) then
        introTimer = introTimer - deltaTime
    end

    introTimer = math.max(introTimer, 0)
    return introTimer <= 0
end

render_outro = function(deltaTime, clearState)
    if (clearState == 0) then
		return true
	end

    gfx.ResetTransform()
    gfx.BeginPath()
    gfx.FillColor(0, 0, 0, math.floor(200 * math.min(outroTimer, 1)))
	gfx.FastRect(-1, 0, (resx * 2), (resy * 2))
    gfx.Fill()
    gfx.Scale(scale, scale)
    gfx.TextAlign(gfx.TEXT_ALIGN_CENTER + gfx.TEXT_ALIGN_MIDDLE)
    gfx.LoadSkinFont("slant.ttf")
    gfx.FontSize(70)

	local clearText = gfx.CreateLabel(clearTexts[clearState], 70, 0)

	if portrait then
		gfx.FillColor(245, 65, 125, math.floor(255 * math.min(outroTimer, 1)))
		gfx.DrawLabel(clearText, (desw / 2), (desh / 2) - 99, resx)
		gfx.FillColor(55, 255, 255, math.floor(255 * math.min(outroTimer, 1)))
		gfx.DrawLabel(clearText, (desw / 2) + 1, (desh / 2) - 100, resx)
		gfx.FillColor(255, 255, 255, math.floor(255 * math.min(outroTimer, 1)))
		gfx.DrawLabel(clearText, (desw / 2), (desh / 2) - 100, resx)
	else
		gfx.FillColor(245, 65, 125, math.floor(255 * math.min(outroTimer, 1)))
		gfx.DrawLabel(clearText, (desw / 2), (desh / 2) + 1, resx)
		gfx.FillColor(55, 255, 255, math.floor(255 * math.min(outroTimer, 1)))
		gfx.DrawLabel(clearText, (desw / 2) + 1, (desh / 2), resx)
		gfx.FillColor(255, 255, 255, math.floor(255 * math.min(outroTimer, 1)))
		gfx.DrawLabel(clearText, (desw / 2), (desh / 2), resx)
	end

    outroTimer = outroTimer + deltaTime
    return outroTimer > 2, 1 - outroTimer
end

update_score = function(newScore)
    score = newScore
end

update_combo = function(newCombo)
    combo = newCombo

    if combo > maxCombo then
        maxCombo = combo
    end

	comboTimer = 0.75
end

near_hit = function(wasLate) 
    late = wasLate
    earlateTimer = 0.75
end

gfx.ResetTransform()

-- ======================== Start mutliplayer ========================

json = require "json"

local normal_font = game.GetSkinSetting('multi.normal_font')
if normal_font == nil then
    normal_font = 'slant.ttf'
end
local mono_font = game.GetSkinSetting('multi.mono_font')
if mono_font == nil then
    mono_font = 'slant.ttf'
end

local users = nil

function init_tcp()
    Tcp.SetTopicHandler("game.scoreboard", function(data)
        users = {}
        for i, u in ipairs(data.users) do
            table.insert(users, u)
        end
    end)
end


-- Hook the render function and draw the scoreboard
local real_render = render
render = function(deltaTime)
    real_render(deltaTime)
    draw_users(deltaTime)
end

-- Update the users in the scoreboard
function score_callback(response)
    if response.status ~= 200 then 
        error() 
        return 
    end
    local jsondata = json.decode(response.text)
    users = {}
    for i, u in ipairs(jsondata.users) do
        table.insert(users, u)
    end
end

-- Render scoreboard
function draw_users(detaTime)
    if (users == nil) then
        return
    end

    local yshift = 0

    if portrait then
        local bannerWidth, bannerHeight = gfx.ImageSize(topFillPortrait)
        yshift = desw * (bannerHeight / bannerWidth)
        gfx.Scale(0.7, 0.7)
    end

    gfx.Save()

    -- Add a small margin at the edge
    gfx.Translate(5,yshift+200)

    -- Reset some text related stuff that was changed in draw_state
    gfx.TextAlign(gfx.TEXT_ALIGN_LEFT)
    gfx.FontSize(35)
    gfx.FillColor(255, 255, 255)
    local yoff = 0
    if portrait then
        yoff = 125
    end
    local rank = 0
    for i, u in ipairs(users) do
        gfx.FillColor(255, 255, 255)
        local score_big = string.format("%04d",math.floor(u.score/10000))
        local score_small = string.format("%04d",u.score%10000)
        local user_text = '('..u.name..')'

        local size_big = 34
        local size_small = 26
        local size_name = 26

        if u.id == gameplay.user_id then
            size_big = 42
            size_small = 30
            size_name = 34
            rank = i
        end

        gfx.LoadSkinFont(normal_font)
        gfx.FontSize(size_big)
        gfx.Text(score_big, 0, yoff)
        local xmin,ymin,xmax,ymax_big = gfx.TextBounds(0, yoff, score_big)
        xmax = xmax + 7

        gfx.FontSize(size_small)
        gfx.Text(score_small, xmax, yoff)
        xmin,ymin,xmax,ymax = gfx.TextBounds(xmax, yoff, score_small)
        xmax = xmax + 7

        if u.id == gameplay.user_id then
            gfx.FillColor(237, 240, 144)
        end

        gfx.LoadSkinFont(normal_font)
        gfx.FontSize(size_name)
        gfx.Text(user_text, xmax, yoff)

        yoff = ymax_big + 15
    end

    gfx.Restore()
end