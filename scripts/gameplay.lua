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

local jacketFallback = gfx.CreateSkinImage("song_select/jacket_loading.png", 0)
local bottomFill = gfx.CreateSkinImage("console/console.png", 0)
local bottomFillL = gfx.CreateSkinImage("console/console_l.png", 0)
local topFill = gfx.CreateSkinImage("fill_top.png", 0)
local topFillL = gfx.CreateSkinImage("fill_top_l.png", 0)
local critBarAnim = gfx.CreateSkinImage("crit_anim.png", 0)
local critBar = gfx.CreateSkinImage("crit_bar.png", 0)
local critBarGlow = gfx.CreateSkinImage("crit_bar_glow.png", 0)
local critConsole = gfx.CreateSkinImage("crit_console.png", 0)
local laserCursor = gfx.CreateSkinImage("pointer.png", 0)
local laserCursorOverlay = gfx.CreateSkinImage("pointer_overlay.png", 0)
local appealCard = gfx.CreateSkinImage("appeal_card.png", 0)
local trackinfoBack = gfx.CreateSkinImage("trackinfo_back.png", 0)
local progressFill = gfx.CreateSkinImage("progress_fill.png", 0)
local progressArrow = gfx.CreateSkinImage("progress_arrow.png", 0)
local scoreBack = gfx.CreateSkinImage("score_back.png", 0)
local userBack = gfx.CreateSkinImage("userpanel_back.png", 0)
local volforce = gfx.CreateSkinImage("volforce.png", 0)

local dan = {
	gfx.CreateSkinImage("dan/none.png", 0),
	gfx.CreateSkinImage("dan/1.png", 0),
	gfx.CreateSkinImage("dan/2.png", 0),
	gfx.CreateSkinImage("dan/3.png", 0),
	gfx.CreateSkinImage("dan/4.png", 0),
	gfx.CreateSkinImage("dan/5.png", 0),
	gfx.CreateSkinImage("dan/6.png", 0),
	gfx.CreateSkinImage("dan/7.png", 0),
	gfx.CreateSkinImage("dan/8.png", 0),
	gfx.CreateSkinImage("dan/9.png", 0),
	gfx.CreateSkinImage("dan/10.png", 0),
	gfx.CreateSkinImage("dan/11.png", 0),
	gfx.CreateSkinImage("dan/inf.png", 0)
}

local scoreBackAnim = gfx.LoadSkinAnimation("anim_frames/score_arrows", (1.0 / 44.0))
local logoAnim = gfx.LoadSkinAnimation("anim_frames/logo", (1.0 / 60.0))

local laserAnimDome = {
	gfx.LoadSkinAnimation("hitanim_frames/laser_l_dome", (1.0 / 40.0)),
	gfx.LoadSkinAnimation("hitanim_frames/laser_r_dome", (1.0 / 40.0))
}

local laserAnimCritical = {
	gfx.LoadSkinAnimation("hitanim_frames/laser_critical", (1.0 / 40.0)),
	gfx.LoadSkinAnimation("hitanim_frames/laser_critical", (1.0 / 40.0))
}

local laserCursorTail = {
	gfx.CreateSkinImage("laser_cursor_tail_l.png", 0),
	gfx.CreateSkinImage("laser_cursor_tail_r.png", 0)
}

local alertLBack = gfx.CreateSkinImage("alert_l_back.png", 0)
local alertRBack = gfx.CreateSkinImage("alert_r_back.png", 0)
local alertL = gfx.CreateSkinImage("alert_l.png", 0)
local alertR = gfx.CreateSkinImage("alert_r.png", 0)

local alertFill = gfx.CreateSkinImage("laser_alerts/alert_fill.png", 0)
local alertBack = gfx.CreateSkinImage("laser_alerts/alert_back.png", 0)
local alertLt = gfx.CreateSkinImage("laser_alerts/alert_l_white.png", 0)
local alertRt = gfx.CreateSkinImage("laser_alerts/alert_r_white.png", 0)
local alertLs = gfx.CreateSkinImage("laser_alerts/alert_l_shadow.png", 0)
local alertRs = gfx.CreateSkinImage("laser_alerts/alert_r_shadow.png", 0)

local gaugeEffBack = gfx.CreateSkinImage("gauges/effective/gauge-back.png", 0)
local gaugeEffFillNormalAnim = gfx.LoadSkinAnimation("gauges/effective/fill_normal_frames", (1.0 / 48.0))
local gaugeEffFillPassAnim = gfx.LoadSkinAnimation("gauges/effective/fill_pass_frames", (1.0 / 48.0))

