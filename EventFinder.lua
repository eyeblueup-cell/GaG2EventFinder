--[[
    PROFESSIONAL KEYWORD SEARCH TOOL v2.0
    - Clean, modern UI with rounded corners
    - Proper scrolling with ScrollingFrame
    - Real-time scan progress with bar
    - Click to copy, right-click to inspect
    - Filter results
    - Shows match count in header
    - Fast scanning with chunk processing
    - Toggle with Right Shift
]]

local player = game.Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")

-- ========== KEYWORDS ==========
local keywords = {
    -- Mutations
    "bloodlit","electric","starstruck","rainbow","mutat","mutation","mut","boost",
    "bloodmoon","lightning","shocked","starfull","cloudy","weather","rain","storm",
    "event","trigger","apply","effect","buff","debuff","aura",
    -- Growth
    "plant","harvest","sell","buy","seed","crop","garden","plot","water",
    "sprinkler","grow","growth","speed","time","progress","stage","mature",
    "acorn","berry","fruit","vegetable","flower","tree",
    -- Economy & Dupe
    "dupe","duplicate","clone","spawn","give","add","remove","take",
    "currency","shekel","money","cash","coin","gem","premium","shop","store",
    -- Remotes
    "remote","event","function","bindable","unreliable","fire","invoke","send",
    "server","client","replicate","network","rpc","signal","callback",
    -- Pets
    "pet","egg","hatch","incubate","ability","buff","bonus","chance","luck",
    "companion","familiar","beast","creature",
    -- Player
    "player","stats","inventory","backpack","tool","gear","item","quantity",
    "level","exp","experience","rank","tier",
    -- Size & Weight
    "size","weight","mass","scale","big","large","small","giant","tiny",
    "multiplier","bonus","factor","modifier",
    -- Stealing
    "steal","thief","rob","take","night","dark","moon","lunar","sneak",
    -- Admin
    "admin","mod","god","cheat","bypass","noclip","fly","speed","jump",
    "debug","test","dev","development","sandbox","studio",
    -- Misc
    "gold","silver","bronze","legendary","rare","common","uncommon",
}

for i, kw in ipairs(keywords) do keywords[i] = kw:lower() end

-- ========== CREATE GUI ==========
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KeywordSearch"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = player:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0.35, 0, 0.75, 0)
MainFrame.Position = UDim2.new(0.325, 0, 0.125, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0.02, 0)
UICorner.Parent = MainFrame

-- ========== TITLE BAR ==========
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0.07, 0)
TitleBar.BackgroundColor3 = Color3.fromRGB(38, 38, 50)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame
local TitleBarCorner = Instance.new("UICorner")
TitleBarCorner.CornerRadius = UDim.new(0.02, 0)
TitleBarCorner.Parent = TitleBar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0.8, 0, 1, 0)
Title.Position = UDim2.new(0.03, 0, 0, 0)
Title.Text = "🔍 Keyword Search"
Title.TextSize = 20
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TitleBar

local MatchCount = Instance.new("TextLabel")
MatchCount.Size = UDim2.new(0.25, 0, 1, 0)
MatchCount.Position = UDim2.new(0.75, 0, 0, 0)
MatchCount.Text = "0 found"
MatchCount.TextSize = 14
MatchCount.TextColor3 = Color3.fromRGB(180, 180, 200)
MatchCount.BackgroundTransparency = 1
MatchCount.Font = Enum.Font.Gotham
MatchCount.Parent = TitleBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0.05, 0, 1, 0)
CloseBtn.Position = UDim2.new(0.95, 0, 0, 0)
CloseBtn.Text = "✕"
CloseBtn.TextSize = 18
CloseBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = TitleBar
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

-- ========== DRAGGING ==========
local drag = false
local dragStart, dragOffset
TitleBar.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then
        drag = true
        dragStart = i.Position
        dragOffset = MainFrame.Position
    end
end)
TitleBar.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then drag = false end
end)
UserInputService.InputChanged:Connect(function(i)
    if drag and i.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = i.Position - dragStart
        MainFrame.Position = UDim2.new(dragOffset.X.Scale, dragOffset.X.Offset + delta.X,
                                       dragOffset.Y.Scale, dragOffset.Y.Offset + delta.Y)
    end
end)

-- ========== TOGGLE WITH RIGHT SHIFT ==========
local guiVisible = true
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        guiVisible = not guiVisible
        MainFrame.Visible = guiVisible
    end
end)

-- ========== CONTENT ==========
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -16, 1, -0.12)
Content.Position = UDim2.new(0, 8, 0.08, 0)
Content.BackgroundTransparency = 1
Content.Parent = MainFrame

-- ========== PROGRESS VIEW ==========
local ProgressView = Instance.new("Frame")
ProgressView.Size = UDim2.new(1, 0, 1, 0)
ProgressView.BackgroundTransparency = 1
ProgressView.Parent = Content

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, 0, 0.1, 0)
StatusLabel.Position = UDim2.new(0, 0, 0.05, 0)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Preparing scan..."
StatusLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextSize = 16
StatusLabel.Parent = ProgressView

