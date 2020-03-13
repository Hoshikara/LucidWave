easing = require('easing');

game.LoadSkinSample('cursor_song');
game.LoadSkinSample('cursor_difficulty');
game.LoadSkinSample('woosh');

local resx;
local resy;
local portrait;
local desw;
local desh;
local scale;
local xShift;
local yShift;


ResetLayoutInformation = function()
  resx, resy = game.GetResolution();
  portrait = resy > resx;
  desw = (portrait and 720) or 1280;
  desh = desw * (resy / resx);
  scale = resx / desw;
  xShift = (resx - (desw * scale)) / 2;
  yShift = (resy - (desh * scale)) / 2;
end

drawAberratedText = function(text, x, y, offset)
  gfx.FillColor(245, 65, 125, 255);
  gfx.Text(text, x, (y + offset));
  gfx.FillColor(55, 255, 255, 255);
  gfx.Text(text, (x + offset), y);
  gfx.FillColor(255, 255, 255, 255)
  gfx.Text(text, x, y);
end

local noGrade = Image.new('song_select/grades/none.png');
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
    flicker = (gradeImage == grades[1].image)
  };
end

local noMedal = Image.new('song_select/medals/none.png');
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

-- SongData Class
SongData = {};

SongData.new = function(jacketCache)
  local this = {
    memo = Memo.new(),
    selectedIndex = 1,
    selectedDifficulty = 0,
    jacketCache = jacketCache,
    images = {
      cursor = Image.new('song_select/level_cursor.png'),
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
  gfx.BeginPath();
  gfx.TextAlign(gfx.TEXT_ALIGN_LEFT + gfx.TEXT_ALIGN_MIDDLE);
  gfx.FillColor(55, 55, 55, 105);
  gfx.DrawLabel(label, (x + 1), (y + 1), maxWidth);
  gfx.FillColor(55, 55, 55, 255);
  gfx.DrawLabel(label, x, y, maxWidth);
end

SongData.drawEffectorIllustrator = function(this, label, x, y, maxWidth)
  gfx.BeginPath();
  gfx.TextAlign(gfx.TEXT_ALIGN_LEFT + gfx.TEXT_ALIGN_MIDDLE);
  gfx.FillColor(255, 255, 255, 255);
  gfx.DrawLabel(label, x, y, maxWidth);
end

SongData.drawBPM = function(this, bpm, x, y)
  gfx.BeginPath();
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
  gfx.FontSize(15)
  gfx.Text(string.sub(scoreString, -4), (x + 48), y + 1);
end

SongData.drawDifficulty = function(this, index, diff, jacket)
  local jacket = this.jacketCache.images.jacketLoading;

  if (diff ~= nil) then
    jacket = this.jacketCache:get(diff.jacketPath);
  end

  if (portrait) then
    jacket:draw({
      x = 43 + (index * 47.5),
      y = 262,
      w = 47.5,
      h = 47.5,
    });

    gfx.BeginPath();
    gfx.FillColor(0, 0, 0, 0);
    gfx.StrokeColor(0, 0, 0, 255);
    gfx.StrokeWidth(2);
    gfx.Rect(19, 239, 190, 48);
    gfx.Stroke();
    gfx.Fill();
  else
    jacket:draw({
      x = 89,
      y = 94 + (index * 66.5),
      w = 66.5,
      h = 66.5,
    });

    gfx.BeginPath();
    gfx.FillColor(0, 0, 0, 0);
    gfx.StrokeColor(0, 0, 0, 255);
    gfx.StrokeWidth(2);
    gfx.Rect(56, 61, 67, 265);
    gfx.Stroke();
    gfx.Fill();
  end

  if (diff == nil) then
    this.images.noDiff:draw({
      x = (portrait and (332 + (index * 82))) or (160 + (index * 82)),
      y = (portrait and 261) or 564,
      s = 0.25
    });
  else
    this.images.difficulties[diff.difficulty + 1]:draw({
      x = (portrait and (332 + (index * 82))) or (160 + (index * 82)),
      y = (portrait and 261) or 564,
      s = 0.25
    });

    local level = string.format('%02d', diff.level);

    local x;

    if (diff.level >= 10) then
      x = portrait and (331 + (index * 82)) or (159 + (index * 82));
    else
      x = portrait and (333 + (index * 82)) or (161 + (index * 82));
    end

    gfx.BeginPath();
    gfx.LoadSkinFont('slant.ttf');
    gfx.TextAlign(gfx.TEXT_ALIGN_CENTER, gfx.TEXT_ALIGN_MIDDLE);
    gfx.BeginPath();
    gfx.FontSize(36);
    drawAberratedText(
      level,
      x,
      (portrait and 265.5) or 568.5,
      0.8);
  end
end

SongData.drawCursor = function(this, index)
  this.images.cursor:draw({
    x = (portrait and (332 + (index * 82))) or (160 + (index * 82)),
    y = (portrait and 256) or 559,
    s = 0.25
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
      s = 1 / 3,
    });
  else
    this.images.songPanelLS:draw({
      x = 254,
      y = 359.5,
      s = 1 / 3,
    })
  end

  local jacket = this.jacketCache:get(diff.jacketPath);

  jacket:draw({
    x = (portrait and 114) or 269,
    y = (portrait and 138) or 193,
    w = (portrait and 190) or 260,
    h = (portrait and 190) or 260,
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
      gfx.LoadSkinFont('arial.ttf');
      return gfx.CreateLabel(song.title, 24, 0);
    end
  );

  this:drawTitleArtist(
    title,
    (portrait and 236) or 60,
    (portrait and 112) or 372,
    (portrait and 460) or 410
  );

  local artist = this.memo:memoize(
    string.format('artist_%s', song.artist),
    function()
      gfx.LoadSkinFont('arial.ttf');
      return gfx.CreateLabel(song.artist, 18, 0);
    end
  );

  this:drawTitleArtist(
    artist,
    (portrait and 236) or 60,
    (portrait and 144) or 401,
    (portrait and 460) or 410
  );

  local effector = this.memo:memoize(
    string.format('eff_%s_%s', song.id, diff.id),
    function()
      gfx.LoadSkinFont('arial.ttf');
      return gfx.CreateLabel(diff.effector, 14, 0);
    end
  );

  this:drawEffectorIllustrator(
    effector,
    (portrait and 340) or 150,
    (portrait and 54) or 432,
    (portrait and 350) or 320
  )

  if (diff.illustrator) then
    local illustrator = this.memo:memoize(
      string.format('ill_%s_%s', song,id, diff.id),
      function()
        gfx.LoadSkinFont('arial.ttf');
        return gfx.CreateLabel(diff.illustrator, 14, 0);
      end
    );

    this:drawEffectorIllustrator(
      illustrator,
      (portrait and 340) or 150,
      (portrait and 76) or 451,
      (portrait and 350) or 320
    );
  end

  this:drawBPM(song.bpm, 95, 482);

  local highScore = diff.scores[1];

  if (highScore) then
    this:drawHighScore(
      highScore.score, 
      (portrait and 474) or 282, 
      (portrait and 182) or 482
    );
  end

  local grade = findGradeImage(diff);

  grade.image:draw({
    x = (portrait and 635) or 450.5,
    y = (portrait and 179) or 238,
    s = (portrait and 0.5) or 0.65,
    alpha = (grade.flicker and glowState and 0.9) or 1
  });

  local medal = findMedalImage(diff);

  medal.image:draw({
    x = (portrait and 682) or 450.5,
    y = (portrait and 179) or 302,
    s = (portrait and 0.5) or 0.65,
    alpha = (grade.flicker and glowState and 0.9) or 1
  });

  for i = 1, 4 do
    local diff = findDifficulty(song.difficulties, i);
    this:drawDifficulty((i - 1), diff, jacket);
  end

  this:drawCursor(diff.difficulty);
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
        Image.new('song_select/plates/novice.png'),
        Image.new('song_select/plates/advanced.png'),
        Image.new('song_select/plates/exhaust.png'),
        Image.new('song_select/plates/maximum.png')
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
    
    if (cursorPos < 0) then
      this.rowOffset = this.rowOffset - this.columns;
      cursorPos = cursorPos + this.columns;
    elseif (cursorPos >= (this.columns * this.rows)) then
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

SongTable.setDifficulty = function(this, difficulty)
  if (difficulty ~= this.selectedDifficulty) then
    game.PlaySample('cursor_difficulty');
  end

  this.selectedDifficulty = difficulty;
end

SongTable.drawSongs = function(this)
  for i = 1, (this.columns * this.rows) do
    if (this.rowOffset + i <= #songwheel.songs) then
      this:drawSong(i - 1, this.rowOffset + i);
    end
  end
end

SongTable.drawTitle = function(this, label, x, y, maxWidth)
  gfx.BeginPath();
  gfx.LoadSkinFont('arial.ttf');
  gfx.TextAlign(gfx.TEXT_ALIGN_CENTER + gfx.TEXT_ALIGN_MIDDLE);
  gfx.FillColor(55, 55, 55, 255);
  gfx.DrawLabel(label, x, y, maxWidth);
end

SongTable.drawLevel = function(this, level, x, y)
  gfx.BeginPath();
  gfx.LoadSkinFont('slant.ttf');
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
  local alpha;

  this.images.cursorDiamondWire:draw({
    x = x - 2,
    y = y,
    w = this.images.cursorDiamondWire.w * 1.5,
    h = h,
    alpha = 0.5
  });

  alpha = easing.outSine(t, 1, -1, 1);
  h = this.images.cursor.h * easing.outSine(t, 0, 1, 1);

  this.images.cursor:draw({
    x = x - 2,
    y = y,
    h = h,
    alpha = alpha,
    s = 0.25
  });

  this.images.cursor:draw({
    x = x - 2,
    y = y,
    alpha = (glowState and 0.8) or 1,
    s = 0.25
  });

  gfx.GlobalCompositeOperation(gfx.BLEND_OP_LIGHTER);

  this.images.cursorDiamond:draw({
    x = x + 98,
    y = y,
    alpha = 1
  });

  this.images.cursorDiamond:draw({
    x = x - 102,
    y = y,
    alpha = 1
  });

  local s = this.images.cursorDiamond.w / 1.5;

  this.images.cursorDiamond:draw({
    x = x + 88 + easing.outQuad(t, 0, -4, 0.5),
    y = y,
    w = s,
    h = s,
    alpha = 0.5
  });

  this.images.cursorDiamond:draw({
    x = x - 92 - easing.outQuad(t, 0, -4, 0.5),
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

  local x, y = this:calculateCursorPos(pos)

  x = x + 20;
  y = y + 16;

  local diff = song.difficulties[this.selectedDifficulty];

  if (diff == nil) then
    diff = song.difficulties[1];
  end

  this.images.plates[diff.difficulty + 1]:draw({
    x = x - 25,
    y = y - 25,
    w = 195,
    h = 181
  });

  local jacket = this.jacketCache:get(diff.jacketPath);
  
  jacket:draw({
    x = x - 44,
    y = y - 26,
    w = 122,
    h = 122
  });

  local grade = findGradeImage(diff);

  grade.image:draw({
    x = x + 42,
    y = y - 70,
    s = 0.5,
    alpha = (grade.flicker and glowState and 0.9) or 1
  });

  local medal = findMedalImage(diff);

  medal.image:draw({
    x = x + 42,
    y = y - 33,
    s = 0.5,
    alpha = (grade.flicker and glowState and 0.9) or 1
  });

  local title = this.memo:memoize(
    string.format('title_%s', song.id),
    function()
      gfx.LoadSkinFont('arial.ttf');
      return gfx.CreateLabel(song.title, 12, 0)
    end
  );

  this:drawTitle(title, (x - 22), (y + 48), 170);

  local level = string.format('%02d', diff.level);

  this:drawLevel(
    level,
    ((diff.level >= 10) and (x + 41.5)) or (x + 43.5),
    y + 10
  );
end

SongTable.render = function(this, deltaTime)
  if (not portrait) then
    gfx.Save();
      gfx.Translate(desw / 2.45, - (desh / 2.02));
      gfx.Scale(1.05, 1.05);
      this:drawSongs();
      this:drawCursor(deltaTime);
    gfx.Restore();
  else
    this:drawSongs();
    this:drawCursor(deltaTime);
  end
end

local jacketCache = JacketCache.new();
local songData = SongData.new(jacketCache);
local songTable = SongTable.new(jacketCache);
local searchIndex = 1;
local searchSound = 1;
local searchText = gfx.CreateLabel('', 5, 0);

glowState = false;
currentTime = 0;

get_page_size = function()
  return 12
end

drawSearch = function(deltaTime)
  local sOffset = 0;

  if (portrait) then
    gfx.BeginPath();
    gfx.LoadSkinFont('arial.ttf');
    gfx.UpdateLabel(
      searchText,
      string.format("SEARCH: %s",songwheel.searchText),
      14,
      0
    );

    gfx.BeginPath();
    gfx.TextAlign(gfx.TEXT_ALIGN_LEFT + gfx.TEXT_ALIGN_MIDDLE);
    gfx.FillColor(245, 65, 125, 255);

    if (searchIndex ~= ((songwheel.searchInputActive and 0) or 1)) then
      gfx.BeginPath();
      gfx.FillColor(0, 0, 0, 255);
      gfx.RoundedRect(225, 198.3, 383, 20, 10);
      gfx.Fill();
      gfx.FillColor(245, 65, 125, 255);
    end

    if (searchSound ~= ((songwheel.searchInputActive and 0) or 1)) then
      game.PlaySample('woosh');
    end

    searchSound = (songwheel.searchInputActive and 0) or 1;
    gfx.DrawLabel(searchText, 270, 207, 580);
  else
      gfx.BeginPath();
      gfx.LoadSkinFont('arial.ttf');
      gfx.UpdateLabel(
        searchText,
        string.format("SEARCH: %s",songwheel.searchText),
        18,
        0
      );

      if (searchIndex ~= ((songwheel.searchInputActive and 0) or 1)) then
        gfx.BeginPath();
        gfx.FillColor(0, 0, 0, 100);
        gfx.Rect(0, 0, resx, resy);
        gfx.Fill();
        gfx.FillColor(245, 65, 125, 255)
      end
  
      gfx.BeginPath();
      gfx.TextAlign(gfx.TEXT_ALIGN_LEFT + gfx.TEXT_ALIGN_MIDDLE);
      gfx.FillColor(255, 255, 255);
      gfx.StrokeColor(245, 65, 125, 255);
      gfx.RoundedRect(845, 10, 420, 24, 12);
      gfx.StrokeWidth(2);
      gfx.Stroke();
      gfx.Fill();
      gfx.FillColor(245, 65, 125, 255);
  
      if (searchSound ~= ((songwheel.searchInputActive and 0) or 1)) then
        game.PlaySample('woosh');
      end
  
      searchSound = (songwheel.searchInputActive and 0) or 1;
      gfx.DrawLabel(searchText, 855, 20, 580);
  end
end

drawForce = function(totalForce, deltaTime)
  local forceText;
  local x;
  local y;

  if (portrait) then
    x = desw - 54;
    y = 303.5;
    gfx.TextAlign(gfx.TEXT_ALIGN_RIGHT + gfx.TEXT_ALIGN_BOTTOM);
  else
    x = 449
    y = 490;
    gfx.TextAlign(gfx.TEXT_ALIGN_LEFT + gfx.TEXT_ALIGN_MIDDLE);
  end

  gfx.BeginPath();
  gfx.LoadSkinFont('russellsquare.ttf');
  gfx.TextAlign(gfx.TEXT_ALIGN_RIGHT + gfx.TEXT_ALIGN_BOTTOM);
  gfx.FillColor(255, 255, 255, 255);

  forceText = string.format(string.sub(totalForce, 0, 2) .. ".");
  gfx.FontSize((portrait and 16) or 18);
  gfx.Text(forceText, x, y);

  forceText = string.format(string.sub(totalForce, -2));
  gfx.FontSize((portrait and 13) or 14);
  gfx.Text(forceText, (portrait and (x + 15)) or x + 15, (y - 0.5));
  
  gfx.LoadSkinFont('arial.ttf');
end

local legend = gfx.CreateSkinImage('song_select/legend.png', 0);

drawLegend = function(deltaTime)
  local w, h = gfx.ImageSize(legend);

  w = w * 1 / 3;
  h = h * 1 / 3;

  gfx.BeginPath();
  gfx.ImageRect((desw - w), (desh - h), w, h, legend, 1, 0);
end

render = function(deltaTime)
  ResetLayoutInformation();

  currentTime = currentTime + deltaTime;

  if ((math.floor(currentTime * 1000) % 100) < 50) then
    glowState = false;
  else
    glowState = true;
  end


  songData:render(deltaTime);
  songTable:render(deltaTime);

  drawLegend(deltaTime);
  drawSearch(deltaTime);

  if (totalForce) then
    drawForce(totalForce, deltaTime);
  end
end

set_index = function(newIndex)
  songData:setIndex(newIndex)
  songTable:setIndex(newIndex)
end

set_diff = function(newDiff)
  songData:setDifficulty(newDiff)
  songTable:setDifficulty(newDiff)
end

totalForce = nil;

local badgeRates = {
  0.50,
  1.00,
  1.02,
  1.04,
  1.10
};

local gradeRates = {
  {['min'] = 9900000, ['rate'] = 1.05},
  {['min'] = 9800000, ['rate'] = 1.02},
  {['min'] = 9700000, ['rate'] = 1.00},
  {['min'] = 9500000, ['rate'] = 0.97},
  {['min'] = 9300000, ['rate'] = 0.94},
  {['min'] = 9900000, ['rate'] = 0.91},
  {['min'] = 8700000, ['rate'] = 0.88},
  {['min'] = 7500000, ['rate'] = 0.85},
  {['min'] = 6500000, ['rate'] = 0.82},
  {['min'] =       0, ['rate'] = 0.80},
};

calculateForce = function(diff)
	if (#diff.scores < 1) then
		return 0;
  end
  
	local score = diff.scores[1];
	local badgeRate = badgeRates[diff.topBadge];
  local gradeRate;
  
    for i, v in ipairs(gradeRates) do
      if (score.score >= v.min) then
        gradeRate = v.rate;
		    break;
      end
    end

	return math.floor((diff.level * 2) * (score.score / 10000000) * gradeRate * badgeRate) / 100;
end
  
songs_changed = function(withAll)
  if (not withAll) then
    return;
  end

  local diffsById = {};
  local diffs = {};
  
  for i = 1, #songwheel.allSongs do
    local song = songwheel.allSongs[i];
    
    for j = 1, #song.difficulties do
      local diff = song.difficulties[j];
      
      diff.force = calculateForce(diff);
      table.insert(diffs, diff);
      diffsById[diff.id] = diff;
    end
  end

  table.sort(diffs, function (l, r)
    return l.force > r.force;
  end)

  totalForce = 0
  for i = 1, 50 do
    if (diffs[i]) then
      totalForce = totalForce + diffs[i].force;
      diffs[i].forceInTotal = true;
    end
  end

  for i = 1, #songwheel.songs do
    local song = songwheel.songs[i];

    for j = 1, #song.difficulties do
      local diff = song.difficulties[j];
      local newDiff = diffsById[diff.id];

      song.difficulties[j] = newDiff;
    end
  end
end