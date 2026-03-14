local SilentAimEnabled = false
local FOV = 150
local WhitelistedPlayer = ""
local SnapUnderEnabled = false 
local SnapDepth = -10 

local SpeedEnabled = false
local WarpDistance = 0.4
local WarpCooldown = 0.05
local lastWarp = 0
local InfiniteJumpEnabled = false
local JumpHeight = 10

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

TweenService:Create(logo, TweenInfo.new(1.2,Enum.EasingStyle.Quint,Enum.EasingDirection.Out), {ImageTransparency = 0, Position = UDim2.new(0.5,-80,0.5,0)}):Play()
TweenService:Create(text, TweenInfo.new(1), {TextTransparency = 0}):Play()
task.wait(2.5)
intro:Destroy()

local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "Neverman x'Dev",
    Author = "Kiwwy",
    Icon = "rbxassetid://79955709475525",
    Theme = "Dark",
    Size = UDim2.fromOffset(350,450),
    Acrylic = true,
    HideSearchBar = true,
    OpenButton = { Enabled = false }
})

Window:Tag({ Title = "v1.6.6", Icon = "github", Color = Color3.fromHex("#30ff6a"), Radius = 0 })
Window:SetBackgroundTransparency(0.25)
Window:SetBackgroundImageTransparency(0.25)

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
local UserInputService = game:GetService("UserInputService")
local ContentProvider = game:GetService("ContentProvider")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local BULLET_SPEED = 1200
local GunNames = {"P226","MP5","M24","Draco","Glock","Sawnoff","Uzi","G3","C9","Hunting Rifle","Anaconda","AK47","Remington","Double Barrel"}
local GunLookup = {}
for _,v in pairs(GunNames) do GunLookup[v] = true end

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

local CombatTab = Window:Tab({ Title = "Combat", Icon = "crosshair" })
local MovementTab = Window:Tab({ Title = "Movement", Icon = "person-standing" })
local PlayerTab = Window:Tab({ Title = "Player", Icon = "user" })
local VisualsTab = Window:Tab({ Title = "Visuals", Icon = "eye" })

CombatTab:Section({ Title = "Silent Aim" })
CombatTab:Toggle({
    Title = "Enable Silent Aim",
    Default = false,
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
    Callback = function(v) WhitelistedPlayer = v end
})

task.spawn(function()
    while task.wait(5) do FriendDropdown:Refresh(GetPlayerList()) end
end)

CombatTab:Slider({
    Title = "FOV",
    Step = 1,
    Value = { Min = 50, Max = 800, Default = FOV },
    Callback = function(v)
        FOV = v
        if fovCircle then fovCircle.Radius = v end
    end
})

MovementTab:Section({Title = "Underground"})
MovementTab:Toggle({
    Title = "Snap Under (มุดดิน)",
    Default = false,
    Callback = function(v) SnapUnderEnabled = v end
})
MovementTab:Slider({
    Title = "Snap Depth (ความลึก)",
    Step = 0.5,
    Value = {Min = -20, Max = 0, Default = -10},
    Callback = function(v) SnapDepth = v end
})

PlayerTab:Section({Title = "Speed Warp"})
PlayerTab:Toggle({
    Title = "Enable Speed Warp",
    Default = false,
    Callback = function(v) SpeedEnabled = v end
})
PlayerTab:Slider({
    Title = "Warp Distance",
    Step = 0.1,
    Value = {Min = 0.1, Max = 5, Default = 0.4},
    Callback = function(v) WarpDistance = v end
})

PlayerTab:Section({Title = "Jump Modification"})
PlayerTab:Toggle({
    Title = "Infinite Jump (Spam)",
    Default = false,
    Callback = function(v) InfiniteJumpEnabled = v end
})
PlayerTab:Slider({
    Title = "Jump Height (Increment)",
    Step = 1,
    Value = {Min = 5, Max = 100, Default = 10},
    Callback = function(v) JumpHeight = v end
})