local gaugeExcBack = gfx.CreateSkinImage("gauges/excessive/gauge-back.png", 0)
local gaugeExcFillNormal = gfx.CreateSkinImage("gauges/excessive/gauge-fill.png", 0)
local gaugeExcFillPass = gfx.CreateSkinImage("gauges/excessive/gauge-fill.png", 0)

local gaugePercentBack = gfx.CreateSkinImage("gaugep_back.png", 0)

local customColors = game.GetSkinSetting("custom_colors")
local earlatePos = game.GetSkinSetting("earlate_position")
local userName = game.GetSkinSetting("username")
local displayScoreDiff = game.GetSkinSetting("display_score_diff")
local displayUserInfo = game.GetSkinSetting("display_user_info")
local displayChain = game.GetSkinSetting("display_chain")
local displayVolforce = game.GetSkinSetting("display_volforce")
local skillLevel = game.GetSkinSetting("skill_level")

local difficulties = {
	gfx.CreateSkinImage("difficulties/novice.png", 0),
	gfx.CreateSkinImage("difficulties/advanced.png", 0),
	gfx.CreateSkinImage("difficulties/exhaust.png", 0),
	gfx.CreateSkinImage("difficulties/maximum.png", 0)
}

if (introTimer == nil) then
	introTimer = 1
	outroTimer = 0
end

local alertTimers = {-2, -2}

local earlateTimer = 0
local earlateColors = {{255, 255, 0}, {0, 255, 255}}

local critBarAnimTimer = 0

local genericTimer = 0
local fadeTimer = 0

local score = 0
local combo = 0
local maxCombo = 0
local maxChain = 0
local randBinary = math.random(0, 1)
local jacket = nil
local critLinePos = {0.95, 0.73}
local songInfoWidth = 400
local jacketWidth = 72.5
local comboScale = 0
local late = false
local title = nil
local artist = nil
local diffNames = {"NOVICE", "ADVANCED", "EXHAUST", "MAXIMUM"}
local clearTexts = {"TRACK CRASH", "TRACK COMPLETE", "TRACK COMPLETE", "ULTIMATE CHAIN", "PERFECT"}

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

    gfx.Translate(0, yshift - 150 * math.max(introTimer - 1, 0))
    drawTrackInfo(deltaTime)
    drawScore(deltaTime)
    gfx.Translate(0, -yshift + 150 * math.max(introTimer - 1, 0))

    drawGauge(deltaTime)
    drawEarlate(deltaTime)
    drawCombo(deltaTime)
    drawAlerts(deltaTime)

    if (introTimer > 0) then
        gfx.FillColor(0, 0, 0, math.floor(255 * math.min(introTimer, 1)))
        gfx.FastRect(-1, 0, (resx * 2), (resy * 2))
    end

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
    local distFromCenter = resx / 2 - gameplay.critLine.x
    local dvx = math.cos(gameplay.critLine.rotation)
    local dvy = math.sin(gameplay.critLine.rotation)
    return math.sqrt(dvx * dvx + dvy * dvy) * distFromCenter