local BarBg = Instance.new("Frame")
BarBg.Size = UDim2.new(0.9, 0, 0.06, 0)
BarBg.Position = UDim2.new(0.05, 0, 0.2, 0)
BarBg.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
BarBg.BorderSizePixel = 0
BarBg.Parent = ProgressView
local BarBgCorner = Instance.new("UICorner")
BarBgCorner.CornerRadius = UDim.new(0.5, 0)
BarBgCorner.Parent = BarBg

local BarFill = Instance.new("Frame")
BarFill.Size = UDim2.new(0, 0, 1, 0)
BarFill.BackgroundColor3 = Color3.fromRGB(80, 160, 255)
BarFill.BorderSizePixel = 0
BarFill.Parent = BarBg
local BarFillCorner = Instance.new("UICorner")
BarFillCorner.CornerRadius = UDim.new(0.5, 0)
BarFillCorner.Parent = BarFill

local Grad = Instance.new("UIGradient")
Grad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(80, 160, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(140, 80, 255))
})
Grad.Parent = BarFill

local ProgressText = Instance.new("TextLabel")
ProgressText.Size = UDim2.new(1, 0, 0.08, 0)
ProgressText.Position = UDim2.new(0, 0, 0.3, 0)
ProgressText.BackgroundTransparency = 1
ProgressText.Text = "0%"
ProgressText.TextColor3 = Color3.fromRGB(200, 200, 200)
ProgressText.Font = Enum.Font.Gotham
ProgressText.TextSize = 18
ProgressText.Parent = ProgressView

local FoundLabel = Instance.new("TextLabel")
FoundLabel.Size = UDim2.new(1, 0, 0.08, 0)
FoundLabel.Position = UDim2.new(0, 0, 0.42, 0)
FoundLabel.BackgroundTransparency = 1
FoundLabel.Text = "Found: 0 matches"
FoundLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
FoundLabel.Font = Enum.Font.Gotham
FoundLabel.TextSize = 15
FoundLabel.Parent = ProgressView

local CancelBtn = Instance.new("TextButton")
CancelBtn.Size = UDim2.new(0.3, 0, 0.08, 0)
CancelBtn.Position = UDim2.new(0.35, 0, 0.55, 0)
CancelBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
CancelBtn.BorderSizePixel = 0
CancelBtn.Text = "Cancel"
CancelBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CancelBtn.Font = Enum.Font.GothamBold
CancelBtn.TextSize = 15
CancelBtn.Parent = ProgressView
local CancelCorner = Instance.new("UICorner")
CancelCorner.CornerRadius = UDim.new(0.5, 0)
CancelCorner.Parent = CancelBtn

local scanCancelled = false
CancelBtn.MouseButton1Click:Connect(function()
    scanCancelled = true
    StatusLabel.Text = "❌ Cancelled"
    ProgressText.Text = "Cancelled"
    BarFill.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
    BarFill.Size = UDim2.new(1, 0, 1, 0)
    CancelBtn.Visible = false
end)

-- ========== RESULTS VIEW ==========
local ResultsView = Instance.new("Frame")
ResultsView.Size = UDim2.new(1, 0, 1, 0)
ResultsView.BackgroundTransparency = 1
ResultsView.Visible = false
ResultsView.Parent = Content

-- Filter box
local FilterBox = Instance.new("TextBox")
FilterBox.Size = UDim2.new(1, 0, 0.08, 0)
FilterBox.Position = UDim2.new(0, 0, 0, 0)
FilterBox.BackgroundColor3 = Color3.fromRGB(22, 22, 32)
FilterBox.BorderSizePixel = 0
FilterBox.Text = ""
FilterBox.PlaceholderText = "🔍 Filter results..."
FilterBox.TextColor3 = Color3.fromRGB(230, 230, 230)
FilterBox.PlaceholderColor3 = Color3.fromRGB(130, 130, 130)
FilterBox.Font = Enum.Font.Gotham
FilterBox.TextSize = 14
FilterBox.Parent = ResultsView
local FilterCorner = Instance.new("UICorner")
FilterCorner.CornerRadius = UDim.new(0.5, 0)
FilterCorner.Parent = FilterBox

-- Scrollable results list
local ListFrame = Instance.new("ScrollingFrame")
ListFrame.Size = UDim2.new(1, 0, 1, -0.09)
ListFrame.Position = UDim2.new(0, 0, 0.09, 0)
ListFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 28)
ListFrame.BorderSizePixel = 0
ListFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ListFrame.ScrollBarThickness = 6
ListFrame.Parent = ResultsView
local ListCorner = Instance.new("UICorner")
ListCorner.CornerRadius = UDim.new(0.02, 0)
ListCorner.Parent = ListFrame

local ListLayout = Instance.new("UIListLayout")
ListLayout.Padding = UDim.new(0, 2)
ListLayout.Parent = ListFrame

