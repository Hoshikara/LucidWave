easing = require("easing")

gfx.LoadSkinFont("arial.ttf")

game.LoadSkinSample("cursor_song")
game.LoadSkinSample("cursor_difficulty")
game.LoadSkinSample("woosh")

local resx, resy = game.GetResolution()

local portrait = resy > resx
local landscape = resx > resy

-- GRADES
local noGrade = Image.skin("song_select/grade/nograde.png")
local grades = {
  {["min"] = 9900000, ["image"] = Image.skin("song_select/grade/s.png")},
  {["min"] = 9800000, ["image"] = Image.skin("song_select/grade/aaap.png")},
  {["min"] = 9700000, ["image"] = Image.skin("song_select/grade/aaa.png")},
  {["min"] = 9500000, ["image"] = Image.skin("song_select/grade/aap.png")},
  {["min"] = 9300000, ["image"] = Image.skin("song_select/grade/aa.png")},
  {["min"] = 9000000, ["image"] = Image.skin("song_select/grade/ap.png")},
  {["min"] = 8700000, ["image"] = Image.skin("song_select/grade/a.png")},
  {["min"] = 7500000, ["image"] = Image.skin("song_select/grade/b.png")},
  {["min"] = 6500000, ["image"] = Image.skin("song_select/grade/c.png")},
  {["min"] =       0, ["image"] = Image.skin("song_select/grade/d.png")},
}

function lookup_grade_image(difficulty)
  local gradeImage = noGrade
  if difficulty.scores[1] ~= nil then
		local highScore = difficulty.scores[1]
    for i, v in ipairs(grades) do
      if highScore.score >= v.min then
        gradeImage = v.image
        break
      end
    end
  end
  return { image = gradeImage, flicker = (gradeImage == grades[1].image) }
end

-- MEDALS
local noMedal = Image.skin("song_select/medal/nomedal.png")
local medals = {
  Image.skin("song_select/medal/played.png"),
  Image.skin("song_select/medal/clear.png"),
  Image.skin("song_select/medal/hard.png"),
  Image.skin("song_select/medal/uc.png"),
  Image.skin("song_select/medal/puc.png")
}

function lookup_medal_image(difficulty)
  local medalImage = noMedal
  local flicker = false
  if difficulty.scores[1] ~= nil then
    if difficulty.topBadge ~= 0 then
      medalImage = medals[difficulty.topBadge]
      if difficulty.topBadge >= 3 then -- hard
        flicker = true
      end
    end
  end
  return { image = medalImage, flicker = flicker }
end

-- LOOKUP DIFFICULTY
function lookup_difficulty(diffs, diff)
  local diffIndex = nil
  for i, v in ipairs(diffs) do
    if v.difficulty + 1 == diff then
      diffIndex = i
    end
  end
  local difficulty = nil
  if diffIndex ~= nil then
    difficulty = diffs[diffIndex]
  end
  return difficulty
end

-- JACKETCACHE CLASS
--------------------
JacketCache = {}
JacketCache.new = function()
  local this = {
    cache = {},
    images = {
      loading = Image.skin("song_select/jacket_loading.png"),
    }
  }
  setmetatable(this, {__index = JacketCache})
  return this
end

JacketCache.get = function(this, path)
  local jacket = this.cache[path]
  if not jacket or jacket == this.images.loading.image then
    jacket = gfx.LoadImageJob(path, this.images.loading.image)
    this.cache[path] = jacket
  end
  return Image.wrap(jacket)
end

-- SONGDATA CLASS
-----------------
SongData = {}
SongData.new = function(jacketCache)
  local this = {
    selectedIndex = 1,
    selectedDifficulty = 0,
    memo = Memo.new(),
    jacketCache = jacketCache,
    images = {
      dataBg = Image.skin("song_select/data_bg_v.png"),
      cursor = Image.skin("song_select/level_cursor.png"),
      none = Image.skin("song_select/level/none.png"),
      difficulties = {
        Image.skin("song_select/level/novice.png"),
        Image.skin("song_select/level/advanced.png"),
        Image.skin("song_select/level/exhaust.png"),
        Image.skin("song_select/level/maximum.png")
      },
    }
  }

  setmetatable(this, {__index = SongData})
  return this
end