end

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

			for i = 0, 80 do
				frames[i]  = gfx.CreateSkinImage(string.format("%s/%03d.png", path, i), 0)
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

		local holdInnerAnimFrames = loadHoldAnimFrames("hitanim_frames/hold_inner")

		local holdDomeAnimFrames = loadHoldAnimFrames("hitanim_frames/hold_dome")

		local holdCriticalAnimFrames = loadHoldAnimFrames("hitanim_frames/hold_critical")

		local holdEndAnimFrames = loadHoldEndAnimFrames("hitanim_frames/hold_end")

		local holdAnimTimer = {0, 0, 0, 0, 0, 0}

		local holdAnimIndex = {1, 1, 1, 1, 1, 1}

		local holdEndAnimTimer = {0, 0, 0, 0, 0, 0}

		local holdEndAnimIndex = {1, 1, 1, 1, 1, 1}

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

			if (holdAnimTimer[i] > (1.0 / 36.0)) then
				holdAnimTimer[i] = 0
				holdAnimIndex[i] = holdAnimIndex[i] + 1
			end

			if (holdAnimTimer[i] < (1.0 / 36.0)) then
				gfx.GlobalCompositeOperation(gfx.BLEND_OP_LIGHTER)
				gfx.ImageRect(-213, -221, 426, 426, holdInnerAnimFrames[holdAnimIndex[i]], 5, 0)
				gfx.ImageRect(-213, -221, 426, 426, holdDomeAnimFrames[holdAnimIndex[i]], 1.5, 0)
				gfx.GlobalCompositeOperation(gfx.BLEND_OP_SOURCE_OVER)
				gfx.ImageRect(-213, -221, 426, 426, holdCriticalAnimFrames[holdAnimIndex[i]], 1, 0)
			end

			if (holdAnimIndex[i] == 80) then
				holdAnimIndex[i] = 10
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

			holdAnimTimer[i] = holdAnimTimer[i] + deltaTime

			if (holdAnimTimer[i] > (1.0 / 36.0)) then
				holdAnimTimer[i] = 0
				holdEndAnimIndex[i] = holdEndAnimIndex[i] + 1
			end

			if (holdAnimTimer[i] < (1.0 / 36.0)) then
				gfx.GlobalCompositeOperation(gfx.BLEND_OP_LIGHTER)
				gfx.ImageRect(-213, -221, 426, 426, holdEndAnimFrames[holdEndAnimIndex[i]], 1.5, 0)
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

		local critAnimFramesBT = loadCritAnimFrames("hitanim_frames/critical_bt")

		local critAnimFramesFX = loadCritAnimFrames("hitanim_frames/critical_fx")

		local critAnimQueue = {{}, {}, {}, {}, {}, {}}

		local critAnimTimer = {{}, {}, {}, {}, {}, {}}

		local critAnimIndex = {{}, {}, {}, {}, {}, {}}

		local startCritAnim = {{}, {}, {}, {}, {}, {}}

		local critBT = false

		local critFX = false

		for i = 1, 6 do
			for j = 1, 6 do
				critAnimQueue[i][j] = 1
				critAnimTimer[i][j] = 0
				critAnimIndex[i][j] = 1
				startCritAnim[i][j] = false
			end
		end

		function critAnim(deltaTime, i, j)
			gfx.Save()

			if (i == 1) then hitLane = 1 critBT = true critFX = false
			elseif (i == 2) then hitLane = 2 critBT = true critFX = false
			elseif (i == 3) then hitLane = 3 critBT = true critFX = false
			elseif (i == 4) then hitLane = 4 critBT = true critFX = false
			elseif (i == 5) then hitLane = 1.5 critFX = true critBT = false
			elseif (i == 6) then hitLane = 3.5 critFX = true critBT = false
			end

			hitAnimationTransform(hitLane)

			gfx.BeginPath()
			gfx.FillColor(255, 255, 255)

			critAnimTimer[i][j] = critAnimTimer[i][j] + deltaTime

			if (critAnimTimer[i][j] > (1.0 / 56.0)) then
				critAnimTimer[i][j] = 0
				critAnimIndex[i][j] = critAnimIndex[i][j] + 1
			end

			if (critAnimTimer[i][j] < (1.0 / 56.0)) then
				if (critBT == true) then
					gfx.ImageRect(-200, -206, 400, 400, critAnimFramesBT[critAnimIndex[i][j]], 1, 0)
				elseif (critFX == true) then
					gfx.ImageRect(-200, -206, 400, 400, critAnimFramesFX[critAnimIndex[i][j]], 1, 0)
				end
			end

			if (critAnimIndex[i][j] == 17) then
				startCritAnim[i][j] = false
				critAnimTimer[i][j] = 0
				critAnimIndex[i][j] = 1
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

		local nearAnimFramesBT = loadNearAnimFrames("hitanim_frames/near_bt")

		local nearAnimFramesFX = loadNearAnimFrames("hitanim_frames/near_fx")

		local nearAnimQueue = {{}, {}, {}, {}, {}, {}}

		local nearAnimTimer = {{}, {}, {}, {}, {}, {}}

		local nearAnimIndex = {{}, {}, {}, {}, {}, {}}

		local startNearAnim = {{}, {}, {}, {}, {}, {}}

		local nearBT = false

		local nearFX = false

		for i = 1, 6 do
			for j = 1, 6 do
				nearAnimQueue[i][j] = 1
				nearAnimTimer[i][j] = 0
				nearAnimIndex[i][j] = 1
				startNearAnim[i][j] = false
			end
		end

		function nearAnim(deltaTime, i, j)
			gfx.Save()

			if (i == 1) then hitLane = 1 nearBT = true nearFX = false
			elseif (i == 2) then hitLane = 2 nearBT = true nearFX = false
			elseif (i == 3) then hitLane = 3 nearBT = true nearFX = false
			elseif (i == 4) then hitLane = 4 nearBT = true nearFX = false
			elseif (i == 5) then hitLane = 1.5 nearBT = false nearFX = true
			elseif (i == 6) then hitLane = 3.5 nearBT = false nearFX = true
			end

			hitAnimationTransform(hitLane)

			gfx.BeginPath()
			gfx.FillColor(255, 255, 255)

			nearAnimTimer[i][j] = nearAnimTimer[i][j] + deltaTime

			if (nearAnimTimer[i][j] > (1.0 / 58.0)) then
				nearAnimTimer[i][j] = 0
				nearAnimIndex[i][j] = nearAnimIndex[i][j] + 1
			end

			if (nearAnimTimer[i][j] < (1.0 / 58.0)) then
				if (nearBT == true) then
					gfx.ImageRect(-200, -206, 400, 400, nearAnimFramesBT[nearAnimIndex[i][j]], 1, 0)
				elseif (nearFX == true) then
					gfx.ImageRect(-200, -206, 400, 400, nearAnimFramesFX[nearAnimIndex[i][j]], 1, 0)
				end
			end

			if (nearAnimIndex[i][j] == 21) then
				startNearAnim[i][j] = false
				nearAnimTimer[i][j] = 0
				nearAnimIndex[i][j] = 1
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

		laserEndAnimInnerFrames[1] = loadLaserEndAnimFrames("hitanim_frames/laser_end_l_inner")
		laserEndAnimInnerFrames[2] = loadLaserEndAnimFrames("hitanim_frames/laser_end_r_inner")

		laserEndAnimOuterFrames[1] = loadLaserEndAnimFrames("hitanim_frames/laser_end_l_outer")
		laserEndAnimOuterFrames[2] = loadLaserEndAnimFrames("hitanim_frames/laser_end_r_outer")

		local laserEndAnimQueue = {{}, {}}

		local laserEndAnimTimer = {{}, {}}

		local laserEndAnimIndex = {{}, {}}

		local startLaserEndAnim = {{}, {}}

		for i = 1, 2 do
			for j = 1, 6 do
				laserEndAnimQueue[i][j] = 1
				laserEndAnimTimer[i][j] = 0
				laserEndAnimIndex[i][j] = 1
				startLaserEndAnim[i][j] = false
			end
		end

		local laserEndPos = {0, 0}

		function laserEndAnim(deltaTime, pos, i, j)
			gfx.Save()

			gfx.BeginPath()
			if (customColors == true) then
				r,g,b = game.GetLaserColor(i - 1)
				gfx.FillColor(math.min(r + 55, 255), math.min(g + 55, 255), math.min(b + 55, 255), 55)
			else
				gfx.FillColor(255, 255, 255)
			end

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
				startLaserEndAnim[i][j] = false
				laserEndAnimTimer[i][j] = 0
				laserEndAnimIndex[i][j] = 1
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

	function buttonCritical(i)
		for j = 1, 6 do
			if (startCritAnim[i][j] == false) then
				startCritAnim[i][j] = true
				break
			end
		end
	end

	function buttonNear(i)
		for j = 1, 6 do
			if (startNearAnim[i][j] == false) then
				startNearAnim[i][j] = true
				break
			end
		end
	end

	function button_hit(button, rating, delta)
		if ((button == game.BUTTON_BTA) and (rating == 2)) then
			buttonCritical(1)
		end
		if ((button == game.BUTTON_BTB) and (rating == 2)) then
			buttonCritical(2)
		end
		if ((button == game.BUTTON_BTC) and (rating == 2)) then
			buttonCritical(3)
		end
		if ((button == game.BUTTON_BTD) and (rating == 2)) then
			buttonCritical(4)
		end
		if ((button == game.BUTTON_FXL) and (rating == 2)) then
			buttonCritical(5)
		end
		if ((button == game.BUTTON_FXR) and (rating == 2)) then
			buttonCritical(6)
		end

		if ((button == game.BUTTON_BTA) and (rating == 1)) then
			buttonNear(1)
		end
		if ((button == game.BUTTON_BTB) and (rating == 1)) then
			buttonNear(2)
		end
		if ((button == game.BUTTON_BTC) and (rating == 1)) then
			buttonNear(3)
		end
		if ((button == game.BUTTON_BTD) and (rating == 1)) then
			buttonNear(4)
		end
		if ((button == game.BUTTON_FXL) and (rating == 1)) then
			buttonNear(5)
		end
		if ((button == game.BUTTON_FXR) and (rating == 1)) then
			buttonNear(6)
		end
	end

