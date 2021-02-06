local jacket = nil;
local shotTimer = 0;
local shotPath = '';
local played = false;
local grade = nil;
local lastGrade = -1;
local toggleStats = true

game.LoadSkinSample('result');
game.LoadSkinSample('shutter');

local resx;
local resy;
local desw;
local desh;
local scale;
local xShift;
local yShift;

resetLayoutInformation = function()
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

drawShiftedText = function(text, color1, color2, size, x, y, offset)
  gfx.FontSize(size);
  gfx.FillColor(color1[1], color1[2], color1[3], color1[4]);
  gfx.Text(text, (x + offset), (y + offset));
  gfx.FillColor(color2[1], color2[2], color2[3], color2[4]);
  gfx.Text(text, x, y);
end

Results = {};

Results.new = function()
  local this = {
    images = {
      backgroundPT = Image.new('result/bg_pt.jpg'),
      backgroundLS = Image.new('result/bg_ls.png'),
      infoPanelPT = Image.new('result/info_panel_pt.png'),
      divider = Image.new('result/divider.png'),
      legend = Image.new('result/legend.png'),
      difficulties = {
        Image.new('song_select/difficulties/novice.png'),
        Image.new('song_select/difficulties/advanced.png'),
        Image.new('song_select/difficulties/exhaust.png'),
        Image.new('song_select/difficulties/maximum.png')
      },
    }
  };

  setmetatable(this, { __index = Results });

  return this;
end

Results.drawJacket = function(this, jacket, x, y, w, h)
  local x1 = x - (w / 2);
  local y1 = y - (h / 2);

  gfx.BeginPath();
  gfx.FillColor(245, 65, 125, 255);
  gfx.Rect((x1 - 4), (y1 - 4), w, h);
  gfx.Fill();

  gfx.BeginPath();
  gfx.FillColor(15, 225, 225, 255);
  gfx.Rect((x1 + 4), (y1 + 4), w, h);
  gfx.Fill();

  gfx.BeginPath();
  gfx.FillColor(255, 255, 255, 255);
  gfx.Rect((x1 - 2), (y1 - 2), (w + 4), (h + 4));
  gfx.Fill();

  gfx.BeginPath();
  gfx.ImageRect(x1, y1, w, h, jacket, 1, 0);
end

Results.drawTitleArtist = function(this, label, x, y, offset, maxWidth)
  gfx.BeginPath();
  gfx.TextAlign(gfx.TEXT_ALIGN_CENTER);
  gfx.FillColor(245, 65, 125, 255);
  gfx.DrawLabel(label, (x + offset), (y + offset), maxWidth);
  gfx.FillColor(25, 25, 25, 255);
  gfx.DrawLabel(label, x, y, maxWidth);
end

Results.drawDifficulty = function(this, index, level, x, y)
  this.images.difficulties[index]:draw({
    x = x,
    y = y,
    s = (portrait and 0.25) or 0.35
  });

  local x2;

  if (level >= 10) then
    x2 = (portrait and 421) or 878
  else
    x2 = (portrait and 424) or 881
  end

  gfx.BeginPath();
  gfx.LoadSkinFont('slant.ttf');
  gfx.TextAlign(gfx.TEXT_ALIGN_CENTER + gfx.TEXT_ALIGN_MIDDLE);
  gfx.FontSize((portrait and 38) or 48);
  drawAberratedText(
    string.format('%02d', level),
    x2,
    (portrait and (y - 5)) or (y - 6),
    (portrait and 0.5) or 0.8
  );
end

