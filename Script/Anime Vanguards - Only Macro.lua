repeat task.wait() until game:IsLoaded() and game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("LoadingScreen") == nil and game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("LobbyLoadingScreen") == nil
local Loader = loadstring(game:HttpGet("https://raw.githubusercontent.com/x0GiGz/Workspace/main/Gui/fluent%20main%20(search).lua"))()
local Saveed = loadstring(game:HttpGet("https://raw.githubusercontent.com/x0GiGz/Workspace/main/Gui/fluent%20save%20config.lua"))()
local Setting = loadstring(game:HttpGet("https://raw.githubusercontent.com/x0GiGz/Workspace/main/Gui/fluent%20interfaces.lua"))()
local SetFile = loadstring(game:HttpGet("https://raw.githubusercontent.com/x0GiGz/Workspace/main/Function/filehelper.lua"))()
local Options = Loader.Options
local Windows = Loader:CreateWindow(
    {
        Title = "Anime Vanguards",
        SubTitle = "1.0 [YT @crazyday3693]",
        TabWidth = 130,
        Size = UDim2.fromOffset(540, 440),
        Theme = "Darker",
        Acrylic = true,
        UpdateDate = "09/09/2024 - 1.0",
        UpdateLog = "● Release",
        IconVisual = nil,
        BlackScreen = false,
        MinimizeKey = Enum.KeyCode.LeftAlt
    }
)

local Tabs_Main =
{
    [1] = Windows:AddTab({Title = "Macro", Name = nil, Icon = "folder"}),
    [2] = Windows:AddTab({Title = "Game", Name = nil, Icon = "layers"}),
    [3] = Windows:AddTab({Title = "Settings", Name = nil, Icon = "settings"})
}

local Tabs_Secs =
{
    [1] = {Tabs_Main[1]:AddSection("Settings"), Tabs_Main[1]:AddSection("Macro")},
    [2] = {Tabs_Main[2]:AddSection("Game")}
}

local Game =
{
    Time = tick(),

    Signals = {},
    Buttons = {}
}

local Macro =
{
    Value = {},
    Count = {
        __len = function(num)
            local count = 0
            for idx, data in next, num do
                count += 1
            end
            return count
        end
    }
}

do
    SetFile:CheckFolder("CrazyDay")
    SetFile:CheckFolder("CrazyDay/Anime Vanguards")
    SetFile:CheckFolder("CrazyDay/Anime Vanguards/Macro")
    SetFile:CheckFile("CrazyDay/Anime Vanguards/Macro/Starter.json", {})
end

Tabs_Secs[1][1]:AddDropdown(
    "Macro File",
    {
        Title = "Select File",
        Values = SetFile:ListFile("CrazyDay/Anime Vanguards/Macro","json"),
        Default = "Starter",
    }
)

Tabs_Secs[1][1]:AddInput(
    "File Name",
    {
        Title = "File Name",
        Placeholder = "File name here...",
        Numeric = false,
        Finished = false,
        Default = ""
    }
)

Game.Buttons.Create =
Tabs_Secs[1][1]:AddButton(
    {
        Title = "Create Macro File",
        Callback = function()
            Windows:Dialog(
                {
                    Title = "Notify",
                    Content = string.format("You're sure to create the ".."%s.json", Options["File Name"].Value),
                    Buttons = {
                        {Title = "Yes", Callback = Create_Macro},
                        {Title = "No"}
                    }
                }
            )
        end
    }
)

Game.Buttons.Delete =
Tabs_Secs[1][1]:AddButton(
    {
        Title = "Delete Select Macro",
        Callback = function()
            Windows:Dialog(
                {
                    Title = "Notify",
                    Content = string.format("You're sure to delete the ".."%s.json", Options["Macro File"].Value),
                    Buttons = {
                        {Title = "Yes", Callback = Delete_Macro},
                        {Title = "No"}
                    }
                }
            )
        end
    }
)

Tabs_Secs[1][2]:AddDropdown(
    "Record Type",
    {
        Title = "Record Type",
        Values = {"Hybrid","Money","Time"},
        Default = "Money"
    }
)