local insertFunction = {false, false}

function render_crit_overlay(deltaTime)

	-- HIT ANIMATIONS
		-- CRITICAL
			for i = 1, 6 do
				for j = 1, 6 do
					if (startCritAnim[i][j] == true) then
						critAnim(deltaTime, i, j)
					end
				end
			end
		
		-- NEAR
			for i = 1, 6 do
				for j = 1, 6 do
					if (startNearAnim[i][j] == true) then
						nearAnim(deltaTime, i, j)
					end
				end
			end

		-- HOLD
			for i = 1, 6 do
				if (gameplay.noteHeld[i]) then
					holdAnim(deltaTime, i)
					startEndAnim[i] = true
				else
					holdAnimIndex[i] = 1
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

		local bfw, bfh = gfx.ImageSize(bottomFill)

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
				gfx.DrawRect(bottomFill, io_x, io_y, io_w, io_h)
				gfx.Scale((1 / 0.95), (1 / 0.95))
			else
				gfx.Scale((1 * 0.85), (1 * 0.85))
				gfx.FillColor(255, 255, 255)
				gfx.DrawRect(bottomFillL, io_x, (io_y - 90), io_w, io_h)
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

						if (customColors == true) then
							r,g,b = game.GetLaserColor(0)
							gfx.FillColor(math.min(r + 55, 255), math.min(g + 55, 255), math.min(b + 55, 255), 55)
						else
							gfx.FillColor(255, 255, 255)
						end

						gfx.GlobalCompositeOperation(gfx.BLEND_OP_LIGHTER)
						gfx.BeginPath()
						gfx.ImageRect(pos - lCXY, -lCXY, lCWH, lCWH, laserAnimDome[1], 1.5, 0)
						gfx.TickAnimation(laserAnimDome[1], deltaTime)

						gfx.GlobalCompositeOperation(gfx.BLEND_OP_SOURCE_OVER)
						gfx.BeginPath()
						gfx.FillColor(255, 255, 255)
						gfx.ImageRect(pos - lCXY, -lCXY, lCWH, lCWH, laserAnimCritical[1], 1, 0)
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

						if (customColors == true) then
							r,g,b = game.GetLaserColor(1)
							gfx.FillColor(math.min(r + 55, 255), math.min(g + 55, 255), math.min(b + 55, 255), 55)
						else
							gfx.FillColor(255, 255, 255)
						end

						gfx.GlobalCompositeOperation(gfx.BLEND_OP_LIGHTER)
						gfx.BeginPath()
						gfx.ImageRect(pos - lCXY, -lCXY, lCWH, lCWH, laserAnimDome[2], 1.5, 0)
						gfx.TickAnimation(laserAnimDome[2], deltaTime)

						gfx.GlobalCompositeOperation(gfx.BLEND_OP_SOURCE_OVER)
						gfx.BeginPath()
						gfx.FillColor(255, 255, 255)
						gfx.ImageRect(pos - lCXY, -lCXY, lCWH, lCWH, laserAnimCritical[2], 1, 0)
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
						if (customColors == true) then
							r,g,b = game.GetLaserColor(0)
							gfx.FillColor(math.min(r + 55, 255), math.min(g + 55, 255), math.min(b + 55, 255), 55)
						else
							gfx.FillColor(255, 255, 255)
						end
						gfx.ImageRect(pos - lCXY, -lCXY, lCWH, lCWH, laserCursorTail[1], 1, 0)
						
						gfx.Restore()
					end

					if (i == 2 and gameplay.laserActive[2]) then
						gfx.Save()

						gfx.GlobalCompositeOperation(gfx.BLEND_OP_LIGHTER)
						gfx.BeginPath()
						if (customColors == true) then
						r,g,b = game.GetLaserColor(1)
							gfx.FillColor(math.min(r + 55, 255), math.min(g + 55, 255), math.min(b + 55, 255), 55)
						else
							gfx.FillColor(255, 255, 255)
						end
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

