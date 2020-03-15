gfx.LoadSkinFont('arial.ttf');

-- Memo Class
Memo = {};

Memo.new = function()
  local this = {
    cache = {}
  };

  setmetatable(this, { __index = Memo });

  return this
end

Memo.memoize = function(this, key, generator)
  local value = this.cache[key]

  if (not value) then
    value = generator();
    this.cache[key] = value;
  end

  return value;
end

-- Image Class
Image = {
  ANCHOR_CENTER = 1,
  ANCHOR_RIGHT = 2,
  ANCHOR_BOTTOM = 3
};

Image.new = function(path)
  local image = gfx.CreateSkinImage(path, 0);
  return Image.wrapper(image);
end

Image.wrapper = function(image)
  local this = {
    image = image
  };
  local w, h = gfx.ImageSize(this.image);

  this.w = w;
  this.h = h;

  setmetatable(this, { __index = Image });

  return this;
end

Image.draw = function(this, params)
  local x = params.x;
  local y = params.y;
  local w = params.w or this.w;
  local h = params.h or this.h;
  local s = params.s or 1;
  local alpha = params.alpha or 1;
  local angle = params.angle or 0;
  local anchorX = params.anchorX or Image.ANCHOR_CENTER;
  local anchorY = params.anchorY or Image.ANCHOR_CENTER;

  w = w * s;
  h = h * s;

  if (anchorX == Image.ANCHOR_RIGHT) then
    x = x - w;
  else
    x = x - (w / 2);
  end

  if (anchorY == Image.ANCHOR_BOTTOM) then
    y = y - h;
  end
    y = y - (h / 2);
  end

  gfx.BeginPath();
  gfx.ImageRect(x, y, w, h, this.image, alpha, angle);
end
