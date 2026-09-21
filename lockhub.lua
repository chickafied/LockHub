local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- // ============================================
-- // KEY SYSTEM (Remote - GitHub hosted)
-- // ============================================
local KEY_URL = "https://raw.githubusercontent.com/chickafied/LockHub/main/keys.json"

local VALID_KEYS = {}

local function refreshKeys()
    local ok, data = pcall(function()
        return HttpService:JSONDecode(game:HttpGet(KEY_URL .. "?t=" .. tick()))
    end)
    if ok and type(data) == "table" then
        VALID_KEYS = data
        return true
    end
    return false
end

local SAVE_FILE = "LockHub_Key.txt"
local function saveKey(k)
    if writefile then writefile(SAVE_FILE, k) end
end
local function loadKey()
    if isfile and isfile(SAVE_FILE) then
        local ok, data = pcall(readfile, SAVE_FILE)
        if ok then return data end
    end
    return nil
end

local function showKeyUI()
    local KeyGui = Instance.new("ScreenGui")
    KeyGui.Name = "LockHub_KeySystem"
    KeyGui.ResetOnSpawn = false
    KeyGui.IgnoreGuiInset = true
    KeyGui.Parent = CoreGui

    local Blur = Instance.new("Frame")
    Blur.Size = UDim2.new(1, 0, 1, 0)
    Blur.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Blur.BackgroundTransparency = 0.4
    Blur.BorderSizePixel = 0
    Blur.Parent = KeyGui

    local KeyFrame = Instance.new("Frame")
    KeyFrame.Size = UDim2.new(0, 400, 0, 260)
    KeyFrame.Position = UDim2.new(0.5, -200, 0.5, -130)
    KeyFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    KeyFrame.BorderSizePixel = 0
    KeyFrame.Parent = KeyGui
    Instance.new("UICorner", KeyFrame).CornerRadius = UDim.new(0, 14)

    local Grad = Instance.new("UIGradient")
    Grad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(45, 45, 45)),
    })
    Grad.Rotation = 45
    Grad.Parent = KeyFrame

    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(120, 120, 120)
    Stroke.Thickness = 2
    Stroke.Transparency = 0.3
    Stroke.Parent = KeyFrame

    local KeyTitle = Instance.new("TextLabel")
    KeyTitle.Size = UDim2.new(1, 0, 0, 50)
    KeyTitle.Position = UDim2.new(0, 0, 0, 15)
    KeyTitle.BackgroundTransparency = 1
    KeyTitle.Text = "LOCK HUB"
    KeyTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    KeyTitle.Font = Enum.Font.GothamBold
    KeyTitle.TextSize = 32
    KeyTitle.Parent = KeyFrame
    local TitleStroke = Instance.new("UIStroke")
    TitleStroke.Color = Color3.fromRGB(0, 0, 0)
    TitleStroke.Thickness = 2
    TitleStroke.Parent = KeyTitle

    local KeySub = Instance.new("TextLabel")
    KeySub.Size = UDim2.new(1, 0, 0, 20)
    KeySub.Position = UDim2.new(0, 0, 0, 60)
    KeySub.BackgroundTransparency = 1
    KeySub.Text = "Enter your key to continue"
    KeySub.TextColor3 = Color3.fromRGB(180, 180, 180)
    KeySub.Font = Enum.Font.Gotham
    KeySub.TextSize = 14
    KeySub.Parent = KeyFrame

    local KeyInput = Instance.new("TextBox")
    KeyInput.Size = UDim2.new(0.85, 0, 0, 45)
    KeyInput.Position = UDim2.new(0.5, 0, 0, 105)
    KeyInput.AnchorPoint = Vector2.new(0.5, 0)
    KeyInput.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    KeyInput.BorderSizePixel = 0
    KeyInput.PlaceholderText = "Paste your key here..."
    KeyInput.Text = ""
    KeyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    KeyInput.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
    KeyInput.Font = Enum.Font.GothamBold
    KeyInput.TextSize = 15
    KeyInput.ClearTextOnFocus = false
    KeyInput.Parent = KeyFrame
    Instance.new("UICorner", KeyInput).CornerRadius = UDim.new(0, 8)

    local InputStroke = Instance.new("UIStroke")
    InputStroke.Color = Color3.fromRGB(80, 80, 80)
    InputStroke.Thickness = 1
    InputStroke.Parent = KeyInput

    local Status = Instance.new("TextLabel")
    Status.Size = UDim2.new(1, 0, 0, 18)
    Status.Position = UDim2.new(0, 0, 0, 155)
    Status.BackgroundTransparency = 1
    Status.Text = ""
    Status.TextColor3 = Color3.fromRGB(255, 80, 80)
    Status.Font = Enum.Font.GothamBold
    Status.TextSize = 12
    Status.Parent = KeyFrame

    local Submit = Instance.new("TextButton")
    Submit.Size = UDim2.new(0.85, 0, 0, 42)
    Submit.Position = UDim2.new(0.5, 0, 0, 180)
    Submit.AnchorPoint = Vector2.new(0.5, 0)
    Submit.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
    Submit.BorderSizePixel = 0
    Submit.Text = "SUBMIT"
    Submit.TextColor3 = Color3.fromRGB(0, 0, 0)
    Submit.Font = Enum.Font.GothamBold
    Submit.TextSize = 15
    Submit.Parent = KeyFrame
    Instance.new("UICorner", Submit).CornerRadius = UDim.new(0, 8)

    local BtnStroke = Instance.new("UIStroke")
    BtnStroke.Color = Color3.fromRGB(255, 255, 255)
    BtnStroke.Thickness = 1
    BtnStroke.Transparency = 0.5
    BtnStroke.Parent = Submit

    return KeyGui, KeyInput, Status, Submit