function DrawBanner(deltaTime)
    local bannerWidth, bannerHeight = gfx.ImageSize(topFill)
    local actualHeight = desw * (bannerHeight / bannerWidth)

    gfx.FillColor(255, 255, 255)
    gfx.DrawRect(topFill, 0, 0, desw, actualHeight)

    return actualHeight
end

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
	gfx.FillColor(255, 255, 255)
	gfx.FontSize(20)
	gfx.Text(string.format("%02d", gameplay.level), 59, 101)
	gfx.Fill()

	-- JACKET
	gfx.BeginPath()
	gfx.FillColor(255, 255, 255)
	gfx.ImageRect(10, 4, jacketWidth, jacketWidth, jacket, 1 ,0)

	-- BPM AND HI-SPEED
	gfx.TextAlign(gfx.TEXT_ALIGN_RIGHT)
	gfx.FillColor(255, 255, 255)
	gfx.FontSize(24) 
	gfx.Text(string.format("%.0f", gameplay.bpm), 245, 79)
	gfx.Text(string.format("%.1f", gameplay.hispeed), 245, 107)

	-- TRACK TITLE
	gfx.LoadSkinFont("arial.ttf")
	gfx.TextAlign(gfx.TEXT_ALIGN_TOP + gfx.TEXT_ALIGN_CENTER)

	local tW, tH = gfx.ImageSize(topFillL)

	if portrait then
		local trackTitle = gfx.CreateLabel(gameplay.title .. " / " .. gameplay.artist, 16, 0)
		gfx.FillColor(105, 105, 105)
		gfx.DrawLabel(trackTitle, ((desw / 2) - 19.3), -122.8, 435)
		gfx.FillColor(255, 255, 255)
		gfx.DrawLabel(trackTitle, ((desw / 2) - 20), -123.5, 435)
	else
		gfx.BeginPath()
		gfx.ImageRect((desw / 5) + 25, -31, tW/4, tH/4, topFillL, 1, 0)
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

		local displayUser = gfx.CreateLabel(userName, 24, 0)

		-- USERNAME
		gfx.TextAlign(gfx.TEXT_ALIGN_LEFT)
		gfx.FillColor(255, 255, 255)
		gfx.DrawLabel(displayUser, 75, 266, 126)
		gfx.FontSize(24)

		-- SCORE DIFFERENCE
		if (displayScoreDiff == true) then
			drawBestDiff(deltaTime, 253, 283)
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
    gfx.FontSize(26)

    difference = score - gameplay.scoreReplays[1].currentScore

    local prefix = "+ "

    gfx.FillColor(135, 135, 255)
    gfx.FontSize(30)

    if difference < 0 then 
        scorerank = false
        gfx.FillColor(255, 85, 85)
        difference = math.abs(difference)
        prefix = "- "
    elseif difference > 0 then
        scorerank = true
    end

    gfx.TextAlign(gfx.TEXT_ALIGN_RIGHT)
    gfx.FontSize(26)
	gfx.Text(string.format("%s%01d", prefix, difference), (x - 53), (y + 31))
