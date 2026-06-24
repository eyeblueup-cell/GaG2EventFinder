--[[
    PROFESSIONAL KEYWORD SEARCH v5.0
    - Left-click: Fire event with parameters (fixed error handling)
    - Right-click: Copy path (or inspect if Studio tool loaded)
    - Copy All / Export (TXT, CSV, JSON)
    - File Viewer & Editor – view/edit exported files
    - Full scrolling, filter, progress bar
]]

local player = game.Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")

-- ========== KEYWORDS ==========
local keywords = {
    "bloodlit","electric","starstruck","rainbow","mutat","mutation","mut","boost",
    "bloodmoon","lightning","shocked","starfull","cloudy","weather","rain","storm",
    "event","trigger","apply","effect","buff","debuff","aura",
    "plant","harvest","sell","buy","seed","crop","garden","plot","water",
    "sprinkler","grow","growth","speed","time","progress","stage","mature",
    "acorn","berry","fruit","vegetable","flower","tree",
    "dupe","duplicate","clone","spawn","give","add","remove","take",
    "currency","shekel","money","cash","coin","gem","premium","shop","store",
    "remote","event","function","bindable","unreliable","fire","invoke","send",
    "server","client","replicate","network","rpc","signal","callback",
    "pet","egg","hatch","incubate","ability","buff","bonus","chance","luck",
    "companion","familiar","beast","creature",
    "player","stats","inventory","backpack","tool","gear","item","quantity",
    "level","exp","experience","rank","tier",
    "size","weight","mass","scale","big","large","small","giant","tiny",
    "multiplier","bonus","factor","modifier",
    "steal","thief","rob","take","night","dark","moon","lunar","sneak",
    "admin","mod","god","cheat","bypass","noclip","fly","speed","jump",
    "debug","test","dev","development","sandbox","studio",
    "gold","silver","bronze","legendary","rare","common","uncommon",
}
for i, kw in ipairs(keywords) do keywords[i] = kw:lower() end

-- ========== GUI ==========
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KeywordSearch"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = player:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0.42, 0, 0.85, 0)
MainFrame.Position = UDim2.new(0.29, 0, 0.075, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0.02, 0)
UICorner.Parent = MainFrame

-- Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0.06, 0)
TitleBar.BackgroundColor3 = Color3.fromRGB(38, 38, 50)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame
local TitleBarCorner = Instance.new("UICorner")
TitleBarCorner.CornerRadius = UDim.new(0.02, 0)
TitleBarCorner.Parent = TitleBar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0.6, 0, 1, 0)
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
MatchCount.Position = UDim2.new(0.7, 0, 0, 0)
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

-- Dragging
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

-- Toggle (Right Shift)
local guiVisible = true
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        guiVisible = not guiVisible
        MainFrame.Visible = guiVisible
    end
end)

-- Content
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -16, 1, -0.09)
Content.Position = UDim2.new(0, 8, 0.08, 0)
Content.BackgroundTransparency = 1
Content.Parent = MainFrame

-- Progress View
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
CancelBtn.Size = UDim2.new(0.25, 0, 0.08, 0)
CancelBtn.Position = UDim2.new(0.375, 0, 0.55, 0)
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

-- Results View
local ResultsView = Instance.new("Frame")
ResultsView.Size = UDim2.new(1, 0, 1, 0)
ResultsView.BackgroundTransparency = 1
ResultsView.Visible = false
ResultsView.Parent = Content

-- Toolbar
local Toolbar = Instance.new("Frame")
Toolbar.Size = UDim2.new(1, 0, 0.14, 0)
Toolbar.BackgroundTransparency = 1
Toolbar.Parent = ResultsView

