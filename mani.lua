-- CONFIG
local SilentAimEnabled = false
local FOV = 150
local WhitelistedPlayer = ""
local SnapUnderEnabled = false -- ตัวแปรมุดดิน
local SnapDepth = -10 -- ความลึกเริ่มต้น

--// Intro Animation
local TweenService = game:GetService("TweenService")

local intro = Instance.new("ScreenGui")
intro.Parent = game.CoreGui
intro.Name = "JerryHubIntro"
intro.ResetOnSpawn = false

local logo = Instance.new("ImageLabel")
logo.Parent = intro
logo.Size = UDim2.fromOffset(110,110)
logo.AnchorPoint = Vector2.new(0.5,0.5)
logo.Position = UDim2.new(0.5,-140,0.5,0)
logo.BackgroundTransparency = 1
logo.Image = "rbxassetid://79955709475525"
logo.ImageTransparency = 1

local text = Instance.new("TextLabel")
text.Parent = intro
text.Size = UDim2.fromOffset(320,60)
text.AnchorPoint = Vector2.new(0.5,0.5)
text.Position = UDim2.new(0.5,60,0.5,0)
text.BackgroundTransparency = 1
text.Text = "Welcome To\nJerry Hub"
text.TextColor3 = Color3.fromRGB(255,255,255)
text.TextScaled = true
text.Font = Enum.Font.GothamBold
text.TextTransparency = 1

TweenService:Create(
logo,
TweenInfo.new(1.2,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),
{
ImageTransparency = 0,
Position = UDim2.new(0.5,-80,0.5,0)
}
):Play()

TweenService:Create(
text,
TweenInfo.new(1),
{TextTransparency = 0}
):Play()

task.wait(2.5)
intro:Destroy()

--// WindUI
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Window = WindUI:CreateWindow({
Title = "Neverman x'Dev",
Author = "Kiwwy",
Icon = "rbxassetid://79955709475525",
Theme = "Dark",
Size = UDim2.fromOffset(350,450),
Acrylic = true,
HideSearchBar = true,

OpenButton = {
Enabled = false
}
})

Window:Tag({
Title = "v1.6.6",
Icon = "github",
Color = Color3.fromHex("#30ff6a"),
Radius = 0,
})

Window:SetBackgroundTransparency(0.25)
Window:SetBackgroundImageTransparency(0.25)

--// Toggle Button
local gui = Instance.new("ScreenGui")
gui.Parent = game.CoreGui
gui.Name = "NM_Toggle"
gui.ResetOnSpawn = false

local btn = Instance.new("ImageButton")
btn.Parent = gui
btn.Size = UDim2.fromOffset(42,42)
btn.Position = UDim2.fromOffset(40,220)

btn.BackgroundTransparency = 1
btn.Image = "rbxassetid://79955709475525"
btn.ScaleType = Enum.ScaleType.Fit

btn.Active = true
btn.Draggable = true
btn.AnchorPoint = Vector2.new(0.5,0.5)

btn.MouseButton1Click:Connect(function()
    local down = TweenService:Create(btn,TweenInfo.new(0.07),{Size = UDim2.fromOffset(36,36)})    
    local up = TweenService:Create(btn,TweenInfo.new(0.07),{Size = UDim2.fromOffset(42,42)})    
    down:Play()    
    down.Completed:Wait()    
    up:Play()    
    Window:Toggle()
end)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local SilentAimEnabled = true
local FOV = 150
local BULLET_SPEED = 1200

local GunNames = {
"P226","MP5","M24","Draco","Glock","Sawnoff","Uzi","G3","C9",
"Hunting Rifle","Anaconda","AK47","Remington","Double Barrel"
}

local GunLookup = {}
for _,v in pairs(GunNames) do
    GunLookup[v] = true
end

local fovCircle = Drawing.new("Circle")
fovCircle.Color = Color3.fromRGB(255,255,255)
fovCircle.Thickness = 1
fovCircle.NumSides = 100
fovCircle.Radius = FOV
fovCircle.Filled = false
fovCircle.Visible = true

local tracerLine = Drawing.new("Line")
tracerLine.Color = Color3.fromRGB(255,0,0)
tracerLine.Thickness = 1
tracerLine.Visible = false

--// แท็บ Combat (หน้าแรก)
local CombatTab = Window:Tab({
Title = "Combat",
Icon = "crosshair"
})

-- ย้ายมาไว้ลำดับที่ 1 ของแท็บแรก
CombatTab:Toggle({
Title = "Snap Under (มุดดิน)",
Default = false,
Callback = function(v)
    SnapUnderEnabled = v
end
})