end

function loadNumberImages(path)
    local image = {}
    for i = 0, 9 do
        image[i + 1] = gfx.CreateSkinImage(string.format("%s/%d.png", path, i), 0)
    end
    return image
end

local scoreNumberLarge = loadNumberImages("score_l")
local scoreNumberSmall = loadNumberImages("score_s")

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

local scoreEffective = 0
local scoreSmall = 0
local duration = 0.30

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
	gfx.ImageRect((desw - 228), -19, 250, 128, scoreBackAnim, 1, 0)
	gfx.TickAnimation(scoreBackAnim, deltaTime)

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
	gfx.FillColor(255, 255, 255)
	gfx.FontSize(22)
	gfx.Text(string.format("%04d", maxChain), (desw - 167), 79)

	gfx.Restore()
end

function drawGauge(deltaTime)
	gfx.Save()

	if portrait then
		gfx.Translate(10, 0)
		gfx.Scale((1 * 0.95), (1 * 0.95))
	end

    local height = 1024 * (scale * 0.35)
    local width = 512 * (scale * 0.35)
    local posy = (resy / 2) - (height / 2)
    local posx = resx - (resx / 16) - width * (1 - math.max(introTimer - 1, 0))

    if portrait then
        width = width * 0.7
        height = height * 0.7
        posy = posy - 30
        posx = resx - width * (1 - math.max(introTimer - 1, 0))
    end

    local ratePercentage = math.floor(gameplay.gauge * 100)

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
    local fillyscissor = posyfill + gaugeEffFillH - (gaugeEffFillH * math.min(gaugeImgHighNoClear, gameplay.gauge))
    local fillhscissor = gaugeEffFillH * gameplay.gauge
    local fillyscissorClear = posyfill + gaugeEffFillH - (gaugeEffFillH * gameplay.gauge)
    local fillhscissorClear = math.max(0, gaugeEffFillH * (gameplay.gauge - (1 - gaugeImgLowClear)))

    -- GAUGE BACK
    gfx.BeginPath()

    if (gameplay.gaugeType == 0) then
        gfx.ImageRect(posxgauge, posygauge, gaugeEffBackW, gaugeEffBackH, gaugeEffBack, 1, 0)
    elseif (gameplay.gaugeType == 1) then
        gfx.ImageRect(posxgauge, posygauge, gaugeEffBackW, gaugeEffBackH, gaugeExcBack, 1, 0)
    end

    gfx.Fill()

    -- GAUGE FILL
    gfx.BeginPath()
    
    local gaugeFill = gaugeEffFillNormal

    if (gameplay.gaugeType == 0) then
        if (ratePercentage < 70) then
            gaugeFill = gaugeEffFillNormalAnim
        else
            gaugeFill = gaugeEffFillPassAnim
        end
    elseif (gameplay.gaugeType == 1) then
        posxfill = posxgauge + 19.2
        posyfill = (posygauge + 9)
		gaugeEffFillW = 29
		gaugeEffFillH = (687 / 2)
        gaugeFill = gaugeExcFillPass
    end

	if (gameplay.gaugeType == 0) then
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
	
    posy = posy + (70 * 0.35) + height - height * gameplay.gauge
    posy = math.min(fillyscissor, fillyscissorClear)

	local gpW, gpH = gfx.ImageSize(gaugePercentBack)

	gfx.BeginPath()
	gfx.FillColor(255, 255, 255)
	gfx.ImageRect((posx - 46), (posy - 17.3), (gpW * 0.3), (gpH * 0.3), gaugePercentBack, 1, 0)

	gfx.FillColor(255, 255, 255)

    local gaugePercent = "00%"

    if (gameplay.gauge < 0.1) then
        gaugePercent = string.format("%02d%%", ratePercentage)
    else
        gaugePercent = string.format("%d%%", ratePercentage)
    end

	gfx.LoadSkinFont("slant.ttf")
    gfx.TextAlign(gfx.TEXT_ALIGN_RIGHT + gfx.TEXT_ALIGN_MIDDLE)
	gfx.FontSize(16)
	gfx.Text(gaugePercent, (posx - 1), (posy - 6.3))

	gfx.Restore()