SongData.render = function(this, deltaTime)
  local song = songwheel.songs[this.selectedIndex]
  if not song then return end

  -- LOOKUP DIFFICULTY
  local diff = song.difficulties[this.selectedDifficulty]
  if diff == nil then diff = song.difficulties[1] end

  -- BACKGROUND
  this.images.dataBg:draw({ x = 356, y = 200, w = 712, h = 349 })


  -- JACKET
  local jacket = this.jacketCache:get(diff.jacketPath)
  jacket:draw({ x = 18, y = 42, w = 192, h = 192, anchor_h = Image.ANCHOR_LEFT, anchor_v = Image.ANCHOR_TOP })

  gfx.BeginPath()
  gfx.FillColor(0, 0, 0, 0)
  gfx.StrokeColor(0, 0, 0, 255)
  gfx.StrokeWidth(2)
  gfx.Rect(19, 43, 190, 190)
  gfx.Stroke()
  gfx.Fill()

  -- TITLE
  local title = this.memo:memoize(string.format("title_%s", song.id), function ()
    gfx.LoadSkinFont("arial.ttf")
    return gfx.CreateLabel(song.title, 24, 0)
  end)
  this:draw_title_artist(title, 232, 96, 460)

  -- ARTIST
  local artist = this.memo:memoize(string.format("artist_%s", song.id), function ()
    gfx.LoadSkinFont("arial.ttf")
    return gfx.CreateLabel(song.artist, 18, 0)
  end)
  this:draw_title_artist(artist, 232, 135, 390)

  -- EFFECTOR
  local effector = this.memo:memoize(string.format("eff_%s_%s", song.id, diff.id), function ()
    gfx.LoadSkinFont("arial.ttf")
    return gfx.CreateLabel(diff.effector, 14, 0)
  end)
  gfx.TextAlign(gfx.TEXT_ALIGN_LEFT + gfx.TEXT_ALIGN_BASELINE)
  gfx.FillColor(255, 255, 255, 255)
  gfx.DrawLabel(effector, 340, 46, 350)

  -- ILLUSTRATOR
  if diff.illustrator then
    local illustrator = this.memo:memoize(string.format("ill_%s_%s", song.id, diff.id), function ()
      gfx.LoadSkinFont("arial.ttf")
      return gfx.CreateLabel(diff.illustrator, 14, 0)
    end)
    gfx.TextAlign(gfx.TEXT_ALIGN_LEFT + gfx.TEXT_ALIGN_BASELINE)
    gfx.FillColor(255, 255, 255, 255)
    gfx.DrawLabel(illustrator, 340, 69, 350)
  end

  -- BPM
  gfx.LoadSkinFont("avantgarde.ttf")
  gfx.FontSize(20)
  gfx.TextAlign(gfx.TEXT_ALIGN_LEFT + gfx.TEXT_ALIGN_BASELINE)
  gfx.FillColor(255, 255, 255, 255)
  gfx.Text(song.bpm, 278, 187)

  -- HI-SCORE
  local hiScore = diff.scores[1]

  if hiScore then
	gfx.LoadSkinFont("avantgarde.ttf")
    local scoreText = string.format("%08d", hiScore.score)

    gfx.FontSize(20)
    gfx.TextAlign(gfx.TEXT_ALIGN_LEFT + gfx.TEXT_ALIGN_BASELINE)
    gfx.FillColor(255, 255, 255, 255)
    gfx.Text(string.sub(scoreText, 1, 4), 474, 187)

	gfx.FontSize(16)
    gfx.TextAlign(gfx.TEXT_ALIGN_LEFT + gfx.TEXT_ALIGN_BASELINE)
    gfx.FillColor(255, 255, 255, 255)
    gfx.Text(string.sub(scoreText, -4), 520, 187) 
  end

  -- GRADE AND MEDAL
  gfx.Scale(1*0.49, 1*0.49)
  local grade = lookup_grade_image(diff)
  grade.image:draw({ x = 1293, y = 365, alpha = grade.flicker and glowState and 0.9 or 1 })
  local medal = lookup_medal_image(diff)
  medal.image:draw({ x = 1389, y = 365, alpha = medal.flicker and glowState and 0.9 or 1 })
  gfx.Scale(1/0.49, 1/0.49)

  for i = 1, 4 do
    local d = lookup_difficulty(song.difficulties, i)
    this:draw_difficulty(i - 1, d, jacket)
  end

  this:draw_cursor(diff.difficulty)
