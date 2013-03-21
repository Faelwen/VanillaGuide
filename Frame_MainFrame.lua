--[[--------------------------------------------------
----- VanillaGuide -----
------------------
Frame_MainFrame.lua
Authors: mrmr
Version: 1.04.1
------------------------------------------------------
Description: 
    Powerleveling Guide for 1.12.1 servers
    based on Joana Guide
    1.00
		-- Initial Ace2 release
	1.99a
		-- Ally addition starter version
    1.03
		-- No Changes. Just adjusting "version".
    		1.99x for a beta release was a weird choise.
	1.04.1
		-- Main Frame object
------------------------------------------------------
Connection:
--]]--------------------------------------------------

--local VGuide = VGuide
Dv(" VGuide Frame_MainFrame.lua Start")

objMainFrame = {}
objMainFrame.__index = objMainFrame

function objMainFrame:new(fParent, tTexture, oSettings, oDisplay)
	fParent = fParent or nil
	local obj = {}
    setmetatable(obj, self)

    local tUI = oSettings:GetSettingsUI()

	local function Render_MF(fParent, sName, tTexture, tUI)
		local bLocked = tUI.Locked
		local tSize = tUI.MainFrameSize
		local tAnch = tUI.MainFrameAnchor
		local tColor = tUI.MainFrameColor
		local frame = CreateFrame("Frame", sName, fParent)
		frame:ClearAllPoints()
		frame:SetPoint(tAnch.sFrom, UIParent, tAnch.sTo, tAnch.nX, tAnch.nY)
		frame:SetMinResize(320,320)
		frame:SetMaxResize(640,840)
		frame:SetWidth(tSize.nWidth)
		frame:SetHeight(tSize.nHeight)
		frame:SetMovable(true)
		frame:SetResizable(true)
		if bLocked then
			frame:SetMovable(false)
			frame:SetResizable(false)
		end
		frame:SetBackdrop(tTexture.BACKDROP)
		frame:SetBackdropColor(tColor.nR, tColor.nG, tColor.nB, tColor.nA)
		frame:EnableMouse(true)
		frame:SetClampedToScreen(true)
		frame:RegisterForDrag("LeftButton")
		frame:SetScript("OnMouseDown", function()
			local fStep = getglobal("VG_MainFrame_StepFrame")
			local fScroll = getglobal("VG_MainFrame_ScrollFrame")
			local StepFrame = tUI.StepFrameVisible
			local ScrollFrame = tUI.ScrollFrameVisible
			local bLocked = tUI.Locked
			local x, y = GetCursorPosition()
			local s = this:GetEffectiveScale()
			x = x / s
			y = y / s
			local bottom = this:GetBottom();
			local top = this:GetTop();
			local left = this:GetLeft();
			local right = this:GetRight();

			local bottomStep = fStep:GetBottom()
			local topScroll = fScroll:GetTop()
			
			if arg1 == "LeftButton" and not this.isMoving and not this.isResizing and not bLocked then
				if (x < left + 5 and y < bottom + 5) then
					this:StartSizing("BOTTOMLEFT")
					this.isResizing = true
				elseif (x < left + 5 and y > top - 5) then
					this:StartSizing("TOPLEFT")
					this.isResizing = true
				elseif (x > right - 5 and y < bottom + 5) then
					this:StartSizing("BOTTOMRIGHT")
					this.isResizing = true
				elseif (x > right - 5 and y > top - 5) then
					this:StartSizing("TOPRIGHT")
					this.isResizing = true
				elseif (x < left + 5) then
					this:StartSizing("LEFT")
					this.isResizing = true
				elseif (x > right - 5) then
					this:StartSizing("RIGHT")
					this.isResizing = true
				elseif (y < bottom + 5) then
					this:StartSizing("BOTTOM")
					this.isResizing = true
				elseif (y > top - 5) then
					this:StartSizing("TOP")
					this.isResizing = true
				elseif StepFrame and ScrollFrame and 
				  (x > left + 5 and y > topScroll and y < bottomStep and x < right +5) then
					local nH = this:GetHeight()
					local nGapMin = nH * 0.85 - (nH /2)
					local nGapMax = nH * 0.45 - (nH /2)
					local nC = nH / 2
					local nT = fStep:GetTop()
					local nMinH = nC - nGapMin - 23
					local nMaxH = nC - nGapMax - 23
					fStep:SetMinResize(fStep:GetWidth(), nMinH)
					fStep:SetMaxResize(fStep:GetWidth(), nMaxH)
					fStep.isResizing = true
					fStep:StartSizing("BOTTOM")
				--elseif
				else
					this:StartMoving()
					this.isMoving = true
				end
			end
		end)
		frame:SetScript("OnMouseUp", function()
			local fStep = getglobal("VG_MainFrame_StepFrame")
			local fSlider = getglobal("VG_SettingsFrame_StepScrollSlider")
			if arg1 == "LeftButton" then
				if this.isMoving then
					this:StopMovingOrSizing()
					this.isMoving = false
					local from, _, to, x, y = this:GetPoint(1)
					tUI.MainFrameAnchor = {
						sFrom = from,
						sTo = to,
						nX = x,
						nY = y,
					}
					oSettings:SetSettingsUI(tUI)
				elseif this.isResizing then
					this:StopMovingOrSizing()
					this.isResizing = false
				end
				if fStep.isResizing then
					fStep:StopMovingOrSizing()
					fStep.isResizing = false
					local nH = fStep:GetHeight()
					local oldVal = fSlider:GetValue()
					local newVal = math.floor(nH * 100 / this:GetHeight() + 4)
					if newVal ~= oldVal then
						fSlider:SetValue(newVal)
					end
				end
			end
		end)
		frame:SetScript("OnSizeChanged", function()
			local fStep = getglobal("VG_MainFrame_StepFrame")
			local fScroll = getglobal("VG_MainFrame_ScrollFrame")
			local StepFrame = tUI.StepFrameVisible
			local ScrollFrame = tUI.ScrollFrameVisible
			local StepScroll = tUI.StepScroll
			local width = this:GetWidth()
			local height = this:GetHeight()
			if StepFrame and not ScrollFrame then
				height = height / StepScroll
			elseif StepFrame and ScrollFrame then
				local Per = height * (1 - StepScroll)
				local Gap = Per - (height / 2)
				fStep:SetPoint("BOTTOMRIGHT", this, "RIGHT", -5, Gap)
				fScroll:SetPoint("TOPLEFT", fStep, "BOTTOMLEFT", 0, -2)
			end
			--VGuide.db.char.UIoptions.MainFrameSize.nWidth = width
			--VGuide.db.char.UIoptions.MainFrameSize.nHeight = height
			tUI.MainFrameSize = {
				nWidth = width,
				nHeight = height,
			}
			oSettings:SetSettingsUI(tUI)
		end)
		frame:SetScript("OnHide", function()
			if this.isMoving then
				this:StopMovingOrSizing();
				this.isMoving = false;
			end
			if this.isResizing then
				this:StopMovingOrSizing();
				this.isResizing = false;
			end
		end)
		return frame
    end
	local function Render_MFTitle(fParent, sName)
		local version = GetAddOnMetadata("VanillaGuide", "Version")
		local fs = fParent:CreateFontString(sName, "ARTWORK", "GameFontNormalSmall")
		fs:SetPoint("TOPLEFT", fParent, "TOPLEFT", 31, -6)
		fs:SetTextColor(.91, .79, .11, 1)
		fs:SetJustifyH("CENTER")
		fs:SetJustifyV("CENTER")
		fs:SetText("|cccff1919Vanilla|ccceeeeeeGuide |ccca1a1a1v|ccc4a4aa1" .. version .. "|r")
		return fs
    end
    local function Render_Button(fParent, sName, nWidth, nHeight, tTexture)
		local btn = CreateFrame("Button", sName, fParent)
		btn:SetWidth(nWidth)
		btn:SetHeight(nHeight)
		btn:SetNormalTexture(tTexture.NORMAL)
		btn:SetPushedTexture(tTexture.PUSHED)
		btn:SetHighlightTexture(tTexture.HIGHLIGHT)
		btn:RegisterForClicks("LeftButtonUp")
		return btn
    end
    local function Render_MFStepNumberFrame(fParent, sName, nWidth, nHeight, tTexture)
		local frame = CreateFrame("Frame", sName, fParent)
		frame:SetWidth(nWidth)
		frame:SetHeight(nHeight)
		frame:SetBackdrop(tTexture.BACKDROP)
		frame:SetBackdropColor(.1, .1, .1, .9)
		return frame
    end
    local function Render_MFStepNumberLabel(fParent, sName)
		local fs = fParent:CreateFontString(sName, "ARTWORK", "GameFontNormalSmall")
		fs:SetPoint("CENTER", fParent, "CENTER", 0, 0)
		fs:SetTextColor(.71, .71, .71, 1)
		fs:SetJustifyH("CENTER")
		fs:SetJustifyV("CENTER")
		return fs
    end
    local function Render_MFDropDownMenu(fParent, sName)
		local frame= CreateFrame("Frame", sName, fParent)
		frame.UncheckHack = function()
		  --_G[this:GetName().."Check"]:Hide()
		  getglobal(this:GetName().."Check"):Hide()
		end
		frame.displayMode = "MENU"
		frame.info = {}

		frame:SetHeight(25)
		frame:SetWidth(25)
    	return frame
    end
    local function Render_MFDropDownMenuZoneFrame(fParent, sName, tTexture)
		local frame = CreateFrame("Frame", sName, fParent)
		frame:SetBackdrop(tTexture.BACKDROP);
		frame:SetBackdropColor(.1, .1, .1, .7)
		return frame
    end
    local function Render_MFDropDownMenuZoneLabel(fParent, sName)
		local fs = fParent:CreateFontString(sName, "ARTWORK", "GameFontNormalSmall")
		fs:SetTextColor(.91, .91, .91, 1)
		fs:SetJustifyH("CENTER")
		fs:SetJustifyV("CENTER")
		fs:SetPoint("BOTTOMLEFT", fParent, "BOTTOMLEFT", 15, 6)
		return fs
	end
	local function Render_MFStepFrame(fParent, sName, tTexture, tUI)
		local tColor = tUI.StepFrameColor
		local frame = CreateFrame("Frame", sName, fParent)
		frame:SetResizable(true)
		frame:SetBackdrop(tTexture.BACKDROP)
		frame:SetBackdropColor(tColor.nR, tColor.nG, tColor.nB, tColor.nA)
		--frame:SetScript("OnSizeChanged" , function()
		--end)
		frame:SetScript("OnHide" , function()
			if this.isMoving then
				this:StopMovingOrSizing();
				this.isMoving = false;
			end
			if this.isResizing then
				this:StopMovingOrSizing();
				this.isResizing = false;
			end
		end)
		return frame
    end
    local function Render_MFStepLabel(fParent, sName, tUI)
		local tColor = tUI.StepFrameTextColor
		local fs = fParent:CreateFontString(sName, "ARTWORK", "GameFontNormalSmall")
		fs:SetPoint("TOPLEFT", fParent, "TOPLEFT", 5, -5)
		fs:SetPoint("BOTTOMRIGHT", fParent, "BOTTOMRIGHT", -5, 5)
		--fs:SetTextColor(.91, .91, .91, .99)
		fs:SetTextColor(tColor.nR, tColor.nG, tColor.nB, tColor.nA)
		fs:SetJustifyH("LEFT")
		fs:SetJustifyV("TOP")
		return fs
    end

    local function Render_MFScrollFrame(fParent, sName, tTexture, tUI)
		local tColor = tUI.ScrollFrameColor
		local frame = CreateFrame("ScrollFrame", sName, fParent)
		frame:SetBackdrop(tTexture.BACKDROP)
		frame:SetBackdropColor(tColor.nR, tColor.nG, tColor.nB, tColor.nA)
		frame:EnableMouseWheel(true)
		frame:SetScript("OnSizeChanged", function()
			obj:RefreshScrollFrame()
		end)
		frame:SetScript("OnMouseWheel", function()
			local fSlider = getglobal("VG_MainFrame_ScrollFrameSlider")
			local current = fSlider:GetValue()
			local step = fSlider:GetValueStep()
			local smin, smax = fSlider:GetMinMaxValues()
			local delta = arg1
			if IsShiftKeyDown() and (delta > 0) then
				fSlider:SetValue(0)
			elseif IsShiftKeyDown() and (delta < 0) then
				fSlider:SetValue(smax)
			elseif (delta < 0) and (current < smax) then
				fSlider:SetValue(current + 20)
			elseif (delta > 0) and (current > 1) then
				fSlider:SetValue(current - 20)
			end
		end)
		return frame
    end

    local function Render_MFScrollFrameChild(fParent, sName)
		local nScrollFrameChildWidth = fParent:GetWidth() - 10
		local nScrollFrameChildHeight = fParent:GetHeight() - 10
		local frame = CreateFrame("Frame", sName, fParent)
		frame:SetWidth(nScrollFrameChildWidth)
		frame:SetHeight(nScrollFrameChildHeight)
		return frame
    end
    local function Render_MFScrollFrameSlider(fParent, sName)
		local sld = CreateFrame("Slider", sName, fParent)
		sld.background = sld:CreateTexture(nil, "BACKGROUND")
		sld.background:SetAllPoints(true)
		sld.background:SetTexture(.0, .0, .0, 0.5)
		sld.thumb = fParent:CreateTexture(nil, "OVERLAY")
		--sld.thumb:SetTexture("Interface\\AddOns\\VGuide\\textures\\flash-up-round")
		sld.thumb:SetTexture("Interface\\Buttons\\UI-ScrollBar-Knob")
		sld.thumb:SetWidth(31)
		sld.thumb:SetHeight(31)
		sld:SetThumbTexture(sld.thumb)
		sld:SetWidth(14)
		sld:SetOrientation("VERTICAL");
		sld:SetValueStep(10)
		sld:SetScript("OnValueChanged", function()
			local fScroll = getglobal("VG_MainFrame_ScrollFrame")
			fScroll:SetVerticalScroll(arg1)
		end)
		return sld
    end
    --local function ChangeView(nMainFrameHeight, bStepFrame, bScrollFrame, tUI)
    local function ChangeView(tUI)
		local fMain = getglobal("VG_MainFrame")
		local fStep = getglobal("VG_MainFrame_StepFrame")
		local fScroll = getglobal("VG_MainFrame_ScrollFrame")
		--local fChild = getglobal("VG_MainFrame_ScrollFrameChild")
		--local fSlider = getglobal("VG_MainFrame_ScrollFrameSlider")
		local nStepScroll = tUI.StepScroll
		local bStepFrame = tUI.StepFrameVisible
		local bScrollFrame = tUI.ScrollFrameVisible
		local nMainFrameHeight = tUI.MainFrameSize.nHeight

		if bScrollFrame then
			fMain:SetHeight(nMainFrameHeight)
			fMain:SetMinResize(320, 320)
			fMain:SetMaxResize(640, 640)
		else
			fMain:SetHeight(nMainFrameHeight*nStepScroll)
			fMain:SetMinResize(320, 320*nStepScroll)
			fMain:SetMaxResize(640, 640*nStepScroll)
		end
		if bStepFrame and not bScrollFrame then
			fScroll:Hide()
			fStep:SetPoint("BOTTOMRIGHT", fMain, "BOTTOMRIGHT", -5, 27)
			fStep:Show()
		elseif not bStepFrame and bScrollFrame then
			fStep:Hide()
			fScroll:SetPoint("TOPLEFT", fMain, "TOPLEFT", 5, -23)
			fScroll:Show()
		elseif bStepFrame and bScrollFrame then
			local nH =  fMain:GetHeight()
			local nGap = (nH - 2 * nStepScroll * nH) / 2
			fStep:SetPoint("BOTTOMRIGHT", fMain, "RIGHT", -5, nGap)
			fScroll:SetPoint("TOPLEFT", fStep, "BOTTOMLEFT", 0, -2)
			fStep:Show()
			fScroll:Show()
		end
    end

	obj.tWidgets = {}
    -------------------------------
    --- Rendering
    -------------------------------
    --do
	-- Addon Main Frame and Title
		--obj.obj.tWidgets.frame_MainFrame = Render_MF(UIParent, "VG_MainFrame")
		obj.tWidgets.frame_MainFrame = Render_MF(nil, "VG_MainFrame", tTexture, tUI)
		obj.tWidgets.frame_MainFrame.isMoving = nil
		obj.tWidgets.frame_MainFrame.isResizing = nil
		obj.tWidgets.fs_Title = Render_MFTitle(obj.tWidgets.frame_MainFrame, nil)
	-- Close, Settings and About Buttons
		obj.tWidgets.button_CloseButton = Render_Button(obj.tWidgets.frame_MainFrame, nil, 16, 16, tTexture.B_CLOSE)
		obj.tWidgets.button_CloseButton:SetPoint("TOPRIGHT", obj.tWidgets.frame_MainFrame, "TOPRIGHT", -6, -5)
		obj.tWidgets.button_SettingsButton = Render_Button(obj.tWidgets.frame_MainFrame, nil, 20, 20, tTexture.B_OPTION)
		obj.tWidgets.button_SettingsButton:SetPoint("BOTTOMRIGHT", obj.tWidgets.frame_MainFrame, "BOTTOMRIGHT", -6, 5)
		obj.tWidgets.button_AboutButton = Render_Button(obj.tWidgets.frame_MainFrame, nil, 20, 20, tTexture.B_ABOUT)
		obj.tWidgets.button_AboutButton:SetPoint("BOTTOMRIGHT", obj.tWidgets.frame_MainFrame, "BOTTOMRIGHT", -27, 5)
   	-- Lock Button
		if tUI.Locked then
			obj.tWidgets.button_LockButton = Render_Button(obj.tWidgets.frame_MainFrame, nil, 16, 16, tTexture.B_LOCKED)
		else
			obj.tWidgets.button_LockButton = Render_Button(obj.tWidgets.frame_MainFrame, nil, 16, 16, tTexture.B_UNLOCKED)
		end
		obj.tWidgets.button_LockButton:SetPoint("TOPLEFT", obj.tWidgets.frame_MainFrame, "TOPLEFT", 6, -5)
	-- ChangeView Button
		obj.tWidgets.button_ChangeViewButton = Render_Button(obj.tWidgets.frame_MainFrame, nil, 16, 16, tTexture.B_FLASH)
		obj.tWidgets.button_ChangeViewButton:SetPoint("TOPRIGHT", obj.tWidgets.frame_MainFrame, "TOPRIGHT", -105, -5)
    -- Prev and Next Guide Buttons
		obj.tWidgets.button_PrevGuideButton = Render_Button(obj.tWidgets.frame_MainFrame, nil, 25, 16, tTexture.B_DOUBLEARROWLEFT)
		obj.tWidgets.button_PrevGuideButton:SetPoint("BOTTOMRIGHT", obj.tWidgets.frame_MainFrame, "BOTTOMRIGHT", -75, 7)
		obj.tWidgets.button_NextGuideButton = Render_Button(obj.tWidgets.frame_MainFrame, nil, 25, 16, tTexture.B_DOUBLEARROWRIGHT)
		obj.tWidgets.button_NextGuideButton:SetPoint("BOTTOMRIGHT", obj.tWidgets.frame_MainFrame, "BOTTOMRIGHT", -50, 7)
	-- DropDown Menu, Button, ZoneFrame and ZoneLabel
		obj.tWidgets.frame_DropDownMenu = Render_MFDropDownMenu(obj.tWidgets.frame_MainFrame, "VG_MainFrame_DropDownMenu")
		obj.tWidgets.frame_DropDownMenu:SetPoint("TOPLEFT", obj.tWidgets.frame_MainFrame, "BOTTOMLEFT", 12, 26)
		obj.tWidgets.frame_DropDownMenu:SetPoint("BOTTOMRIGHT", obj.tWidgets.frame_MainFrame, "BOTTOMLEFT", 22, 3)
		obj.tWidgets.button_DropDownMenu = Render_Button(obj.tWidgets.frame_DropDownMenu, nil, 16, 16, tTexture.B_DDMRIGHT_DOWN)
		obj.tWidgets.button_DropDownMenu:SetPoint("CENTER", obj.tWidgets.frame_DropDownMenu, "LEFT", 3, 0)
		obj.tWidgets.button_DropDownMenu:RegisterForClicks("LeftButtonUp", "RightButtonUp")
		obj.tWidgets.frame_DropDownMenuZoneFrame = Render_MFDropDownMenuZoneFrame(obj.tWidgets.frame_DropDownMenu, nil, tTexture)
		obj.tWidgets.frame_DropDownMenuZoneFrame:SetPoint("TOPLEFT", obj.tWidgets.frame_DropDownMenu, "TOPLEFT", 5, -2)
		obj.tWidgets.frame_DropDownMenuZoneFrame:SetPoint("BOTTOMRIGHT", obj.tWidgets.button_PrevGuideButton, "LEFT", -5, -10)
		obj.tWidgets.fs_DropDownMenuZone = Render_MFDropDownMenuZoneLabel(obj.tWidgets.frame_DropDownMenuZoneFrame, "VG_MainFrame_DropDownMenuLabel")
    -- Pren and Next Step Buttons
		obj.tWidgets.button_PrevStepButton = Render_Button(obj.tWidgets.frame_MainFrame, nil, 25, 16, tTexture.B_DOUBLEARROWLEFT)
		obj.tWidgets.button_PrevStepButton:SetPoint("TOPRIGHT", obj.tWidgets.frame_MainFrame, "TOPRIGHT", -76, -5)
		obj.tWidgets.button_NextStepButton = Render_Button(obj.tWidgets.frame_MainFrame, nil, 25, 16, tTexture.B_DOUBLEARROWRIGHT)
		obj.tWidgets.button_NextStepButton:SetPoint("TOPRIGHT", obj.tWidgets.frame_MainFrame, "TOPRIGHT", -26, -5)
	-- Step Number Frame & Label
		obj.tWidgets.frame_StepNumberFrame = Render_MFStepNumberFrame(obj.tWidgets.frame_MainFrame, nil, 25, 18, tTexture)
		obj.tWidgets.frame_StepNumberFrame:SetPoint("TOPRIGHT", obj.tWidgets.frame_MainFrame, "TOPRIGHT", -51, -4)
		obj.tWidgets.fs_StepNumber = Render_MFStepNumberLabel(obj.tWidgets.frame_StepNumberFrame, "VG_MainFrame_StepNumberFrameLabel")
	-- Step Frame & Label
		obj.tWidgets.frame_StepFrame = Render_MFStepFrame(obj.tWidgets.frame_MainFrame, "VG_MainFrame_StepFrame", tTexture, tUI)
		obj.tWidgets.frame_StepFrame:SetPoint("TOPLEFT", obj.tWidgets.frame_MainFrame, "TOPLEFT", 5, -23)
		--  Uncomment those will just make the frame visible at start, but we call GuideChange just after, so, not needed here
		-- see ***
		--local fMHeight = obj.tWidgets.fMF:GetHeight()
		--local nPer = fMHeight * (1 - tUIoptions.nStepScroll)
		--local nGap = nPer - (fMHeight/2)
		--obj.tWidgets.frame_StepFrame:SetPoint("BOTTOMRIGHT", obj.tWidgets.frame_MainFrame, "RIGHT", -5, nGap)
		obj.tWidgets.fs_StepFrame = Render_MFStepLabel(obj.tWidgets.frame_StepFrame, "VG_MainFrame_StepFrameLabel", tUI)
	-- Scroll Frame, ScrollChild and Slider
		obj.tWidgets.frame_ScrollFrame = Render_MFScrollFrame(obj.tWidgets.frame_MainFrame, "VG_MainFrame_ScrollFrame", tTexture, tUI)
		-- ***
		--obj.tWidgets.frame_ScrollFrame:SetPoint("TOPLEFT", obj.tWidgets.frame_StepFrame, "BOTTOMLEFT", 0, -2)
		obj.tWidgets.frame_ScrollFrame:SetPoint("BOTTOMRIGHT", obj.tWidgets.frame_MainFrame, "BOTTOMRIGHT", -25, 27)
		obj.tWidgets.frame_ScrollFrameChild = Render_MFScrollFrameChild(obj.tWidgets.frame_ScrollFrame, "VG_MainFrame_ScrollFrameChild")
		obj.tWidgets.frame_ScrollFrameChild.Entries = {}
		obj.tWidgets.frame_ScrollFrameChild.nFSTotalWidth = 0
		obj.tWidgets.frame_ScrollFrameChild.nFSTotalHeight = 0
		--obj.tWidgets.frame_ScrollFrameChild.nSHTotalWidth = 0
		--obj.tWidgets.frame_ScrollFrameChild.nSHTotalHeight = 0
		obj.tWidgets.frame_ScrollFrameChild:SetPoint("TOPLEFT", obj.tWidgets.frame_ScrollFrame, "TOPLEFT", 0, 0)
		obj.tWidgets.frame_ScrollFrameChild:SetPoint("BOTTOMRIGHT", obj.tWidgets.frame_ScrollFrame, "BOTTOMRIGHT", 0, 0)
		obj.tWidgets.slider_ScrollFrameSlider = Render_MFScrollFrameSlider(obj.tWidgets.frame_ScrollFrame, "VG_MainFrame_ScrollFrameSlider")
		obj.tWidgets.slider_ScrollFrameSlider:SetPoint("TOPLEFT", obj.tWidgets.frame_ScrollFrame, "TOPRIGHT", 2, -5)
		obj.tWidgets.slider_ScrollFrameSlider:SetPoint("BOTTOMLEFT", obj.tWidgets.frame_ScrollFrame, "BOTTOMRIGHT", 2, 5)
	--end

	-------------------------------
    --- UI Events Handling
    -------------------------------
	do
    -- Close Button
    	--obj.tWidgets.button_CloseButton:SetScript("OnClick", objMainFrame:HideFrame())
		obj.tWidgets.button_CloseButton:SetScript("OnClick", function()
			local fMain = getglobal("VG_MainFrame")
			local fSettings = getglobal("VG_SettingsFrame")
			local fAbout = getglobal("VG_AboutFrame")
			fMain:Hide()
			if fSettings:IsVisible() then
				fSettings:Hide()
				fSettings.showthis = true
			end
			if fAbout:IsVisible() then
				fAbout:Hide()
			end
		end)
	-- Lock Button
		obj.tWidgets.button_LockButton:SetScript("OnClick", function()
			local bLocked = tUI.Locked
			local frame = getglobal("VG_MainFrame")
			if bLocked then
				this:SetNormalTexture(tTexture.B_UNLOCKED.NORMAL)
				this:SetPushedTexture(tTexture.B_UNLOCKED.PUSHED)
				--tUIoptions.Locked = false
				--VGuide.db.profile.UIoptions.Locked = false
				tUI.Locked = false
				oSettings:SetSettingsUI(tUI)
				frame:SetMovable(true)
				frame:SetResizable(true)
			else
				this:SetNormalTexture(tTexture.B_LOCKED.NORMAL)
				this:SetPushedTexture(tTexture.B_LOCKED.PUSHED)
				--tUIoptions.Locked = true
				--VGuide.db.profile.UIoptions.Locked = true
				--VGuide.db.char.UIoptions.Locked = true
				tUI.Locked = true
				oSettings:SetSettingsUI(tUI)
				frame:SetMovable(false)
				frame:SetResizable(false)
			end
		end)
	-- Settings Button
		--obj.tWidgets.button_SettingsButton:SetScript("OnClick", objSettingsFrame:Hide())
		obj.tWidgets.button_SettingsButton:SetScript("OnClick", function()
			local fSettings = getglobal("VG_SettingsFrame")
			if fSettings:IsVisible() then
				fSettings:Hide()
			else
				fSettings:Show()
			end
		end)
	-- About Button
		--obj.tWidgets.button_AboutButton:SetScript("OnClick", objAboutFrame:Hide())
		obj.tWidgets.button_AboutButton:SetScript("OnClick", function()
		  local fAbout = getglobal("VG_AboutFrame")
		  if fAbout:IsVisible() then
			fAbout:Hide()
		  else
			fAbout:Show()
		  end
		end)
	-- Change View Button
		obj.tWidgets.button_ChangeViewButton:SetScript("OnClick", function()
			local fChild = getglobal("VG_MainFrame_ScrollFrameChild")
			local bStepFrame = tUI.StepFrameVisible
			local bScrollFrame = tUI.ScrollFrameVisible
			local nMainFrameHeight = tUI.MainFrameSize.nHeight

			if bStepFrame and bScrollFrame then
				bStepFrame = true
				bScrollFrame = false
			elseif bStepFrame and not bScrollFrame then
				bStepFrame = false
				bScrollFrame = true
			else
				bStepFrame = true
				bScrollFrame = true
			end
			--ChangeView(nMainFrameHeight, bStepFrame, bScrollFrame)
			--tUIoptions.StepFrameVisible = bStepFrame
			--tUIoptions.ScrollFrameVisible = bScrollFrame
			--VGuide.db.profile.UIoptions.StepFrameVisible = bStepFrame
			--VGuide.db.profile.UIoptions.ScrollFrameVisible = bScrollFrame
			--VGuide.db.char.UIoptions.StepFrameVisible = bStepFrame
			--VGuide.db.char.UIoptions.ScrollFrameVisible = bScrollFrame
			tUI.StepFrameVisible = bStepFrame
			tUI.ScrollFrameVisible = bScrollFrame
			oSettings:SetSettingsUI(tUI)
			ChangeView(tUI)
			--UI.SetSliderMinMax(fChild.nFSTotalHeight)
		end)
	-- Prev and Next Guide Buttons
		obj.tWidgets.button_PrevGuideButton:SetScript("OnClick", function()
			--GuideChange(oDisplay, "BACKWARD")
			--Dv("     --- Prev Guide ---")
			oDisplay:PrevGuide()
			obj:RefreshData()
		end)
		obj.tWidgets.button_NextGuideButton:SetScript("OnClick", function()
			--GuideChange(oDisplay, "FORWARD")
			--Dv("     --- Next Guide ---")
			oDisplay:NextGuide()
			obj:RefreshData()
		end)
	-- Prev and Next Step Buttons
		obj.tWidgets.button_PrevStepButton:SetScript("OnClick", function()
			--Dv("     --- Prev Step ---")
			--[[
			local tColF = tUIoptions.StepFrameColor
			local fChild = getglobal("VG_MainFrame_ScrollFrameChild")
			local locX, locY, zone
			local step = oDisplay:GetStep()
			fChild.shEntryHandle[step]:SetBackdropColor(.1, .1, .1, .5)
			locX, locY, zone = StepChange(oDisplay, "Backward")
			local step = oDisplay:GetStep()
			fChild.shEntryHandle[step]:SetBackdropColor(tColF.nR, tColF.nG, tColF.nB, tColF.nA)
			if VGuide.db.char.MetaMapBWPSupportEnable then
				UI.SetMetaMapBWPDestination(locX, locY, zone)
			end
			]]
			oDisplay:PrevStep()
			obj:RefreshData()
		end)
		obj.tWidgets.button_NextStepButton:SetScript("OnClick", function()
			--Dv("     --- Next Step ---")
			--[[
			local tColF = tUIoptions.StepFrameColor
			local fChild = getglobal("VG_MainFrame_ScrollFrameChild")
			local locX, locY, zone
			local step = oDisplay:GetStep()
			fChild.shEntryHandle[step]:SetBackdropColor(.1, .1, .1, .5)
			locX, locY, zone = StepChange(oDisplay, "Forward")
			local step = oDisplay:GetStep()
			fChild.shEntryHandle[step]:SetBackdropColor(tColF.nR, tColF.nG, tColF.nB, tColF.nA)
			if VGuide.db.char.MetaMapBWPSupportEnable then
				UI.SetMetaMapBWPDestination(locX, locY, zone)
			end
			]]
			oDisplay:NextStep()
			obj:RefreshData()
		end)
	-- DropDown Menu
		obj.tWidgets.button_DropDownMenu:SetScript("OnClick", function()
			ToggleDropDownMenu(1, nil, obj.tWidgets.frame_DropDownMenu, obj.tWidgets.button_DropDownMenu, 0, 0);
		end)
	end

	-------------------------------
	--- External Methods 
	-------------------------------

	obj.RefreshStepFrameLabel = function(self)
		local s = oDisplay:GetStepLabel()
		local fs = obj.tWidgets.fs_StepFrame
		fs:SetText(s)
	end

	obj.RefreshStepNumberFrameLabel = function(self)
		local t = oDisplay:GetCurrentStep()
		local fs = obj.tWidgets.fs_StepNumber
		fs:SetText(t)
	end

	obj.RefreshDropDownMenuLabel = function(self)
		local t = oDisplay:GetGuideTitle()
		local fs = obj.tWidgets.fs_DropDownMenuZone
		fs:SetText(t)
	end

	obj.ScrollFrameChildEntriesCreate = function(self, tEntries)
		local UI = oSettings:GetSettingsUI()
		local tColF = UI.StepFrameColor
		local tColT = UI.ScrollFrameTextColor
		
		local sfc = obj.tWidgets.frame_ScrollFrameChild
		sfc:Hide()
		
		t = {}
		for k,_ in ipairs(tEntries) do
			local sh
			sh = CreateFrame("SimpleHTML", "VG_shEntry"..k, sfc)
			sh:Hide()
			sh:EnableMouse(true)
			sh:SetFont(tTexture.FONT_PATH, tTexture.FONT_HEIGHT)
			sh:SetTextColor(tColT.nR, tColT.nG, tColT.nB, tColT.nA)
			sh:SetBackdrop(tTexture.BACKDROPSH)
			sh:SetBackdropColor(.1, .1, .1, .5)
			sh:SetJustifyH("LEFT")
			sh:SetJustifyV("TOP")
			if k > 1 then
				sh:SetPoint("TOPLEFT", t[k-1], "BOTTOMLEFT", 0, -tTexture.SCROLLFRAME_PADDING)
			else
				sh:SetPoint("TOPLEFT", sfc, "TOPLEFT", 5, -15)
			end
			sh:SetScript("OnEnter", function()
				this:SetTextColor(.91, .91, .91, .99)
				this:SetBackdropColor(.3, .3, .3, .7)
				local tx = tonumber(strsub(this:GetName(), 11))
			end)
			sh:SetScript("OnLeave", function()
				local UI = oSettings:GetSettingsUI()
				local tColF = UI.StepFrameColor
				local step = oDisplay:GetCurrentStep()
			    local tx = tonumber(strsub(this:GetName(), 11))
				this:SetTextColor(tColT.nR, tColT.nG, tColT.nB, tColT.nA)
				if tx == step then
					this:SetBackdropColor(tColF.nR, tColF.nG, tColF.nB, tColF.nA)
				else
					this:SetBackdropColor(.1, .1, .1, .5)
				end
			end)
			sh:SetScript("OnMouseUp", function()
				if arg1 == "LeftButton" then
					local step = oDisplay:GetCurrentStep()
					this:GetParent().Entries[step]:SetBackdropColor(.1, .1, .1, .5)
					local tx = strsub(this:GetName(), 11)
					oDisplay:StepByID(tonumber(tx))
					obj:RefreshData(false)
					--local locX, locY, zone
					--locX, locY, zone = StepChange(VGuide.UI.Display, "Step", tonumber(t))
					--if VGuide.db.char.MetaMapBWPSupportEnable then
					--	UI.SetMetaMapBWPDestination(locX, locY, zone)
					--end
				end
			end)
			t[k] = sh
		end
		sfc:Show()
		return t
	end

	obj.ScrollFrameChildEntriesHide = function(self)
		for _,v in ipairs(obj.tWidgets.frame_ScrollFrameChild.Entries) do
			v:Hide()
		end
	end

	-- not needed?
	obj.ScrollFrameChildEntriesDelete = function(self)
		for k,_ in ipairs(obj.tWidgets.frame_ScrollFrameChild.Entries) do
			obj.tWidgets.frame_ScrollFrameChild.Entries[k] = nil
		end
	end
	-- not needed?
	obj.ScrollFrameChildEntriesCount = function(self)
		local count = 0
		for _,_ in ipairs(obj.tWidgets.frame_ScrollFrameChild.Entries) do
			count = count + 1
		end
		return count
	end

	obj.RefreshScrollFrame = function(self)
		local function ScrollFrameChildHeight(tTexture, nWidth, tEntries)
			tEntries.textWidth = {}
			tEntries.textHeight = {}
			local tHeight = 0
			local frame = CreateFrame("Frame", nil, nil)
			local fs = frame:CreateFontString(nil, "ARTWORK", tTexture.FONT)
			fs:SetFont(tTexture.FONT_PATH, tTexture.FONT_HEIGHT)
			nWidth = math.floor(nWidth)
			for k,v in ipairs(tEntries) do
				fs:SetText(tEntries[k])
				tEntries.textWidth[k] = fs:GetWidth()
				local val = math.floor((tEntries.textWidth[k]) / (nWidth))
				tEntries.textHeight[k] = (val + 1) * tTexture.FONT_HEIGHT + 5
				tHeight = tHeight + tEntries.textHeight[k] + tTexture.SCROLLFRAME_PADDING
			end
			return tHeight, tEntries
		end

		local fMain = obj.tWidgets.frame_MainFrame
		local fScroll = obj.tWidgets.frame_ScrollFrame
		local fChild = obj.tWidgets.frame_ScrollFrameChild
		local fSlider = obj.tWidgets.slider_ScrollFrameSlider

		local mainFrameWidth = fMain:GetWidth()
		local scrollFrameWidth = fScroll:GetWidth()

		local s = fScroll:GetEffectiveScale()
		scrollFrameWidth = scrollFrameWidth * (1/s)

		obj:ScrollFrameChildEntriesHide()
		--obj:ScrollFrameChildEntriesDelete()
		
		local t = {}
		t = oDisplay:GetScrollFrameDisplay()
		fChild.Entries = obj:ScrollFrameChildEntriesCreate(t)

		-- inside t we've the "lenght" of the rendered string
		-- We need this to get how many lines there are in every 
		-- ScrollFrameChildEntries entity
		local totalHeight = 0
		totalHeight, t = ScrollFrameChildHeight(tTexture, scrollFrameWidth, t)

		-- let's see if we need a slider or not....
		-- ...ohh...and let's set the slider object accordingly
		-- we use the totalHeight from plain string to decide this...
		local nFrameH = nil
		local sliderVisible = nil
		local shWidth = nil
		nFrameH = fScroll:GetHeight() + 5
		if totalHeight - nFrameH + 10 > 0 then
			fSlider:SetMinMaxValues(0, totalHeight - nFrameH + 10)
			fSlider:Show()
			fScroll:SetPoint("BOTTOMRIGHT", fMain, "BOTTOMRIGHT", -25, 27)
			sliderVisible = true
			shWidth = mainFrameWidth - 40
		else
			fSlider:SetMinMaxValues(0, 0)
			fSlider:SetValue(0)
			fSlider:Hide()
			fScroll:SetPoint("BOTTOMRIGHT", fMain, "BOTTOMRIGHT", -5, 27)
			sliderVisible = false
			shWidth = mainFrameWidth - 40 + 20
		end

		-- we now zero totalHeight, and we rebuild it, frameXframe, to get the total
		-- ScrollFrameChild total height
		totalHeight = 0
		local UI = oSettings:GetSettingsUI()
		local tColF = UI.StepFrameColor
		for k, v in pairs(fChild.Entries) do
			if k <= oDisplay:GetCurrentStepCount() then
				if not sliderVisible then
					local val = math.floor(t.textWidth[k] / (scrollFrameWidth + 20))
					t.textHeight[k] = (val+1) * tTexture.FONT_HEIGHT + 5
				end
				totalHeight = totalHeight + t.textHeight[k] + tTexture.SCROLLFRAME_PADDING
				v:SetWidth(shWidth)
				v:SetHeight(t.textHeight[k])
				v:SetText(t[k])
				v:Show()
				v.scrollFrameWidth = scrollFrameWidth
				v.textHeight = t.textHeight[k]
				v.textWidth = t.textWidth[k]
				if k == oDisplay:GetCurrentStep() then
					v:SetBackdropColor(tColF.nR, tColF.nG, tColF.nB, tColF.nA)
				else
					v:SetBackdropColor(.1, .1, .1, .5)
				end
			else
				v:Hide()
				v = nil
			end
		end
		totalHeight = totalHeight - tTexture.SCROLLFRAME_PADDING
		fChild:SetHeight(totalHeight)
		fScroll:UpdateScrollChildRect()
	end

	obj.RefreshMetaMapBWP = function(self)
		local t = oDisplay:GetCurrentStepInfo()
		obj:SetMetaMapBWPDestination(t.x, t.y, t.zone)
	end

	obj.RefreshData = function(self)
		obj:RefreshStepFrameLabel()
		obj:RefreshStepNumberFrameLabel()
		obj:RefreshDropDownMenuLabel()
		obj:RefreshDropDownMenuLabel()
		obj:RefreshScrollFrame()
		local tMetaMapBWP = oSettings:GetSettingsMetaMapBWP()
		if tMetaMapBWP.Support and tMetaMapBWP.Enable then
			obj:RefreshMetaMapBWP()
		end
	end

	local function AddToDDM(nLevel, sType, sLabel, nID)
		local info = {}
		info.isTitle = false
		
		info.keepShownOnClick = false
		info.disabled = nil
		
		info.notCheckable = true --1?

		info.text = sLabel
		info.value = sLabel
    	info.arg1 = nID
    	info.arg2 = sLabel
    	if sType == "s" then
    		info.hasArrow = true
			info.func = this.UncheckHack
		else
			info.hasArrow = false --nil?
			info.func = function(arg1, arg2)
				oDisplay:GuideByID(arg1)
				obj:RefreshData()
          		CloseDropDownMenus()
			end
		end
		UIDropDownMenu_AddButton(info, nLevel)
	end

	local function DropDown_Init(level)		
		local tDDM = oDisplay:RetriveTableDDM()
		local tCharInfo = oSettings:GetSettingsCharInfo()
		local info = {}
		level = level or 1
		if level == 1 then
			-- Title
			info.isTitle = 1
			info.text = "Vanilla Guide"
			info.notCheckable = true
			UIDropDownMenu_AddButton(info, level)
			-- Voices from Table DDM
			for k,v in ipairs(tDDM.lvl1) do
				AddToDDM(level, v[1], v[2], v.id)
			end
			-- Close menu item
			info.text = CLOSE--"Close"
			info.keepShownOnClick = false
			info.disabled = nil
			info.hasArrow = nil
			info.notCheckable = 1
			info.value = nil
			info.func = function()
				CloseDropDownMenus()
			end
			UIDropDownMenu_AddButton(info, level)
		elseif level == 2 then
			local s = UIDROPDOWNMENU_MENU_VALUE
			if s == "Starting Zones" then
				if tCharInfo.Faction == "Horde" then
					s = "[H] " .. s
				else
					s = "[A] " .. s
				end
			end
			for k,v in ipairs(tDDM.lvl2[s]) do
				AddToDDM(level, v[1], v[2], v.id)
			end
		elseif level == 3 then
			local s = UIDROPDOWNMENU_MENU_VALUE
			-- to handle both factions, we check if there's a 0 at the 4th place!
			-- so that we won't get in the way of Starting Zones
			if string.find(s, "0", 4) then
				if tCharInfo.Faction == "Horde" then
					s = "[H] " .. s
				else
					s = "[A] " .. s
				end
			end
			for k,v in ipairs(tDDM.lvl3[s]) do
				AddToDDM(level, v[1], v[2], v.id)
			end
		end
	end

	obj.InitializeDDM = function(self)
		UIDropDownMenu_Initialize(obj.tWidgets.frame_DropDownMenu, DropDown_Init)
	end

	obj.SetMetaMapBWPDestination = function(self, nX, nY, sZone)
		local fBWP_DisplayFrame = getglobal("BWP_DisplayFrame")
		local sBWPDistanceText = getglobal("BWPDistanceText")
		local sBWPDestText = getglobal("BWPDestText")
		--local fsetmininote = getglobal("setmininote")
		--local fMetaMapNotes_AddNewNote = getglobal("MetaMapNotes_AddNewNote")

		if not fBWP_DisplayFrame or not sBWPDestText or not sBWPDistanceText then --or not fsetmininote then
			Dv("  ??? BWP not working :P")
		elseif nX and nY and sZone then
			local continent, zone = MetaMap_NameToZoneID(GetRealZoneText())

			BWP_Destination = {}
			BWP_Destination.name = sZone
			BWP_Destination.x = nX/100
			BWP_Destination.y = nY/100
			BWP_Destination.zone = MetaMap_ZoneNames[continent][zone]
			if sZone == BWP_Destination.zone then
				local frame = getglobal("BWPDestText")
				frame:SetText("["..BWP_Destination.name.."] - [" .. BWP_Destination.x*100 .. "," .. BWP_Destination.y*100 .. "]")
				local frame = getglobal("BWPDistanceText")
				frame:SetText(BWP_GetDistText())
				local frame = getglobal("BWP_DisplayFrame")
				frame:Show()
				--fMetaMapNotes_AddNewNote(continent, zone, 
				--	BWP_Destination.x, BWP_Destination.y, BWP_Destination.name, 
				--	nil, nil, "VanillaGuide", "8", nil, nil, nil, 2)
				--fsetmininote(BWP_Destination.x, BWP_Destination.y, BWP_Destination.name, "7", continent, zone)
			else
				BWP_ClearDest() 
				local frame = getglobal("BWP_DisplayFrame")
				frame:Hide()
			end
		end
	end

	-------------------------------
    --- Initialization
    -------------------------------
    do
		-- DropDown Menu Initialization
		--tWidgets.fs_DropDownMenuZone:SetText("Inizialization")
		--UIDropDownMenu_Initialize(tWidgets.frame_DropDownMenu, DropDown_Init)
		-- Step Frame Initialization
		--local nStep = tGuideValues.Step
		--local sTextStepLabel = tFSEntries[nStep]
		--tWidgets.fs_StepFrame:SetText("Initialization text")
		--tWidgets.fs_StepNumber:SetText("1")
		-- Scroll Frame Initialization
		--local nGID = tGuideValues.GuideID
		--GuideChange("GID", nGID)
		--tWidgets.frame_ScrollFrame:SetScrollChild(tWidgets.frame_ScrollFrameChild)
		--tWidgets.frame_ScrollFrame:UpdateScrollChildRect()
		-- MainFrame View
		

		--local bStepFrame = tUI.StepFrameVisible
		--local bScrollFrame = tUI.ScrollFrameVisible
		--local nHeight = tUI.MainFrameSize.nHeight
		--ChangeView(nHeight, bStepFrame, bScrollFrame)
		ChangeView(tUI)
		obj:InitializeDDM()
		obj.tWidgets.frame_ScrollFrame:SetScrollChild(obj.tWidgets.frame_ScrollFrameChild)
		obj:RefreshData(true)
    end

    return obj
end

Dv(" VGuide Frame_MainFrame.lua End")