end

local comboDigits = loadNumberImages("chain")
local comboDigits_uc = loadNumberImages("chain_uc")
local chainText = gfx.CreateSkinImage("chain/chain.png", 0)
local chainText_uc = gfx.CreateSkinImage("chain_uc/chain_uc.png", 0)
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

	if (displayChain == true) then
		if (gameplay.comboState == 2) or (gameplay.comboState == 1) then
			gfx.BeginPath()
			gfx.ImageRect(posx - (503 / 19), posy - (92 / 2.2), (503 / (19/2)), (92 / (19/2)), chainText_uc, 0.4, 0)
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
	end

	gfx.Restore()
end

function drawEarlate(deltaTime)
	gfx.Save()

    earlateTimer = math.max(earlateTimer - deltaTime, 0)

    if ((earlateTimer == 0) and (game.GetButton(game.BUTTON_STA) == false)) then 
		return nil 
	end

    local alpha = math.floor(earlateTimer * 40) % 4

    alpha = alpha * 100 + 25

    alpha = alpha * 160 + 25

    gfx.BeginPath()
    gfx.FontSize(20)
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
			earlateHeight = 170
		else
			earlateHeight = 220
		end
	elseif (earlatePos == "Upper") then
		if portrait then
			earlateHeight = 310
		else
			earlateHeight = 360
		end
	elseif (earlatePos == "Upper++") then
		if portrait then
			earlateHeight = 420
		else
			earlateHeight = 470
		end
	elseif (earlatePos == "Off") then
		earlateHeight = 3000
	end

	if portrait then 
		ypos = desh * critLinePos[2] - 200
	end

    if late then
		gfx.FillColor(255, 255, 255, alpha)
        gfx.Text("> LATE <", (desw / 2) - 1, (ypos - earlateHeight))
        gfx.FillColor(55, 255, 255, alpha)
        gfx.Text("> LATE <", (desw / 2) - 1, (ypos - earlateHeight))
    else
		gfx.FillColor(255, 255, 255, alpha)
        gfx.Text("> EARLY <", (desw / 2) + 1, (ypos - earlateHeight))
        gfx.FillColor(255, 55, 255, alpha)
        gfx.Text("> EARLY <", (desw / 2) + 1, (ypos - earlateHeight))
    end

	gfx.Restore()
end

