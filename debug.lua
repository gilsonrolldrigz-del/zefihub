-- Orion
local OrionLib = loadstring(game:HttpGet('https://raw.githubusercontent.com/DozeIsOkLol/UILibarySource/refs/heads/main/Orion'))()
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
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")

-- Função para pressionar tecla
local function pressKey(key)
    VirtualInputManager:SendKeyEvent(true, key, false, game)
    task.wait(0.1)
    VirtualInputManager:SendKeyEvent(false, key, false, game)
end

-- Função para clicar na tela
local function clickScreen()
    local camera = workspace.CurrentCamera
    local screenSize = camera.ViewportSize
    local centerX = screenSize.X / 2
    local centerY = screenSize.Y / 2
    
    VirtualInputManager:SendMouseButtonEvent(centerX, centerY, 0, true, game, 1)
    task.wait(0.1)
    VirtualInputManager:SendMouseButtonEvent(centerX, centerY, 0, false, game, 1)
end

-- Funções do Remote Spy (método direto)
local function selectPickaxe()
    local args = {"Use", "Harvester"}
    -- Método 1: Tentar encontrar o remote com nome vazio diretamente
    for _, remote in pairs(Events:GetChildren()) do
        if remote.Name == "" and remote:IsA("RemoteEvent") then
            local success, err = pcall(function()
                remote:FireServer(unpack(args))
            end)
            if success then
                print("✅ Picareta selecionada com sucesso!")
                return
            else
                print("❌ Erro:", err)
            end
        end
    end
    print("❌ Remote não encontrado!")
end

local function collectResource()
    local args = {"Collect", Instance.new("Model", nil)}
    for _, remote in pairs(Events:GetChildren()) do
        if remote.Name == "" and remote:IsA("RemoteEvent") then
            local success, err = pcall(function()
                remote:FireServer(unpack(args))
            end)
            if success then
                print("✅ Recurso coletado!")
                return
            else
                print("❌ Erro ao coletar:", err)
            end
        end
    end
end

local function selectLasso()
    local args = {"Use", "Lasso"}
    for _, remote in pairs(Events:GetChildren()) do
        if remote.Name == "" and remote:IsA("RemoteEvent") then
            local success, err = pcall(function()
                remote:FireServer(unpack(args))
            end)
            if success then
                print("✅ Laço selecionado!")
                return
            else
                print("❌ Erro ao selecionar laço:", err)
            end
        end
    end
end

local function engageTree(treeModel)
    local args = {string.char(1), "Engage", treeModel or Instance.new("Model", nil)}
    for _, remote in pairs(Functions:GetChildren()) do
        if remote.Name == "" and remote:IsA("RemoteFunction") then
            local success, err = pcall(function()
                remote:InvokeServer(unpack(args))
            end)
            if success then
                print("✅ Árvore cortada!")
                return
            else
                print("❌ Erro ao cortar árvore:", err)
            end
        end
    end
end

local function lassoHorse(horseModel)
    if horseModel then
        local args = {"{463ef6a9-08f2-46ed-8b98-e0f1e584679e}", "Activate", horseModel}
        for _, remote in pairs(Events:GetChildren()) do
            if remote.Name == "" and remote:IsA("RemoteEvent") then
                local success, err = pcall(function()
                    remote:FireServer(unpack(args))
                end)
                if success then
                    print("✅ Cavalo lassado!")
                    return
                else
                    print("❌ Erro ao lassar cavalo:", err)
                end
            end
        end
    end
end

