local ReplicatedStorage = game:GetService("ReplicatedStorage");
local Players = game:GetService("Players")
local Teams = game:GetService("Teams");

local LocalPlayer = Players.LocalPlayer;

local Character, HumanoidRootPart, Head, Humanoid
local Shoot = ReplicatedStorage:WaitForChild("Guns").Remotes.fire;

local WhitelistedToolNames = {
    "HK416A5";
}

local IgnoreList = {
}

local function DefineVariables()
    Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait();
    HumanoidRootPart = Character:WaitForChild("HumanoidRootPart");
    Head = Character:WaitForChild("Head");
    Humanoid = Character:WaitForChild("Humanoid");
end

DefineVariables()

LocalPlayer.CharacterAdded:Connect(function()
    print("Respawned")
    DefineVariables()
end)

local function GetRandomGun()
    local Guns = {}
    
    for Index, Player in pairs(Players:GetPlayers()) do
        local OtherCharacter = Player.Character
        
        if OtherCharacter then
            local Tool = OtherCharacter:FindFirstChildOfClass("Tool");
            local OtherHumanoid = OtherCharacter:FindFirstChild("Humanoid")
            
            if OtherHumanoid and Tool then
                if table.find(WhitelistedToolNames, Tool.Name) then
                    table.insert(Guns, Tool);
                    
                    local Died; Died = OtherHumanoid.Died:Connect(function()
                        Died:Disconnect()
                        Tool.Parent = OtherCharacter;
                    end)
                    
                    local Died; Died = Humanoid.Died:Connect(function()
                        Died:Disconnect()
                        Tool.Parent = OtherCharacter;
                    end)
                    
                    Tool.Parent = Character;
                    
                    break
                end
            end
        end
    end
    
    return Guns[1];
end

local function KillAll(Data)
    local DeathTable = {}
    Data = Data or {
        ["KillSelf"] = true;
        ["NotKillRandom"] = false;
    }
    
    local ShouldKillSelf = Data["KillSelf"];
    local KillRandom = Data["NotKillRandom"];
    
    for Index, Value in pairs(Players:GetPlayers()) do
        if not ShouldKillSelf and Value == LocalPlayer then
            continue
        end
        
        local Character = Value.Character;
        
        if Character then
            local Head = Character:FindFirstChild("Head");
            
            if Head then
                local ShouldBeIgnored = math.random(1,2)
                
                if ShouldBeIgnored == 1 and KillRandom then
                    continue
                end
                
                if not table.find(IgnoreList, Value.Name) then
                    table.insert(DeathTable, {
                        Head;
                        -math.huge
                    })
                end
            end
        end
    end
    
    if #DeathTable > 1 then
        return Shoot:FireServer(DeathTable, Teams.SECURITY.HK416A5, Vector3.new(1/0,1/0,1/0), Vector3.new(-1/0,-1/0,-1/0), {})
    end
end

local function KillPlayer(Player, Damage)
    Damage = Damage or -math.huge
    
    local Character = Player.Character;
    
    if Character then
        local Head = Character:FindFirstChild("Head");
        
        if Head then
            Shoot:FireServer({
                {
                    Head;
                    -math.huge
                }
            }, Teams.SECURITY.HK416A5, Vector3.new(), Vector3.new(), {})
        end
    end
end
KillAll()