Results.drawScore = function(this, score, highScore, positive, x1, y1, x2, y2)
  local scoreLarge = string.sub(score, 1, 4);
  local scoreSmall = string.sub(score, -4);

  gfx.BeginPath();
  gfx.LoadSkinFont('avantgarde.ttf');
  gfx.TextAlign(gfx.TEXT_ALIGN_RIGHT);

  drawShiftedText(
    scoreLarge,
    { 245, 65, 125, 255 },
    { 25, 25, 25, 255 },
    (portrait and 72) or 94,
    x1,
    y1,
    1
  );

  drawShiftedText(
    scoreSmall,
    { 245, 65, 125, 255 },
    { 25, 25, 25, 255 },
    (portrait and 58) or 75,
    x2,
    y2,
    1
  );

  if (not portrait) then
    gfx.BeginPath();
    gfx.FillColor(255, 255, 255, 255);
    gfx.StrokeColor(245, 65, 125, 255);
    gfx.RoundedRect(1154, 248, 200, 26, 12);
    gfx.Fill();
    gfx.Stroke();

    if (highScore) then
      gfx.BeginPath();
      gfx.TextAlign(gfx.TEXT_ALIGN_RIGHT);
      gfx.FontSize(24);
      
      if (positive == true) then
        gfx.FillColor(55, 105, 255, 255);
      else
        gfx.FillColor(255, 25, 25, 255);
      end
      gfx.Text(highScore, 1274, 270);
    end
  end
end