RunService.PostSimulation:Connect(function()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChild("Humanoid")
    if not hrp or not hum then return end

    if SnapUnderEnabled then
        local ray = Ray.new(hrp.Position + Vector3.new(0, 5, 0), Vector3.new(0, -50, 0))
        local part, pos = workspace:FindPartOnRayWithIgnoreList(ray, {char})
        if part then    
            hrp.CFrame = CFrame.new(hrp.Position.X, pos.Y + SnapDepth, hrp.Position.Z) * hrp.CFrame.Rotation    
        end    
    end

    if SpeedEnabled and tick() - lastWarp >= WarpCooldown then
        if hum.MoveDirection.Magnitude > 0 then
            hrp.CFrame = hrp.CFrame + hrp.CFrame.LookVector * WarpDistance
            lastWarp = tick()
        end
    end
end)

UserInputService.JumpRequest:Connect(function()
    if InfiniteJumpEnabled and LocalPlayer.Character then
        local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then hrp.Velocity = Vector3.new(hrp.Velocity.X, JumpHeight, hrp.Velocity.Z) end
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
    local p1 = Instance.new("Part", workspace)
    p1.Anchored, p1.CanCollide, p1.Transparency, p1.Size, p1.Position = true, false, 1, Vector3.new(0.2,0.2,0.2), startPos
    local p2 = Instance.new("Part", workspace)
    p2.Anchored, p2.CanCollide, p2.Transparency, p2.Size, p2.Position = true, false, 1, Vector3.new(0.2,0.2,0.2), endPos
    local a1, a2 = Instance.new("Attachment",p1), Instance.new("Attachment",p2)
    local beam = Instance.new("Beam", p1)
    beam.Attachment0, beam.Attachment1, beam.Width0, beam.Width1, beam.LightEmission = a1, a2, 0.35, 0.35, 1
    beam.Color = ColorSequence.new(Color3.fromRGB(180,0,0))
    task.delay(0.60,function() p1:Destroy() p2:Destroy() end)
end

local function GetClosestTarget()
    local closest, shortest = nil, math.huge
    local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    for _,player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Name ~= WhitelistedPlayer and player.Character and player.Character:FindFirstChild("Head") then
            local targetPart = player.Character.Head
            local pos,onScreen = Camera:WorldToViewportPoint(targetPart.Position)
            if onScreen then
                local dist = (Vector2.new(pos.X,pos.Y) - center).Magnitude
                if dist < FOV and dist < shortest then
                    shortest, closest = dist, player
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
    local travelTime = (Camera.CFrame.Position - targetPart.Position).Magnitude / BULLET_SPEED
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
    fovCircle.Position, fovCircle.Radius = center, FOV
    if SilentAimEnabled then
        local target = GetClosestTarget()
        if target and target.Name ~= WhitelistedPlayer and target.Character and target.Character:FindFirstChild("Head") then
            local pred = PredictPosition(target.Character.Head)
            local pos,onScreen = Camera:WorldToViewportPoint(pred)
            if onScreen then
                tracerLine.From, tracerLine.To, tracerLine.Visible = center, Vector2.new(pos.X,pos.Y), true
            else tracerLine.Visible = false end
        else tracerLine.Visible = false end
    else tracerLine.Visible = false end
end)

local ItemESP_Enabled = true
local BillboardCache = {}
local ItemESP_UpdateConnections = {}
local WeaponDB = {}
local RARITY_COLORS = {
    ["Common"] = Color3.fromRGB(255,255,255), ["Uncommon"] = Color3.fromRGB(99,255,52),
    ["Rare"] = Color3.fromRGB(51,170,255), ["Epic"] = Color3.fromRGB(237,44,255),
    ["Legendary"] = Color3.fromRGB(255,150,0), ["Omega"] = Color3.fromRGB(255,20,51)
}

local function generateUniqueKey(tool)
    if not tool or not tool:IsA("Tool") then return nil end
    local itemId = tool:GetAttribute("ItemId") or tool:GetAttribute("Id")    
    if itemId then return "ITEMID_"..tostring(itemId) end    
    local partsData = {}    
    for _,part in ipairs(tool:GetDescendants()) do
        if (part:IsA("SpecialMesh") or part:IsA("MeshPart")) and part.MeshId ~= "" then 
            table.insert(partsData,"MESH_"..part.MeshId)
        end    
    end    
    return #partsData > 0 and "MESHKEY_"..table.concat(partsData,";") or "NAME_"..tool.Name