end

SongData.draw_title_artist = function(this, label, x, y, maxWidth)
  gfx.TextAlign(gfx.TEXT_ALIGN_LEFT + gfx.TEXT_ALIGN_BASELINE)
  gfx.FillColor(55, 55, 55, 105)
  gfx.DrawLabel(label, x + 1, y + 1, maxWidth)
  gfx.FillColor(55, 55, 55, 255)
  gfx.DrawLabel(label, x, y, maxWidth)
end

SongData.draw_difficulty = function(this, index, diff, jacket)
  local x = 344
  local y = 280

  -- JACKET ICON
  local jacket = this.jacketCache.images.loading
  if diff ~= nil then jacket = this.jacketCache:get(diff.jacketPath) end
  jacket:draw({ x = 18 + index * 48, y = 239, w = 48, h = 48, anchor_h = Image.ANCHOR_LEFT, anchor_v = Image.ANCHOR_TOP })

  gfx.BeginPath()
  gfx.FillColor(0, 0, 0, 0)
  gfx.StrokeColor(0, 0, 0, 255)
  gfx.StrokeWidth(2)
  gfx.Rect(19, 239, 190, 48)
  gfx.Stroke()
  gfx.Fill()

  if diff == nil then
	gfx.Scale(1*0.25, 1*0.25)
    this.images.none:draw({ x = 1325 + index * 328.5, y = 1055 })
	gfx.Scale(1/0.25, 1/0.25)
  else

    -- DIFFICULTY PLATE
	gfx.Scale(1*0.25, 1*0.25)
    this.images.difficulties[diff.difficulty + 1]:draw({ x = 1325 + index * 328.5, y = 1055 })
	gfx.Scale(1/0.25, 1/0.25)

    -- DIFFICULTY LEVEL
    local levelText = string.format("%02d", diff.level)
	gfx.TextAlign(gfx.TEXT_ALIGN_CENTER, gfx.TEXT_ALIGN_MIDDLE)
	gfx.BeginPath()
	gfx.LoadSkinFont("slant.ttf")
	gfx.FontSize(36)
	gfx.FillColor(245, 65, 125)
	gfx.Text(levelText, 332.5 + index * 81.2, 269.8)
	gfx.FillColor(55, 255, 255)
	gfx.Text(levelText, 333.3 + index * 81.2, 268)
	gfx.FillColor(255, 255, 255)
	gfx.Text(levelText, 332.5 + index * 81.2, 268)
  end

end

SongData.draw_cursor = function(this, index)
  local x = 344
  local y = 280

  -- CURSOR
  gfx.Scale(1*0.25, 1*0.25)
  this.images.cursor:draw({ x = 1325 + index * 328.5, y = 1035 })
  gfx.Scale(1/0.25, 1/0.25)
end

SongData.set_index = function(this, newIndex)
  this.selectedIndex = newIndex
end

SongData.set_difficulty = function(this, newDiff)
  this.selectedDifficulty = newDiff
end


-- SONG TABLE CLASS
------------------
SongTable = {}
SongTable.new = function(jacketCache)
  local this = {
    cols = 3,
    rows = 3,
    selectedIndex = 1,
    selectedDifficulty = 0,
    rowOffset = 0, -- song index offset of top-left song in page
    cursorPos = 0, -- cursor position in page [0..cols * rows)
    displayCursorPos = 0,
    cursorAnim = 0,
    cursorAnimTotal = 0.1,
    memo = Memo.new(),
    jacketCache = jacketCache,
    images = {
      cursor = Image.skin("song_select/cursor.png"),
      cursorDiamond = Image.skin("song_select/cursor_diamond.png"),
      cursorDiamondWire = Image.skin("song_select/cursor_diamond_wire.png"),
      plates = {
        Image.skin("song_select/plate/novice.png"),
        Image.skin("song_select/plate/advanced.png"),
        Image.skin("song_select/plate/exhaust.png"),
        Image.skin("song_select/plate/maximum.png")
      }
    }
  }
  setmetatable(this, {__index = SongTable})
  return this
end

SongTable.calc_cursor_point = function(this, pos)
  local col = pos % this.cols
  local row = math.floor((pos) / this.cols)
  local x = 138 + col * (this.images.cursor.w/4) --138
  local y = 478 + row * (this.images.cursor.h/4) --478
  return x, y