end

local function keyAlreadyValid()
    local saved = loadKey()
    if saved and VALID_KEYS[saved] then return true end
    return false
end

-- Fetch keys from GitHub before showing UI
if not refreshKeys() then
    warn("[LockHub] Could not fetch keys. Check internet / URL.")
end

if not keyAlreadyValid() then
    local KeyGui, KeyInput, Status, Submit = showKeyUI()
    local verified = false

    Submit.MouseButton1Click:Connect(function()
        local entered = KeyInput.Text
        if entered == "" then
            Status.TextColor3 = Color3.fromRGB(255, 80, 80)
            Status.Text = "Please enter a key."
            return
        end

        -- Refresh from server in case keys changed since launch
        refreshKeys()

        if VALID_KEYS[entered] then
            Status.TextColor3 = Color3.fromRGB(80, 255, 120)
            Status.Text = "Key accepted! Loading..."
            saveKey(entered)
            verified = true
            task.wait(0.6)
            KeyGui:Destroy()
        else
            Status.TextColor3 = Color3.fromRGB(255, 80, 80)
            Status.Text = "Invalid key. Try again."
            KeyInput.Text = ""
        end
    end)

    repeat task.wait(0.1) until verified
end
-- // ============================================
-- // END KEY SYSTEM
-- // ============================================

local Config = {
    Enabled = true,
    Target = nil,
    Smoothness = 0.450,
    Prediction = 0.100,
    WallCheck = true,
    Visible = true,
    IsHolding = false,
    SelectedPlayers = {},
    SearchText = "",
    ActivationMode = "Right Mouse Click",
    TargetPart = "HumanoidRootPart"
}

local KeyMap = {
    ["Right Mouse Click"] = Enum.UserInputType.MouseButton2,
    ["Left Mouse Click"] = Enum.UserInputType.MouseButton1,
    ["The Letter F"] = Enum.KeyCode.F,
    ["The Letter E"] = Enum.KeyCode.E
}

-- // UI Creation
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Sosas_V1_Lock"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 520, 0, 420)
MainFrame.Position = UDim2.new(0.5, -260, 0.5, -210)
MainFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 15)