Results.drawGraph = function(this, x, y, w, h)
  local gaugeType = result.gauge_type or result.flags or 0;

  gfx.BeginPath();
  gfx.FillColor(0, 0, 0, 255);
  gfx.Rect(x, y, w, h);
  gfx.Fill();

  gfx.BeginPath();
  gfx.MoveTo(x, y + h - (h * result.gaugeSamples[1]));

  for i = 2, #result.gaugeSamples do
    gfx.LineTo(x + i * (w / #result.gaugeSamples), y + h - (h * result.gaugeSamples[i]));
  end

  if (gaugeType == 1) then
    gfx.StrokeWidth(2);
    gfx.StrokeColor(255, 0, 255, 255);
    gfx.Stroke();
  else
    gfx.StrokeWidth(2);

    gfx.StrokeColor(15, 225, 225, 255);
    gfx.Scissor(x, (y + (h * 0.3)), w, (h * 0.7));
    gfx.Stroke();
    gfx.ResetScissor();

    gfx.StrokeColor(245, 65, 125, 255);
    gfx.Scissor(x, y, w, (h * 0.3));
    gfx.Stroke();
    gfx.ResetScissor();
  end

  grade:draw({
    x =  x + 4,
    y = (portrait and (y + 17)) or (y + 21),
    s = (portrait and 0.1) or 0.13,
    anchorX = 4
  });
end

Results.drawMetrics = function(this, metrics)
  gfx.BeginPath();
  gfx.LoadSkinFont('avantgarde.ttf');
  gfx.TextAlign(gfx.TEXT_ALIGN_CENTER);
  gfx.FontSize((portrait and 18) or 21);

  for i = 1, #metrics do
    local metric = metrics[i].metric;
    local x = metrics[i].x;
    local y = metrics[i].y;

    if (i == 1) then
      gfx.FillColor(0, 0, 0, 255);
    else
      gfx.FillColor(255, 255, 255, 255);
    end

    gfx.Text(metric, x, y);
  end
end

Results.render = function(this, showStats);
  if (result.badge > 1) and (not played) then
    game.PlaySample('result', true);
    played = true;
  end

  if (game.GetButton(game.BUTTON_STA) or game.GetButton(game.BUTTON_BCK)) then
    game.StopSample('result');
  end

  if (portrait) then
    this.images.backgroundPT:draw({
      x = desw / 2,
      y = desh / 2,
      w = desw,
      h = desh
    });
  else
    this.images.backgroundLS:draw({
      x = desw / 2,
      y = desh / 2,
      w = desw,
      h = desh
    });

    this.images.legend:draw({
      x = desw,
      y = desh,
      s = 1 / 3,
      anchorX = 2,
      anchorY = 3
    });
  end

  if (jacket == nil) then
    jacket = gfx.CreateImage(result.jacketPath, 0);
  end

  if (jacket) then
    this:drawJacket(
      jacket,
      (portrait and 360) or 400,
      (portrait and 160) or 280,
      (portrait and 265) or 460,
      (portrait and 265) or 460
    );
  end

  this.images.divider:draw({
    x = (portrait and 359.5) or 400,
    y = (portrait and 326) or 600,
    s = (portrait and (1 / 3)) or 0.42
  });

  gfx.LoadSkinFont('arial.ttf');
  
  local title = gfx.CreateLabel(result.title, (portrait and 24) or 34, 0);

  this:drawTitleArtist(
    title,
    (portrait and 360) or 400,
    (portrait and 305) or 570,
    (portrait and 0.3) or 0.5,
    (portrait and 460) or 480
  );

  local artist = gfx.CreateLabel(result.artist, (portrait and 20) or 26, 0);

  this:drawTitleArtist(
    artist,
    (portrait and 360) or 400,
    (portrait and 350) or 630,
    (portrait and 0.3) or 0.5,
    (portrait and 460) or 480
  );

  if (toggleStats) then
    if (portrait) then
      this.images.infoPanelPT:draw({
        x = 720,
        y = 654,
        s = 1 / 3,
        anchorX = 2
      });
    else
      this.images.infoPanelPT:draw({
        x = 1280,
        y = 350,
        s = 0.45,
        anchorX = 2
      });
    end

    local diffIndex = result.difficulty + 1;

    this:drawDifficulty(
      diffIndex,
      result.level,
      (portrait and 422) or 879,
      (portrait and 456) or 84
    );

    this:drawGraph(
      (portrait and 394) or 839,
      (portrait and 600) or 278,
      (portrait and 294) or 398,
      (portrait and 74) or 100
    );

    local highScore;
    local highScoreString;
    local difference;
    local positive = true;

    for i, v in ipairs(result.highScores) do
      if (i == 1) then
        highScore = v.score;
      end
    end

    local score = result.score
    if (highScore) then
      difference = score - highScore;
      highScoreString = string.format('%08d', highScore);
    end

    local scoreString = string.format('%08d', score);

    if (difference and (difference < 0)) then
      positive = false;
    end

    this:drawScore(
      scoreString,
      highScoreString,
      positive,
      (portrait and 554) or 1054,
      (portrait and 574) or 242,
      (portrait and 686) or 1223,
      (portrait and 574) or 242
    );

    local metrics = {
      { 
        metric = string.format('%d%%', math.floor(result.gauge * 100)),
        x = (portrait and 653) or 1186,
        y = (portrait and 697) or 407
      },
      { 
        metric = string.format('%04d', result.perfects),
        x = (portrait and 608) or 1130,
        y = (portrait and 723) or 441.5
      },
      { 
        metric = string.format('%04d', result.goods),
        x = (portrait and 608) or 1130,
        y = (portrait and 748) or 476
      },
      { 
        metric = string.format('%04d', result.earlies),
        x = (portrait and 530) or 1020,
        y = (portrait and 774) or 511
      },
      { 
        metric = string.format('%04d', result.lates),
        x = (portrait and 645) or 1177,
        y = (portrait and 774) or 511
      },
      { 
        metric = string.format('%04d', result.misses),
        x = (portrait and 608) or 1130,
        y = (portrait and 800) or 545.5
      },
      { 
        metric = string.format('%04d', result.maxCombo),
        x = (portrait and 608) or 1130,
        y = (portrait and 825) or 580
      },
      { 
        metric = string.format('%.1f ms', result.medianHitDelta),
        x = (portrait and 608) or 1130,
        y = (portrait and 851) or 614
      },
      {
        metric = string.format('%.1f ms', result.meanHitDelta),
        x = (portrait and 608) or 1130,
        y = (portrait and 877) or 649.5
      }
    };

    this:drawMetrics(metrics);
  end
end

drawHighScores = function()
  if (not toggleStats) then
    gfx.Save();
    gfx.Translate(
      (portrait and 0) or 810,
      (portrait and 440) or 50
    );

    gfx.LoadSkinFont('avantgarde.ttf');

    for i, v in ipairs(result.highScores) do
      local index = string.format('%d', i);
      local y = (portrait and ((i - 1) * 86)) or ((i - 1) * 140);
      local score = string.format('%08d', v.score);
      local scoreLarge = string.sub(score, 1, 4);
      local scoreSmall = string.sub(score, -4);

      gfx.TextAlign(gfx.TEXT_ALIGN_LEFT);

      gfx.BeginPath();
      gfx.FillColor(0, 0, 0, 200);
      gfx.StrokeColor(245, 65, 125, 255);
      gfx.StrokeWidth(1);
      gfx.RoundedRect(
        35,
        (y - 30),
        (portrait and 280) or 410,
        (portrait and 70) or 100,
        (portrait and 11) or 13
      );
      gfx.Fill();
      gfx.Stroke();

      gfx.BeginPath();

      drawShiftedText(
        index,
        { 245, 65, 125, 255 },
        { 25, 25, 25, 255},
        (portrait and 25) or 36,
        (portrait and 10) or 0,
        (portrait and (y - 10)) or (y - 2),
        0.8
      );

      drawShiftedText(
        scoreLarge,
        { 245, 65, 125, 255 },
        { 255, 255, 255, 255},
        (portrait and 65) or 96,
        (portrait and 42) or 46,
        (portrait and (y + 31)) or (y + 55),
        1.3
      );

      drawShiftedText(
        scoreSmall,
        { 245, 65, 125, 255 },
        { 255, 255, 255, 255},
        (portrait and 52) or 76,
        (portrait and 190) or 264,
        (portrait and (y + 31)) or (y + 55),
        1.3
      );

      gfx.TextAlign(gfx.TEXT_ALIGN_RIGHT);
      gfx.FontSize((portrait and 14) or 20);
      gfx.FillColor(255, 255, 255, 80);
      
      if (v.timestamp > 0) then
        gfx.Text(
          os.date('%m-%d-%Y', v.timestamp),
          (portrait and 305) or 436,
          (portrait and (y - 14)) or (y - 9)
        );
      end

      if (i == 5) then
        break;
      end
    end

    gfx.Restore();
  end
end

drawScreenshotNotification = function(x, y)
  gfx.Save();

  gfx.Translate(x, y);

  gfx.BeginPath();
  gfx.TextAlign(gfx.TEXT_ALIGN_LEFT + gfx.TEXT_ALIGN_TOP);
  gfx.RoundedRect(-10, -40, 300, 40, 10);
  gfx.FillColor(0, 0, 0, 200);
  gfx.StrokeColor(245, 65, 125, 255);
  gfx.StrokeWidth(1);
  gfx.Fill();
  gfx.Stroke();

  gfx.BeginPath();
  gfx.FillColor(255, 255, 255, 255);
  gfx.FontSize(15);
  gfx.Text('Screenshot saved to: ', -4, -35);
  gfx.Text(shotPath, -4 , -17);

  gfx.Restore();
end

get_capture_rect = function()
  resetLayoutInformation();

  local x = (resx - (desw * scale)) / 2;
  local y = (resy - (desh * scale)) / 2;
  local w = desw * scale;
  local h = desh * scale;

  return x, y, w, h;
end

screenshot_captured = function(path)
  shotTimer = 5;
  shotPath = path;
  game.PlaySample('shutter');
end

local results = Results.new();
local genericTimer = 0;

render = function(deltaTime, showStats)

  resetLayoutInformation();

  if (game.GetButton(game.BUTTON_FXR) and game.GetButton(game.BUTTON_FXL)) then
    genericTimer = genericTimer + deltaTime;
    if (genericTimer > 0.2) then
      toggleStats = not toggleStats;
      genericTimer = 0;
    end
  end
  
  gfx.Scale(scale, scale);

  if (not grade) then
    grade = Image.new(string.format('score/%s.png', result.grade));
  end

  results:render(showStats);

  drawHighScores();

  shotTimer = math.max(shotTimer - deltaTime, 0);

  if (shotTimer > 1) then
    drawScreenshotNotification(
      (portrait and 425) or 980,
      (portrait and 960) or 710
    );
  end
end