end

SongTable.set_index = function(this, newIndex)
  if newIndex ~= this.selectedIndex then
    game.PlaySample("cursor_song")
  end

  local delta = newIndex - this.selectedIndex
  if delta < -1 or delta > 1 then
    local newOffset = newIndex - 1
    this.rowOffset = math.floor((newIndex - 1) / this.cols) * this.cols
    this.cursorPos = (newIndex - 1) - this.rowOffset
    this.displayCursorPos = this.cursorPos
  else
    local newCursorPos = this.cursorPos + delta

    if newCursorPos < 0 then
      -- scroll up
      this.rowOffset = this.rowOffset - this.cols
      if this.rowOffset < 0 then
      end
      newCursorPos = newCursorPos + this.cols
    elseif newCursorPos >= this.cols * this.rows then
      -- scroll down
      this.rowOffset = this.rowOffset + this.cols
      newCursorPos = newCursorPos - this.cols
    else
      -- no scroll, move cursor in page
    end
    if this.cursorAnim > 0 then
      this.displayCursorPos = easing.outQuad(0.5 - this.cursorAnim, this.displayCursorPos, this.cursorPos - this.displayCursorPos, 0.5)
    end
    this.cursorPos = newCursorPos
    this.cursorAnim = this.cursorAnimTotal
  end
  this.selectedIndex = newIndex
end

SongTable.set_difficulty = function(this, newDiff)
  if newDiff ~= this.selectedDifficulty then
    game.PlaySample("cursor_difficulty")
  end
  this.selectedDifficulty = newDiff
end

SongTable.render = function(this, deltaTime)
  this:draw_songs()
  this:draw_cursor(deltaTime)
end

SongTable.draw_songs = function(this)
  for i = 1, this.cols * this.rows do
    if this.rowOffset + i <= #songwheel.songs then
      this:draw_song(i - 1, this.rowOffset + i)
    end
  end
end

-- SONG PLATE
SongTable.draw_song = function(this, pos, songIndex)
  local song = songwheel.songs[songIndex]
  if not song then return end

  -- DIFFICULTY LOOKUP
  local diff = song.difficulties[this.selectedDifficulty]
  if diff == nil then diff = song.difficulties[1] end

  local x, y = this:calc_cursor_point(pos)
  x = x + 20
  y = y + 16

	this.images.plates[diff.difficulty + 1]:draw({ x = x - 25, y  = y - 25, w = 195, h = 181})


  -- JACKET
  local jacket = this.jacketCache:get(diff.jacketPath)
  jacket:draw({ x = x - 44, y = y - 26, w = 122, h = 122 })

	-- GRADE AND MEDAL
	gfx.Scale(1*0.49, 1*0.49)
  local grade = lookup_grade_image(diff)
  grade.image:draw({ x = (x + 42.8)*(1/0.49), y = (y - 70)*(1/0.49), alpha = grade.flicker and glowState and 0.9 or 1 })


  local medal = lookup_medal_image(diff)
  medal.image:draw({ x = (x + 42.8)*(1/0.49), y = (y - 33)*(1/0.49), alpha = medal.flicker and glowState and 0.9 or 1 })
  gfx.Scale(1/0.49, 1/0.49)


  -- TITLE
  local title = this.memo:memoize(string.format("title_%s", song.id), function ()
    gfx.LoadSkinFont("arial.ttf")
    return gfx.CreateLabel(song.title, 12, 0)
  end)
  gfx.FillColor(0, 0, 0, 255)
  gfx.TextAlign(gfx.TEXT_ALIGN_CENTER + gfx.TEXT_ALIGN_BASELINE)
  gfx.DrawLabel(title, x - 22, y + 41, 170)


  -- DIFFICULTY LEVEL
  local levelText1 = string.format("%02d", diff.level)

  if diff.level > 10 then
	  gfx.BeginPath()
	  gfx.LoadSkinFont("slant.ttf")
	  gfx.FontSize(24)
	  gfx.FillColor(245, 65, 125)
	  gfx.Text(levelText1, x + 41.5, y+17.8)
	  gfx.FillColor(55, 255, 255)
	  gfx.Text(levelText1, x + 42.3, y+16)
	  gfx.FillColor(255, 255, 255)
	  gfx.Text(levelText1, x + 41.5, y+16)
  else  
	  gfx.BeginPath()
	  gfx.LoadSkinFont("slant.ttf")
	  gfx.FontSize(24)
	  gfx.FillColor(245, 65, 125)
	  gfx.Text(levelText1, x + 43.5, y+17.8)
	  gfx.FillColor(55, 255, 255)
	  gfx.Text(levelText1, x + 44.3, y+16)
	  gfx.FillColor(255, 255, 255)
	  gfx.Text(levelText1, x + 43.5, y+16)
  end