CombatTab:Section({
Title = "Silent Aim"
})

CombatTab:Toggle({
Title = "Enable Silent Aim",
Default = SilentAimEnabled,
Callback = function(v)
    SilentAimEnabled = v
    fovCircle.Visible = v
end
})

local function GetPlayerList()
    local list = {"None"}
    for _,p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then table.insert(list, p.Name) end
    end
    return list
end

local FriendDropdown = CombatTab:Dropdown({
Title = "Whitelist Friend (No Tracer)",
Multi = false,
Options = GetPlayerList(),
Default = "None",
Callback = function(v)
    WhitelistedPlayer = v
end
})

task.spawn(function()
    while task.wait(5) do
        FriendDropdown:Refresh(GetPlayerList())
    end
end)

CombatTab:Slider({
Title = "FOV",
Step = 1,
Value = {
Min = 50,
Max = 800,
Default = FOV
},
Callback = function(v)
    FOV = v
    if fovCircle then
        fovCircle.Radius = v
    end
end
})

--// Movement Tab (ย้ายที่เหลือมานี่)
local MovementTab = Window:Tab({
Title = "Movement",
Icon = "person-standing"
})

MovementTab:Section({Title = "Underground Settings"})

MovementTab:Slider({
Title = "Snap Depth (ความลึก)",
Step = 0.5,
Value = {Min = -20, Max = 0, Default = -10},
Callback = function(v)
    SnapDepth = v
end
})

--// Loop สำหรับการมุดดิน
RunService.PostSimulation:Connect(function()
    if SnapUnderEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = LocalPlayer.Character.HumanoidRootPart
        local ray = Ray.new(hrp.Position + Vector3.new(0, 5, 0), Vector3.new(0, -50, 0))
        local part, pos = workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character})

        if part then    
            hrp.CFrame = CFrame.new(hrp.Position.X, pos.Y + SnapDepth, hrp.Position.Z) * hrp.CFrame.Rotation    
        end    
    end
end)

local function GetGunMuzzle()
    if not LocalPlayer.Character then return nil end
    for _,tool in pairs(LocalPlayer.Character:GetChildren()) do
        if tool:IsA("Tool") and GunLookup[tool.Name] then
            local handle = tool:FindFirstChild("Handle")
            if handle then return handle.Position end
        end
    end
    return nil
end

local function CreateBeamShot(startPos,endPos)
    local p1 = Instance.new("Part")
    p1.Anchored = true
    p1.CanCollide = false
    p1.Transparency = 1
    p1.Size = Vector3.new(0.2,0.2,0.2)
    p1.Position = startPos
    p1.Parent = workspace

    local p2 = Instance.new("Part")
    p2.Anchored = true
    p2.CanCollide = false
    p2.Transparency = 1
    p2.Size = Vector3.new(0.2,0.2,0.2)
    p2.Position = endPos
    p2.Parent = workspace

    local a1 = Instance.new("Attachment",p1)
    local a2 = Instance.new("Attachment",p2)

    local beam = Instance.new("Beam")
    beam.Attachment0 = a1
    beam.Attachment1 = a2
    beam.Width0 = 0.35
    beam.Width1 = 0.35
    beam.FaceCamera = false
    beam.LightEmission = 1
    beam.Texture = ""
    beam.Transparency = NumberSequence.new(0)
    beam.Color = ColorSequence.new(Color3.fromRGB(180,0,0))
    beam.Parent = p1

    task.delay(0.60,function()
        p1:Destroy()
        p2:Destroy()
    end)
end

local function GetClosestTarget()
    local closest
    local shortest = math.huge
    local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)

    for _,player in pairs(Players:GetPlayers()) do
        -- แก้ไข: ลบเงื่อนไขเช็ค AimPart และใช้ Head เป็นค่ามาตรฐานแทน
        if player ~= LocalPlayer and player.Name ~= WhitelistedPlayer and player.Character and player.Character:FindFirstChild("Head") then
            local targetPart = player.Character.Head
            local pos,onScreen = Camera:WorldToViewportPoint(targetPart.Position)

            if onScreen then
                local dist = (Vector2.new(pos.X,pos.Y) - center).Magnitude
                if dist < FOV and dist < shortest then
                    shortest = dist
                    closest = player
                end
            end
        end
    end
    return closest
end

local function PredictPosition(targetPart)
    local root = targetPart.Parent:FindFirstChild("HumanoidRootPart")
    if not root then return targetPart.Position end
    local velocity = root.AssemblyLinearVelocity
    local distance = (Camera.CFrame.Position - targetPart.Position).Magnitude
    local travelTime = distance / BULLET_SPEED
    local predicted = targetPart.Position + (velocity * travelTime)
    if velocity.Magnitude > 150 then predicted = targetPart.Position + (velocity.Unit * 8) end
    return predicted