local OuterGlow = Instance.new("ImageLabel")
OuterGlow.Name = "OuterGlow"
OuterGlow.BackgroundTransparency = 1
OuterGlow.Position = UDim2.new(0, -30, 0, -30)
OuterGlow.Size = UDim2.new(1, 60, 1, 60)
OuterGlow.ZIndex = 0
OuterGlow.Image = "rbxassetid://1316045217"
OuterGlow.ImageColor3 = Color3.fromRGB(50, 50, 50)
OuterGlow.ImageTransparency = 0.5
OuterGlow.Parent = MainFrame

local BGGradient = Instance.new("UIGradient")
BGGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(80, 80, 80))
})
BGGradient.Rotation = 45
BGGradient.Parent = MainFrame

-- Title Section
local TitleFrame = Instance.new("Frame")
TitleFrame.Size = UDim2.new(1, 0, 0, 70)
TitleFrame.BackgroundTransparency = 1
TitleFrame.Parent = MainFrame

local TitleBackdrop = Instance.new("Frame")
TitleBackdrop.Size = UDim2.new(0, 220, 0, 60)
TitleBackdrop.Position = UDim2.new(0.5, 0, 0.5, 0)
TitleBackdrop.AnchorPoint = Vector2.new(0.5, 0.5)
TitleBackdrop.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
TitleBackdrop.BackgroundTransparency = 0.5
TitleBackdrop.ZIndex = 1
TitleBackdrop.Parent = TitleFrame
Instance.new("UICorner", TitleBackdrop).CornerRadius = UDim.new(0, 10)

local function addTextOutline(obj)
    local s = Instance.new("UIStroke")
    s.Thickness = 2
    s.Color = Color3.fromRGB(0, 0, 0)
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
    s.Parent = obj
end

local TopRow = Instance.new("Frame")
TopRow.Size = UDim2.new(1, 0, 0, 32)
TopRow.Position = UDim2.new(0, 0, 0, 5)
TopRow.BackgroundTransparency = 1
TopRow.Parent = TitleBackdrop

local TitleListLayout = Instance.new("UIListLayout")
TitleListLayout.FillDirection = Enum.FillDirection.Horizontal
TitleListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
TitleListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
TitleListLayout.Padding = UDim.new(0, 2)
TitleListLayout.Parent = TopRow

local MainTitle = Instance.new("TextLabel")
MainTitle.AutomaticSize = Enum.AutomaticSize.X
MainTitle.BackgroundTransparency = 1
MainTitle.Text = "Lock Hub"
MainTitle.TextColor3 = Color3.fromRGB(200, 200, 200)
MainTitle.Font = Enum.Font.GothamBold
MainTitle.TextSize = 28
MainTitle.ZIndex = 2
MainTitle.Parent = TopRow
addTextOutline(MainTitle)

local SubTitleLabel = Instance.new("TextLabel")
SubTitleLabel.Size = UDim2.new(1, 0, 0, 20)
SubTitleLabel.Position = UDim2.new(0, 0, 0, 35)
SubTitleLabel.BackgroundTransparency = 1
SubTitleLabel.Text = "By sosa"
SubTitleLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
SubTitleLabel.Font = Enum.Font.GothamBold
SubTitleLabel.TextSize = 14
SubTitleLabel.ZIndex = 2
SubTitleLabel.Parent = TitleBackdrop
addTextOutline(SubTitleLabel)

-- Sections
local PlayerSection = Instance.new("Frame")
PlayerSection.Name = "PlayerSection"
PlayerSection.Size = UDim2.new(0.5, -15, 1, -95)
PlayerSection.Position = UDim2.new(0, 10, 0, 85)
PlayerSection.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
PlayerSection.BackgroundTransparency = 0.6
PlayerSection.ZIndex = 3
PlayerSection.Parent = MainFrame
Instance.new("UICorner", PlayerSection).CornerRadius = UDim.new(0, 12)

