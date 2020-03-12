easing = require('easing');

game.LoadSkinSample('cursor_song');
game.LoadSkinSample('cusor_difficulty');
game.LoadSkinSample('woosh');

-- local resx;
-- local resy;
-- local portrait;
-- local landscape;
-- local desw;
-- local desh;
-- local scale;

-- ResetLayoutInformation = function()
--   resx, resy = game.GetResolution();
--   portrait = resy > resx;
--   landscape = resx > resy;
--   desw = (portrait and 720) or 1280;
--   desh = desw * (resy / resx);
--   scale = resx / desw;
-- end

local resx, resy = game.GetResolution();
local portrait = resy > resx;
local desw = (portrait and 720) or 1280;
local desh = desw * (resy / resx);
local scale = resx / desw;

drawAberratedText = function(text, x, y, offset)
  gfx.FillColor(245, 65, 125);
  gfx.Text(text, x, (y + offset));
  gfx.FillColor(55, 255, 255);
  gfx.Text(text, (x + offset), y));
  gfx.FillColor(255, 255, 255)
  gfx.Text(text, x, y);
end

local noGrade = Image.new('song_select/grades/no_grade.png');
local grades = {
  {['min'] = 9900000, ['image'] = Image.new('song_select/grades/S.png')},
  {['min'] = 9800000, ['image'] = Image.new('song_select/grades/AAA+.png')},
  {['min'] = 9700000, ['image'] = Image.new('song_select/grades/AAA.png')},
  {['min'] = 9500000, ['image'] = Image.new('song_select/grades/AA+.png')},
  {['min'] = 9300000, ['image'] = Image.new('song_select/grades/AA.png')},
  {['min'] = 9000000, ['image'] = Image.new('song_select/grades/A+.png')},
  {['min'] = 8700000, ['image'] = Image.new('song_select/grades/A.png')},
  {['min'] = 7500000, ['image'] = Image.new('song_select/grades/B.png')},
  {['min'] = 6500000, ['image'] = Image.new('song_select/grades/C.png')},
  {['min'] =       0, ['image'] = Image.new('song_select/grades/D.png')}
};

findGradeImage = function(difficulty)
  local gradeImage = noGrade;
  
  if (difficulty.scores[1] ~= nil) then
    local highScore = difficulty.scores[1];

    for i, v in ipairs(grades) do
      if (highScore.score >= v.min) then
        gradeImage = v.image;
        break;
      end
    end
  end

  return { 
    image = gradeImage, 
    flicker = (gradeImage = grades[1].image) 
  };
end

local noMedal = Image.new('song_select/medals/no_medal.png');
local medals = {
  Image.new('song_select/medals/hc.png'),
  Image.new('song_select/medals/c.png'),
  Image.new('song_select/medals/hc.png'),
  Image.new('song_select/medals/uc.png'),
  Image.new('song_select/medals/puc.png')
}

findMedalImage = function(difficulty)
  local medalImage = noMedal;
  local flicker = false;

  if (difficulty.scores[1] ~= nil) then
    if (difficulty.topBadge ~= 0) then
      medalImage = medals[difficulty.topBadge];

      if (difficulty.topBadge >= 3) then
        flicker = true;
      end
    end
  end

  return {
    image = medalImage,
    flicker = flicker
  };
end

findDifficulty = function(diffs, diff)
  local diffIndex = nil;
  local difficulty = nil;

  for i, v in ipairs(diffs) do
    if ((v.difficulty + 1) == diff) then
      diffIndex = i;
    end
  end

  if (diffIndex ~= nil) then
    difficulty = diffs[diffIndex];
  end

  return difficulty;
end

-- JacketCache Class
JacketCache = {};

JacketCache.new = function()
  local this = {
    cache = {},
    images = {
      jacketLoading = Image.new('song_select/jacket_loading.png')
    }
  };

  setmetatable(this, { __index = JacketCache });

  return this;
end

