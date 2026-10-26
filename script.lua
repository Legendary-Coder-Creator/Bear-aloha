--===================================================================================--
-- BEAR ALPHA: COMPLETE UNLIMITED SKIN PIPELINE (AUTOMATIC ENUMERATION)
--===================================================================================--

-- [System Services & Memory Allocations]
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- [State Variables]
local ActiveSkin = nil
local CurrentCharacterConnection = nil

-- [Dynamic Path Finder Engine]
local SkinFolder = ReplicatedStorage:FindFirstChild("BearSkins") 
    or ReplicatedStorage:FindFirstChild("Skins") 
    or ReplicatedStorage:FindFirstChild("SkinFolder")

local function FindInventoryUI()
    local TargetGUIs = {"Menu", "MenuGui", "ShopGui", "CustomizationGui", "MainGui"}
    for _, guiName in ipairs(TargetGUIs) do
        local gui = PlayerGui:FindFirstChild(guiName)
        if gui then
            local scrollingFrame = gui:FindFirstChildOfClass("ScrollingFrame") 
                or gui:FindFirstChild("SkinsGrid", true) 
                or gui:FindFirstChild("Inventory", true)
            if scrollingFrame then return scrollingFrame end
        end
    end
    return nil
end

-- [High-Fidelity Local Model Transformer]
local function ApplyLocalMorph(character, skinName)
    if not character or not SkinFolder then return end
    local SkinAsset = SkinFolder:FindFirstChild(skinName)
    if not SkinAsset then return end
    
    print("[Morph Engine]: Executing high-fidelity visual swap for: " .. skinName)
    
    for _, item in ipairs(character:GetChildren()) do
        if item:IsA("Accessory") or item:IsA("Shirt") or item:IsA("Pants") or item:IsA("BodyColors") then
            item:Destroy()
        end
    end
    
    for _, asset in ipairs(SkinAsset:GetChildren()) do
        if asset:IsA("Decal") or asset:IsA("Texture") then
            local head = character:FindFirstChild("Head")
            if head then
                local newDecal = asset:Clone()
                newDecal.Parent = head
            end
        elseif asset:IsA("SpecialMesh") or asset:IsA("MeshPart") then
            local lowerTorso = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Torso")
            if lowerTorso then
                local meshClone = asset:Clone()
                meshClone.Parent = lowerTorso
            end
        elseif asset:IsA("Model") then
            local attachmentModel = asset:Clone()
            attachmentModel.Parent = character
        end
    end
end

-- [All-Skin Inventory Framework Injector]
local function InjectAllSkinsToInventory()
    local InventoryGrid = FindInventoryUI()
    
    if not SkinFolder or not InventoryGrid then
        warn("[System Failure]: Failed to map target UI elements.")
        return
    end
    
    local TemplateSlot = InventoryGrid:FindFirstChildOfClass("Frame") 
        or InventoryGrid:FindFirstChildOfClass("TextButton") 
        or InventoryGrid:FindFirstChildOfClass("ImageButton")
        
    if not TemplateSlot then
        warn("[Injection Warning]: No standard layout blueprint exists to copy.")
        return
    end
    
    -- DYNAMIC LOOP: Grabs every single skin folder inside Bear Alpha's game data
    for _, skinAsset in ipairs(SkinFolder:GetChildren()) do
        local skinName = skinAsset.Name
        
        -- Prevent duplicating slots if they already exist natively
        if not InventoryGrid:FindFirstChild("Local_" .. skinName) then
            
            local NewSlot = TemplateSlot:Clone()
            NewSlot.Name = "Local_" .. skinName
            NewSlot.Visible = true
            
            local Label = NewSlot:FindFirstChildOfClass("TextLabel") or NewSlot:FindFirstChild("Title", true)
            if Label then Label.Text = skinName end
            
            local ActionButton = NewSlot:IsA("TextButton") and NewSlot or NewSlot:FindFirstChildOfClass("TextButton")
            if not ActionButton then ActionButton = NewSlot:FindFirstChildOfClass("ImageButton") end
            
            if ActionButton then
                ActionButton.Text = "EQUIP"
                
                ActionButton.MouseButton1Click:Connect(function()
                    if ActiveSkin == skinName then
                        ActiveSkin = nil
                        ActionButton.Text = "EQUIP"
                        LocalPlayer:LoadCharacter()
                    else
                        for _, otherCell in ipairs(InventoryGrid:GetChildren()) do
                            if otherCell.Name:match("^Local_") and otherCell ~= NewSlot then
                                local subBtn = otherCell:FindFirstChildOfClass("TextButton") or otherCell:FindFirstChildOfClass("ImageButton")
                                if subBtn and subBtn:IsA("TextButton") then subBtn.Text = "EQUIP" end
                            end
                        end
                        
                        ActiveSkin = skinName
                        ActionButton.Text = "DEQUIP"
                        
                        local character = LocalPlayer.Character
                        if character then
                            ApplyLocalMorph(character, skinName)
                        end
                    end
                end)
            end
            
            NewSlot.Parent = InventoryGrid
        end
    end
end

-- Run System
InjectAllSkinsToInventory()

if CurrentCharacterConnection then CurrentCharacterConnection:Disconnect() end
CurrentCharacterConnection = LocalPlayer.CharacterAdded:Connect(function(newCharacter)
    task.wait(0.5)
    if ActiveSkin then
        ApplyLocalMorph(newCharacter, ActiveSkin)
    end
end)
