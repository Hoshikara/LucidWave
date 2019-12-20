local mposx = 0;
local mposy = 0;
local hovered = nil;
local buttonWidth = 200
local buttonHeight = 50
local buttonBorder = 2;
local label = -1;

local backgroundImage = gfx.CreateSkinImage("song_select/title_bg.jpg", 0)

local resx, resy = game.GetResolution()

local portrait = resy > resx
local landscape = resx > resy

local desw = 720
local desh = 1280

local scale = math.min(resx / 800, resy /800)

mouse_clipped = function(x,y,w,h)
    return mposx > x and mposy > y and mposx < x+w and mposy < y+h;
end;

draw_button = function(name, x, y, hoverindex)
    local rx = x - (buttonWidth / 2);
    local ty = y - (buttonHeight / 2);
    gfx.BeginPath();
    gfx.FillColor(15, 255, 255);
    if name == "EXIT" then
        gfx.FillColor(15, 255, 255);
    end

    if mouse_clipped(rx, ty, buttonWidth, buttonHeight) then
       hovered = hoverindex;
       gfx.FillColor(15, 255, 255);
    end
    gfx.RoundedRect(rx - buttonBorder,
        ty - buttonBorder,
        buttonWidth + (buttonBorder * 2),
        buttonHeight + (buttonBorder * 2), 24);
    gfx.Fill();
    gfx.BeginPath();
    gfx.FillColor(150, 150, 150);

	if mouse_clipped(rx, ty, buttonWidth, buttonHeight) then
       hovered = hoverindex;
       gfx.FillColor(55, 55, 55);
    end

    gfx.RoundedRect(rx, ty, buttonWidth, buttonHeight, 24);
    gfx.Fill();
    gfx.BeginPath();
    gfx.FillColor(255, 255, 255);

	if mouse_clipped(rx,ty, buttonWidth, buttonHeight) then
       hovered = hoverindex;
       gfx.FillColor(255, 255, 255);
    end

    gfx.TextAlign(gfx.TEXT_ALIGN_CENTER + gfx.TEXT_ALIGN_MIDDLE);
    gfx.FontSize(24);
    gfx.Text(name, x, y)
end

render = function(deltaTime)
    resx,resy = game.GetResolution();
    mposx,mposy = game.GetMousePos();

	gfx.Save()

	gfx.BeginPath()
	gfx.FillColor(255, 255, 255)
	gfx.Rect(0, 0, resx, resy)
	gfx.Fill()

    local desw = 720
    local desh = 1280
    local scale = resy / desh

    local xshift = (resx - desw * scale) / 2
    local yshift = (resy - desh * scale) / 2

    gfx.Translate(xshift, yshift)
    gfx.Scale(scale, scale)

	gfx.BeginPath()
	gfx.FillColor(255, 255, 255)
	if portrait then
		gfx.Scale(1/scale, 1/scale)
		gfx.ImageRect(0, 0, resx, resy, backgroundImage, 1, 0)
	elseif landscape then
		gfx.ImageRect(0, 0, desw, desh, backgroundImage, 1, 0)
	end
	gfx.Fill()

	gfx.Restore()

    gfx.ResetTransform()
	
    gfx.BeginPath()
    buttonY = resy / 2;
    hovered = nil;
    gfx.LoadSkinFont("slant.ttf");

    draw_button("SINGLEPLAYER", resx / 2, buttonY, Menu.Start);
    buttonY = buttonY + 70;
    draw_button("MULTIPLAYER", resx / 2, buttonY, Menu.Multiplayer);
    buttonY = buttonY + 70;
    draw_button("GET SONGS", resx / 2, buttonY, Menu.DLScreen);
	buttonY = buttonY + 70;
    draw_button("SETTINGS", resx / 2, buttonY, Menu.Settings);
    buttonY = buttonY + 70;
    draw_button("EXIT", resx / 2, buttonY, Menu.Exit);
    gfx.BeginPath();
    gfx.FillColor(255,255,255);
    gfx.FontSize(120);
    if label == -1 then
        gfx.LoadSkinFont("slant.ttf");
        label = gfx.CreateLabel("", 36, 0);
        label3 = gfx.CreateLabel("", 16, 0);
        label4 = gfx.CreateLabel("", 16, 0);
        gfx.LoadSkinFont("slant.ttf");
    end
    gfx.TextAlign(gfx.TEXT_ALIGN_CENTER + gfx.TEXT_ALIGN_MIDDLE);
    gfx.DrawLabel(label, resx / 2, resy / 2 - 280, resx-40);
    gfx.DrawLabel(label3, resx / 2, resy / 2 - 125, resx-40);
    gfx.DrawLabel(label4, resx / 2, resy / 2 - 100, resx-40);

    updateUrl, updateVersion = game.UpdateAvailable()
    if updateUrl then
       gfx.BeginPath()
       gfx.TextAlign(gfx.TEXT_ALIGN_BOTTOM + gfx.TEXT_ALIGN_LEFT)
       gfx.FontSize(30)
       gfx.Text(string.format("Version %s is now available", updateVersion), 5, resy - buttonHeight - 10)
       draw_button("VIEW", buttonWidth / 2 + 5, resy - buttonHeight / 2 - 5, 4);
    end
end;

mouse_pressed = function(button)
    if hovered then
        hovered()
    end
    return 0
end