local CamlockSection = Instance.new("Frame")
CamlockSection.Name = "CamlockSection"
CamlockSection.Size = UDim2.new(0.5, -15, 1, -95)
CamlockSection.Position = UDim2.new(0.5, 5, 0, 85)
CamlockSection.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
CamlockSection.BackgroundTransparency = 0.6
CamlockSection.ZIndex = 3
CamlockSection.Parent = MainFrame
Instance.new("UICorner", CamlockSection).CornerRadius = UDim.new(0, 12)

local ListLayout = Instance.new("UIListLayout")
ListLayout.Padding = UDim.new(0, 8)
ListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
ListLayout.Parent = CamlockSection
Instance.new("UIPadding", CamlockSection).PaddingTop = UDim.new(0, 10)

-- // Controls
local function createToggle(text, default, callback, order)
    local btn = Instance.new("TextButton")
    btn.LayoutOrder = order
    btn.Size = UDim2.new(0.9, 0, 0, 32)
    btn.BackgroundColor3 = default and Color3.fromRGB(30, 30, 30) or Color3.fromRGB(40, 10, 10)
    btn.Text = text .. ": " .. (default and "ON" or "OFF")
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    btn.ZIndex = 4
    btn.Parent = CamlockSection
    Instance.new("UICorner", btn)
    local function update(state)
        btn.Text = text .. ": " .. (state and "ON" or "OFF")
        btn.BackgroundColor3 = state and Color3.fromRGB(30, 30, 30) or Color3.fromRGB(40, 10, 10)
    end
    btn.MouseButton1Click:Connect(function() update(callback()) end)
    return update
end

local updateCamVisuals = createToggle("Camlock System", Config.Enabled, function() Config.Enabled = not Config.Enabled return Config.Enabled end, 1)
local updateWallVisuals = createToggle("Wall Check", Config.WallCheck, function() Config.WallCheck = not Config.WallCheck return Config.WallCheck end, 2)