local FilterBox = Instance.new("TextBox")
FilterBox.Size = UDim2.new(0.3, -5, 1, 0)
FilterBox.Position = UDim2.new(0, 0, 0, 0)
FilterBox.BackgroundColor3 = Color3.fromRGB(22, 22, 32)
FilterBox.BorderSizePixel = 0
FilterBox.Text = ""
FilterBox.PlaceholderText = "🔍 Filter..."
FilterBox.TextColor3 = Color3.fromRGB(230, 230, 230)
FilterBox.PlaceholderColor3 = Color3.fromRGB(130, 130, 130)
FilterBox.Font = Enum.Font.Gotham
FilterBox.TextSize = 14
FilterBox.Parent = Toolbar
local FilterCorner = Instance.new("UICorner")
FilterCorner.CornerRadius = UDim.new(0.5, 0)
FilterCorner.Parent = FilterBox

-- Copy All button
local CopyAllBtn = Instance.new("TextButton")
CopyAllBtn.Size = UDim2.new(0.15, -5, 1, 0)
CopyAllBtn.Position = UDim2.new(0.32, 0, 0, 0)
CopyAllBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
CopyAllBtn.BorderSizePixel = 0
CopyAllBtn.Text = "📋 Copy All"
CopyAllBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CopyAllBtn.Font = Enum.Font.GothamBold
CopyAllBtn.TextSize = 11
CopyAllBtn.Parent = Toolbar
local CopyCorner = Instance.new("UICorner")
CopyCorner.CornerRadius = UDim.new(0.5, 0)
CopyCorner.Parent = CopyAllBtn

-- Export button
local ExportBtn = Instance.new("TextButton")
ExportBtn.Size = UDim2.new(0.15, -5, 1, 0)
ExportBtn.Position = UDim2.new(0.49, 0, 0, 0)
ExportBtn.BackgroundColor3 = Color3.fromRGB(50, 70, 50)
ExportBtn.BorderSizePixel = 0
ExportBtn.Text = "📄 Export"
ExportBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ExportBtn.Font = Enum.Font.GothamBold
ExportBtn.TextSize = 11
ExportBtn.Parent = Toolbar
local ExportCorner = Instance.new("UICorner")
ExportCorner.CornerRadius = UDim.new(0.5, 0)
ExportCorner.Parent = ExportBtn

-- View Files button
local ViewFilesBtn = Instance.new("TextButton")
ViewFilesBtn.Size = UDim2.new(0.18, -5, 1, 0)
ViewFilesBtn.Position = UDim2.new(0.66, 0, 0, 0)
ViewFilesBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 90)
ViewFilesBtn.BorderSizePixel = 0
ViewFilesBtn.Text = "📂 View Files"
ViewFilesBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ViewFilesBtn.Font = Enum.Font.GothamBold
ViewFilesBtn.TextSize = 11
ViewFilesBtn.Parent = Toolbar
local ViewFilesCorner = Instance.new("UICorner")
ViewFilesCorner.CornerRadius = UDim.new(0.5, 0)
ViewFilesCorner.Parent = ViewFilesBtn

-- Export menu popup
local ExportMenu = Instance.new("Frame")
ExportMenu.Size = UDim2.new(0.25, 0, 0.3, 0)
ExportMenu.Position = UDim2.new(0.55, 0, 0.12, 0)
ExportMenu.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
ExportMenu.BorderSizePixel = 0
ExportMenu.Visible = false
ExportMenu.Parent = MainFrame
local ExportMenuCorner = Instance.new("UICorner")
ExportMenuCorner.CornerRadius = UDim.new(0.02, 0)
ExportMenuCorner.Parent = ExportMenu

local ExportOptions = {
    {name = "📄 Export .txt", format = "txt"},
    {name = "📊 Export .csv", format = "csv"},
    {name = "📋 Export .json", format = "json"},
}

local exportMenuLayout = Instance.new("UIListLayout")
exportMenuLayout.Padding = UDim.new(0, 4)
exportMenuLayout.Parent = ExportMenu

