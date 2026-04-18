-- Orion
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/DozeIsOkLol/UILibarySource/refs/heads/main/Orion"))()
local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local root = char:WaitForChild("HumanoidRootPart")

-- Estados
local farm = {
    Rock = false,
    Tin = false,
    Bush = false,
    Tree = false,
    Wheat = false,
    Horse = false
}

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Communication = ReplicatedStorage:WaitForChild("Communication")
local Events = Communication:WaitForChild("Events")
local Functions = Communication:WaitForChild("Functions")

-- Funções do Remote Spy
local function collectResource()
    local args = {"Collect", Instance.new("Model", nil)}
    Events:WaitForChild(""):FireServer(unpack(args))
end

local function selectPickaxe()
    local args = {"Use", "Harvester"}
    Events:WaitForChild(""):FireServer(unpack(args))
end

local function engageTree(treeModel)
    local args = {string.char(1), "Engage", treeModel or Instance.new("Model", nil)}
    Functions:WaitForChild(""):FireServer(unpack(args))
end

local function selectLasso()
    local args = {"Use", "Lasso"}
    Events:WaitForChild(""):FireServer(unpack(args))
end

local function lassoHorse(horseModel)
    if horseModel then
        local args = {"{463ef6a9-08f2-46ed-8b98-e0f1e584679e}", "Activate", horseModel}
        Events:WaitForChild(""):FireServer(unpack(args))
    end
end

-- Window
local Window = OrionLib:MakeWindow({
    Name = "Farm Hub OP 😈",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "FarmHub",
})

local Tab = Window:MakeTab({
    Name = "Auto Farm",
    Icon = "rbxassetid://4483345998",
})

local Section = Tab:AddSection({
    Name = "Recursos",
})

-- Nova seção para ferramentas
local ToolSection = Tab:AddSection({
    Name = "Ferramentas Manuais",
})

-- Função otimizada (pega posição mais próxima)
local function getClosestPos(filterFunc)
    local closest = nil
    local closestModel = nil
    local dist = math.huge
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("Model") and filterFunc(v) then
            local part = v.PrimaryPart or v:FindFirstChildWhichIsA("BasePart", true)
            local pos = part and part.Position or v:GetAttribute("areaPos1")
            if pos then
                local d = (pos - root.Position).Magnitude
                if d < dist then
                    dist = d
                    closest = pos
                    closestModel = v
                end
            end
        end
    end
    return closest, closestModel
end

-- Loop principal
task.spawn(function()
    while task.wait(1) do
        local targetPos, targetModel = nil, nil
        
        if farm.Rock then
            targetPos, targetModel = getClosestPos(function(v)
                return v:GetAttribute("itemName") == "Rock" and (v:GetAttribute("health") or 0) > 0
            end)
            if targetPos then
                selectPickaxe()
                root.CFrame = CFrame.new(targetPos + Vector3.new(0,5,0))
                task.wait(0.5)
                collectResource()
            end
            
        elseif farm.Tin then
            targetPos, targetModel = getClosestPos(function(v)
                return v:GetAttribute("itemName") == "Tin Rock"
            end)
            if targetPos then
                selectPickaxe()
                root.CFrame = CFrame.new(targetPos + Vector3.new(0,5,0))
                task.wait(0.5)
                collectResource()
            end
            
        elseif farm.Bush then
            targetPos, targetModel = getClosestPos(function(v)
                local n = v:GetAttribute("itemName")
                return n == "Blackberry Bush" or n == "Raspberry Bush"
            end)
            if targetPos then
                root.CFrame = CFrame.new(targetPos + Vector3.new(0,5,0))
                task.wait(0.5)
                collectResource()
            end
            
        elseif farm.Tree then
            targetPos, targetModel = getClosestPos(function(v)
                return v:GetAttribute("itemName") == "Log"
            end)
            if targetPos then
                root.CFrame = CFrame.new(targetPos + Vector3.new(0,5,0))
                task.wait(0.5)
                engageTree(targetModel)
                task.wait(0.5)
                collectResource()
            end
            
        elseif farm.Wheat then
            targetPos, targetModel = getClosestPos(function(v)
                return v:GetAttribute("itemName") == "Wheat Crop"
            end)
            if targetPos then
                root.CFrame = CFrame.new(targetPos + Vector3.new(0,5,0))
                task.wait(0.5)
                collectResource()
            end
            
        elseif farm.Horse then
            targetPos, targetModel = getClosestPos(function(v)
                return v:GetAttribute("species") == "Horse"
                    and v:GetAttribute("behaviour") == "WanderingAnimal"
            end)
            if targetPos then
                selectLasso()
                root.CFrame = CFrame.new(targetPos + Vector3.new(0,5,0))
                task.wait(0.5)
                lassoHorse(targetModel)
            end
        end
    end
end)

-- Toggles
Section:AddToggle({
    Name = "🪨 Pedra",
    Default = false,
    Callback = function(v) farm.Rock = v end
})

Section:AddToggle({
    Name = "⛏️ Tin",
    Default = false,
    Callback = function(v) farm.Tin = v end
})

Section:AddToggle({
    Name = "🌿 Berries",
    Default = false,
    Callback = function(v) farm.Bush = v end
})

Section:AddToggle({
    Name = "🌲 Madeira",
    Default = false,
    Callback = function(v) farm.Tree = v end
})

Section:AddToggle({
    Name = "🌾 Trigo",
    Default = false,
    Callback = function(v) farm.Wheat = v end
})

Section:AddToggle({
    Name = "🐎 Cavalo (Selvagem)",
    Default = false,
    Callback = function(v) farm.Horse = v end
})

-- Botão fechar
Section:AddButton({
    Name = "Fechar GUI",
    Callback = function()
        OrionLib:Destroy()
    end
})

-- Botões de ferramentas manuais
ToolSection:AddButton({
    Name = "🔨 Selecionar Picareta",
    Callback = function()
        selectPickaxe()
    end
})

ToolSection:AddButton({
    Name = "🪢 Selecionar Laço",
    Callback = function()
        selectLasso()
    end
})

ToolSection:AddButton({
    Name = "📦 Coletar Recurso Próximo",
    Callback = function()
        collectResource()
    end
})

ToolSection:AddButton({
    Name = "🌲 Cortar Árvore Próxima",
    Callback = function()
        local _, treeModel = getClosestPos(function(v)
            return v:GetAttribute("itemName") == "Log"
        end)
        if treeModel then
            engageTree(treeModel)
        end
    end
})

OrionLib:Init()