end

local function IsHoldingAllowedGun(args)
    local ok,weapon = pcall(function() return args[3] end)
    if ok and typeof(weapon) == "Instance" and GunLookup[weapon.Name] then return true end
    if LocalPlayer.Character then
        for _,v in pairs(LocalPlayer.Character:GetChildren()) do
            if v:IsA("Tool") and GunLookup[v.Name] then return true end
        end
    end
    return false
end

local send = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Send")
local oldFire
oldFire = hookfunction(send.FireServer,function(self,...)
    local args = {...}
    if SilentAimEnabled and IsHoldingAllowedGun(args) then
        local target = GetClosestTarget()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            local hitPart = target.Character.Head
            local aimPos = PredictPosition(hitPart)
            local muzzle = GetGunMuzzle() or Camera.CFrame.Position
            CreateBeamShot(muzzle,aimPos)
            args[4] = CFrame.new(1/0,1/0,1/0)
            args[5] = {[1] = {[1] = {["Instance"] = hitPart, ["Position"] = aimPos}}}
        end
    end
    return oldFire(self,unpack(args))
end)

RunService.RenderStepped:Connect(function()
    local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    fovCircle.Position = center
    fovCircle.Radius = FOV
    if SilentAimEnabled then
        local target = GetClosestTarget()
        if target and target.Name ~= WhitelistedPlayer and target.Character and target.Character:FindFirstChild("Head") then
            local pred = PredictPosition(target.Character.Head)
            local pos,onScreen = Camera:WorldToViewportPoint(pred)
            if onScreen then
                tracerLine.From = center
                tracerLine.To = Vector2.new(pos.X,pos.Y)
                tracerLine.Visible = true
            else
                tracerLine.Visible = false
            end
        else
            tracerLine.Visible = false
        end
    else
        tracerLine.Visible = false
    end
end)

--// Visuals & Item ESP
local ContentProvider = game:GetService("ContentProvider")
local ItemESP_Enabled = true
local BillboardCache = {}
local ItemESP_UpdateConnections = {}
local WeaponDB = {}
local PreloadedImages = {}

local RARITY_COLORS = {
    ["Common"] = Color3.fromRGB(255,255,255),
    ["Uncommon"] = Color3.fromRGB(99,255,52),
    ["Rare"] = Color3.fromRGB(51,170,255),
    ["Epic"] = Color3.fromRGB(237,44,255),
    ["Legendary"] = Color3.fromRGB(255,150,0),
    ["Omega"] = Color3.fromRGB(255,20,51),
}

local VisualsTab = Window:Tab({Title = "Visuals", Icon = "eye"})
VisualsTab:Section({Title = "Item ESP"})

VisualsTab:Toggle({
Title = "Enable Item ESP",
Default = ItemESP_Enabled,
Callback = function(v)
    ItemESP_Enabled = v
    for _, billboard in pairs(BillboardCache) do billboard.Enabled = v end
end
})

local function generateUniqueKey(tool)
    if not tool or not tool:IsA("Tool") then return nil end
    local itemId = tool:GetAttribute("ItemId") or tool:GetAttribute("Id")    
    if itemId then return "ITEMID_"..tostring(itemId) end    
    local partsData = {}    
    for _,part in ipairs(tool:GetDescendants()) do    
        if part:IsA("SpecialMesh") and part.MeshId ~= "" then table.insert(partsData,"MESH_"..part.MeshId.."|TEX_"..(part.TextureId or ""))
        elseif part:IsA("MeshPart") and part.MeshId ~= "" then table.insert(partsData,"MESH_"..part.MeshId.."|TEX_"..(part.TextureID or ""))
        elseif part:IsA("Decal") then table.insert(partsData,"DECAL_"..part.Texture)
        elseif part:IsA("Part") then table.insert(partsData,"PART_"..part.Name) end    
    end    
    if #partsData > 0 then table.sort(partsData) return "MESHKEY_"..table.concat(partsData,";") end    
    local displayName = tool:GetAttribute("DisplayName") or tool.Name    
    local rarity = tool:GetAttribute("RarityName") or tool:GetAttribute("Rarity") or "Common"    
    local imageId = tool:GetAttribute("ImageId") or "NOIMAGE"    
    return "NAME_"..displayName.."_"..rarity.."_"..imageId
end

