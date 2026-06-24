--[[
    ULTRA-FAST KEYWORD SEARCH – Premium UI
    - Uses game:GetDescendants() for instant object list
    - Processes 500 objects per chunk → lightning fast
    - Beautiful glass‑morphism design
    - Smooth scrolling results
    - Click to copy, right‑click to inspect
]]

local player = game.Players.LocalPlayer

-- ========== KEYWORDS (Lowercase for speed) ==========
local keywords = {
    -- Mutations
    "bloodlit", "electric", "starstruck", "rainbow", "mutat", "mutation", "mut", "boost",
    "bloodmoon", "lightning", "shocked", "starfull", "cloudy", "weather", "rain", "storm",
    "event", "trigger", "apply", "effect", "buff", "debuff", "aura",

    -- Growth
    "plant", "harvest", "sell", "buy", "seed", "crop", "garden", "plot", "water",
    "sprinkler", "grow", "growth", "speed", "time", "progress", "stage", "mature",
    "acorn", "berry", "fruit", "vegetable", "flower", "tree",

    -- Economy & Dupe
    "dupe", "duplicate", "clone", "spawn", "give", "add", "remove", "take",
    "currency", "shekel", "money", "cash", "coin", "gem", "premium", "shop", "store",

    -- Remotes
    "remote", "event", "function", "bindable", "unreliable", "fire", "invoke", "send",
    "server", "client", "replicate", "network", "rpc", "signal", "callback",

    -- Pets
    "pet", "egg", "hatch", "incubate", "ability", "buff", "bonus", "chance", "luck",
    "companion", "familiar", "beast", "creature",

    -- Player
    "player", "stats", "inventory", "backpack", "tool", "gear", "item", "quantity",
    "level", "exp", "experience", "rank", "tier",

    -- Size & Weight
    "size", "weight", "mass", "scale", "big", "large", "small", "giant", "tiny",
    "multiplier", "bonus", "factor", "modifier",

    -- Stealing
    "steal", "thief", "rob", "take", "night", "dark", "moon", "lunar", "sneak",

    -- Admin / Dev
    "admin", "mod", "god", "cheat", "exploit", "bypass", "noclip", "fly", "speed", "jump",
    "debug", "test", "dev", "development", "sandbox", "studio", "secret",

    -- GUI
    "gui", "screen", "frame", "label", "button", "textbox", "scroll", "list",
    "menu", "dialog", "popup", "notification",

    -- Misc
    "gold", "silver", "bronze", "legendary", "rare", "common", "uncommon",
}

-- Convert to lowercase for faster matching
for i, kw in ipairs(keywords) do
    keywords[i] = kw:lower()
end

-- ========== CREATE MAIN GUI ==========
local gui = Instance.new("ScreenGui")
gui.Name = "KeywordSearch"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 620, 0, 480)
main.Position = UDim2.new(0.5, -310, 0.5, -240)
main.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
main.BackgroundTransparency = 0.05
main.BorderSizePixel = 0
main.ClipsDescendants = true
main.Parent = gui

-- Rounded corners (using UICorner)
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = main

-- Subtle shadow
local shadow = Instance.new("Frame")
shadow.Size = UDim2.new(1, 0, 1, 0)
shadow.Position = UDim2.new(0, 0, 0, 0)
shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
shadow.BackgroundTransparency = 0.5
shadow.BorderSizePixel = 0
shadow.ZIndex = -1
shadow.Parent = main

-- ========== TITLE BAR ==========
local title = Instance.new("Frame")
title.Size = UDim2.new(1, 0, 0, 36)
title.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
title.BackgroundTransparency = 0.1
title.BorderSizePixel = 0
title.Parent = main

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 8)
titleCorner.Parent = title

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -100, 1, 0)
titleLabel.Position = UDim2.new(0, 12, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "🔍 Keyword Search"
titleLabel.TextColor3 = Color3.fromRGB(255,255,255)
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 16
titleLabel.Parent = title

-- Close button
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 36, 1, 0)
closeBtn.Position = UDim2.new(1, -36, 0, 0)
closeBtn.BackgroundTransparency = 1
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(255,255,255)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 18
closeBtn.Parent = title

closeBtn.MouseButton1Click:Connect(function() gui:Destroy() end)

-- ========== DRAGGING ==========
local drag = false
local startPos, offset
title.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then
        drag = true
        startPos = i.Position
        offset = main.Position
    end
end)
title.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then drag = false end
end)
game:GetService("UserInputService").InputChanged:Connect(function(i)
    if drag and i.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = i.Position - startPos
        main.Position = UDim2.new(offset.X.Scale, offset.X.Offset + delta.X,
                                  offset.Y.Scale, offset.Y.Offset + delta.Y)
    end
end)

-- ========== CONTENT ==========
local content = Instance.new("Frame")
content.Size = UDim2.new(1, -20, 1, -56)
content.Position = UDim2.new(0, 10, 0, 46)
content.BackgroundTransparency = 1
content.Parent = main