-- Window
local Window = OrionLib:MakeWindow({
    Name = "Zefi",
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
                end
            end
        end
    end
    return closest
end

-- Loop principal
task.spawn(function()
    while task.wait(0.3) do -- Loop mais rápido para cavalos
        local targetPos = nil
        
        if farm.Rock then
            targetPos = getClosestPos(function(v)
                return v:GetAttribute("itemName") == "Rock" and (v:GetAttribute("health") or 0) > 0
            end)
            
        elseif farm.Tin then
            targetPos = getClosestPos(function(v)
                return v:GetAttribute("itemName") == "Tin Rock"
            end)
            
        elseif farm.Bush then
            targetPos = getClosestPos(function(v)
                local n = v:GetAttribute("itemName")
                return n == "Blackberry Bush" or n == "Raspberry Bush"
            end)
            
        elseif farm.Tree then
            targetPos = getClosestPos(function(v)
                return v:GetAttribute("itemName") == "Log"
            end)
            
        elseif farm.Wheat then
            targetPos = getClosestPos(function(v)
                return v:GetAttribute("itemName") == "Wheat Crop"
            end)
            
        elseif farm.Horse then
            local closestHorse = nil
            local closestDist = math.huge
            
            -- Encontra o cavalo mais próximo
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("Model") then
                    local species = v:GetAttribute("species")
                    local behaviour = v:GetAttribute("behaviour")
                    local owner = v:GetAttribute("owner")
                    
                    -- Ignora cavalos à venda (que têm BillboardGui)
                    local hasForSaleGui = v:FindFirstChildWhichIsA("BillboardGui", true)
                    
                    if species == "Horse" 
                        and behaviour == "WanderingAnimal" 
                        and (owner == nil or owner == "")
                        and not hasForSaleGui then
                        
                        local part = v.PrimaryPart or v:FindFirstChildWhichIsA("BasePart", true)
                        if part then
                            local d = (part.Position - root.Position).Magnitude
                            if d < closestDist then
                                closestDist = d
                                closestHorse = v
                            end
                        end
                    end
                end
            end
            
            if closestHorse then
                local horsePart = closestHorse.PrimaryPart or closestHorse:FindFirstChildWhichIsA("BasePart", true)
                if horsePart then
                    -- Fica COLADO no cavalo (mesma posição + um pouco acima)
                    root.CFrame = CFrame.new(horsePart.Position + Vector3.new(0, 2, 0))
                    task.wait(0.1)
                    
                    -- Clica rapidamente
                    for i = 1, 10 do
                        clickScreen()
                        task.wait(0.15)
                    end
                end
            end
        end
        
        -- Teleporte normal para outros recursos (sem clique)
        if targetPos and not farm.Horse then
            root.CFrame = CFrame.new(targetPos + Vector3.new(0,5,0))
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

-- Botão de debug para cavalos
ToolSection:AddButton({
    Name = "🔍 Debug Cavalo Próximo",
    Callback = function()
        print("=== DEBUG CAVALO MAIS PRÓXIMO ===")
        local closestHorse = nil
        local closestDist = math.huge
        
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("Model") and v:GetAttribute("species") == "Horse" then
                local part = v.PrimaryPart or v:FindFirstChildWhichIsA("BasePart", true)
                if part then
                    local d = (part.Position - root.Position).Magnitude
                    if d < closestDist then
                        closestDist = d
                        closestHorse = v
                    end
                end
            end
        end
        
        if closestHorse then
            print("Nome:", closestHorse.Name)
            print("Distância:", closestDist)
            print("=== ATRIBUTOS ===")
            for _, attr in pairs(closestHorse:GetAttributes()) do
                print(_, "=", attr)
            end
            print("=== CHILDREN ===")
            for _, child in pairs(closestHorse:GetChildren()) do
                print("Child:", child.Name, "Type:", child.ClassName)
            end
        else
            print("Nenhum cavalo encontrado!")
        end
    end
})

-- Botões de ferramentas manuais com debug
ToolSection:AddButton({
    Name = "🔨 Selecionar Picareta",
    Callback = function()
        print("Tentando selecionar picareta...")
        selectPickaxe()
        print("Comando enviado!")
    end
})

ToolSection:AddButton({
    Name = "🪢 Selecionar Laço",
    Callback = function()
        print("Tentando selecionar laço...")
        selectLasso()
        print("Comando enviado!")
    end
})

ToolSection:AddButton({
    Name = "📦 Coletar Recurso Próximo",
    Callback = function()
        print("Tentando coletar...")
        collectResource()
        print("Comando enviado!")
    end
})

-- Alternativa: encontrar remote por nome vazio
local function findEmptyNameRemote(parent)
    for _, child in pairs(parent:GetChildren()) do
        if child.Name == "" and child:IsA("RemoteEvent") then
            return child
        end
    end
    return nil
end

-- Função alternativa para selecionar picareta
ToolSection:AddButton({
    Name = "🔨 Selecionar Picareta (Alt)",
    Callback = function()
        local remote = findEmptyNameRemote(Events)
        if remote then
            local args = {"Use", "Harvester"}
            remote:FireServer(unpack(args))
            print("Picareta selecionada (método alternativo)!")
        else
            print("Remote não encontrado!")
        end
    end
})

-- Testar todos os remotes com nome vazio
ToolSection:AddButton({
    Name = "🧪 Testar Todos os Remotes",
    Callback = function()
        print("=== TESTANDO TODOS OS REMOTES ===")
        local events = Events:GetChildren()
        for i, remote in pairs(events) do
            if remote.Name == "" and remote:IsA("RemoteEvent") then
                print("Testando remote índice", i)
                local success, err = pcall(function()
                    remote:FireServer("Use", "Harvester")
                end)
                if success then
                    print("✅ Remote", i, "funcionou!")
                    task.wait(0.5) -- Pausa entre testes
                else
                    print("❌ Remote", i, "erro:", err)
                end
            end
        end
        print("=== TESTE CONCLUÍDO ===")
    end
})

OrionLib:Init()