for _, opt in ipairs(ExportOptions) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 30)
    btn.Position = UDim2.new(0, 5, 0, 0)
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
    btn.BorderSizePixel = 0
    btn.Text = opt.name
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 13
    btn.Parent = ExportMenu
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0.5, 0)
    btnCorner.Parent = btn

    btn.MouseEnter:Connect(function() btn.BackgroundColor3 = Color3.fromRGB(60, 60, 80) end)
    btn.MouseLeave:Connect(function() btn.BackgroundColor3 = Color3.fromRGB(45, 45, 60) end)

    btn.MouseButton1Click:Connect(function()
        ExportMenu.Visible = false
        exportResults(opt.format)
    end)
end

ExportBtn.MouseButton1Click:Connect(function()
    ExportMenu.Visible = not ExportMenu.Visible
end)

-- Close export menu when clicking elsewhere
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        if ExportMenu.Visible then
            local mousePos = UserInputService:GetMouseLocation()
            local menuPos = ExportMenu.AbsolutePosition
            local menuSize = ExportMenu.AbsoluteSize
            if mousePos.X < menuPos.X or mousePos.X > menuPos.X + menuSize.X or
               mousePos.Y < menuPos.Y or mousePos.Y > menuPos.Y + menuSize.Y then
                ExportMenu.Visible = false
            end
        end
    end
end)

-- ========== FILE VIEWER / EDITOR ==========
local FileViewer = Instance.new("Frame")
FileViewer.Size = UDim2.new(0.8, 0, 0.7, 0)
FileViewer.Position = UDim2.new(0.1, 0, 0.15, 0)
FileViewer.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
FileViewer.BorderSizePixel = 0
FileViewer.Visible = false
FileViewer.Parent = MainFrame
local FileViewerCorner = Instance.new("UICorner")
FileViewerCorner.CornerRadius = UDim.new(0.02, 0)
FileViewerCorner.Parent = FileViewer

local FileViewerTitle = Instance.new("Frame")
FileViewerTitle.Size = UDim2.new(1, 0, 0.08, 0)
FileViewerTitle.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
FileViewerTitle.BorderSizePixel = 0
FileViewerTitle.Parent = FileViewer
local FVTitleCorner = Instance.new("UICorner")
FVTitleCorner.CornerRadius = UDim.new(0.02, 0)
FVTitleCorner.Parent = FileViewerTitle

local FVTitleLabel = Instance.new("TextLabel")
FVTitleLabel.Size = UDim2.new(0.8, 0, 1, 0)
FVTitleLabel.Position = UDim2.new(0.03, 0, 0, 0)
FVTitleLabel.BackgroundTransparency = 1
FVTitleLabel.Text = "📂 File Viewer"
FVTitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
FVTitleLabel.Font = Enum.Font.GothamBold
FVTitleLabel.TextSize = 16
FVTitleLabel.TextXAlignment = Enum.TextXAlignment.Left
FVTitleLabel.Parent = FileViewerTitle

local FVCloseBtn = Instance.new("TextButton")
FVCloseBtn.Size = UDim2.new(0.05, 0, 1, 0)
FVCloseBtn.Position = UDim2.new(0.95, 0, 0, 0)
FVCloseBtn.Text = "✕"
FVCloseBtn.TextSize = 18
FVCloseBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
FVCloseBtn.BackgroundTransparency = 1
FVCloseBtn.Font = Enum.Font.GothamBold
FVCloseBtn.Parent = FileViewerTitle
FVCloseBtn.MouseButton1Click:Connect(function()
    FileViewer.Visible = false
    ViewFilesBtn.Text = "📂 View Files"
end)

-- File list
local FileListFrame = Instance.new("Frame")
FileListFrame.Size = UDim2.new(0.3, -10, 1, -0.08)
FileListFrame.Position = UDim2.new(0, 10, 0.08, 0)
FileListFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 35)
FileListFrame.BorderSizePixel = 0
FileListFrame.Parent = FileViewer
local FLCorner = Instance.new("UICorner")
FLCorner.CornerRadius = UDim.new(0.01, 0)
FLCorner.Parent = FileListFrame