local function createDropdown(label, options, current, callback, order)
    local dropBtn = Instance.new("TextButton")
    dropBtn.LayoutOrder = order
    dropBtn.Size = UDim2.new(0.9, 0, 0, 32)
    dropBtn.BackgroundColor3 = Color3.fromRGB(120, 120, 120)
    dropBtn.Text = label .. ": " .. current
    dropBtn.TextColor3 = Color3.new(1, 1, 1)
    dropBtn.Font = Enum.Font.GothamBold
    dropBtn.TextSize = 13
    dropBtn.ZIndex = 11
    dropBtn.Parent = CamlockSection
    Instance.new("UICorner", dropBtn)
    local dropList = Instance.new("Frame")
    dropList.Size = UDim2.new(1, 0, 0, 0)
    dropList.Position = UDim2.new(0, 0, 1, 5)
    dropList.BackgroundColor3 = Color3.fromRGB(30, 0, 0)
    dropList.Visible = false
    dropList.ClipsDescendants = true
    dropList.ZIndex = 20
    dropList.Parent = dropBtn
    Instance.new("UICorner", dropList)
    Instance.new("UIListLayout", dropList)
    for _, name in pairs(options) do
        local opt = Instance.new("TextButton")
        opt.Size = UDim2.new(1, 0, 0, 28)
        opt.BackgroundTransparency = 1
        opt.Text = name
        opt.TextColor3 = Color3.new(1, 1, 1)
        opt.Font = Enum.Font.GothamBold
        opt.TextSize = 12
        opt.ZIndex = 21
        opt.Parent = dropList
        opt.MouseButton1Click:Connect(function()
            dropBtn.Text = label .. ": " .. name
            dropList.Visible = false
            dropList.Size = UDim2.new(1, 0, 0, 0)
            callback(name)
        end)
    end
    dropBtn.MouseButton1Click:Connect(function()
        dropList.Visible = not dropList.Visible
        dropList.Size = dropList.Visible and UDim2.new(1, 0, 0, #options * 28) or UDim2.new(1, 0, 0, 0)
    end)
end

local modeKeys = {} for k,_ in pairs(KeyMap) do table.insert(modeKeys, k) end
createDropdown("Mode", modeKeys, Config.ActivationMode, function(v) Config.ActivationMode = v end, 3)

local function createSlider(name, min, max, default, callback, order)
    local sliderFrame = Instance.new("Frame")
    sliderFrame.Name = "SliderContainer"
    sliderFrame.LayoutOrder = order
    sliderFrame.Size = UDim2.new(0.9, 0, 0, 42)
    sliderFrame.BackgroundTransparency = 1
    sliderFrame.Parent = CamlockSection
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 18)
    label.Text = name .. ": " .. string.format("%.3f", default)
    label.TextColor3 = Color3.new(1, 1, 1)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamBold
    label.TextSize = 13
    label.Parent = sliderFrame
    local bar = Instance.new("Frame")
    bar.Name = "SliderBar"
    bar.Size = UDim2.new(1, 0, 0, 4)
    bar.Position = UDim2.new(0, 0, 0.75, 0)
    bar.BackgroundColor3 = Color3.fromRGB(60, 20, 20)
    bar.Parent = sliderFrame
    Instance.new("UICorner", bar)
    local knob = Instance.new("Frame")
    knob.Name = "SliderKnob"
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.AnchorPoint = Vector2.new(0.5, 0.5)
    knob.Position = UDim2.new((default - min)/(max - min), 0, 0.5, 0)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.ZIndex = 6
    knob.Parent = bar
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
    local knobStroke = Instance.new("UIStroke")
    knobStroke.Color = Color3.fromRGB(120, 120, 120)
    knobStroke.Thickness = 2
    knobStroke.Parent = knob
    local sliding = false
    knob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then sliding = true end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then sliding = false end
    end)
    RunService.RenderStepped:Connect(function()
        if sliding then
            local mousePos = UserInputService:GetMouseLocation().X
            local barPos = bar.AbsolutePosition.X
            local barSize = bar.AbsoluteSize.X
            local percent = math.clamp((mousePos - barPos) / barSize, 0, 1)
            knob.Position = UDim2.new(percent, 0, 0.5, 0)
            local val = math.floor((min + (max - min) * percent) * 1000) / 1000
            label.Text = name .. ": " .. string.format("%.3f", val)
            callback(val)
        end
    end)
end

createSlider("Smoothness", 0.01, 0.8, Config.Smoothness, function(v) Config.Smoothness = v end, 4)
createSlider("Prediction", 0.01, 0.4, Config.Prediction, function(v) Config.Prediction = v end, 5)
createDropdown("Target Part", {"Head", "HumanoidRootPart", "Legs"}, Config.TargetPart, function(v) Config.TargetPart = v end, 6)

local SearchBox = Instance.new("TextBox")
SearchBox.Size = UDim2.new(1, -10, 0, 30)
SearchBox.Position = UDim2.new(0, 5, 0, 5)
SearchBox.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
SearchBox.BackgroundTransparency = 0.5
SearchBox.PlaceholderText = "Search Players..."
SearchBox.Text = ""
SearchBox.TextColor3 = Color3.new(1, 1, 1)
SearchBox.Font = Enum.Font.GothamBold
SearchBox.ZIndex = 4
SearchBox.Parent = PlayerSection
Instance.new("UICorner", SearchBox)

local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Size = UDim2.new(1, -10, 1, -45)
ScrollFrame.Position = UDim2.new(0, 5, 0, 40)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.ScrollBarThickness = 2
ScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(50, 50, 50)
ScrollFrame.ZIndex = 4
ScrollFrame.Parent = PlayerSection
Instance.new("UIListLayout", ScrollFrame).Padding = UDim.new(0, 5)