local function registerItems(folder)
    for _,tool in ipairs(folder:GetDescendants()) do
        if not tool:IsA("Tool") then continue end
        local key = generateUniqueKey(tool)    
        if not key then continue end    
        local displayName = tool:GetAttribute("DisplayName") or tool.Name    
        local imageId = tool:GetAttribute("ImageId") or "rbxassetid://7072725737"    
        local rarity = tool:GetAttribute("RarityName") or tool:GetAttribute("Rarity") or "Common"    
        WeaponDB[key] = {Name = displayName, Rarity = rarity, ImageId = imageId, Key = key}    
        if imageId and not PreloadedImages[imageId] then    
            PreloadedImages[imageId] = true    
            task.spawn(function() pcall(function() ContentProvider:PreloadAsync({imageId}) end) end)    
        end    
    end
end

pcall(function()
    local itemsFolder = ReplicatedStorage:WaitForChild("Items",5)
    if itemsFolder then registerItems(itemsFolder) end
    for _,obj in ipairs(ReplicatedStorage:GetChildren()) do if obj:IsA("Folder") then registerItems(obj) end end
end)

local function getWeaponInfo(tool)
    local key = generateUniqueKey(tool)
    return WeaponDB[key]
end

local function createBillboardForPlayer(player)
    if player == LocalPlayer then return end    
    if BillboardCache[player] then return end    

    local billboard, container, connections = nil, nil, {}
    local lastHash = ""    

    local function updateESP()    
        if not billboard then return end    
        local currentTools = {}    
        local function scan(folder)    
            if not folder then return end    
            for _,tool in ipairs(folder:GetChildren()) do    
                if tool:IsA("Tool") and tool.Name ~= "Fists" then    
                    local info = getWeaponInfo(tool)    
                    if info then table.insert(currentTools,info) end    
                end    
            end    
        end    
        if player.Character then scan(player.Character) end    
        local backpack = player:FindFirstChild("Backpack")    
        if backpack then scan(backpack) end    
        container:ClearAllChildren()    
        local layout = Instance.new("UIGridLayout")    
        layout.CellSize = UDim2.new(0,16,0,16)     
        layout.CellPadding = UDim2.new(0,3,0,0)    
        layout.HorizontalAlignment = Enum.HorizontalAlignment.Center    
        layout.VerticalAlignment = Enum.VerticalAlignment.Bottom    
        layout.Parent = container    
        for i,info in ipairs(currentTools) do    
            local img = Instance.new("ImageLabel")    
            img.Parent = container    
            img.Size = UDim2.new(0,16,0,16)     
            img.BackgroundTransparency = 1    
            img.Image = info.ImageId    
            img.LayoutOrder = i    
            img.ImageColor3 = RARITY_COLORS[info.Rarity] or Color3.new(1,1,1)    
        end    
    end    

    local function setup()    
        local char = player.Character    
        if not char then return end    
        local hrp = char:FindFirstChild("HumanoidRootPart")    
        if not hrp then return end    
        billboard = Instance.new("BillboardGui")    
        billboard.Size = UDim2.new(0,280,0,40)    
        billboard.StudsOffset = Vector3.new(0,-8.5,0)     
        billboard.AlwaysOnTop = true    
        billboard.Enabled = ItemESP_Enabled    
        billboard.Adornee = hrp    
        billboard.Parent = hrp    
        container = Instance.new("Frame")    
        container.Size = UDim2.new(1,0,1,0)    
        container.BackgroundTransparency = 1    
        container.Parent = billboard    
        BillboardCache[player] = billboard    

        table.insert(connections, RunService.RenderStepped:Connect(function()    
            if not player.Character then return end    
            if not ItemESP_Enabled then billboard.Enabled = false return end    
            billboard.Enabled = true    
            local currentKeys = {}    
            local function scan(folder)    
                if not folder then return end    
                for _,tool in ipairs(folder:GetChildren()) do    
                    if tool:IsA("Tool") then    
                        local info = getWeaponInfo(tool)    
                        if info then table.insert(currentKeys,info.Key) end    
                    end    
                end    
            end    
            scan(player.Character)    
            local backpack = player:FindFirstChild("Backpack")    
            if backpack then scan(backpack) end    
            table.sort(currentKeys)    
            local newHash = table.concat(currentKeys,"|")    
            if newHash ~= lastHash then lastHash = newHash updateESP() end    
        end))    
        updateESP()    
    end    

    if player.Character then task.spawn(setup) end    
    table.insert(connections, player.CharacterAdded:Connect(function() task.wait(1) setup() end))    
    ItemESP_UpdateConnections[player] = connections
end