local FileListScroll = Instance.new("ScrollingFrame")
FileListScroll.Size = UDim2.new(1, 0, 1, 0)
FileListScroll.BackgroundTransparency = 1
FileListScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
FileListScroll.ScrollBarThickness = 4
FileListScroll.Parent = FileListFrame

local FileListLayout = Instance.new("UIListLayout")
FileListLayout.Padding = UDim.new(0, 2)
FileListLayout.Parent = FileListScroll

local FileLabel = Instance.new("TextLabel")
FileLabel.Size = UDim2.new(0.7, -10, 0.06, 0)
FileLabel.Position = UDim2.new(0.3, 10, 0.08, 0)
FileLabel.BackgroundTransparency = 1
FileLabel.Text = "File Content:"
FileLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
FileLabel.Font = Enum.Font.Gotham
FileLabel.TextSize = 14
FileLabel.TextXAlignment = Enum.TextXAlignment.Left
FileLabel.Parent = FileViewer

-- File content editor
local FileEditor = Instance.new("TextBox")
FileEditor.Size = UDim2.new(0.7, -20, 0.82, 0)
FileEditor.Position = UDim2.new(0.3, 10, 0.08, 0)
FileEditor.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
FileEditor.BorderSizePixel = 0
FileEditor.Text = ""
FileEditor.TextColor3 = Color3.fromRGB(230, 230, 230)
FileEditor.TextWrapped = true
FileEditor.TextScaled = false
FileEditor.Font = Enum.Font.Code
FileEditor.TextSize = 13
FileEditor.MultiLine = true
FileEditor.Parent = FileViewer
local FECorner = Instance.new("UICorner")
FECorner.CornerRadius = UDim.new(0.01, 0)
FECorner.Parent = FileEditor

-- File actions
local FileActions = Instance.new("Frame")
FileActions.Size = UDim2.new(0.7, -20, 0.08, 0)
FileActions.Position = UDim2.new(0.3, 10, 0.92, 0)
FileActions.BackgroundTransparency = 1
FileActions.Parent = FileViewer

local SaveFileBtn = Instance.new("TextButton")
SaveFileBtn.Size = UDim2.new(0.25, 0, 1, 0)
SaveFileBtn.Position = UDim2.new(0, 0, 0, 0)
SaveFileBtn.BackgroundColor3 = Color3.fromRGB(60, 180, 80)
SaveFileBtn.BorderSizePixel = 0
SaveFileBtn.Text = "💾 Save"
SaveFileBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SaveFileBtn.Font = Enum.Font.GothamBold
SaveFileBtn.TextSize = 14
SaveFileBtn.Parent = FileActions
local SFBCorner = Instance.new("UICorner")
SFBCorner.CornerRadius = UDim.new(0.5, 0)
SFBCorner.Parent = SaveFileBtn

local RefreshFilesBtn = Instance.new("TextButton")
RefreshFilesBtn.Size = UDim2.new(0.25, 0, 1, 0)
RefreshFilesBtn.Position = UDim2.new(0.27, 0, 0, 0)
RefreshFilesBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 80)
RefreshFilesBtn.BorderSizePixel = 0
RefreshFilesBtn.Text = "🔄 Refresh"
RefreshFilesBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
RefreshFilesBtn.Font = Enum.Font.GothamBold
RefreshFilesBtn.TextSize = 14
RefreshFilesBtn.Parent = FileActions
local RFBCorner = Instance.new("UICorner")
RFBCorner.CornerRadius = UDim.new(0.5, 0)
RFBCorner.Parent = RefreshFilesBtn

local selectedFile = nil

