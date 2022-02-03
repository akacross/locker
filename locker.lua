local sampev = require 'samp.events'
local imgui = require 'imgui'
local lockervar = 0
local lockerstate = 0
local lockercmd = 0

local inicfg = require 'inicfg'
local locker = inicfg.load({
    -- Deagle  [1]
    -- Shotgun [2]
    -- SPAS-12 [3]
    -- MP5     [4]
    -- M4      [5]
    -- AK-47   [6]
    -- Smoke   [7]
    -- Camera  [8]
    -- Sniper  [9]
    -- Vest    [10]
    -- Aid     [11]
    settings = 
    {
      key = 88
    },
    guns = 
    {
      true, true, false, false, false, false, false, false, false, true, true
    }
}, 'locker.ini')

-- this function does all the work with ImGui
-- it is called every frame, but only if imgui.Process is true

local main_window_state = imgui.ImBool(false)
function imgui.OnDrawFrame()
  if main_window_state.v then
    -- window settings
    width, height = getScreenResolution()
    imgui.SetNextWindowPos(imgui.ImVec2(width / 2, height / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
    imgui.SetNextWindowSize(imgui.ImVec2(500, 245), imgui.Cond.FirstUseEver)
    imgui.Begin('Locker Settings', main_window_state, imgui.WindowFlags.NoResize)

    -- menu functions

    imgui.Text('Key (keycode.info)')

    --set key
    lkey = imgui.ImInt(locker.settings.key)
    imgui.PushItemWidth(25)
    if imgui.DragInt("", lkey) then locker.settings.key = lkey.v end

    imgui.Text('Locker Equipment')
    if imgui.Checkbox('Deagle', imgui.ImBool(locker.guns[1])) then locker.guns[1] = not locker.guns[1] end 
    imgui.SameLine(125)
    if imgui.Checkbox('Shotgun', imgui.ImBool(locker.guns[2])) then locker.guns[2] = not locker.guns[2] end 
    imgui.SameLine(250)
    if imgui.Checkbox('SPAS-12', imgui.ImBool(locker.guns[3])) then locker.guns[3] = not locker.guns[3] end 
    imgui.SameLine(375)
    if imgui.Checkbox('MP5', imgui.ImBool(locker.guns[4])) then locker.guns[4] = not locker.guns[4] end 
    if imgui.Checkbox('M4', imgui.ImBool(locker.guns[5])) then locker.guns[5] = not locker.guns[5] end
    imgui.SameLine(125)
    if imgui.Checkbox('AK-47', imgui.ImBool(locker.guns[6])) then locker.guns[6] = not locker.guns[6] end
    imgui.SameLine(250)
    if imgui.Checkbox('Smoke Grenade', imgui.ImBool(locker.guns[7])) then locker.guns[7] = not locker.guns[7] end
    imgui.SameLine(375)
    if imgui.Checkbox('Camera', imgui.ImBool(locker.guns[8])) then locker.guns[8] = not locker.guns[8] end
    if imgui.Checkbox('Sniper', imgui.ImBool(locker.guns[9])) then locker.guns[9] = not locker.guns[9] end
    imgui.SameLine(125)
    if imgui.Checkbox('Vest', imgui.ImBool(locker.guns[10])) then locker.guns[10] = not locker.guns[10] end
    imgui.SameLine(250) 
    if imgui.Checkbox('First Aid Kit', imgui.ImBool(locker.guns[11])) then locker.guns[11] = not locker.guns[11] end
    imgui.End() -- end of window
  end
end

-- Main Function
function main()
  if not isSampLoaded() or not isSampfuncsLoaded() then return end
  while not isSampAvailable() do wait(100) end

  sampRegisterChatCommand("lsettings", function() main_window_state.v = not main_window_state.v end)
  while true do
    wait(0)
    imgui.Process = main_window_state.v
    if wasKeyPressed(locker.settings.key) and lockervar == 0 and not sampIsChatInputActive() and not sampIsDialogActive() and not sampIsScoreboardOpen() and not isSampfuncsConsoleActive() then
      lockervar = 1
      sendLockerCmd()
    end 
  end
  wait(-1)
end


--Quit game
function onScriptTerminate(scr, quitGame) 
	if scr == script.this then 
		showCursor(false) 
		inicfg.save(locker, 'locker.ini')
	end
end

--Real health
local function getLast(var)
     return tonumber(tostring(var):sub(-3))
end

function getCharRealHealth(char)
  fhealth = getLast(getCharHealth(char))
  return fhealth
end


function sendLockerCmd()
  --lua_thread.create(function()
  --  lockercmd = lockercmd + 1
  --  if lockercmd ~= 3
  --  then
  --    lockercmd = 0
      sampSendChat("/locker")
  --  else    
  --    wait(2000)
  --    sampSendChat("/locker")
  --  end
  --end)
end

--sampSendDialogResponse(int id, int button, int listitem, zstring input)
function sampev.onShowDialog(id, style, title, button1, button2, text)
  if lockervar == 1 then
    if title:find('LSPD Menu') or title:find('FBI Menu') or title:find('ARES Menu') then
      sampSendDialogResponse(id, 1, 1, nil)
      return false
    end


    if title:find('LSPD Equipment') or title:find('FBI Weapons') or title:find('ARES Equipment') then

      --Deagle
      if lockerstate == 0 then
        if hasCharGotWeapon(PLAYER_PED, 24) or locker.guns[1] == false then
          lockerstate = 1
          sampev.onShowDialog(id, style, title, button1, button2, text)
          return false
        end

        sampSendDialogResponse(id, 1, 0, nil)
        lockerstate = 1
        sendLockerCmd()
        return false
      end

      --Shotgun
      if lockerstate == 1 then
        if hasCharGotWeapon(PLAYER_PED, 25) or hasCharGotWeapon(PLAYER_PED, 27) or locker.guns[2] == false then
          lockerstate = 2
          sampev.onShowDialog(id, style, title, button1, button2, text)
          return false
        end

        sampSendDialogResponse(id, 1, 1, nil)
        lockerstate = 2
        sendLockerCmd()
        return false
      end

      --SPAS-12
      if lockerstate == 2 then
        if hasCharGotWeapon(PLAYER_PED, 27) or locker.guns[3] == false then
          lockerstate = 3
          sampev.onShowDialog(id, style, title, button1, button2, text)
          return false
        end

        sampSendDialogResponse(id, 1, 2, nil)
        lockerstate = 3
        sendLockerCmd()
        return false
      end

      --MP5
      if lockerstate == 3 then
        if hasCharGotWeapon(PLAYER_PED, 29) or locker.guns[4] == false then
          lockerstate = 4
          sampev.onShowDialog(id, style, title, button1, button2, text)
          return false
        end

        sampSendDialogResponse(id, 1, 3, nil)
        lockerstate = 4
        sendLockerCmd()
        return false
      end

      --M4
      if lockerstate == 4 then
        if hasCharGotWeapon(PLAYER_PED, 31) or locker.guns[5] == false then
          lockerstate = 5
          sampev.onShowDialog(id, style, title, button1, button2, text)
          return false
        end

        sampSendDialogResponse(id, 1, 4, nil)
        lockerstate = 5
        sendLockerCmd()
        return false
      end

      --AK-47
      if lockerstate == 5 then
        if hasCharGotWeapon(PLAYER_PED, 30) or locker.guns[6] == false then
          lockerstate = 6
          sampev.onShowDialog(id, style, title, button1, button2, text)
          return false
        end

        sampSendDialogResponse(id, 1, 5, nil)
        lockerstate = 6
        sendLockerCmd()
        return false
      end

       --Smoke Grenade
       if lockerstate == 6 then
        if hasCharGotWeapon(PLAYER_PED, 17) or locker.guns[7] == false then
          lockerstate = 7
          sampev.onShowDialog(id, style, title, button1, button2, text)
          return false
        end

        sampSendDialogResponse(id, 1, 6, nil)
        lockerstate = 7
        sendLockerCmd()
        return false
      end     

       --Camera
       if lockerstate == 7 then
        if hasCharGotWeapon(PLAYER_PED, 43) or locker.guns[8] == false then
          lockerstate = 8
          sampev.onShowDialog(id, style, title, button1, button2, text)
          return false
        end

        sampSendDialogResponse(id, 1, 7, nil)
        lockerstate = 8
        sendLockerCmd()
        return false
      end

       --Sniper Rifle
       if lockerstate == 8 then
        if hasCharGotWeapon(PLAYER_PED, 34) or locker.guns[9] == false then
          lockerstate = 9
          sampev.onShowDialog(id, style, title, button1, button2, text)
          return false
        end

        sampSendDialogResponse(id, 1, 8, nil)
        lockerstate = 9
        sendLockerCmd()
        return false
      end

      --Armor
      if lockerstate == 9 then
        if(getCharArmour(PLAYER_PED) == 100 or locker.guns[10] == false)
        then
          lockerstate = 10
          sampev.onShowDialog(id, style, title, button1, button2, text)
          return false
        end

        sampSendDialogResponse(id, 1, 9, nil)
        lockerstate = 10
        sendLockerCmd()
        return false
      end
      --Health
      if lockerstate == 10 then
	      if(getCharRealHealth(PLAYER_PED) == 100 or locker.guns[11] == false)
	      then
	        lockerstate = 0
          lockervar = 0
          lockercmd = 0
	        return false
        end

        sampSendDialogResponse(id, 1, 10, nil)
        lockerstate = 0
        lockervar = 0
        lockercmd = 0
        return false
      end

    end



  end
end

function sampev.onServerMessage(color, text)
    if (text:match('You are not in range of your lockers.') or text:match('You have been muted automatically for spamming. Please wait 10 seconds and try again.') or text:match('You are muted from submitting commands right now.') or text:match("You can't use your lockers if you were recently shot.")) and lockervar == 1 then
        lockervar = 0
        lockercmd = 0
    end
	
	if text:match("You can't use your lockers if you were recently shot.") and lockervar == 1 then
		lockervar = 0
        lockercmd = 0
	end
	
    if text:match('You have failed to pick the lock!') then
        sampSendChat("/lockpick")
    end
    if text:match('You have successfully picked the lock of this vehicle.') then
        sampSendChat("/pvl")
	sampSendChat("/lockpick")
    end
    --if text:find('HQ:') then
--	return false
--    end
end

--[[function sampev.onSetPlayerHealth(health)
   setCharHealth(PLAYER_PED, getCharRealHealth(PLAYER_PED))
   sampAddChatMessage(health, -1)
   sampAddChatMessage(getCharRealHealth(PLAYER_PED), -1)
   return false
end

function sampev.onShowTextDraw(id, data)
    print(string.format("ID:%d - X:%f Y:%f - Text:%s", id, data.position.x, data.position.y, data.text))
    if data.position.y == 70.250000 or data.position.y == 68.250000 then return false end 
end--]]

function apply_style()
	local s = imgui.GetStyle()
	local clrs = s.Colors
	local clr = imgui.Col
	local im4 = imgui.ImVec4
	local im2 = imgui.ImVec2
	s.WindowPadding = im2(5, 5)
	s.WindowRounding = 6.0
	s.FramePadding = im2(5, 5)
	s.FrameRounding = 4.0
	s.ItemSpacing = im2(12, 8)
	s.ItemInnerSpacing = im2(8, 6)
	s.IndentSpacing = 25.0
	s.ScrollbarSize = 15.0
	s.ScrollbarRounding = 9.0
	s.GrabMinSize = 5.0
	s.GrabRounding = 3.0
	clrs[clr.Text] = im4(1.00, 1.00, 1.00, 1.00)
	clrs[clr.TextDisabled] = im4(0.70, 0.71, 0.74, 1.00)
	clrs[clr.WindowBg] = im4(0.11, 0.13, 0.16, 1.00)
	clrs[clr.ChildWindowBg] = im4(0.16, 0.17, 0.20, 1.00)
	clrs[clr.PopupBg] = im4(0.16, 0.17, 0.20, 1.00)
	clrs[clr.Border] = im4(0.12, 0.12, 0.16, 1.00)
	clrs[clr.BorderShadow] = im4(0.00, 0.00, 0.00, 0.00)
	clrs[clr.FrameBg] = im4(0.09, 0.10, 0.15, 1.00)
	clrs[clr.FrameBgHovered] = im4(0.12, 0.13, 0.17, 1.00)
	clrs[clr.FrameBgActive] = im4(0.07, 0.08, 0.13, 1.00)
	clrs[clr.TitleBg] = im4(0.14, 0.14, 0.14, 1.00)
	clrs[clr.TitleBgActive] = im4(0.14, 0.14, 0.14, 1.00)
	clrs[clr.TitleBgCollapsed] = im4(0.14, 0.14, 0.14, 1.00)
	clrs[clr.MenuBarBg] = im4(0.14, 0.14, 0.14, 1.00)
	clrs[clr.ScrollbarBg] = im4(0.17, 0.17, 0.17, 1.00)
	clrs[clr.ScrollbarGrab] = im4(0.25, 0.25, 0.25, 1.00)
	clrs[clr.ScrollbarGrabHovered] = im4(0.25, 0.25, 0.25, 1.00)
	clrs[clr.ScrollbarGrabActive] = im4(0.25, 0.25, 0.25, 1.00)
	clrs[clr.CheckMark] = im4(0.86, 0.87, 0.90, 1.00)
	clrs[clr.SliderGrab] = im4(0.48, 0.49, 0.51, 1.00)
	clrs[clr.SliderGrabActive] = im4(0.66, 0.67, 0.69, 1.00)
	clrs[clr.Button] = im4(0.09, 0.10, 0.15, 1.00)
	clrs[clr.ButtonHovered] = im4(0.12, 0.13, 0.17, 1.00)
	clrs[clr.ButtonActive] = im4(0.07, 0.08, 0.13, 1.00)
	clrs[clr.Header] = im4(0.29, 0.34, 0.43, 1.00)
	clrs[clr.HeaderHovered] = im4(0.21, 0.24, 0.31, 1.00)
	clrs[clr.HeaderActive] = im4(0.29, 0.34, 0.43, 1.00)
	clrs[clr.Separator] = im4(0.43, 0.43, 0.50, 0.50)
	clrs[clr.SeparatorHovered] = im4(0.43, 0.43, 0.50, 0.50)
	clrs[clr.SeparatorActive] = im4(0.43, 0.43, 0.50, 0.50)
	clrs[clr.ResizeGrip] = im4(0.26, 0.59, 0.98, 0.25)
	clrs[clr.ResizeGripHovered] = im4(0.26, 0.59, 0.98, 0.67)
	clrs[clr.ResizeGripActive] = im4(0.26, 0.59, 0.98, 0.95)
	clrs[clr.PlotLines] = im4(0.61, 0.61, 0.61, 1.00)
	clrs[clr.PlotLinesHovered] = im4(1.00, 0.43, 0.35, 1.00)
	clrs[clr.PlotHistogram] = im4(0.90, 0.70, 0.00, 1.00)
	clrs[clr.PlotHistogramHovered] = im4(1.00, 0.60, 0.00, 1.00)
	clrs[clr.TextSelectedBg] = im4(0.25, 0.25, 0.25, 0.50)
  clrs[clr.CloseButton] = im4(0.40, 0.39, 0.38, 0.16)
  clrs[clr.CloseButtonHovered] = im4(0.40, 0.39, 0.38, 0.39)
  clrs[clr.CloseButtonActive] = im4(0.40, 0.39, 0.38, 1.00)
end
apply_style()