JacketCache.get = function(this, path)
  local jacket = this.cache[path];

  if ((not jacket) or (jacket == this.images.jacketLoading.image)) then
    jacket = gfx.LoadImageJob(path, this.images.jacketLoading.image);
    this.cache[path] = jacket;
  end

  return Image.wrapper(jacket);
end

-- SongData Class --
-- Use to draw information and metadata for the selected song
SongData = {};

SongData.new = function(jacketCache)
  local this = {
    memo = Memo.new(),
    selectedIndex = 1,
    selectedDifficulty = 0,
    jacketCache = jacketCache,
    images = {
      songPanelPT = Image.new('song_select/song_panel_pt.png'),
      songPanelLS = Image.new('song_select/song_panel_ls.png'),
      noDiff = Image.new('song_select/difficulties/none.png'),
      difficulties = {
        Image.new('song_select/difficulties/novice.png'),
        Image.new('song_select/difficulties/advanced.png'),
        Image.new('song_select/difficulties/exhaust.png'),
        Image.new('song_select/difficulties/maximum.png')
      }
    }
  };

  setmetatable(this, { __index = SongData });

  return this;
end

SongData.setIndex = function(this, index)
  this.selectedIndex = index;
end

SongData.setDifficulty = function(this, difficulty)
  this.selectedDifficulty = difficulty;
end

SongData.drawTitleArtist = function(this, label, x, y, maxWidth)
  gfx.LoadSkinFont('arial.ttf');
  gfx.TextAlign(gfx.TEXT_ALIGN_LEFT + gfx.TEXT_ALIGN_MIDDLE);
  gfx.FillColor(55, 55, 55, 105);
  gfx.DrawLabel(label, (x + 1), (y + 1), maxWidth);
  gfx.FillColor(55, 55, 55, 255);
  gfx.DrawLabel(label, x, y, maxWidth);
end

SongData.drawEffectorIllustrator = function(this, label, x, y, maxWidth)
  gfx.LoadSkinFont('arial.ttf');
  gfx.TextAlign(gfx.TEXT_ALIGN_LEFT + gfx.TEXT_ALIGN_MIDDLE);
  gfx.FillColor(255, 255, 255, 255);
  gfx.DrawLabel(label, x, y, maxWidth);
end

SongData.drawBPM = function(this, bpm, x, y)
  gfx.LoadSkinFont('avantgarde.ttf');
  gfx.TextAlign(gfx.TEXT_ALIGN_LEFT + gfx.TEXT_ALIGN_MIDDLE);
  gfx.FontSize(20);
  gfx.FillColor(255, 255, 255, 255);
  gfx.Text(bpm, x, y);
end

SongData.drawHighScore = function(this, score, x, y)
  local scoreString = string.format('%08d', score);

  gfx.LoadSkinFont('avantgarde.ttf');
  gfx.TextAlign(gfx.TEXT_ALIGN_LEFT + gfx.TEXT_ALIGN_MIDDLE);
  gfx.FillColor(255, 255, 255, 255);
  gfx.FontSize(20)
  gfx.Text(string.sub(scoreString, 1, 4), x, y);
  gfx.FontSize(16)
  gfx.Text(string.sub(scoreString, -4), (x + 50), y);
end

SongData.drawDifficulty = function(this, index, diff, jacket)
  local x = 344;
  local y = 280;
  local jacket = this.jacketCache.images.jacketLoading;

  if (diff ~= nil) then
    jacket = this.jacketCache:get(diff.jacketPath);
  end

  jacket:draw({
    x = 18 + (index * 48),
    y = 239,
    w = 48,
    h = 48,
  });

  gfx.BeginPath();
  gfx.FillColor(0, 0, 0, 0);
  gfx.StrokeColor(0, 0, 0, 255);
  gfx.StrokeWidth(2);
  gfx.Rect(19, 239, 190, 48);
  gfx.Stroke();
  gfx.Fill();

  -- TODO: translate each plate and text instead, will keep the plate and text aligned
  if (diff == nil) then
    this.images.none:draw({
      x = 1325 + (index * 328.5),
      y = 1055,
      s = 0.25
    });
  end

  this.images.difficulties[diff.difficulty + 1]:draw({
    x = 1325 + (index * 328.5),
    y = 1055,
    s = 0.25
  });

    -- TODO: use drawAberratedText function instead
  local level = string.format('%02d', diff.level);
  gfx.LoadSkinFont('slant.ttf');
  gfx.TextAlign(gfx.TEXT_ALIGN_CENTER, gfx.TEXT_ALIGN_MIDDLE);
  gfx.BeginPath();
  gfx.FontSize(36);
	gfx.FillColor(245, 65, 125);
	gfx.Text(level, 332.5 + index * 81.2, 269.8);
	gfx.FillColor(55, 255, 255);
	gfx.Text(level, 333.3 + index * 81.2, 268);
	gfx.FillColor(255, 255, 255);
	gfx.Text(level, 332.5 + index * 81.2, 268);