-- ========== PROGRESS VIEW ==========
local progressView = Instance.new("Frame")
progressView.Size = UDim2.new(1, 0, 1, 0)
progressView.BackgroundTransparency = 1
progressView.Parent = content

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, 0, 0, 32)
statusLabel.Position = UDim2.new(0, 0, 0, 10)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Preparing scan..."
statusLabel.TextColor3 = Color3.fromRGB(220,220,220)
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 18
statusLabel.Parent = progressView

local barBg = Instance.new("Frame")
barBg.Size = UDim2.new(0.85, 0, 0, 22)
barBg.Position = UDim2.new(0.075, 0, 0, 60)
barBg.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
barBg.BorderSizePixel = 0
barBg.Parent = progressView
local barBgCorner = Instance.new("UICorner")
barBgCorner.CornerRadius = UDim.new(0, 4)
barBgCorner.Parent = barBg

local barFill = Instance.new("Frame")
barFill.Size = UDim2.new(0, 0, 1, 0)
barFill.BackgroundColor3 = Color3.fromRGB(100, 200, 255)
barFill.BorderSizePixel = 0
barFill.Parent = barBg
local barFillCorner = Instance.new("UICorner")
barFillCorner.CornerRadius = UDim.new(0, 4)
barFillCorner.Parent = barFill

-- Gradient for bar fill (optional)
local grad = Instance.new("UIGradient")
grad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(60, 180, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 80, 255))
})
grad.Parent = barFill

local progressText = Instance.new("TextLabel")
progressText.Size = UDim2.new(1, 0, 0, 30)
progressText.Position = UDim2.new(0, 0, 0, 100)
progressText.BackgroundTransparency = 1
progressText.Text = "0%"
progressText.TextColor3 = Color3.fromRGB(200,200,200)
progressText.Font = Enum.Font.Gotham
progressText.TextSize = 16
progressText.Parent = progressView

local foundCountLabel = Instance.new("TextLabel")
foundCountLabel.Size = UDim2.new(1, 0, 0, 30)
foundCountLabel.Position = UDim2.new(0, 0, 0, 140)
foundCountLabel.BackgroundTransparency = 1
foundCountLabel.Text = "Found: 0 matches"
foundCountLabel.TextColor3 = Color3.fromRGB(180,180,180)
foundCountLabel.Font = Enum.Font.Gotham
foundCountLabel.TextSize = 15
foundCountLabel.Parent = progressView

local cancelBtn = Instance.new("TextButton")
cancelBtn.Size = UDim2.new(0, 140, 0, 36)
cancelBtn.Position = UDim2.new(0.5, -70, 0, 190)
cancelBtn.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
cancelBtn.BorderSizePixel = 0
cancelBtn.Text = "Cancel Scan"
cancelBtn.TextColor3 = Color3.fromRGB(255,255,255)
cancelBtn.Font = Enum.Font.GothamBold
cancelBtn.TextSize = 15
cancelBtn.Parent = progressView
local cancelCorner = Instance.new("UICorner")
cancelCorner.CornerRadius = UDim.new(0, 4)
cancelCorner.Parent = cancelBtn

-- Hover effect
cancelBtn.MouseEnter:Connect(function() cancelBtn.BackgroundColor3 = Color3.fromRGB(200, 70, 70) end)
cancelBtn.MouseLeave:Connect(function() cancelBtn.BackgroundColor3 = Color3.fromRGB(180, 60, 60) end)

local scanCancelled = false
cancelBtn.MouseButton1Click:Connect(function()
    scanCancelled = true
    statusLabel.Text = "❌ Cancelled"
    progressText.Text = "Cancelled"
    barFill.Size = UDim2.new(1, 0, 1, 0)
    barFill.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
    cancelBtn.Visible = false
end)

-- ========== RESULTS VIEW ==========
local resultsView = Instance.new("Frame")
resultsView.Size = UDim2.new(1, 0, 1, 0)
resultsView.BackgroundTransparency = 1
resultsView.Visible = false
resultsView.Parent = content

local filterBox = Instance.new("TextBox")
filterBox.Size = UDim2.new(1, 0, 0, 32)
filterBox.Position = UDim2.new(0, 0, 0, 0)
filterBox.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
filterBox.BorderSizePixel = 0
filterBox.Text = ""
filterBox.PlaceholderText = "🔍 Filter results..."
filterBox.TextColor3 = Color3.fromRGB(220,220,220)
filterBox.PlaceholderColor3 = Color3.fromRGB(130,130,130)
filterBox.Font = Enum.Font.Gotham
filterBox.TextSize = 14
filterBox.Parent = resultsView
local filterCorner = Instance.new("UICorner")
filterCorner.CornerRadius = UDim.new(0, 4)
filterCorner.Parent = filterBox

local listFrame = Instance.new("ScrollingFrame")
listFrame.Size = UDim2.new(1, 0, 1, -40)
listFrame.Position = UDim2.new(0, 0, 0, 40)
listFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
listFrame.BorderSizePixel = 0
listFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
listFrame.ScrollBarThickness = 6
listFrame.Parent = resultsView
local listCorner = Instance.new("UICorner")
listCorner.CornerRadius = UDim.new(0, 4)
listCorner.Parent = listFrame

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 2)
listLayout.Parent = listFrame