end

-- SONG CURSOR
SongTable.draw_cursor = function(this, deltaTime)
  gfx.Save()

  local pos = this.displayCursorPos
  if this.cursorAnim > 0 then
    this.cursorAnim = this.cursorAnim - deltaTime
    if this.cursorAnim <= 0 then
      this.displayCursorPos = this.cursorPos
      pos = this.cursorPos
    else
      pos = easing.outQuad(this.cursorAnimTotal - this.cursorAnim, this.displayCursorPos, this.cursorPos - this.displayCursorPos, this.cursorAnimTotal)
    end
  end

  local x, y = this:calc_cursor_point(pos)
  gfx.FillColor(255, 255, 255)

  local t = currentTime % 1

  -- SCROLLING TEXT
  gfx.Scissor(
    x - this.images.cursor.w / 2, y - (this.images.cursor.h - 30) / 2,
    this.images.cursor.w, this.images.cursor.h - 30)
  local offset = (currentTime * 50) % 290
  local alpha = glowState and 0.8 or 1

  gfx.ResetScissor()

  -- DIAMOND WIREFRAME
  local h = (this.images.cursorDiamondWire.h * 1.5) * easing.outQuad(t * 2, 0, 1, 1)
  this.images.cursorDiamondWire:draw({ x = x, y = y, w = this.images.cursorDiamondWire.w * 1.5, h = h, alpha = 0.5 })

  -- GHOST CURSOR
  alpha = easing.outSine(t, 1, -1, 1)
  h = this.images.cursor.h * easing.outSine(t, 0, 1, 1)
  gfx.Scale(1*0.25, 1*0.25)
  this.images.cursor:draw({ x = x*4, y = y*4, h = h, alpha = alpha })

  -- CURSOR
  this.images.cursor:draw({ x = x*4, y = y*4, alpha = glowState and 0.8 or 1 })
  gfx.Scale(1/0.25, 1/0.25)

  -- DIAMOND KNOT
  gfx.GlobalCompositeOperation(gfx.BLEND_OP_LIGHTER)
  this.images.cursorDiamond:draw({ x = x + 100, y = y, alpha = 1 })
  this.images.cursorDiamond:draw({ x = x - 100, y = y, alpha = 1 })

  local s = this.images.cursorDiamond.w / 1.5
  this.images.cursorDiamond:draw({ x = x + 90 + easing.outQuad(t, 0, -4, 0.5), y = y, w = s, h = s, alpha = 0.5 })
  this.images.cursorDiamond:draw({ x = x - 90 - easing.outQuad(t, 0, -4, 0.5), y = y, w = s, h = s, alpha = 0.5 })

  gfx.Restore()
end


-- MAIN
local jacketCache = JacketCache.new()
local songData = SongData.new(jacketCache)
local songTable = SongTable.new(jacketCache)

glowState = false
currentTime = 0

-- CALLBACK
get_page_size = function()
  return 12
end

local searchIndex = 1
local searchSound = 1
local searchText = gfx.CreateLabel("", 5, 0)

-- SONG SEARCH
soffset = 0
draw_search = function(x,y,w,h)
 
  gfx.BeginPath()
  
  local xpos = x + (searchIndex + soffset)*w
  gfx.LoadSkinFont("arial.ttf");
  gfx.UpdateLabel(searchText, string.format("SEARCH: %s",songwheel.searchText), 14, 0)
  
  gfx.BeginPath()
  gfx.TextAlign(gfx.TEXT_ALIGN_LEFT + gfx.TEXT_ALIGN_MIDDLE)
  gfx.FillColor(245, 65, 125)

  if searchIndex ~= (songwheel.searchInputActive and 0 or 1) then
      gfx.BeginPath()
	  gfx.FillColor(0, 0, 0, 255)
	  gfx.RoundedRect(225, 198.3, 382.2, 20, 10)
	  gfx.Fill()
	  gfx.FillColor(245, 65, 125)
  end
  
  if searchSound ~= (songwheel.searchInputActive and 0 or 1) then
      game.PlaySample("woosh")
  end
  searchSound = songwheel.searchInputActive and 0 or 1
  gfx.DrawLabel(searchText, 270, 207, w-20)