end

local function registerItems(folder)
    for _,tool in ipairs(folder:GetDescendants()) do
        if tool:IsA("Tool") then
            local key = generateUniqueKey(tool)    
            if key then
                WeaponDB[key] = {
                    Name = tool:GetAttribute("DisplayName") or tool.Name,
                    Rarity = tool:GetAttribute("RarityName") or "Common",
                    ImageId = tool:GetAttribute("ImageId") or "rbxassetid://7072725737",
                    Key = key
                }
            end
        end
    end
end

pcall(function()
    local itemsFolder = ReplicatedStorage:WaitForChild("Items",5)
    if itemsFolder then registerItems(itemsFolder) end
end)

local ESP_Config = { Master = true, ShowName = true, ShowHealth = true, ShowDistance = true, ShowBox = true }

VisualsTab:Section({ Title = "Items" })
VisualsTab:Toggle({
    Title = "Enable Item ESP",
    Default = ItemESP_Enabled,
    Callback = function(v)
        ItemESP_Enabled = v
        for _, b in pairs(BillboardCache) do b.Enabled = v end
    end
})

VisualsTab:Section({ Title = "Players" })
VisualsTab:Toggle({ Title = "Enable ESP Master", Default = true, Callback = function(v) ESP_Config.Master = v end })
VisualsTab:Toggle({ Title = "Show 2D Box", Default = true, Callback = function(v) ESP_Config.ShowBox = v end })
VisualsTab:Toggle({ Title = "Show Names", Default = true, Callback = function(v) ESP_Config.ShowName = v end })
VisualsTab:Toggle({ Title = "Show Health", Default = true, Callback = function(v) ESP_Config.ShowHealth = v end })
VisualsTab:Toggle({ Title = "Show Distance", Default = true, Callback = function(v) ESP_Config.ShowDistance = v end })

local ESP_Storage = {}

local function CreateESP(player)
    if player == LocalPlayer then return end
    
    local Box = Drawing.new("Square")
    Box.Visible = false
    Box.Color = Color3.fromRGB(255, 255, 255)
    Box.Thickness = 1
    Box.Transparency = 1
    Box.Filled = false

    local NameGui = Instance.new("BillboardGui")
    NameGui.Size, NameGui.StudsOffset, NameGui.AlwaysOnTop = UDim2.new(0,120,0,30), Vector3.new(0,2.5,0), true
    local NameText = Instance.new("TextLabel", NameGui)
    NameText.Size, NameText.BackgroundTransparency, NameText.TextColor3, NameText.TextSize, NameText.Font = UDim2.new(1,0,1,0), 1, Color3.new(1,1,1), 10, Enum.Font.SourceSansBold
    
    local InfoGui = Instance.new("BillboardGui")
    InfoGui.Size, InfoGui.StudsOffset, InfoGui.AlwaysOnTop = UDim2.new(0,120,0,20), Vector3.new(0,-3.5,0), true
    local InfoText = Instance.new("TextLabel", InfoGui)
    InfoText.Size, InfoText.BackgroundTransparency, InfoText.TextColor3, InfoText.TextSize, InfoText.Font = UDim2.new(1,0,1,0), 1, Color3.new(1,1,1), 10, Enum.Font.SourceSansBold
    
    ESP_Storage[player] = { Box = Box, NameGui = NameGui, NameText = NameText, InfoGui = InfoGui, InfoText = InfoText }
end