end

SongData.drawCursor = function(this, index)
  this.images.cursor:draw({
    x = 1325 + (index * 328.5),
    y = 1035
  });
end

SongData.render = function(this, deltaTime)
  local song = songwheel.songs[this.selectedIndex];

  if (not song) then
    return;
  end

  local diff = song.difficulties[this.selectedDifficulty];

  if (diff == nil) then
    diff = song.difficulties[1];
  end

  if (portrait) then
    this.images.songPanelPT:draw({ 
      x = 356, 
      y = 200, 
      w = 712,
      h = 349
    });
  else
    this.images.songPanelLS:draw({ 
      x = 356, 
      y = 200, 
      w = 712,
      h = 349
    });
  end

  local jacket = this.jacketCache:get(diff.jacketPath);

  jacket:draw({
    x = (portrait and 18) or 18,
    y = (portrait and 42) or 42,
    w = (portrait and 192) or 192,
    h = (portrait and 192) or 192,
  });
  
  -- TODO: remove this stroke, add to song panel image instead
  if (portrait) then
    gfx.BeginPath();
    gfx.FillColor(0, 0, 0, 0);
    gfx.StrokeColor(0, 0, 0, 255);
    gfx.StrokeWidth(2);
    gfx.Rect(19, 43, 190, 190);
    gfx.Stroke();
    gfx.Fill();
  end

  local title = this.memo:memoize(
    string.format('title_%s', song.id),
    function()
      return gfx.CreateLabel(song.title, 24, 0);
    end
  );

  this:drawTitleArtist(
    title,
    (portrait and 232) or 232,
    (portrait and 96) or 96,
    460
  );

  local artist = this.memo:memoize(
    string.format('artist_%s', song.artist),
    function()
      return gfx.CreateLabel(song.artist, 18, 0);
    end
  );

  this:drawTitleArtist(
    artist,
    (portrait and 232) or 232,
    (portrait and 135) or 135,
    390
  );

  local effector = this.memo:memoize(
    string.format('eff_%s_%s', song.id, diff.id),
    function()
      return gfx.CreateLabel(diff.effector, 14, 0);
    end
  );

  this:drawEffectorIllustrator(
    effector,
    (portrait and 340) or 340,
    (portrait and 46) or 46,
    350
  )

  if (diff.illustrator) then
    local illustrator = this.memo:memoize(
      string.format('ill_%s_%s', song,id, diff.id),
      function()
        return gfx.CreateLabel(diff.illustrator, 14, 0);
      end
    );

    this:drawEffectorIllustrator(
      illustrator,
      (portrait and 340) or 340,
      (portrait and 69) or 69,
      350
    );
  end

  local highScore = diff.scores[1];

  if (highScore) then
    this:drawHighScore(
      highScore.score, 
      (portrait and 474) or 474, 
      (portrait and 187) or 187
    );
  end

  local grade = findGradeImage(diff);

  grade.image:draw({
    x = (portrait and 1293) or 1293,
    y = (portrait and 365) or 365,
    alpha = (grade.flicker and glowState and 0.9) or 1
  });

  local medal = findMedalImage(diff);

  medal.image.draw({
    x = (portrait and 1389) or 1389,
    y = (portrait and 365) or 365,
    alpha = (grade.flicker and glowState and 0.9) or 1
  });

  for i = 1, 4 do
    local d = findDifficulty(song.difficulties, i);
    this:drawDifficulty((i - 1), d, jacket);
  end

  this:drawCursor(difficulty);