-- Refresh file list
function refreshFileList()
    for _, child in ipairs(FileListScroll:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end

    -- Check if writefile is available
    local success, files = pcall(function()
        return listfiles()
    end)

    if not success then
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 30)
        btn.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
        btn.BorderSizePixel = 0
        btn.Text = "No files (writefile unavailable)"
        btn.TextColor3 = Color3.fromRGB(200, 200, 200)
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 13
        btn.Parent = FileListScroll
        FileListScroll.CanvasSize = UDim2.new(0, 0, 0, 32)
        return
    end

    local fileList = {}
    for _, f in ipairs(files) do
        if f:match("KeywordSearch_Results_.*%.(txt|csv|json)$") then
            table.insert(fileList, f)
        end
    end

    table.sort(fileList, function(a,b) return a > b end)

    if #fileList == 0 then
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 30)
        btn.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
        btn.BorderSizePixel = 0
        btn.Text = "No export files found"
        btn.TextColor3 = Color3.fromRGB(200, 200, 200)
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 13
        btn.Parent = FileListScroll
        FileListScroll.CanvasSize = UDim2.new(0, 0, 0, 32)
        return
    end

    for _, filePath in ipairs(fileList) do
        local fileName = filePath:match("([^/\\]+)$") or filePath
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 28)
        btn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
        btn.BorderSizePixel = 0
        btn.Text = fileName
        btn.TextColor3 = Color3.fromRGB(230, 230, 230)
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 12
        btn.Parent = FileListScroll

        btn.MouseEnter:Connect(function() btn.BackgroundColor3 = Color3.fromRGB(55, 55, 75) end)
        btn.MouseLeave:Connect(function() btn.BackgroundColor3 = Color3.fromRGB(40, 40, 55) end)

        btn.MouseButton1Click:Connect(function()
            selectedFile = filePath
            -- Load file content
            local success, content = pcall(function()
                return readfile(filePath)
            end)
            if success then
                FileEditor.Text = content
                for _, b in ipairs(FileListScroll:GetChildren()) do
                    if b:IsA("TextButton") then
                        b.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
                    end
                end
                btn.BackgroundColor3 = Color3.fromRGB(70, 100, 140)
            else
                FileEditor.Text = "Error loading file: " .. tostring(content)
            end
        end)
    end

    FileListScroll.CanvasSize = UDim2.new(0, 0, 0, #fileList * 30 + 10)
end

-- Save file
SaveFileBtn.MouseButton1Click:Connect(function()
    if not selectedFile then
        print("No file selected")
        return
    end
    local success, err = pcall(function()
        writefile(selectedFile, FileEditor.Text)
    end)
    if success then
        print("💾 File saved: " .. selectedFile)
        SaveFileBtn.Text = "✅ Saved!"
        task.wait(1)
        SaveFileBtn.Text = "💾 Save"
    else
        print("❌ Error saving: " .. tostring(err))
        SaveFileBtn.Text = "❌ Error"
        task.wait(1)
        SaveFileBtn.Text = "💾 Save"
    end
end)

-- Refresh files
RefreshFilesBtn.MouseButton1Click:Connect(refreshFileList)

-- View Files button
ViewFilesBtn.MouseButton1Click:Connect(function()
    FileViewer.Visible = not FileViewer.Visible
    if FileViewer.Visible then
        ViewFilesBtn.Text = "📂 Close Files"
        refreshFileList()
    else
        ViewFilesBtn.Text = "📂 View Files"
    end
end)

-- Scrolling list
local ListFrame = Instance.new("ScrollingFrame")
ListFrame.Size = UDim2.new(1, 0, 1, -0.16)
ListFrame.Position = UDim2.new(0, 0, 0.16, 0)
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

-- Fire Dialog (popup)
local FireDialog = Instance.new("Frame")
FireDialog.Size = UDim2.new(0.75, 0, 0.55, 0)
FireDialog.Position = UDim2.new(0.125, 0, 0.225, 0)
FireDialog.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
FireDialog.BorderSizePixel = 0
FireDialog.Visible = false
FireDialog.Parent = MainFrame
local DialogCorner = Instance.new("UICorner")
DialogCorner.CornerRadius = UDim.new(0.02, 0)
DialogCorner.Parent = FireDialog

local DialogTitle = Instance.new("TextLabel")
DialogTitle.Size = UDim2.new(1, 0, 0.12, 0)
DialogTitle.Position = UDim2.new(0, 0, 0, 0)
DialogTitle.BackgroundTransparency = 1
DialogTitle.Text = "🔥 Fire Event"
DialogTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
DialogTitle.Font = Enum.Font.GothamBold
DialogTitle.TextSize = 18
DialogTitle.Parent = FireDialog

local EventPathLabel = Instance.new("TextLabel")
EventPathLabel.Size = UDim2.new(1, -20, 0.12, 0)
EventPathLabel.Position = UDim2.new(0, 10, 0.12, 0)
EventPathLabel.BackgroundTransparency = 1
EventPathLabel.Text = "Event: "
EventPathLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
EventPathLabel.Font = Enum.Font.Gotham
EventPathLabel.TextSize = 13
EventPathLabel.TextXAlignment = Enum.TextXAlignment.Left
EventPathLabel.Parent = FireDialog

local ParamLabel = Instance.new("TextLabel")
ParamLabel.Size = UDim2.new(1, -20, 0.1, 0)
ParamLabel.Position = UDim2.new(0, 10, 0.25, 0)
ParamLabel.BackgroundTransparency = 1
ParamLabel.Text = "Parameters (comma separated):"
ParamLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
ParamLabel.Font = Enum.Font.Gotham
ParamLabel.TextSize = 13
ParamLabel.TextXAlignment = Enum.TextXAlignment.Left
ParamLabel.Parent = FireDialog

local ParamBox = Instance.new("TextBox")
ParamBox.Size = UDim2.new(1, -20, 0.2, 0)
ParamBox.Position = UDim2.new(0, 10, 0.35, 0)
ParamBox.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
ParamBox.BorderSizePixel = 0
ParamBox.Text = ""
ParamBox.PlaceholderText = 'e.g. 1, "hello", true'
ParamBox.TextColor3 = Color3.fromRGB(230, 230, 230)
ParamBox.PlaceholderColor3 = Color3.fromRGB(130, 130, 130)
ParamBox.Font = Enum.Font.Gotham
ParamBox.TextSize = 14
ParamBox.Parent = FireDialog
local ParamCorner = Instance.new("UICorner")
ParamCorner.CornerRadius = UDim.new(0.5, 0)
ParamCorner.Parent = ParamBox

-- Error display
local ErrorLabel = Instance.new("TextLabel")
ErrorLabel.Size = UDim2.new(1, -20, 0.12, 0)
ErrorLabel.Position = UDim2.new(0, 10, 0.58, 0)
ErrorLabel.BackgroundTransparency = 1
ErrorLabel.Text = ""
ErrorLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
ErrorLabel.Font = Enum.Font.Gotham
ErrorLabel.TextSize = 13
ErrorLabel.TextXAlignment = Enum.TextXAlignment.Left
ErrorLabel.TextWrapped = true
ErrorLabel.Parent = FireDialog

local FireBtn = Instance.new("TextButton")
FireBtn.Size = UDim2.new(0.28, 0, 0.12, 0)
FireBtn.Position = UDim2.new(0.1, 0, 0.75, 0)
FireBtn.BackgroundColor3 = Color3.fromRGB(60, 180, 80)
FireBtn.BorderSizePixel = 0
FireBtn.Text = "🔥 Fire"
FireBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
FireBtn.Font = Enum.Font.GothamBold
FireBtn.TextSize = 16
FireBtn.Parent = FireDialog
local FireCorner = Instance.new("UICorner")
FireCorner.CornerRadius = UDim.new(0.5, 0)
FireCorner.Parent = FireBtn

local CancelFireBtn = Instance.new("TextButton")
CancelFireBtn.Size = UDim2.new(0.28, 0, 0.12, 0)
CancelFireBtn.Position = UDim2.new(0.62, 0, 0.75, 0)
CancelFireBtn.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
CancelFireBtn.BorderSizePixel = 0
CancelFireBtn.Text = "Cancel"
CancelFireBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CancelFireBtn.Font = Enum.Font.GothamBold
CancelFireBtn.TextSize = 16
CancelFireBtn.Parent = FireDialog
local CancelFireCorner = Instance.new("UICorner")
CancelFireCorner.CornerRadius = UDim.new(0.5, 0)
CancelFireCorner.Parent = CancelFireBtn

local ResultLabel = Instance.new("TextLabel")
ResultLabel.Size = UDim2.new(1, -20, 0.1, 0)
ResultLabel.Position = UDim2.new(0, 10, 0.9, 0)
ResultLabel.BackgroundTransparency = 1
ResultLabel.Text = "Result: "
ResultLabel.TextColor3 = Color3.fromRGB(200, 255, 200)
ResultLabel.Font = Enum.Font.Gotham
ResultLabel.TextSize = 13
ResultLabel.TextXAlignment = Enum.TextXAlignment.Left
ResultLabel.Parent = FireDialog

-- ========== SCAN ENGINE ==========
local results = {}
local selectedInstance = nil

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

-- Start scan
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

-- Populate results list
function populateResults()
    for _, child in ipairs(ListFrame:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    table.sort(results, function(a,b) return a.Name < b.Name end)

    local function copyToClipboard(text)
        setclipboard(text)
        print("📋 Copied: " .. text)
    end

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

        -- Left-click: Fire event
        btn.MouseButton1Click:Connect(function()
            selectedInstance = inst
            for _, b in ipairs(ListFrame:GetChildren()) do
                if b:IsA("TextButton") then
                    b.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
                end
            end
            btn.BackgroundColor3 = Color3.fromRGB(70, 100, 140)
            showFireDialog(inst)
        end)

        -- Right-click: Copy path (or inspect if available)
        btn.MouseButton2Click:Connect(function()
            if _G.InspectInstance then
                _G.InspectInstance(inst)
                print("🔍 Inspecting: " .. path)
            else
                copyToClipboard(path)
                print("📋 Copied path: " .. path)
                btn.BackgroundColor3 = Color3.fromRGB(70, 140, 70)
                task.wait(0.2)
                btn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
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

-- ========== FIRE DIALOG (FIXED) ==========
local function showFireDialog(inst)
    FireDialog.Visible = true
    EventPathLabel.Text = "Event: " .. inst:GetFullName()
    ParamBox.Text = ""
    ResultLabel.Text = "Result: "
    ErrorLabel.Text = ""
    ParamBox:CaptureFocus()
end

local function closeFireDialog()
    FireDialog.Visible = false
end
CancelFireBtn.MouseButton1Click:Connect(closeFireDialog)

FireBtn.MouseButton1Click:Connect(function()
    if not selectedInstance then
        ResultLabel.Text = "❌ No event selected"
        return
    end

    local argsText = ParamBox.Text
    local args = {}
    if argsText ~= "" then
        for part in string.gmatch(argsText, "[^,]+") do
            local trimmed = part:match("^%s*(.-)%s*$")
            if trimmed == "true" then
                table.insert(args, true)
            elseif trimmed == "false" then
                table.insert(args, false)
            elseif trimmed == "nil" then
                table.insert(args, nil)
            elseif tonumber(trimmed) then
                table.insert(args, tonumber(trimmed))
            else
                -- Remove quotes if present
                local str = trimmed:match("^\"(.*)\"$") or trimmed:match("^'(.*)'$") or trimmed
                table.insert(args, str)
            end
        end
    end

    local ev = selectedInstance
    local eventType = ev.ClassName

    -- Clear previous errors
    ErrorLabel.Text = ""
    ResultLabel.Text = "Firing..."

    local success, result = pcall(function()
        if ev:IsA("RemoteEvent") then
            ev:FireServer(unpack(args))
            return "✅ RemoteEvent fired successfully"
        elseif ev:IsA("BindableEvent") then
            ev:Fire(unpack(args))
            return "✅ BindableEvent fired successfully"
        elseif ev:IsA("UnreliableRemoteEvent") then
            ev:FireServer(unpack(args))
            return "✅ UnreliableRemoteEvent fired successfully"
        elseif ev:IsA("RemoteFunction") then
            local response = ev:InvokeServer(unpack(args))
            return "✅ RemoteFunction returned: " .. tostring(response)
        else
            error("❌ Instance is not a fireable event. Type: " .. eventType)
        end
    end)

    if success then
        ResultLabel.Text = result
        ResultLabel.TextColor3 = Color3.fromRGB(200, 255, 200)
        ErrorLabel.Text = ""
    else
        ResultLabel.Text = "❌ Failed"
        ResultLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        ErrorLabel.Text = "Error: " .. tostring(result)
    end
end)

-- ========== EXPORT FUNCTIONS ==========
function exportResults(format)
    if #results == 0 then
        print("No results to export")
        return
    end

    local timestamp = os.date("%Y-%m-%d_%H-%M-%S")
    local text = ""
    local filename = ""

    if format == "txt" then
        text = "Keyword Search Results - " .. os.date("%Y-%m-%d %H:%M:%S") .. "\n"
        text = text .. "=====================================\n\n"
        for _, inst in ipairs(results) do
            text = text .. inst:GetFullName() .. "\n"
        end
        text = text .. "\nTotal: " .. #results .. " matches"
        filename = "KeywordSearch_Results_" .. timestamp .. ".txt"
    elseif format == "csv" then
        text = "Index,Name,Class,Path\n"
        for i, inst in ipairs(results) do
            local name = inst.Name:gsub('"', '""')
            local class = inst.ClassName:gsub('"', '""')
            local path = inst:GetFullName():gsub('"', '""')
            text = text .. i .. ',"' .. name .. '","' .. class .. '","' .. path .. '"\n'
        end
        filename = "KeywordSearch_Results_" .. timestamp .. ".csv"
    elseif format == "json" then
        local jsonTable = {}
        for _, inst in ipairs(results) do
            table.insert(jsonTable, {
                name = inst.Name,
                class = inst.ClassName,
                path = inst:GetFullName()
            })
        end
        text = "[\n"
        for i, item in ipairs(jsonTable) do
            text = text .. '  {\n'
            text = text .. '    "name": "' .. item.name:gsub('"', '\\"') .. '",\n'
            text = text .. '    "class": "' .. item.class:gsub('"', '\\"') .. '",\n'
            text = text .. '    "path": "' .. item.path:gsub('"', '\\"') .. '"\n'
            text = text .. '  }' .. (i < #jsonTable and ',' or '') .. '\n'
        end
        text = text .. "]\n"
        filename = "KeywordSearch_Results_" .. timestamp .. ".json"
    end

    local success = pcall(function()
        writefile(filename, text)
    end)

    if success then
        print("📄 Exported to: " .. filename)
        ExportBtn.Text = "✅ Exported!"
        task.wait(1.5)
        ExportBtn.Text = "📄 Export"
    else
        setclipboard(text)
        print("📋 Copied to clipboard (writefile unavailable)")
        ExportBtn.Text = "📋 Copied!"
        task.wait(1.5)
        ExportBtn.Text = "📄 Export"
    end
end

-- ========== COPY ALL ==========
CopyAllBtn.MouseButton1Click:Connect(function()
    if #results == 0 then
        print("No results to copy")
        return
    end
    local text = ""
    for _, inst in ipairs(results) do
        text = text .. inst:GetFullName() .. "\n"
    end
    setclipboard(text)
    print("📋 Copied all " .. #results .. " results to clipboard")
    CopyAllBtn.Text = "✅ Copied!"
    task.wait(1.5)
    CopyAllBtn.Text = "📋 Copy All"
end)

-- ========== LAUNCH ==========
startScan()
print("✅ Professional Keyword Search v5.0 loaded – Press Right Shift to toggle")
print("🔥 Left-click to fire (fixed error handling), Right-click to copy/inspect")
print("📂 Click 'View Files' to browse and edit exported files")