local function updateList()
    for _, child in pairs(ScrollFrame:GetChildren()) do if child:IsA("TextButton") then child:Destroy() end end
    for _, player in pairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if Config.SearchText ~= "" and not string.find(player.DisplayName:lower(), Config.SearchText:lower()) then continue end
        local btn = Instance.new("TextButton")
        btn.Name = "PlayerBtn"
        btn.Size = UDim2.new(1, -5, 0, 35)
        btn.BackgroundColor3 = Config.SelectedPlayers[player.UserId] and Color3.fromRGB(50, 50, 50) or Color3.fromRGB(40, 20, 20)
        btn.Text = "  " .. player.DisplayName
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 14
        btn.Parent = ScrollFrame
        Instance.new("UICorner", btn)
        btn.MouseButton1Click:Connect(function()
            if Config.SelectedPlayers[player.UserId] then
                Config.SelectedPlayers[player.UserId] = nil
            else
                Config.SelectedPlayers[player.UserId] = true
            end
            updateList()
        end)
    end
end
SearchBox:GetPropertyChangedSignal("Text"):Connect(function() Config.SearchText = SearchBox.Text updateList() end)
Players.PlayerAdded:Connect(updateList)
Players.PlayerRemoving:Connect(updateList)

local dragging, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        local onSlider = false
        for _, obj in pairs(ScreenGui:GetGuiObjectsAtPosition(input.Position.X, input.Position.Y)) do
            if obj.Name == "SliderKnob" or obj.Name == "SliderBar" or obj.Name == "SliderContainer" or obj:IsA("TextBox") or obj:IsA("ScrollingFrame") or obj.Name == "PlayerBtn" or obj.Name == "PlayerSection" or obj.Name == "CamlockSection" then
                onSlider = true break
            end
        end
        if not onSlider then dragging = true dragStart = input.Position startPos = MainFrame.Position end
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end end)

local function isActivating(input)
    local goal = KeyMap[Config.ActivationMode]
    if typeof(goal) == "EnumItem" then
        if goal.EnumType == Enum.UserInputType then return input.UserInputType == goal end
        if goal.EnumType == Enum.KeyCode then return input.KeyCode == goal end
    end
    return false
end

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.V then Config.Visible = not Config.Visible MainFrame.Visible = Config.Visible end
    if input.KeyCode == Enum.KeyCode.P then Config.WallCheck = not Config.WallCheck updateWallVisuals(Config.WallCheck) end
    if input.KeyCode == Enum.KeyCode.Y then Config.Enabled = not Config.Enabled updateCamVisuals(Config.Enabled) end
    if isActivating(input) then
        local target, dist = nil, math.huge
        for id, _ in pairs(Config.SelectedPlayers) do
            local p = Players:GetPlayerByUserId(id)
            if p and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local screenPos, onScreen = Camera:WorldToViewportPoint(p.Character.HumanoidRootPart.Position)
                if onScreen then
                    local d = (Vector2.new(screenPos.X, screenPos.Y) - UserInputService:GetMouseLocation()).Magnitude
                    if d < dist then target = p dist = d end
                end
            end
        end
        Config.Target = target Config.IsHolding = true
    end
end)
UserInputService.InputEnded:Connect(function(input) if isActivating(input) then Config.IsHolding = false Config.Target = nil end end)

RunService.RenderStepped:Connect(function()
    if Config.Enabled and Config.IsHolding and Config.Target and Config.Target.Character then
        local char = Config.Target.Character
        local part = char:FindFirstChild(Config.TargetPart)
        if Config.TargetPart == "Legs" then
            part = char:FindFirstChild("LeftLowerLeg") or char:FindFirstChild("RightLowerLeg") or char:FindFirstChild("HumanoidRootPart")
        end
        if part then
            if Config.WallCheck and #Camera:GetPartsObscuringTarget({Camera.CFrame.Position, part.Position}, {LocalPlayer.Character, char}) > 0 then return end
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, part.Position + (part.Velocity * Config.Prediction)), Config.Smoothness)
        end
    end
end)

updateList()
