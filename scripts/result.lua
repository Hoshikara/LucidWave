local jacket = nil;
local shotTimer = 0;
local shotPath = '';
local played = false;
local grade = nil;
local lastGrade = -1;

game.LoadSkinSample('result');
game.LoadSkinSample('shutter');

local resx;
local resy;
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

drawShiftedText = function(text, color1, color2, size, x, y, offset)
  gfx.FontSize(size);
  gfx.FillColor(color1[1], color1[2], color1[3], color1[4]);
  gfx.Text(text, (x + offset), (y + offset));
  gfx.FillColor(color2[1], color2[2], color2[3], color2[4]);
  gfx.Text(text, x, y);
end

-- Results Class
Results = {};

Results.new = function(showStats)
  local this = {
    images = {
      backgroundPT = Image.new('result/bg_pt.jpg'),
      backgroundLS = Image.new('result/bg_ls.png'),
      infoPanelPT = Image.new('result/info_panel_pt.png'),
      divider = Image.new('result/divider.png'),
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
    s = 0.25
  });

  local x2;

  if (level >= 10) then
    x2 = (portrait and 421) or 421
  else
    x2 = (portrait and 424) or 424
  end

  gfx.BeginPath();
  gfx.LoadSkinFont('slant.ttf');
  gfx.TextAlign(gfx.TEXT_ALIGN_CENTER + gfx.TEXT_ALIGN_MIDDLE);
  gfx.FontSize(38);
  drawAberratedText(
    string.format('%02d', level),
    x2,
    y - 5,
    0.5
  );
end

Results.drawScore = function(this, score, x1, y1, x2, y2)
  local scoreLarge = string.sub(score, 1, 4);
  local scoreSmall = string.sub(score, -4);

  gfx.BeginPath();
  gfx.LoadSkinFont('avantgarde.ttf');
  gfx.TextAlign(gfx.TEXT_ALIGN_RIGHT);

  drawShiftedText(
    scoreLarge,
    { 245, 65, 125, 255 },
    { 25, 25, 25, 255 },
    72,
    x1,
    y1,
    1
  );

  drawShiftedText(
    scoreSmall,
    { 245, 65, 125, 255 },
    { 25, 25, 25, 255 },
    58,
    x2,
    y2,
    1
  );
end