-- ========== SCANNING ENGINE ==========
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
    if matchesAny(inst.Name) then
        table.insert(results, inst)
        return true
    end
    if matchesAny(inst.ClassName) then
        table.insert(results, inst)
        return true
    end
    -- Check common string properties
    local props = {"Value", "Text", "DisplayName", "Title", "Description", "Tag"}
    for i = 1, #props do
        local prop = props[i]
        local success, val = pcall(function() return inst[prop] end)
        if success and type(val) == "string" and matchesAny(val) then
            table.insert(results, inst)
            return true
        end
    end
    -- Check attributes (fast)
    local attrs = inst:GetAttributes()
    for key, val in pairs(attrs) do
        if type(key) == "string" and matchesAny(key) then
            table.insert(results, inst)
            return true
        end
        if type(val) == "string" and matchesAny(val) then
            table.insert(results, inst)
            return true
        end
    end
    return false
end

-- ========== START SCAN ==========
local function startScan()
    statusLabel.Text = "Gathering objects..."
    task.wait()

    -- Get all objects at once (fast)
    local allObjects = game:GetDescendants()
    local total = #allObjects
    statusLabel.Text = "Scanning " .. total .. " objects..."
    task.wait()

    local processed = 0
    scanCancelled = false
    results = {}
    barFill.Size = UDim2.new(0, 0, 1, 0)
    progressText.Text = "0%"
    foundCountLabel.Text = "Found: 0 matches"
    cancelBtn.Visible = true

    local chunkSize = 500  -- optimized chunk size
    for i = 1, total, chunkSize do
        if scanCancelled then break end
        local chunkEnd = math.min(i + chunkSize - 1, total)
        for j = i, chunkEnd do
            checkInstance(allObjects[j])
            processed = processed + 1
        end
        -- Update progress
        local pct = (processed / total) * 100
        barFill.Size = UDim2.new(pct/100, 0, 1, 0)
        progressText.Text = string.format("%.1f%%", pct)
        statusLabel.Text = "Processing " .. processed .. "/" .. total
        foundCountLabel.Text = "Found: " .. #results .. " matches"
        task.wait()  -- yield to update UI
    end

    if scanCancelled then
        statusLabel.Text = "❌ Cancelled"
        progressText.Text = "Cancelled"
        barFill.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
        return
    end

    -- Done
    statusLabel.Text = "✅ Scan complete!"
    progressText.Text = "100%"
    barFill.Size = UDim2.new(1, 0, 1, 0)
    barFill.BackgroundColor3 = Color3.fromRGB(100, 220, 100)
    foundCountLabel.Text = "Found: " .. #results .. " matches"
    task.wait(0.3)

    -- Transition to results
    progressView.Visible = false
    resultsView.Visible = true
    populateResults()
end

-- ========== POPULATE RESULTS ==========
function populateResults()
    -- Clear
    for _, child in ipairs(listFrame:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end

    table.sort(results, function(a,b) return a.Name < b.Name end)

    local function copyToClipboard(text)
        setclipboard(text)
        print("📋 Copied: " .. text)
        -- Visual feedback
    end

    local inspectFunction = _G.InspectInstance

    for _, inst in ipairs(results) do
        local path = inst:GetFullName()
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 26)
        btn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
        btn.BorderSizePixel = 0
        btn.Text = path
        btn.TextColor3 = Color3.fromRGB(220,220,220)
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 13
        btn.Parent = listFrame

        -- Hover
        btn.MouseEnter:Connect(function() btn.BackgroundColor3 = Color3.fromRGB(55, 55, 75) end)
        btn.MouseLeave:Connect(function() btn.BackgroundColor3 = Color3.fromRGB(40, 40, 55) end)

        -- Left-click: copy
        btn.MouseButton1Click:Connect(function()
            copyToClipboard(path)
            btn.BackgroundColor3 = Color3.fromRGB(70, 100, 120)
            task.wait(0.15)
            btn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
        end)

        -- Right-click: inspect
        btn.MouseButton2Click:Connect(function()
            if inspectFunction then
                inspectFunction(inst)
                print("🔍 Inspecting: " .. path)
            else
                copyToClipboard(path)
                print("📋 Copied path (inspect not available)")
            end
        end)
    end

    local count = #results
    listFrame.CanvasSize = UDim2.new(0, 0, 0, count * 28 + 10)
    titleLabel.Text = "🔍 Results (" .. count .. " matches)"

    -- Filter logic
    filterBox:GetPropertyChangedSignal("Text"):Connect(function()
        local filter = filterBox.Text:lower()
        local visible = 0
        for _, btn in ipairs(listFrame:GetChildren()) do
            if btn:IsA("TextButton") then
                if filter == "" then
                    btn.Visible = true
                else
                    btn.Visible = btn.Text:lower():find(filter) ~= nil
                end
                if btn.Visible then visible = visible + 1 end
            end
        end
        listFrame.CanvasSize = UDim2.new(0, 0, 0, visible * 28 + 10)
    end)
end

-- ========== LAUNCH ==========
startScan()
print("✅ Premium Keyword Search loaded. Scanning...")