local backgroundPT = gfx.CreateSkinImage("song_select/bg_pt.jpg", 0);
local backgroundLS = gfx.CreateSkinImage("song_select/bg_ls.png", 0);

local resx;
local resy;
local portrait;
local desw;
local desh;
local scale;

ResetLayoutInformation = function()
  resx, resy = game.GetResolution();
  portrait = resy > resx;
  desw = (portrait and 720) or 1280;
  desh = desw * (resy / resx);
  scale = resx / desw;
end

render = function(deltaTime)
  ResetLayoutInformation();

  local xshift = (resx - desw * scale) / 2;
  local yshift = (resy - desh * scale) / 2;

  gfx.Translate(xshift, yshift);
  gfx.Scale(scale, scale);

  if (portrait) then
    gfx.BeginPath()
    gfx.ImageRect(0, 0, desw, desh, backgroundPT, 1, 0);
  else
    gfx.BeginPath();
    gfx.ImageRect(0, 0, desw, desh, backgroundLS, 1, 0);
  end
end