Tabs_Secs[1][2]:AddToggle(
    "Macro Record",
    {
        Title = "Record Macro",
        Default = false,
        Callback = function(Value)
            if Value then Macro.Value = {} end
        end
    }
)

Tabs_Secs[1][2]:AddSlider(
    "Macro Delay",
    {
        Title = "Macro Delay",
        Default = 0,
        Min = 0,
        Max = 10,
        Rounding = 2
    }
)

Tabs_Secs[1][2]:AddToggle(
    "Macro Play",
    {
        Title = "Play",
        Default = false
    }
)

Tabs_Secs[2][1]:AddToggle(
    "Auto Leave",
    {
        Title = "Auto Leave",
        Default = false
    }
)

Tabs_Secs[2][1]:AddToggle(
    "Auto Next",
    {
        Title = "Auto Next",
        Default = false
    }
)

Tabs_Secs[2][1]:AddToggle(
    "Auto Retry",
    {
        Title = "Auto Retry",
        Default = false
    }
)

Tabs_Secs[2][1]:AddToggle(
    "Auto Start Game / Skip Wave",
    {
        Title = "Auto Start Game / Skip Wave",
        Default = false
    }
)

do
    Setting:SetLibrary(Loader)
    Setting:SetFolder("CrazyDay/Anime Vanguards/"..game:GetService("Players"):GetUserIdFromNameAsync(game:GetService("Players").LocalPlayer.Name))
    Setting:BuildInterfaceSection(Tabs_Main[#Tabs_Main])

    Saveed:SetLibrary(Loader)
    Saveed:SetFolder("CrazyDay/Anime Vanguards/"..game:GetService("Players"):GetUserIdFromNameAsync(game:GetService("Players").LocalPlayer.Name))
    Saveed:SetIgnoreIndexes({"File Name", "Macro Record"})
    Saveed:IgnoreThemeSettings()
    Saveed:BuildConfigSection(Tabs_Main[#Tabs_Main])

    Windows:SelectTab(1)
    Windows:Minimize("Loaded")
end

function stringtopos(str)
    return Vector3.new(table.unpack(str:gsub(" ", ""):split(",")))
end

function NavigationGUISelect(Object)
    local GuiService = game:GetService("GuiService")
    repeat
        GuiService.GuiNavigationEnabled = true
        GuiService.SelectedObject = Object
        wait()
    until GuiService.SelectedObject == Object
    game:GetService("VirtualInputManager"):SendKeyEvent(true, "Return", false, nil)
    game:GetService("VirtualInputManager"):SendKeyEvent(false, "Return", false, nil)
    task.wait(0.25)
    GuiService.GuiNavigationEnabled = false
    GuiService.SelectedObject = nil
end

function Update_Lock()
    while true and wait() do
        if Loader.Unloaded then break
        else
            local A, B = Options, Game.Buttons
            if A["Macro Record"].Value or A["Macro Play"].Value then
                if not B.Delete.IsLocked then
                    B.Delete:Lock()
                end
                if not B.Create.IsLocked then
                    B.Create:Lock()
                end

                if not A["File Name"].IsLocked then
                    A["File Name"]:Lock()
                end
                if not A["Macro File"].IsLocked then
                    A["Macro File"]:Lock()
                end
                if not A["Record Type"].IsLocked then
                    A["Record Type"]:Lock()
                end

                if A["Macro Play"].Value and not A["Macro Record"].IsLocked then
                   A["Macro Record"]:Lock()
                end
                if A["Macro Record"].Value and not A["Macro Play"].IsLocked then
                   A["Macro Play"]:Lock()
                end
            else
                if A["Macro File"].Value == nil and not B.Delete.IsLocked then
                   B.Delete:Lock()
                elseif A["Macro File"].Value ~= nil and B.Delete.IsLocked then
                   B.Delete:UnLock()
                end

                if A["File Name"].Value == "" and not B.Create.IsLocked then
                   B.Create:Lock()
                elseif A["File Name"].Value ~= "" and B.Create.IsLocked then
                   B.Create:UnLock()
                end

                if A["File Name"].IsLocked then
                    A["File Name"]:UnLock()
                end
                if A["Macro Play"].IsLocked then
                   A["Macro Play"]:UnLock()
                end
                if A["Macro File"].IsLocked then
                   A["Macro File"]:UnLock()
                end
                if A["Record Type"].IsLocked then
                   A["Record Type"]:UnLock()
                end
                if A["Macro Record"].IsLocked then
                   A["Macro Record"]:UnLock()
                end
            end
        end
    end
end

function Create_Macro()
    local passed, error = pcall(
        function()
            local link = string.format("CrazyDay/Anime Vanguards/Macro/".."%s.json", Options["File Name"].Value)

            if not isfile then
                error("The Excutor doesn't Support isfile", 9)
            elseif not writefile then
                error("The Excutor doesn't Support writefile", 9)
            elseif isfile(link) then
                error("This File is Already Available", 9)
            else
                SetFile:CheckFile(link, {})

                Options["Macro File"]:SetValues(SetFile:ListFile("CrazyDay/Anime Vanguards/Macro","json"))
                Options["Macro File"]:SetValue(Options["File Name"].Value)
            end
        end
    )
    if passed then
        Loader:Notify({Title = "Successful Create : "..Options["File Name"].Value..".json", Disable = true, Duration = 5})
        Options["File Name"]:SetValue("")
    else
        Loader:Notify({Title = "Unsuccessful Create : "..tostring(error), Disable = true, Duration = 5})
    end
end

function Delete_Macro()
    local text = Options["Macro File"].Value
    local passed, error = pcall(
        function()
            local link = string.format("CrazyDay/Anime Vanguards/Macro/".."%s.json", text)

            if not isfile then
                error("The Excutor doesn't Support isfile", 9)
            elseif not delfile then
                error("The Excutor doesn't Support delfile", 9)
            elseif not isfile(link) then
                error("The file cannot be found", 9)
            else
                SetFile:DeleteFile(link)
                local list = SetFile:ListFile("CrazyDay/Anime Vanguards/Macro","json")

                Options["Macro File"]:SetValues(list)
                Options["Macro File"]:SetValue(#list > 0 and list[#list] or nil)
            end
        end
    )
    if passed then
        Loader:Notify({Title = "Successful Delete : "..text..".json", Disable = true, Duration = 5})
    else
        Loader:Notify({Title = "Unsuccessful Delete : "..tostring(error), Disable = true, Duration = 5})
    end
end

task.spawn(Update_Lock)

if #game:GetService("Players"):GetChildren() > 1 and game.PlaceId ~= 16146832113 then
    game:GetService("Players").LocalPlayer:Kick("Make sure that in The server is no other than you.")
else
    if game.PlaceId ~= 16146832113 then

        local function Macro_Write()
            writefile(string.format("CrazyDay/Anime Vanguards/Macro/".."%s.json", Options["Macro File"].Value), game:GetService("HttpService"):JSONEncode(Macro.Value))
        end
    
        local function Macro_Len()
            setmetatable(Macro.Value, Macro.Count)
            return #Macro.Value
        end
    
        local function Macro_Insert(data)
            if not Macro.Value[tostring(Macro_Len() + 1)] then
                   Macro.Value[tostring(Macro_Len() + 1 )] = data
            end
        end
    
        local function Yen()
            local yen = game:GetService("Players").LocalPlayer.PlayerGui.Hotbar.Main.Yen.Text:split("¥")[1]
            if yen:find(",") then yen = yen:gsub(",","")
            end
            return yen
        end
    
        local function Unit_CFrame(unt)
            for _, Unit in next, workspace.UnitVisuals.UnitCircles:GetChildren() do
                if Unit.Name == unt then
                    return Unit.Position
                end
            end
        end
    
        local function Unit_Position(unt)
            if type(unt) == "string" then
                unt = stringtopos(unt)
            end
            for _, Unit in next, workspace.UnitVisuals.UnitCircles:GetChildren() do
                if Unit.Position == unt or (Unit.Position - unt).Magnitude <= 2 then
                    return Unit.Name
                end
            end
        end
    
        local function Unit_Data(unt)
            for _, Data in next, game:GetService("ReplicatedStorage").Modules.Data.Entities.UnitsData:GetDescendants() do
                if Data.ClassName == "ModuleScript" then
                    local require_data = require(Data)
                    local unt_data =
                    {
                        shinnymodel = tostring(require_data.ShinyModel),
                        model = tostring(require_data.Model),
                        price = tostring(require_data.Price),
                        name = tostring(require_data.Name),
                        id = require_data.ID
                    }
                    if unt_data.name == unt or unt_data.model == unt or unt_data.shinnymodel == unt then
                        return unt_data
                    end
                end
            end
        end
    
        local function Money_Write(type)
            if Options["Record Type"].Value == "Money" or Options["Record Type"].Value == "Hybrid" then
                if type == "Upgrade" then
                    local Totals = game:GetService("Players").LocalPlayer.PlayerGui.UpgradeInterfaces:GetChildren()[1].Stats.UpgradeButton.Inner.Label.Text:split(" ")[2]:split("¥")[1]
    
                    if Totals:find(",") then
                       Totals = Totals:gsub(",","")
                    end
    
                    return Totals
                else
                    return Unit_Data(type).price
                end
            else
                return 0
            end
        end
    
        local function Time_Write()
            if Options["Record Type"].Value == "Time" or Options["Record Type"].Value == "Hybrid" then
                if game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("SkipWave") and game:GetService("Players").LocalPlayer.PlayerGui.SkipWave.Holder.Description.Text == "Vote start:" then
                    return 0
                else
                    local Tick = tick() - Game.Time
                    local Secs = math.floor(Tick) % ((9e9 * 9e9) + (9e9 * 9e9))
                    local Mills = string.format(".%.03d", (Tick % 1) * 1000)
    
                    return Secs..Mills
                end
            else
                return 0
            end
        end
    
        local function Game_Time()
            if game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("SkipWave") and game:GetService("Players").LocalPlayer.PlayerGui.SkipWave.Holder.Description.Text == "Vote start:" then
                return 0
            else
                local Tick = tick() - Game.Time
                local Secs = math.floor(Tick) % ((9e9 * 9e9) + (9e9 * 9e9))
                local Mills = string.format(".%.03d", (Tick % 1) * 1000)
    
                return Secs..Mills
            end
        end
    
        task.spawn(
            function()
                Game.Signals.Place = workspace.UnitVisuals.UnitCircles.ChildAdded:Connect(function (v)
                    if Loader.Unloaded or not Options["Macro Record"].Value then
                        return
                    else
                        repeat wait() until #game:GetService("Players").LocalPlayer.PlayerGui.UpgradeInterfaces:GetChildren() > 0
                        local unit = game:GetService("Players").LocalPlayer.PlayerGui.UpgradeInterfaces:GetChildren()[1]:WaitForChild("Unit"):WaitForChild("Main"):WaitForChild("UnitFrame"):FindFirstChildOfClass("Frame").Name
    
                        Macro_Insert(
                            {
                                ["type"] = "Place",
                                ["unit"] = tostring(unit),
                                ["money"] = tostring(Money_Write(unit)),
                                ["time"] = tostring(Time_Write()),
                                ["cframe"] = tostring(v.Position)
                            }
                        )
                        Macro_Write()
                    end
                end)
            end
        )
    
        task.spawn(
            function()
                Game.Signals.Upgrade = game:GetService("Players").LocalPlayer.PlayerGui.UpgradeInterfaces.ChildAdded:Connect(
                    function(v)
                        local Upgrade_Button, Sell_Button, Priority = v:WaitForChild("Stats"):WaitForChild("UpgradeButton"):WaitForChild("Button"), v:WaitForChild("Unit"):WaitForChild("Sell"):WaitForChild("Button"), v:WaitForChild("Unit"):WaitForChild("Priority"):WaitForChild("Button")
                        Game.Signals[v.Name.."Upgrade"] = Upgrade_Button.InputBegan:Connect(
                            function(input)
                                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                                    if v.Stats.UpgradeButton.Inner.Label.Text ~= "Max" and v.Stats.UpgradeButton:FindFirstChild("Dark") == nil then
                                        Macro_Insert(
                                            {
                                                ["type"] = "Upgrade",
                                                ["unit"] = tostring(v.Unit.Main.UnitFrame:FindFirstChildOfClass("Frame").Name),
                                                ["money"] = tostring(Money_Write("Upgrade")),
                                                ["time"] = tostring(Time_Write()),
                                                ["cframe"] = tostring(Unit_CFrame(v.Name))
                                            }
                                        )
                                        Macro_Write()
                                    end
                                end
                            end
                        )
                        Game.Signals[v.Name.."Sell"] = Sell_Button.InputBegan:Connect(
                            function(input)
                                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                                    Macro_Insert(
                                        {
                                            ["type"] = "Sell",
                                            ["unit"] = tostring(v.Unit.Main.UnitFrame:FindFirstChildOfClass("Frame").Name),
                                            ["money"] = "0",
                                            ["time"] = tostring(Time_Write()),
                                            ["cframe"] = tostring(Unit_CFrame(v.Name))
                                        }
                                    )
                                    Macro_Write()
                                end
                            end
                        )
                        Game.Signals[v.Name.."Priority"] = Priority.InputBegan:Connect(
                            function(input)
                                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                                    Macro_Insert(
                                        {
                                            ["type"] = "ChangePriority",
                                            ["unit"] = tostring(v.Unit.Main.UnitFrame:FindFirstChildOfClass("Frame").Name),
                                            ["money"] = "0",
                                            ["time"] = tostring(Time_Write()),
                                            ["cframe"] = tostring(Unit_CFrame(v.Name))
                                        }
                                    )
                                    Macro_Write()
                                end
                            end
                        )
                        task.spawn(
                            function()
                                repeat task.wait() until not v.Parent
                                if Game.Signals[v.Name.."Upgrade"] then
                                   Game.Signals[v.Name.."Upgrade"]:Disconnect()
                                   Game.Signals[v.Name.."Upgrade"] = nil
                                end
                                if Game.Signals[v.Name.."Sell"] then
                                   Game.Signals[v.Name.."Sell"]:Disconnect()
                                   Game.Signals[v.Name.."Sell"] = nil
                                end
                                if Game.Signals[v.Name.."Priority"] then
                                   Game.Signals[v.Name.."Priority"]:Disconnect()
                                   Game.Signals[v.Name.."Priority"] = nil
                                end
                            end
                        )
                    end
                )
            end
        )
    
        task.spawn(
            function()
                Options["Macro Play"]:OnChanged(
                    function(Value)
                        if Value == true then
                            wait(0.35)
                            if Options["Macro File"].Value == nil then
                                return Loader:Notify({Title = "Error", SubContent = "Select Macro File First"})
                            elseif not isfile(string.format("CrazyDay/Anime Vanguards/Macro/".."%s.json", Options["Macro File"].Value)) then
                                return Loader:Notify({Title = "Error", SubContent = tostring(Options["Macro File"].Value)..".json is empty"})
                            else
                                Macro.Playing = game:GetService("HttpService"):JSONDecode(readfile(string.format("CrazyDay/Anime Vanguards/Macro/".."%s.json", Options["Macro File"].Value)))
                                setmetatable(Macro.Playing, Macro.Count)
                                if #Macro.Playing == 0 then
                                    return Loader:Notify({Title = "Error", SubContent = "Record Action First"})
                                else
                                    for i = 1, #Macro.Playing do
                                        wait(Options["Macro Delay"].Value)
                                        local Data = Macro.Playing[tostring(i)]
    
                                        if Data["money"] then
                                            repeat task.wait() until tonumber(Yen()) >= tonumber(Data["money"]) or not Options["Play Macro"].Value or Loader.Unloaded
                                        end
                                        if Data["time"] then
                                            repeat task.wait() until tonumber(Game_Time()) >= tonumber(Data["time"]) or not Options["Play Macro"].Value or Loader.Unloaded
                                        end
                                        if not Options["Play Macro"].Value or Loader.Unloaded then
                                            break
                                        else
                                            if Data["type"] == "Place" then
                                                if not Options["Play Macro"].Value or Loader.Unloaded then
                                                    break
                                                else
                                                    repeat task.wait() until tonumber(Yen()) >= tonumber(Data["money"]) or not Options["Play Macro"].Value or Loader.Unloaded
                                                    repeat task.wait() until tonumber(Game_Time()) >= tonumber(Data["time"]) or not Options["Play Macro"].Value or Loader.Unloaded
                                                    game:GetService("ReplicatedStorage").Networking.UnitEvent:FireServer("Render", {
                                                        Data["unit"],
                                                        Unit_Data(Data["unit"].id),
                                                        stringtopos(Data["cframe"]),
                                                        0
                                                    })
                                                end
                                            elseif Data["type"] == "Upgrade" then
                                                if not Options["Play Macro"].Value or Loader.Unloaded then
                                                    break
                                                elseif not Unit_Position(Data["cframe"]) then
                                                    Loader:Notify({Title = "Error", SubContent = "Invaild Unit to Upgrade", Disable = true, Duration = 2.5})
                                                else
                                                    repeat task.wait() until tonumber(Yen()) >= tonumber(Data["money"]) or not Options["Play Macro"].Value or Loader.Unloaded
                                                    repeat task.wait() until tonumber(Game_Time()) >= tonumber(Data["time"]) or not Options["Play Macro"].Value or Loader.Unloaded
                                                    game:GetService("ReplicatedStorage").Networking.UnitEvent:FireServer("Upgrade", Unit_Position(Data["cframe"]))
                                                end
                                            elseif Data["type"] == "Sell" then
                                                if not Options["Play Macro"].Value or Loader.Unloaded then
                                                    break
                                                elseif not Unit_Position(Data["cframe"]) then
                                                    Loader:Notify({Title = "Error", SubContent = "Invaild Unit to Sell", Disable = true, Duration = 2.5})
                                                else
                                                    repeat task.wait() until tonumber(Yen()) >= tonumber(Data["money"]) or not Options["Play Macro"].Value or Loader.Unloaded
                                                    repeat task.wait() until tonumber(Game_Time()) >= tonumber(Data["time"]) or not Options["Play Macro"].Value or Loader.Unloaded
                                                    game:GetService("ReplicatedStorage").Networking.UnitEvent:FireServer("Sell", Unit_Position(Data["cframe"]))
                                                end
                                            elseif Data["type"] == "ChangePriority" then
                                                if not Options["Play Macro"].Value or Loader.Unloaded then
                                                    break
                                                elseif not Unit_Position(Data["cframe"]) then
                                                    Loader:Notify({Title = "Error", SubContent = "Invaild Unit to ChangePriority", Disable = true, Duration = 2.5})
                                                else
                                                    repeat task.wait() until tonumber(Yen()) >= tonumber(Data["money"]) or not Options["Play Macro"].Value or Loader.Unloaded
                                                    repeat task.wait() until tonumber(Game_Time()) >= tonumber(Data["time"]) or not Options["Play Macro"].Value or Loader.Unloaded
                                                    game:GetService("ReplicatedStorage").Networking.UnitEvent:FireServer("ChangePriority", Unit_Position(Data["cframe"]))
                                                end
                                            end
                                        end
                                        wait(0.25)
                                        if not Options["Play Macro"].Value or Loader.Unloaded then
                                            break
                                        end
                                    end
                                end
                            end
                        end
                    end
                )
            end
        )
    
        task.spawn(
            function()
                while true and wait() do
                    if Loader.Unloaded then break
                    else
                        pcall(
                            function()
                                local Visual = game:GetService("Players").LocalPlayer.PlayerGui.EndScreen
                                if Options["Auto Leave"].Value and Visual.Enabled and Visual.ShowEndScreen.Visible and Visual.Container.EndScreen:FindFirstChild("Leave") and Visual.Container.EndScreen:FindFirstChild("Leave").Visible then
                                    NavigationGUISelect(Visual.Container.EndScreen.Leave.Button)
                                elseif Options["Auto Next"].Value and Visual.Enabled and Visual.ShowEndScreen.Visible and Visual.Container.EndScreen:FindFirstChild("Next") and Visual.Container.EndScreen:FindFirstChild("Next").Visible then
                                    NavigationGUISelect(Visual.Container.EndScreen.Next.Button)
                                elseif Options["Auto Retry"].Value and Visual.Enabled and Visual.ShowEndScreen.Visible and Visual.Container.EndScreen:FindFirstChild("Retry") and Visual.Container.EndScreen:FindFirstChild("Retry").Visible then
                                    NavigationGUISelect(Visual.Container.EndScreen.Retry.Button)
                                end
                            end
                        )
                    end
                end
            end
        )
    
        task.spawn(
            function()
                while true and wait() do
                    if Loader.Unloaded then break
                    else
                        if #workspace.Camera:GetChildren() > 0 then
                            for _, ItemInfo in next, workspace.Camera:GetChildren() do
                                if ItemInfo:IsA("Model") and #workspace.Camera:GetChildren() > 1 then
                                    game:GetService("VirtualInputManager"):SendMouseButtonEvent(5, 5, 0, not game:GetService("UserInputService"):IsMouseButtonPressed(Enum.UserInputType.MouseButton1), game, 0) Game.Reward_Claim = true
                                elseif not ItemInfo:IsA("Model") and #workspace.Camera:GetChildren() > 0 then
                                    game:GetService("VirtualInputManager"):SendMouseButtonEvent(5, 5, 0, not game:GetService("UserInputService"):IsMouseButtonPressed(Enum.UserInputType.MouseButton1), game, 0) Game.Reward_Claim = true
                                end
                            end
                        end
                    end
                end
            end
        )
    
        task.spawn(
            function()
                while true and wait() do
                    if Loader.Unloaded then break
                    else
                        if Options["Auto Start Game / Skip Wave"].Value and game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("SkipWave") then
                            game:GetService("ReplicatedStorage").Networking.SkipWaveEvent:FireServer("Skip")
                            wait(5)
                        end
                    end
                end
            end
        )
    
        task.spawn(
            function()
                Game.Signals.Replay = game:GetService("Players").LocalPlayer.PlayerGui:WaitForChild("Hotbar"):WaitForChild("Main"):WaitForChild("Yen"):GetPropertyChangedSignal("Text"):Connect(function()
                    if game:GetService("Players").LocalPlayer.PlayerGui.Hotbar.Main.Yen.Text == "0¥" and game:GetService("Players").LocalPlayer.PlayerGui.Guides.List.StageInfo.Enemies.Amount.Text == "x0" and game:GetService("Players").LocalPlayer.PlayerGui.Guides.List.StageInfo.Takedowns.Amount.Text == "x0" and game:GetService("Players").LocalPlayer.PlayerGui.Guides.List.StageInfo.Units.Amount.Text == "x0" and Options["Macro Play"].Value then
                        Options["Macro Play"]:SetValue(false)
                        Loader:Notify({Title = "Replaying Macro...", Duration = 5, Disable = true})
                        wait(0.075)
                        Options["Macro Play"]:SetValue(true)
                    end
                end
                )
            end
        )
    
        task.spawn(
            function()
                while true and wait() do
                    if Loader.Unloaded then
                        for i = 1,#Game.Signals do
                            for i, v in pairs(Game.Signals[i]) do
                                if v then
                                    v:Disconnect()
                                end
                            end
                        end
                        for i,v in pairs(Game.Signals) do
                            if type(v) == "userdata" then
                                if Game.Signals[v] ~= nil then
                                    Game.Signals[v]:Disconnect()
                                end
                            end
                        end
                    end
                end
            end
        )
    end
end