-- ========== SCAN ENGINE ==========
local results = {}

local function matchesAny(str)
    if not str then return false end
    str = str:lower()
    for i = 1, #keywords do
        if str:find(keywords[i]) then
            return true
        end
    end
    return false
end

local function checkInstance(inst)
    if matchesAny(inst.Name) or matchesAny(inst.ClassName) then
        table.insert(results, inst)
        return
    end
    local props = {"Value", "Text", "DisplayName", "Title", "Description", "Tag"}
    for i = 1, #props do
        local ok, val = pcall(function() return inst[props[i]] end)
        if ok and type(val) == "string" and matchesAny(val) then
            table.insert(results, inst)
            return
        end
    end
    local attrs = inst:GetAttributes()
    for key, val in pairs(attrs) do
        if (type(key) == "string" and matchesAny(key)) or (type(val) == "string" and matchesAny(val)) then
            table.insert(results, inst)
            return
        end
    end
end

-- ========== START SCAN ==========
local function startScan()
    StatusLabel.Text = "Gathering objects..."
    task.wait()

    local allObjects = game:GetDescendants()
    local total = #allObjects
    StatusLabel.Text = "Scanning " .. total .. " objects..."
    task.wait()

    local processed = 0
    scanCancelled = false
    results = {}
    BarFill.Size = UDim2.new(0, 0, 1, 0)
    BarFill.BackgroundColor3 = Color3.fromRGB(80, 160, 255)
    ProgressText.Text = "0%"
    FoundLabel.Text = "Found: 0 matches"
    CancelBtn.Visible = true

    local chunkSize = 300
    for i = 1, total, chunkSize do
        if scanCancelled then break end
        local chunkEnd = math.min(i + chunkSize - 1, total)
        for j = i, chunkEnd do
            checkInstance(allObjects[j])
            processed = processed + 1
        end
        local pct = (processed / total) * 100
        BarFill.Size = UDim2.new(pct/100, 0, 1, 0)
        ProgressText.Text = string.format("%.1f%%", pct)
        StatusLabel.Text = "Processing " .. processed .. "/" .. total
        FoundLabel.Text = "Found: " .. #results .. " matches"
        task.wait()
    end

    if scanCancelled then
        StatusLabel.Text = "❌ Cancelled"
        ProgressText.Text = "Cancelled"
        BarFill.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
        return
    end

    StatusLabel.Text = "✅ Scan complete!"
    ProgressText.Text = "100%"
    BarFill.Size = UDim2.new(1, 0, 1, 0)
    BarFill.BackgroundColor3 = Color3.fromRGB(80, 220, 80)
    FoundLabel.Text = "Found: " .. #results .. " matches"
    MatchCount.Text = #results .. " found"
    task.wait(0.3)

    ProgressView.Visible = false
    ResultsView.Visible = true
    populateResults()
end

-- ========== POPULATE RESULTS ==========
function populateResults()
    for _, child in ipairs(ListFrame:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end

    table.sort(results, function(a,b) return a.Name < b.Name end)

    local function copyToClipboard(text)
        setclipboard(text)
        print("📋 Copied: " .. text)
    end

    local inspectFn = _G.InspectInstance

    for _, inst in ipairs(results) do
        local path = inst:GetFullName()
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 30)
        btn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
        btn.BorderSizePixel = 0
        btn.Text = path
        btn.TextColor3 = Color3.fromRGB(230, 230, 230)
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 13
        btn.Parent = ListFrame

        btn.MouseEnter:Connect(function() btn.BackgroundColor3 = Color3.fromRGB(55, 55, 75) end)
        btn.MouseLeave:Connect(function() btn.BackgroundColor3 = Color3.fromRGB(40, 40, 55) end)

        btn.MouseButton1Click:Connect(function()
            copyToClipboard(path)
            btn.BackgroundColor3 = Color3.fromRGB(70, 100, 140)
            task.wait(0.15)
            btn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
        end)

        btn.MouseButton2Click:Connect(function()
            if inspectFn then
                inspectFn(inst)
                print("🔍 Inspecting: " + path)
            else
                copyToClipboard(path)
                print("📋 Copied path (inspect unavailable)")
            end
        end)
    end

    local count = #results
    ListFrame.CanvasSize = UDim2.new(0, 0, 0, count * 32 + 10)
    MatchCount.Text = count .. " found"

    FilterBox:GetPropertyChangedSignal("Text"):Connect(function()
        local filter = FilterBox.Text:lower()
        local visible = 0
        for _, btn in ipairs(ListFrame:GetChildren()) do
            if btn:IsA("TextButton") then
                if filter == "" or btn.Text:lower():find(filter) then
                    btn.Visible = true
                    visible = visible + 1
                else
                    btn.Visible = false
                end
            end
        end
        ListFrame.CanvasSize = UDim2.new(0, 0, 0, visible * 32 + 10)
    end)
end

-- ========== LAUNCH ==========
startScan()
print("✅ Professional Keyword Search loaded – Press Right Shift to toggle")