end

-- CALLBACK
render = function(deltaTime)
  currentTime = currentTime + deltaTime

  if ((math.floor(currentTime * 1000) % 100) < 50) then
    glowState = false
  else
    glowState = true
  end

  gfx.ResetTransform()

  local desw = 720
  local desh = 1280
  local scale = resy / desh

  local xshift = (resx - desw * scale) / 2
  local yshift = (resy - desh * scale) / 2

  gfx.Translate(xshift, yshift)
  gfx.Scale(scale, scale)

  songData:render(deltaTime)
  songTable:render(deltaTime)

  soffset = soffset * 0.8
  draw_search(120, 5, 600, 40)

	if totalForce then
		gfx.BeginPath()
		gfx.LoadSkinFont("russellsquare.ttf")
		gfx.FillColor(255,255,255)
		gfx.FontSize(16)
		gfx.TextAlign(gfx.TEXT_ALIGN_RIGHT + gfx.TEXT_ALIGN_BOTTOM)
		local forceText1 = string.format(string.sub(totalForce, 0, 2) .. ".")
		gfx.Text(forceText1, desw-56, 303)
		gfx.FontSize(13)
		local forceText1 = string.format(string.sub(totalForce, -2))
		gfx.Text(forceText1, desw-41, 302.5)
	end
gfx.LoadSkinFont("arial.ttf")
end

-- CALLBACK
set_index = function(newIndex)
  songData:set_index(newIndex)
  songTable:set_index(newIndex)
end

-- CALLBACK
set_diff = function(newDiff)
  songData:set_difficulty(newDiff)
  songTable:set_difficulty(newDiff)
end

-- FORCE CALCULATION
--------------------
totalForce = nil

local badgeRates = {
	0.5,  -- Played
	1.0,  -- Cleared
	1.02, -- Hard clear
	1.04, -- UC
	1.1   -- PUC
}

local gradeRates = {
	{["min"] = 9900000, ["rate"] = 1.05}, -- S
	{["min"] = 9800000, ["rate"] = 1.02}, -- AAA+
	{["min"] = 9700000, ["rate"] = 1},    -- AAA
	{["min"] = 9500000, ["rate"] = 0.97}, -- AA+
	{["min"] = 9300000, ["rate"] = 0.94}, -- AA
	{["min"] = 9000000, ["rate"] = 0.91}, -- A+
	{["min"] = 8700000, ["rate"] = 0.88}, -- A
	{["min"] = 7500000, ["rate"] = 0.85}, -- B
	{["min"] = 6500000, ["rate"] = 0.82}, -- C
	{["min"] =       0, ["rate"] = 0.8}   -- D
}

calculate_force = function(diff)
	if #diff.scores < 1 then
		return 0
	end
	local score = diff.scores[1]
	local badgeRate = badgeRates[diff.topBadge]
	local gradeRate
    for i, v in ipairs(gradeRates) do
      if score.score >= v.min then
        gradeRate = v.rate
		break
      end
    end
	return math.floor((diff.level * 2) * (score.score / 10000000) * gradeRate * badgeRate) / 100
end

-- CALLBACK
songs_changed = function(withAll)
	if not withAll then return end

  local diffsById = {}
	local diffs = {}
	for i = 1, #songwheel.allSongs do
		local song = songwheel.allSongs[i]
		for j = 1, #song.difficulties do
			local diff = song.difficulties[j]
			diff.force = calculate_force(diff)
      table.insert(diffs, diff)
      diffsById[diff.id] = diff
		end
	end

  table.sort(diffs, function (l, r)
		return l.force > r.force
	end)

  totalForce = 0
	for i = 1, 50 do
		if diffs[i] then
      totalForce = totalForce + diffs[i].force
      diffs[i].forceInTotal = true
		end
  end

  for i = 1, #songwheel.songs do
    local song = songwheel.songs[i]
    for j = 1, #song.difficulties do
      local diff = song.difficulties[j]
      local newDiff = diffsById[diff.id]
      song.difficulties[j] = newDiff
    end
  end
end