end

SongTable = {};

SongTable.new = function(jacketCache)
  local this = {
    columns = 3,
    rows = 3,
    selectedIndex = 1,
    selectedDifficulty = 0,
    rowOffset = 0,
    cursorPos = 0,
    displayCursorPos = 0,
    cursorAnim = 0,
    cursorAnimTotal = 0.1,
    memo = Memo.new(),
    jacketCache = jacketCache,
    images = {
      cursor = Image.new('song_select/cursor.png'),
      cursorDiamond = Image.new('song_select/cursor_diamond.png'),
      cursorDiamondWire = Image.new('song_select/cursor_diamond_wire.png'),
      plates = {
        Image.skin('song_select/plates/novice.png'),
        Image.skin('song_select/plates/advanced.png'),
        Image.skin('song_select/plates/exhaust.png'),
        Image.skin('song_select/plates/maximum.png')
      }
    }
  };

  setmetatable(this, { __index = SongTable });

  return this;
end

SongTable.calculateCursorPos = function(this, pos)
  local column = pos % this.columns;
  local row = math.floor(pos / this.columns);
  local x = 138 + column * (this.images.cursor.w / 4);
  local y = 478 + row * (this.images.cursor.h / 4);

  return x, y;
end

SongTable.setIndex = function(this, index)
  if (index ~= this.selectedIndex) then
    game.PlaySample('cursor_song');
  end

  local delta = index - this.selectedIndex;

  if ((delta < -1) or (delta > 1)) then
    local offset = index - 1;

    this.rowOffset = math.floor((index - 1) / this.columns) * this.columns;
    this.cursorPos = (index - 1) - this.rowOffset;
    this.displayCursorPos = this.cursorPos;
  else
    local cursorPos = this.cursorPos + delta;
    
    cursorPos = cursorPos + this.columns;

    if (cursorPos >= (this.columns * this.rows)) then
      this.rowOffset = this.rowOffset + this.columns;
      cursorPos = cursorPos - this.columns;
    end

    if (this.cursorAnim > 0) then
      this.displayCursorPos = easing.outQuad(
        0.5 - this.cursorAnim,
        this.displayCursorPos,
        this.cursorPos - this.displayCursorPos,
        0.5
      );
    end

    this.cursorPos = cursorPos;
    this.cursorAnim = this.cursorAnimTotal;
  end

  this.selectedIndex = index;
end

SongTable.setDifficulty = function(this, diff)
  if (diff ~= this.selectedDifficulty) then
    game.PlaySample('cursor_difficulty');
  end

  this.selectedDifficulty = diff;
end