local function createBillboardForPlayer(player)
    if player == LocalPlayer or BillboardCache[player] then return end    
    local billboard, container = nil, nil
    local connections = {}

    local function setup()    
        local char = player.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then return end
        billboard = Instance.new("BillboardGui", char.HumanoidRootPart)
        billboard.Size, billboard.StudsOffset, billboard.AlwaysOnTop, billboard.Adornee = UDim2.new(0,280,0,40), Vector3.new(0,-8.5,0), true, char.HumanoidRootPart
        container = Instance.new("Frame", billboard)
        container.Size, container.BackgroundTransparency = UDim2.new(1,0,1,0), 1
        BillboardCache[player] = billboard

        local layout = Instance.new("UIGridLayout", container)    
        layout.CellSize, layout.CellPadding = UDim2.new(0,16,0,16), UDim2.new(0,3,0,0)

        table.insert(connections, RunService.RenderStepped:Connect(function()
            if not player.Character then return end
            billboard.Enabled = ItemESP_Enabled
            
            container:ClearAllChildren()
            layout:Clone().Parent = container
            local tools = {}
            for _,t in pairs(player.Character:GetChildren()) do if t:IsA("Tool") then table.insert(tools, t) end end
            if player:FindFirstChild("Backpack") then for _,t in pairs(player.Backpack:GetChildren()) do if t:IsA("Tool") then table.insert(tools, t) end end end
            
            for _,tool in ipairs(tools) do
                local info = WeaponDB[generateUniqueKey(tool)]
                if info then
                    local img = Instance.new("ImageLabel", container)
                    img.Size, img.BackgroundTransparency, img.Image = UDim2.new(0,16,0,16), 1, info.ImageId
                    img.ImageColor3 = RARITY_COLORS[info.Rarity] or Color3.new(1,1,1)
                end
            end
        end))
    end    

    if player.Character then task.spawn(setup) end
    table.insert(connections, player.CharacterAdded:Connect(function() task.wait(1.5) setup() end))
    ItemESP_UpdateConnections[player] = connections
end

RunService.RenderStepped:Connect(function()
    local myChar = LocalPlayer.Character
    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return end
    
    for player, data in pairs(ESP_Storage) do
        local char = player.Character
        if char and ESP_Config.Master and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Head") then
            local rootPart = char.HumanoidRootPart
            local head = char.Head
            local pos, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
            
            if onScreen then
                if ESP_Config.ShowBox then
                    local headPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
                    local legPos = Camera:WorldToViewportPoint(rootPart.Position - Vector3.new(0, 3, 0))
                    data.Box.Size = Vector2.new(2500 / pos.Z, headPos.Y - legPos.Y)
                    data.Box.Position = Vector2.new(pos.X - data.Box.Size.X / 2, pos.Y - data.Box.Size.Y / 2)
                    data.Box.Visible = true
                else data.Box.Visible = false end

                data.NameGui.Enabled = true
                data.InfoGui.Enabled = true
                local dist = (LocalPlayer.Character.HumanoidRootPart.Position - rootPart.Position).Magnitude
                local hum = char:FindFirstChildOfClass("Humanoid")
                local hp = hum and math.floor(hum.Health) or 0
                
                data.NameText.Text = ESP_Config.ShowName and player.Name or ""
                data.InfoText.Text = (ESP_Config.ShowHealth and "["..hp.." HP] " or "") .. (ESP_Config.ShowDistance and "["..math.floor(dist).."M]" or "")
                data.NameGui.Parent = head
                data.InfoGui.Parent = rootPart
            else
                data.Box.Visible = false
                data.NameGui.Enabled = false
                data.InfoGui.Enabled = false
            end
        else
            data.Box.Visible = false
            data.NameGui.Enabled = false
            data.InfoGui.Enabled = false
        end
    end
end)

for _,p in pairs(Players:GetPlayers()) do 
    CreateESP(p) 
    createBillboardForPlayer(p)
end

Players.PlayerAdded:Connect(function(p)
    CreateESP(p)
    createBillboardForPlayer(p)
end)

Players.PlayerRemoving:Connect(function(p)
    if ESP_Storage[p] then
        ESP_Storage[p].Box:Remove()
        ESP_Storage[p].NameGui:Destroy()
        ESP_Storage[p].InfoGui:Destroy()
        ESP_Storage[p] = nil
    end
  end)