Results.drawGraph = function(this, x, y, w, h)
  gfx.BeginPath();
  gfx.FillColor(0, 0, 0, 255);
  gfx.Rect(x, y, w, h);
  gfx.Fill();

  gfx.BeginPath();
  gfx.MoveTo(x, y + h - (h * result.gaugeSamples[1]));

  for i = 2, #result.gaugeSamples do
    gfx.LineTo(x + i * (w / #result.gaugeSamples), y + h - (h * result.gaugeSamples[i]));
  end

  if ((result.flags & 1) ~= 0) then
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

  this.images.grade:draw({
    x = x + 19,
    y = y + 17,
    s = (portrait and 0.1) or 0.1
  });
end

Results.drawMetrics = function(this, metrics)
  gfx.BeginPath();
  gfx.LoadSkinFont('avantgarde.ttf');
  gfx.TextAlign(gfx.TEXT_ALIGN_CENTER);
  gfx.FontSize(18);

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

Results.render = function(this, deltaTime, showStats);
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

    this.images.infoPanelPT:draw({
      x = 720,
      y = 654,
      s = 1 / 3,
      anchorX = 2
    });
  end

  if (jacket == nil) then
    jacket = gfx.CreateImage(result.jacketPath, 0);
  end

  if (jacket) then
    this:drawJacket(
      jacket,
      (portrait and 360) or 360,
      (portrait and 160) or 360,
      (portrait and 265) or 265,
      (portrait and 265) or 265
    );
  end

  this.images.divider:draw({
    x = (portrait and 359.5) or 359.5,
    y = (portrait and 326) or 326,
    s = (portrait and (1 / 3)) or (1 / 3)
  });

  gfx.LoadSkinFont('arial.ttf');
  
  local title = gfx.CreateLabel(result.title, 24, 0);

  this:drawTitleArtist(
    title,
    (portrait and 360) or 360,
    (portrait and 305) or 305,
    (portrait and 0.3) or 0.3,
    (portrait and 460) or 460
  );

  local artist = gfx.CreateLabel(result.artist, 20, 0);

  this:drawTitleArtist(
    artist,
    (portrait and 360) or 360,
    (portrait and 350) or 350,
    (portrait and 0.3) or 0.3,
    (portrait and 460) or 460
  );

  local diffIndex = result.difficulty + 1;

  this:drawDifficulty(
    diffIndex,
    result.level,
    (portrait and 422) or 422,
    (portrait and 456) or 456
  );

  local score = string.format('%08d', result.score);

  this:drawScore(
    score,
    (portrait and 554) or 554,
    (portrait and 574) or 574,
    (portrait and 686) or 686,
    (portrait and 574) or 574
  );

  if (not grade) or (result.grade ~= lastGrade) then
    lastGrade = result.grade;
    this.images.grade = Image.new(string.format('score/%s.png', result.grade));
  end

  this:drawGraph(
    (portrait and 394) or 394,
    (portrait and 600) or 600,
    (portrait and 294) or 294,
    (portrait and 74) or 74
  );

  if (not grade) or (result.grade ~= lastGrade) then
    lastGrade = result.grade;
    this.images.grade = Image.new(string.format('score/%s.png', result.grade));
  end

  local metrics = {
    { 
      metric = string.format('%d%%', math.floor(result.gauge * 100)),
      x = (portrait and 653) or 653,
      y = (portrait and 697) or 697
    },
    { 
      metric = string.format('%04d', result.perfects),
      x = (portrait and 608) or 608,
      y = (portrait and 723) or 723
    },
    { 
      metric = string.format('%04d', result.goods),
      x = (portrait and 608) or 608,
      y = (portrait and 748) or 748
    },
    { 
      metric = string.format('%04d', result.earlies),
      x = (portrait and 530) or 530,
      y = (portrait and 774) or 774
    },
    { 
      metric = string.format('%04d', result.lates),
      x = (portrait and 645) or 645,
      y = (portrait and 774) or 774
    },
    { 
      metric = string.format('%04d', result.misses),
      x = (portrait and 608) or 608,
      y = (portrait and 800) or 800
    },
    { 
      metric = string.format('%04d', result.maxCombo),
      x = (portrait and 608) or 608,
      y = (portrait and 825) or 825
    },
    { 
      metric = string.format('%.1f ms', result.medianHitDelta),
      x = (portrait and 608) or 608,
      y = (portrait and 851) or 851
    },
    {
      metric = string.format('%.1f ms', result.meanHitDelta),
      x = (portrait and 608) or 608,
      y = (portrait and 877) or 877
    }
  };

  this:drawMetrics(metrics);
end

drawHighScores = function()
  gfx.Save();
  gfx.Translate(
    (portrait and 0) or 0,
    (portrait and 440) or 440
  );

  gfx.LoadSkinFont('avantgarde.ttf');

  for i, v in ipairs(result.highScores) do
    local index = string.format('%d', i);
    local y = (i - 1) * 86;
    local score = string.format('%08d', v.score);
    local scoreLarge = string.sub(score, 1, 4);
    local scoreSmall = string.sub(score, -4);

    gfx.TextAlign(gfx.TEXT_ALIGN_LEFT);

    gfx.BeginPath();
    gfx.FillColor(0, 0, 0, 200);
    gfx.StrokeColor(245, 65, 125, 255);
    gfx.StrokeWidth(1);
    gfx.RoundedRect(35, (y - 30), 280, 70, 11);
    gfx.Fill();
    gfx.Stroke();

    gfx.BeginPath();

    drawShiftedText(
      index,
      { 245, 65, 125, 255 },
      { 25, 25, 25, 255},
      25,
      10,
      (y - 10),
      0.8
    );

    drawShiftedText(
      scoreLarge,
      { 245, 65, 125, 255 },
      { 255, 255, 255, 255},
      65,
      42,
      (y + 31),
      1.3
    );

    drawShiftedText(
      scoreSmall,
      { 245, 65, 125, 255 },
      { 255, 255, 255, 255},
      52,
      190,
      (y + 31),
      1.3
    );

    gfx.TextAlign(gfx.TEXT_ALIGN_RIGHT);
    gfx.FontSize(14);
    gfx.FillColor(255, 255, 255, 80);
    
    if (v.timestamp > 0) then
      gfx.Text(os.date('%m-%d-%Y', v.timestamp), 305, (y - 14));
    end

    if (i == 5) then
      break;
    end
  end

  gfx.Restore();
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
  ResetLayoutInformation();

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

local results = Results.new(showStats);

render = function(deltaTime, showStats)

  ResetLayoutInformation();

  gfx.Scale(scale, scale);

  results:render(deltaTime);

  drawHighScores();

  shotTimer = math.max(shotTimer - deltaTime, 0);

  if (shotTimer > 1) then
    drawScreenshotNotification(
      (portrait and 425) or 425,
      (portrait and 960) or 960
    );
  end
end