for _,p in ipairs(Players:GetPlayers()) do if p ~= LocalPlayer then createBillboardForPlayer(p) end end
Players.PlayerAdded:Connect(function(p) if p ~= LocalPlayer then createBillboardForPlayer(p) end end)
Players.PlayerRemoving:Connect(function(p)
    if BillboardCache[p] then BillboardCache[p]:Destroy() BillboardCache[p] = nil end    
    if ItemESP_UpdateConnections[p] then for _,c in pairs(ItemESP_UpdateConnections[p]) do c:Disconnect() end ItemESP_UpdateConnections[p] = nil end
end)

-- ESP CONFIG
local ESP_Config = {Master = true, ShowName = true, ShowHealth = true, ShowDistance = true}
VisualsTab:Section({Title = "Player ESP"})
VisualsTab:Toggle({Title = "Enable ESP", Default = ESP_Config.Master, Callback = function(v) ESP_Config.Master = v end})
VisualsTab:Toggle({Title = "Show Names", Default = ESP_Config.ShowName, Callback = function(v) ESP_Config.ShowName = v end})
VisualsTab:Toggle({Title = "Show Health", Default = ESP_Config.ShowHealth, Callback = function(v) ESP_Config.ShowHealth = v end})
VisualsTab:Toggle({Title = "Show Distance", Default = ESP_Config.ShowDistance, Callback = function(v) ESP_Config.ShowDistance = v end})

local TextSize = 10
local ESP = {}

local function CreateESP(player)
    if player == LocalPlayer then return end
    local NameGui = Instance.new("BillboardGui")    
    NameGui.Size = UDim2.new(0,120,0,30)    
    NameGui.StudsOffset = Vector3.new(0,2.5,0)    
    NameGui.AlwaysOnTop = true    
    local NameText = Instance.new("TextLabel")    
    NameText.Size = UDim2.new(1,0,1,0)    
    NameText.BackgroundTransparency = 1    
    NameText.TextColor3 = Color3.new(1,1,1)    
    NameText.TextStrokeTransparency = 0    
    NameText.TextSize = TextSize    
    NameText.Font = Enum.Font.SourceSansBold    
    NameText.Parent = NameGui    

    local InfoGui = Instance.new("BillboardGui")    
    InfoGui.Size = UDim2.new(0,120,0,20)    
    InfoGui.StudsOffset = Vector3.new(0,-3.5,0)     
    InfoGui.AlwaysOnTop = true    
    local InfoText = Instance.new("TextLabel")    
    InfoText.Size = UDim2.new(1,0,1,0)    
    InfoText.BackgroundTransparency = 1    
    InfoText.TextColor3 = Color3.new(1,1,1)    
    InfoText.TextStrokeTransparency = 0    
    InfoText.TextSize = TextSize    
    InfoText.Font = Enum.Font.SourceSansBold    
    InfoText.Parent = InfoGui    
    ESP[player] = {NameGui = NameGui, NameText = NameText, InfoGui = InfoGui, InfoText = InfoText}
end

for _,p in pairs(Players:GetPlayers()) do CreateESP(p) end
Players.PlayerAdded:Connect(CreateESP)
Players.PlayerRemoving:Connect(function(p)
    if ESP[p] then
        if ESP[p].NameGui then ESP[p].NameGui:Destroy() end
        if ESP[p].InfoGui then ESP[p].InfoGui:Destroy() end
        ESP[p] = nil
    end
end)

RunService.RenderStepped:Connect(function()
    local myChar = LocalPlayer.Character
    if not myChar then return end
    local myRoot = myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end

    for player, data in pairs(ESP) do
        local char = player.Character
        if char and ESP_Config.Master then
            local head = char:FindFirstChild("Head")
            local root = char:FindFirstChild("HumanoidRootPart")
            local hum = char:FindFirstChildOfClass("Humanoid")
            if head and root and hum then
                data.NameGui.Enabled = true
                data.InfoGui.Enabled = true
                local dist = (myRoot.Position - root.Position).Magnitude
                local nStr = ESP_Config.ShowName and player.Name or ""
                local hStr = ESP_Config.ShowHealth and "["..math.floor(hum.Health).." HP]" or ""
                local dStr = ESP_Config.ShowDistance and "["..math.floor(dist).."M]" or ""
                if dist <= 100 then
                    data.NameGui.Parent = head
                    data.InfoGui.Parent = root
                    data.NameText.Text = nStr
                    data.InfoText.Text = hStr .. dStr
                else
                    data.NameGui.Parent = head
                    data.InfoGui.Parent = nil
                    data.NameText.Text = nStr .. "\n\n" .. hStr .. dStr
                end
            end
        else
            if data.NameGui then data.NameGui.Enabled = false end
            if data.InfoGui then data.InfoGui.Enabled = false end
        end
    end
end)