SongTable.drawSongs = function(this)
  for i = 1, (this.columns * this.rows) do
    if (this.rowOffset + i <= #songwheel.songs) then
      this:drawSong(i - 1, this.rowOffset + i);
    end
  end
end

SongTable.drawTitle = function(this, x, y, maxWidth)
  gfx.LoadSkinFont('arial.ttf');
  gfx.TextAlign(gfx.TEXT_ALIGN_CENTER + gfx.TEXT_ALIGN_MIDDLE);
  gfx.FillColor(0, 0, 0, 255);
  gfx.DrawLabel(label, (x - 22), (y + 41), maxWidth);
end

SongTable.drawLevel = function(this, level, x, y)
  gfx.BeginPath();
  gfx.TextAlign(gfx.TEXT_ALIGN_CENTER + gfx.TEXT_ALIGN_MIDDLE);
  gfx.FontSize(24);
  drawAberratedText(level, x, y, 0.8);
end

SongTable.drawCursor = function(this, deltaTime)
  gfx.Save();
  
  local pos = this.displayCursorPos;

  if (this.cursorAnim > 0) then
    this.cursorAnim = this.cursorAnim - deltaTime;

    if (this.cursorAnim <= 0) then
      this.displayCursorPos = this.cursorPos;
      pos = this.cursorPos;
    else
      pos = easing.outQuad(
        this.cursorAnimTotal - this.cursorAnim,
        this.displayCursorPos,
        this.cursorPos - this.displayCursorPos,
        this.cursorAnimTotal
      );
    end
  end

  local x, y = this:calculateCursorPos(pos);
  local t = currentTime % 1;
  local h = (this.images.cursorDiamondWire.h * 1.5) * easing.outQuad((t * 2), 0, 1, 1);
  
  this.images.cursorDiamondWire:draw(
    x = x,
    y = y,
    w = this.images.cursorDiamondWire.w * 1.5,
    h = h,
    alpha = 0.5
  );

  alpha = easing.outSine(t, 1, -1, 1);
  h = this.images.cursor.h * easing.outSine(t, 0, 1, 1);

  this.images.cursor:draw({
    x = x * 4,
    y = y * 4,
    h = h,
    alpha = alpha,
    s = 0.25
  });

  this.images.cursor:draw({
    x = x * 4,
    y = y * 4,
    alpha = (glowState and 0.8) or 1,
    s = 0.25
  });

  gfx.GlobalCompositeOperation(gfx.BLEND_OP_LIGHTER);

  this.images.cursorDiamond:draw({
    x = x + 100,
    y = y,
    alpha = 1
  });

  this.images.cursorDiamond:draw({
    x = x + 100,
    y = y,
    alpha = 1
  });

  local s = this.images.cursorDiamond.w / 1.5;

  this.images.cursorDiamond:draw({
    x = x + 90 + easing.outQuad(t, 0, -4, 0.5),
    y = y,
    w = s,
    h = s,
    alpha = 0.5
  });

  this.images.cursorDiamond:draw({
    x = x - 90 - easing.outQuad(t, 0, -4, 0.5),
    y = y,
    w = s,
    h = s,
    alpha = 0.5
  });

  gfx.Restore();
end

SongTable.drawSong = function(this, pos, index)
  local song = songwheel.songs[index];
  
  if (not song) then
    return;
  end

  local diff = song.difficulties.[this.selectedDifficulty];

  if (diff == nil) then
    diff = song.difficulties[1];
  end

  local x, y = this:calculateCursorPos(pos)

  x = x + 20;
  y = y + 16;

  local jacket = this.jacketCache:get(diff.jacketPath);
  
  jacket:draw({
    x = x - 44,
    y = y - 26,
    w = 122,
    h = 122
  });

  local grade = findGradeImage(diff);

  grade.image.draw({
    x = x + 42,
    y = y - 70,
    alpha = grade.flicker and glowState and 0.9 
  });

  local medal = findMedalImage(diff);

  local title = this.memo:memoize(
    string.format('title_%s', song.id),
    function()
      return gfx.CreateLabel(song.title, 12, 0)
    end
  );

  local level = string.format('%02d', diff.level);

  this:drawLevel(
    level,
    ((diff.level > 10) and (x + 41.5)) or 43.5,
    y + 16
  );
end

SongTable.render = function(this, deltaTime)
  this:drawSongs();
  this:drawCursor(deltaTime)
end

local jacketCache = JacketCache.new();
local songData = SongData.new(jacketCache);
local songTable = SongTable.new(jacketCache);
local searchIndex = 1;
local searchSound = 1;
local searchText = gfx.CreateLabel('', 5, 0);

glowState = false;
currentTime = 0;

getPageSize = function()
  return 12;
end

drawSearch = function(x, y, w, h)
  local xPos = x + searchIndex;

  gfx.LoadSkinFont('arial.ttf');

  gfx.BeginPath();
  gfx.UpdateLabel(
    searchText,
    string.format('SEARCH: %s', songwheel.searchText),
    14,
    0
  );

  gfx.BeginPath();
  gfx.TextAlign(gfx.TEXT_ALIGN_LEFT + gfx.TEXT_ALIGN_MIDDLE);
  gfx.FillColor()


  