function drawAlerts(deltaTime)
    alertTimers[1] = math.max(alertTimers[1] - deltaTime,-2)
    alertTimers[2] = math.max(alertTimers[2] - deltaTime,-2)

	-- LEFT ALERT
	if alertTimers[1] > 0 then
        gfx.Save()
        local posx = desw / 2 - 300
        local posy = desh * critLinePos[1] - 100

        if portrait then 
            posy = desh * critLinePos[2] - 120
            posx = 65
        end

        gfx.Translate(posx, posy)
        r,g,b = game.GetLaserColor(0)
        local alertScale = (-(alertTimers[1] ^ 2.0) + (1.5 * alertTimers[1])) * 5.0
        alertScale = math.min(alertScale, 1)
        gfx.BeginPath()

		if (customColors == true) then
			gfx.Scale((alertScale ^ 4.0), 1)
			gfx.FillColor(255, 255, 255)
			gfx.ImageRect(-50, -50, 100, 100, alertFill, 1, 0)
			gfx.FillColor(math.min(r + 85, 255), math.min(g + 85, 255), math.min(b + 85, 255), 255)
			gfx.ImageRect(-50, -50, 100, 100, alertBack, 1, 0)
		else
			gfx.FillColor(255, 255, 255)
			gfx.Scale((alertScale ^ 4.0), 1)
			gfx.ImageRect(-50, -50, 100, 100, alertLBack, 1, 0)
		end

		gfx.Scale((1 / alertScale ^ 4.0), 1)
        gfx.BeginPath()

		if (customColors == true) then
			gfx.FillColor(math.min(r + 55, 255), math.min(g + 55, 255), math.min(b + 55, 255), 255)
			gfx.ImageRect(-50, -50, 100, 100, alertLs, ((fadeTimer + 0.05) * alertScale), 0)
			gfx.FillColor(255, 255, 255)
			gfx.ImageRect(-50, -50, 100, 100, alertLt, ((fadeTimer + 0.35) * alertScale), 0)
		else
			gfx.FillColor(255, 255, 255)
			gfx.ImageRect(-50, -50, 100, 100, alertL, ((fadeTimer + 0.3) * alertScale ^ 3.0), 0)
		end

        gfx.Restore()
    end

	-- RIGHT ALERT
    if alertTimers[2] > 0 then
        gfx.Save()
        local posx = desw / 2 + 300
        local posy = desh * critLinePos[1] - 100

        if portrait then 
            posy = desh * critLinePos[2] - 120
            posx = desw - 65
        end

        gfx.Translate(posx, posy)
        r,g,b = game.GetLaserColor(1)
        local alertScale = (-(alertTimers[2] ^ 2.0) + (1.5 * alertTimers[2])) * 5.0
        alertScale = math.min(alertScale, 1)
        gfx.BeginPath()

		if (customColors == true) then
			gfx.Scale((alertScale ^ 4.0), 1)
			gfx.FillColor(255, 255, 255)
			gfx.ImageRect(-50, -50, 100, 100, alertFill, 1, 0)
			gfx.FillColor(math.min(r + 85, 255), math.min(g + 85, 255), math.min(b + 85, 255), 255)
			gfx.ImageRect(-50, -50, 100, 100, alertBack, 1, 0)
		else
		    gfx.FillColor(255, 255, 255)
			gfx.Scale((alertScale ^ 4.0), 1)
			gfx.ImageRect(-50, -50, 100, 100, alertRBack, 1, 0)
		end
			
		gfx.Scale((1 / alertScale ^ 4.0), 1)
        gfx.BeginPath()

		if (customColors == true) then
			gfx.FillColor(math.min(r + 55, 255), math.min(g + 55, 255), math.min(b + 55, 255), 255)
			gfx.ImageRect(-50, -50, 100, 100, alertRs, ((fadeTimer + 0.05) * alertScale), 0)
			gfx.FillColor(255, 255, 255)
			gfx.ImageRect(-50, -50, 100, 100, alertRt, ((fadeTimer + 0.35) * alertScale), 0)
		else
			gfx.FillColor(255, 255, 255)
			gfx.ImageRect(-50, -50, 100, 100, alertR, ((fadeTimer + 0.3) * alertScale ^ 3.0), 0)
		end

        gfx.Restore()
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
    gfx.FillColor(255, 255, 255, math.floor(255 * math.min(outroTimer, 1)))
    gfx.LoadSkinFont("slant.ttf")
    gfx.FontSize(70)
	
	local clearText = gfx.CreateLabel(clearTexts[clearState], 70, 0)

	if portrait then
		gfx.DrawLabel(clearText, (desw / 2), (desh / 2) - 100, resx)
	else
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

laser_alert = function(isRight) 
    if isRight and alertTimers[2] < -1.5 then 
		alertTimers[2] = 1.5
    elseif alertTimers[1] < -1.5 then 
		alertTimers[1] = 1.5
    end
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
        local bannerWidth, bannerHeight = gfx.ImageSize(topFill)
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

        local size_big = 36
        local size_small = 26
        local size_name = 26

        if u.id == gameplay.user_id then
            size_big = 44
            size_small = 30
            size_name = 36
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