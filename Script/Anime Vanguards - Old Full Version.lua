repeat task.wait() until game:IsLoaded() and game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("LoadingScreen") == nil and game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("LobbyLoadingScreen") == nil
local Loader = loadstring(game:HttpGet("https://raw.githubusercontent.com/x0GiGz/Workspace/main/Gui/fluent%20main%20(search).lua"))()
local Saveed = loadstring(game:HttpGet("https://raw.githubusercontent.com/x0GiGz/Workspace/main/Gui/fluent%20save%20config.lua"))()
local Setting = loadstring(game:HttpGet("https://raw.githubusercontent.com/x0GiGz/Workspace/main/Gui/fluent%20interfaces.lua"))()
local SetFile = loadstring(game:HttpGet("https://raw.githubusercontent.com/x0GiGz/Workspace/main/Function/filehelper.lua"))()
local Configs = Loader.Options
local Windows = Loader:CreateWindow(
    {
        Title = "Anime Vanguards",
        SubTitle = "1.0 [YT @crazyday3693]",
        TabWidth = 130,
        Size = UDim2.fromOffset(540, 440),
        Theme = "Darker",
        Acrylic = true,
        UpdateDate = "09/11/2024 - 1.0",
        UpdateLog = "● Release",
        IconVisual = nil,
        BlackScreen = false,
        MinimizeKey = Enum.KeyCode.LeftAlt
    }
)

local Tabs_Main =
{
    [1] = Windows:AddTab({Title = "Join", Name = nil, Icon = "angle-double-small-up"}),
    [2] = Windows:AddTab({Title = "Game", Name = nil, Icon = "layers"}),
    [3] = Windows:AddTab({Title = "Macro", Name = nil, Icon = "folder"}),
    [4] = Windows:AddTab({Title = "Settings", Name = nil, Icon = "settings"})
}

local Tabs_Secs =
{
    [1] = {Tabs_Main[1]:AddSection("Settings"), Tabs_Main[1]:AddSection("Story"), Tabs_Main[1]:AddSection("Legend Stage"), Tabs_Main[1]:AddSection("Challenge")},
    [2] = {Tabs_Main[2]:AddSection("Game"), Tabs_Main[2]:AddSection("Webhook")},
    [3] = {Tabs_Main[3]:AddSection("Setting"), Tabs_Main[3]:AddSection("Macro")}
}

local Game =
{
    Time = tick(),

    Story_Mode = {},
    Story_Acts = {},
    Difficulty = {},

    Legend_Stage_Mode = {},
    Legend_Stage_Acts = {},

    Challenge_Debuff = {"Revitalize", "Shielded", "Exploding", "Strong", "Thrice", "Regen", "Fast"},
    Challenge_Rewards = {},

    Buttons = {},
    Signals = {},
    Others = {}
}

local Macro =
{
    Status = "None",
    Value = {Data = {}},
    Len = {
        __len = function(num)
            local count = 0
            for idx, data in next, num do
                if idx ~= "Data" then
                    count += 1
                end
            end
            return count
        end
    }
}

task.spawn(
    function()
        for _, Game_Story in next, game:GetService("ReplicatedStorage").Modules.Data.StagesData.Story:GetChildren() do
            local Data_Require = require(Game_Story[Game_Story.Name])
            table.insert(Game.Story_Mode, Data_Require.Name)

            if #Game.Story_Acts == 0 then
                for I = 1, #Game_Story.Acts:GetChildren() do
                    table.insert(Game.Story_Acts, Game_Story.Acts:GetChildren()[I].Name)
                end
            end
        end

        for _, Game_Legend_Stage in next, game:GetService("ReplicatedStorage").Modules.Data.StagesData.LegendStage:GetChildren() do
            local Data_Require = require(Game_Legend_Stage[Game_Legend_Stage.Name])
            table.insert(Game.Legend_Stage_Mode, Data_Require.Name)

            if #Game.Legend_Stage_Acts == 0 then
                for I = 1, #Game_Legend_Stage.Acts:GetChildren() do
                    table.insert(Game.Legend_Stage_Acts, Game_Legend_Stage.Acts:GetChildren()[I].Name)
                end
            end
        end

        for _, Game_Difficulty in next, game:GetService("ReplicatedStorage").Assets.Interfaces.DifficultyGradients:GetChildren() do
            table.insert(Game.Difficulty, Game_Difficulty.Name)
        end

        for Game_Challenge_Rewards, _ in next, require(game:GetService("ReplicatedStorage").Modules.Data.ItemsData.EssenceStones) do
            table.insert(Game.Challenge_Rewards, Game_Challenge_Rewards)
        end

        for Game_Challenge_Rewards, _ in next, require(game:GetService("ReplicatedStorage").Modules.Data.ItemsData.MiscItems) do
            table.insert(Game.Challenge_Rewards, Game_Challenge_Rewards)
        end

        do
            SetFile:CheckFolder("CrazyDay")
            SetFile:CheckFolder("CrazyDay/Anime Vanguards")
            SetFile:CheckFolder("CrazyDay/Anime Vanguards/Macro")

            SetFile:CheckFile("CrazyDay/Anime Vanguards/Macro/Starter.json", {Data = {}})
        end
    end
)

Tabs_Secs[1][1]:AddToggle(
    "Auto Start",
    {
        Title = "Auto Start",
        Description = "Start the game after creating the room",
        Default = true
    }
)

Tabs_Secs[1][1]:AddToggle(
    "Friends Only",
    {
        Title = "Friends Only",
        Description = "use friends only when create room",
        Default = false
    }
)


Tabs_Secs[1][1]:AddSlider(
    "Start Delay",
    {
        Title = "Start In X Seconds",
        Description = "Set a delay to enter the room",
        Default = 1,
        Min = 0,
        Max = 30,
        Rounding = 0
    }
)

Game.Buttons.Lobby =
Tabs_Secs[1][1]:AddButton(
    {
        Title = "Return to Lobby",
        Description = "Instant Lobby Teleport",
        Callback = function()
            Windows:Dialog(
                {
                    Title = "Notify",
                    Content = "Do you want to teleport to the lobby?",
                    Buttons = {
                        {Title = "Yes", Callback = Return_Lobby},
                        {Title = "No"}
                    }
                }
            )
        end
    }
)

Tabs_Secs[1][2]:AddDropdown(
    "Story Stage",
    {
        Title = "Selecte Story",
        Values = Game.Story_Mode,
        Multi = false,
        Default = 1
    }
)

Tabs_Secs[1][2]:AddDropdown(
    "Story Act",
    {
        Title = "Selecte Act",
        Values = Game.Story_Acts,
        Multi = false,
        Default = 1
    }
)

Tabs_Secs[1][2]:AddDropdown(
    "Story Difficulty",
    {
        Title = "Selecte Difficulty",
        Values = Game.Difficulty,
        Multi = false,
        Default = 1
    }
)

Tabs_Secs[1][2]:AddToggle(
    "Auto Join Hights",
    {
        Title = "Auto Join Story (Highnest)",
        Description = "Join the highnest story automatically",
        Default = false,
        Callback = function(Value)
            if Value then
                task.spawn(
                    function()
                        repeat task.wait() until Configs["Auto Join Normal"] Configs["Auto Join Normal"]:Lock()
                    end
                )
            else
                task.spawn(
                    function()
                        repeat task.wait() until Configs["Auto Join Normal"] Configs["Auto Join Normal"]:UnLock()
                    end
                )
            end
        end
    }
)

Tabs_Secs[1][2]:AddToggle(
    "Auto Join Normal",
    {
        Title = "Auto Join Story (Normal)",
        Description = "Join select story automatically",
        Default = false,
        Callback = function(Value)
            if Value then
                Configs["Auto Join Hights"]:Lock()
            else
                Configs["Auto Join Hights"]:UnLock()
            end
        end
    }
)

Tabs_Secs[1][3]:AddDropdown(
    "Legend Stage Stage",
    {
        Title = "Selecte Legend Stage",
        Values = Game.Legend_Stage_Mode,
        Multi = false,
        Default = 1
    }
)

Tabs_Secs[1][3]:AddDropdown(
    "Legend Stage Act",
    {
        Title = "Selecte Act",
        Values = Game.Legend_Stage_Acts,
        Multi = false,
        Default = 1
    }
)

Tabs_Secs[1][3]:AddToggle(
    "Auto Join Legend Stage",
    {
        Title = "Auto Join Legend Stage",
        Description = "Join select legend stage automatically",
        Default = false
    }
)

Tabs_Secs[1][4]:AddDropdown(
    "Ignore Challegne World",
    {
        Title = "Ignore Challegne World",
        Values = Game.Story_Mode,
        Multi = true,
        Default = {}
    }
)

Tabs_Secs[1][4]:AddDropdown(
    "Ignore Challegne Debuff",
    {
        Title = "Ignore Challegne Debuff",
        Values = Game.Challenge_Debuff,
        Multi = true,
        Default = {}
    }
)

Tabs_Secs[1][4]:AddDropdown(
    "Ignore Challegne Rewards",
    {
        Title = "Ignore Challegne Rewards",
        Values = Game.Challenge_Rewards,
        Multi = true,
        Default = {}
    }
)

Tabs_Secs[1][4]:AddToggle(
    "Auto Join Challenge",
    {
        Title = "Auto Join Challenges",
        Description = "Join select challenges automatically",
        Default = false
    }
)

Tabs_Secs[2][1]:AddToggle(
    "Auto Skip",
    {
        Title = "Auto Skip Wave / Start Game",
        Description = "Automatically skip wave and start game",
        Default = false
    }
)

Tabs_Secs[2][1]:AddToggle(
    "Auto Leave",
    {
        Title = "Auto Leave",
        Description = "Automatically teleport to the looby if game complete",
        Default = false
    }
)

Tabs_Secs[2][1]:AddToggle(
    "Auto Next",
    {
        Title = "Auto Next",
        Description = "Automatically play next if game complete",
        Default = false
    }
)

Tabs_Secs[2][1]:AddToggle(
    "Auto Retry",
    {
        Title = "Auto Retry",
        Description = "Automatically retry the game if game complete",
        Default = false
    }
)

Tabs_Secs[2][2]:AddInput(
    "Url",
    {
        Title = "Webhook",
        Placeholder = "URL",
        Numeric = false,
        Finished = false,
        Default = nil
    }
)

Tabs_Secs[2][2]:AddToggle(
    "Sned Webhook",
    {
        Title = "Sned Webhook",
        Description = "Send a notifaction to your Discord when the game ends, displaying information about the match and what rewards you've received",
        Default = false
    }
)

Game.Others.Status1 =
Tabs_Secs[3][1]:AddParagraph(
    {
        Title = "Status : None",
        Content = "\nGame Time : 0.00"
    }
)

Tabs_Secs[3][1]:AddToggle(
    "Macro Status",
    {
        Title = "Macro Status",
        Description = "Toggle for Show Macro Status",
        Default = true,
        Callback = function(Value)
            Game.Others.Status1.Frame.Visible = Value
        end
    }
)

Tabs_Secs[3][1]:AddDropdown(
    "Macro File",
    {
        Title = "Select Files",
        Values = SetFile:ListFile("CrazyDay/Anime Vanguards/Macro","json"),
        Default = "Starter"
    }
)

Tabs_Secs[3][1]:AddInput(
    "File Name",
    {
        Title = "File Name",
        Placeholder = "File name here...",
        Default = ""
    }
)

Game.Buttons.Create =
Tabs_Secs[3][1]:AddButton(
    {
        Title = "Create Macro File",
        Description = "Create a macro with the specified name",
        Callback = function()
            Windows:Dialog(
                {
                    Title = "Notify",
                    Content = string.format("You're sure to create the ".."%s.json", Configs["File Name"].Value),
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
Tabs_Secs[3][1]:AddButton(
    {
        Title = "Delete Select Macro",
        Description = "Delete the Selected Macro",
        Callback = function()
            Windows:Dialog(
                {
                    Title = "Notify",
                    Content = string.format("You're sure to delete the ".."%s.json", Configs["Macro File"].Value),
                    Buttons = {
                        {Title = "Yes", Callback = Delete_Macro},
                        {Title = "No"}
                    }
                }
            )
        end
    }
)

Tabs_Secs[3][2]:AddDropdown(
    "Record Type",
    {
        Title = "Record Type",
        Values = {"Hybrid","Money","Time"},
        Default = "Money"
    }
)

Tabs_Secs[3][2]:AddToggle(
    "Macro Record",
    {
        Title = "Record Macro",
        Description =  "Experiencing issues with the recorded macro? Try not to press upgrade to early",
        Default = false,
        Callback = function(Value)
            if Value then Macro.Value = {Data = {}} end
        end
    }
)

Tabs_Secs[3][2]:AddToggle(
    "Macro Play",
    {
        Title = "Play Back Macro",
        Default = false
    }
)


if game.PlaceId == 16146832113 then
    Game.Buttons.Lobby:Lock()

    local function Name_to_Stage(txt)
        for _, Name_Idx in next, game:GetService("ReplicatedStorage").Modules.Data.StagesData.Story:GetChildren() do
            local Data_Require = require(Name_Idx[Name_Idx.Name])
            if Data_Require.Name == txt then
                return Name_Idx.Name
            end
        end
    end

    local function True_Lobby()
        for _, V in next, workspace.MainLobby:GetChildren() do
            if V.Name == "Lobby" and V.ClassName == "Folder" then
                return V
            end
        end
    end

    local function Challenge_Normal_Lobby()
        for _, V in next, True_Lobby().Challenges:GetChildren() do
            if V:IsA("Model") and V.LobbyBanner.Banner.Main.ChallengeInterface.Background.StageName.Text ~= "Daily" and V.LobbyBanner.Banner.Main.ChallengeInterface.Background.MaxPlayers.Amount.Text == "0/4" then
                return V
            end
        end
    end

    local function Challenge_Ignore()
        if #Configs["Ignore Challegne Rewards"].Tables > 0 then
            for I = 1, #Configs["Ignore Challegne Rewards"].Tables do
                if Challenge_Normal_Lobby().LobbyBanner.Banner.Main.ChallengeInterface.Background.Rewards:FindFirstChild(Configs["Ignore Challegne Rewards"].Tables[I]) then
                    return true
                end
            end
        end
        if #Configs["Ignore Challegne Debuff"].Tables > 0 then
            local Debuff_Online = Challenge_Normal_Lobby().LobbyBanner.Banner.Main.ChallengeInterface.Background.Difficulty.Label.Text
            if Debuff_Online:find(" ") then
                local Debuff_Tables = {}
                Debuff_Online = Debuff_Online:split(" ")

                for I = 1, #Debuff_Online do
                    table.insert(Debuff_Tables, Debuff_Online[I]:lower())
                end

                for I = 1, #Configs["Ignore Challegne Debuff"].Tables do
                    if table.find(Debuff_Tables, Configs["Ignore Challegne Debuff"].Tables[I]:lower()) then
                        return true
                    end
                end
            else
                for I = 1, #Configs["Ignore Challegne Debuff"].Tables do
                    if Debuff_Online:lower() == Configs["Ignore Challegne Debuff"].Tables[I]:lower() then
                        return true
                    end
                end
            end
        end
        if #Configs["Ignore Challegne World"].Tables > 0 then
            for I, V in next, Configs["Ignore Challegne World"].Tables do
                local Data_Require = require(game:GetService("ReplicatedStorage").Modules.Data.StagesData)
                for IX, VX in next, Data_Require.Challenge do
                    if IX == Name_to_Stage(V) then
                        for D = 1, 6 do
                            if VX.Acts["Act"..tostring(D)].ActName == Challenge_Normal_Lobby().LobbyBanner.Banner.Main.ChallengeInterface.Background.ActName.Text then
                                return true
                            end
                        end
                    end
                end
            end
        end
    end

    local function Story_Lobby()
        for _, V in next, True_Lobby():GetChildren() do
            if V.Name == "Lobby" and V:IsA("Model") and V.LobbyBanner.Banner.Main:FindFirstChild("ChosenStage") == nil and V.LobbyBanner.Banner.Main.ChoosingStage.Main.ActName.Text == "Choosing..." then
                return V
            end
        end
    end

    task.spawn(
        function()
            while true and wait() do
                if Loader.Unloaded then break
                elseif not Configs["Auto Start"].Value then
                else
                    if game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("MiniLobbyInterface") then
                        task.wait(0.25)
                        NavigationGUISelect(game:GetService("Players").LocalPlayer.PlayerGui.MiniLobbyInterface.Holder.Buttons.Start.Button)
                    end
                end
            end
        end
    )

    task.spawn(
        function()
            while true and wait(0.25) do
                if Loader.Unloaded then break
                elseif Configs["Auto Join Challenge"].Value or Configs["Auto Join Legend Stage"].Value or Configs["Auto Join Normal"].Value or Configs["Auto Join Hights"].Value then
                    if game:GetService("Players").LocalPlayer.PlayerGui.Windows.Lobby.Enabled or game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("MiniLobbyInterface") then
                    if Configs["Auto Join Legend Stage"].Value and game:GetService("Players").LocalPlayer.PlayerGui.Windows.Lobby.Enabled then
                        game:GetService("ReplicatedStorage").Networking.LobbyEvent:FireServer("Confirm",
                    {
                        "LegendStage",
                        Name_to_Stage(Configs["Legend Stage Stage"].Value),
                        Configs["Legend Stage Act"].Value,
                        "Normal",
                        4,
                        0,
                        Configs["Friends Only"].Value
                    })
                    else
                        if game:GetService("Players").LocalPlayer.PlayerGui.Windows.Lobby.Enabled and Configs["Auto Join Normal"].Value then
                            game:GetService("ReplicatedStorage"):WaitForChild("Networking"):WaitForChild("LobbyEvent"):FireServer("Confirm",{
                                "Story",
                                Name_to_Stage(Configs["Story Stage"].Value),
                                Configs["Story Act"].Value,
                                Configs["Story Difficulty"].Value,
                                4,
                                0,
                                Configs["Friends Only"].Value
                            })
                        elseif game:GetService("Players").LocalPlayer.PlayerGui.Windows.Lobby.Enabled and Configs["Auto Join Hights"].Value then
                            for I = 1, #Game.Story_Mode do
                                if game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("MiniLobbyInterface") then
                                    break
                                else
                                    local Stags_Options = game:GetService("Players").LocalPlayer.PlayerGui.Windows.Lobby.Holder.Background.Main.Stages

                                    if Stags_Options["Stage"..tostring(#Game.Story_Mode)].Info.LevelsCleared.Amount.Text == "6/6" then
                                        game:GetService("ReplicatedStorage"):WaitForChild("Networking"):WaitForChild("LobbyEvent"):FireServer("Confirm",{
                                            "Story",
                                            "Stage"..tostring(#Game.Story_Mode),
                                            "Act6",
                                            Configs["Story Difficulty"].Value,
                                            4,
                                            0,
                                            Configs["Friends Only"].Value
                                        })
                                    else
                                        if Stags_Options["Stage"..tostring(I)].Info.LevelsCleared.Amount.Text ~= "6/6" then
                                            game:GetService("ReplicatedStorage"):WaitForChild("Networking"):WaitForChild("LobbyEvent"):FireServer("Confirm",{
                                                "Story",
                                                "Stage"..tostring(I),
                                                "Act"..tostring(tonumber(Stags_Options["Stage"..tostring(I)].Info.LevelsCleared.Amount.Text:split("/")[1] + 1)),
                                                Configs["Story Difficulty"].Value,
                                                4,
                                                0,
                                                Configs["Friends Only"].Value
                                            })
                                        end
                                    end
                                end
                            end
                        end
                    end
                    else
                        if Configs["Auto Join Challenge"].Value and not Challenge_Ignore() then wait(Configs["Start Delay"].Value)
                            game:GetService("ReplicatedStorage").Networking.LobbyEvent:FireServer("Enter", Challenge_Normal_Lobby())
                        elseif Story_Lobby() and (Configs["Auto Join Legend Stage"].Value or Configs["Auto Join Normal"].Value or Configs["Auto Join Hights"].Value) then wait(Configs["Start Delay"].Value)
                            game:GetService("ReplicatedStorage").Networking.LobbyEvent:FireServer("Enter", Story_Lobby())
                        end
                    end
                end
            end
        end
    )
else
    local OwnGui = game:GetService("Players").LocalPlayer.PlayerGui

    function Return_Lobby()
        NavigationGUISelect(game:GetService("Players").LocalPlayer.PlayerGui.Windows.Settings.Main.Settings.Misc.Settings.TeleportToLobby.Teleport.Button)

        game:GetService("Players").LocalPlayer.PlayerGui:WaitForChild("PopupScreen"):WaitForChild("Background").Visible = false
        game:GetService("Players").LocalPlayer.PlayerGui.PopupScreen.BaseConfirmationFrame.Size = UDim2.fromOffset(0.1, 0.1)
        game:GetService("Players").LocalPlayer.PlayerGui.PopupScreen.BaseConfirmationFrame:WaitForChild("Main"):WaitForChild("Description").Visible = false

        NavigationGUISelect(game:GetService("Players").LocalPlayer.PlayerGui.PopupScreen.BaseConfirmationFrame.Main.Buttons:WaitForChild("Yes"):WaitForChild("Button"))
    end

    local function Yen()
        local TexT = game:GetService("Players").LocalPlayer.PlayerGui.Hotbar.Main.Yen.Text:split("¥")[1]

        if TexT:find(",") then
           TexT = TexT:gsub(",","")
        end
        return TexT
    end

    local function Stage_to_Name()
        local a = require(game:GetService("ReplicatedStorage").Modules.Gameplay.GameHandler)
        local b = a.GameData.Stage

        local c = require(game:GetService("ReplicatedStorage").Modules.Data.StagesData.Story[b][b])

        return c.Name
    end

    local function Macro_Data_World()
        if not Macro.Value.Data.World then
            Macro.Value.Data.World = tostring(Stage_to_Name())
        end
    end

    local function Macro_Len()
        setmetatable(Macro.Value, Macro.Len)
        return #Macro.Value
    end

    local function Macro_Insert(dtb)
        if not Macro.Value[tostring(Macro_Len() + 1)] then
               Macro.Value[tostring(Macro_Len() + 1)] = dtb
        end
    end

    local function Macro_Write()
        writefile(string.format("CrazyDay/Anime Vanguards/Macro/".."%s.json", Configs["Macro File"].Value), game:GetService("HttpService"):JSONEncode(Macro.Value))
    end

    local function Unit_Data(TexT)
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
                if unt_data.name == TexT or unt_data.model == TexT or unt_data.shinnymodel == TexT then
                    return unt_data
                end
            end
        end
    end

    local function Unit_CFrame(name)
        for _, Unit in next, workspace.UnitVisuals.UnitCircles:GetChildren() do
            if Unit.Name == name then
                return Unit.Position
            end
        end
    end

    local function Upgrade_Visible(v)
        if #OwnGui.UpgradeInterfaces:GetChildren() > 0 then
            OwnGui.UpgradeInterfaces:GetChildren()[1].Stats.UpgradeButton.Visible = v
        end
    end

    local function Money_Write(type)
        if Configs["Record Type"].Value == "Money" or Configs["Record Type"].Value == "Hybrid" then
            if type == "Upgrade" then
                local Totals = OwnGui.UpgradeInterfaces:GetChildren()[1].Stats.UpgradeButton.Inner.Label.Text:split(" ")[2]:split("¥")[1]

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

    local function Game_Time()
        if OwnGui:FindFirstChild("SkipWave") and OwnGui.SkipWave.Holder.Description.Text == "Vote start:" then
            return 0
        else
            local Tick = tick() - Game.Time
            local Secs = math.floor(Tick) % ((9e9 * 9e9) + (9e9 * 9e9))
            local Mills = string.format(".%.03d", (Tick % 1) * 1000)

            return Secs..Mills
        end
    end

    local function Time_Write()
        if Configs["Record Type"].Value == "Time" or Configs["Record Type"].Value == "Hybrid" then
            if OwnGui:FindFirstChild("SkipWave") and OwnGui.SkipWave.Holder.Description.Text == "Vote start:" then
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

    local function Update_Status()
        if Configs["Macro Record"].Value then
            if Macro.Value[tostring(Macro_Len())] then
                return "\nIndex : "..tostring(Macro_Len().."/"..Macro_Len()).."\nAction : "..Macro.Value[tostring(Macro_Len())]["type"].."\nUnit : "..Macro.Value[tostring(Macro_Len())]["unit"].."\nMoney : "..Macro.Value[tostring(Macro_Len())]["money"].."\nTime : "..Macro.Value[tostring(Macro_Len())]["time"]
            else
                return "\nIndex : 0/0"
            end
        else

        end
    end

    task.spawn(
        function()
            if not getrawmetatable or not newcclosure then return Loader:Notify({Title = "Error", SubContent = "Can't Record Macro The Excutor Doesn't Support getrawmetatable / newcclosure"}) end
            local Gets = getrawmetatable(game:GetService("ReplicatedStorage").Networking)
            local Hook = Gets.__namecall

            task.spawn(
                function()
                    Macro.Place_Toggle = workspace.UnitVisuals.UnitCircles.ChildAdded:Connect(function (v)
                        if Loader.Unloaded or not Configs["Macro Record"].Value then
                            return
                        else
                            if Macro.Placed then task.spawn(
                                function()
                                    if v.Position == stringtopos(Macro.Placed["cframe"]) or (v.Position - stringtopos(Macro.Placed["cframe"])).Magnitude <= 2 then
                                        Macro_Insert(
                                            {
                                                ["type"] = Macro.Placed["type"],
                                                ["unit"] = Macro.Placed["unit"],
                                                ["money"] = Macro.Placed["money"],
                                                ["time"] = Macro.Placed["time"],
                                                ["cframe"] = Macro.Placed["cframe"],
                                                ["rotation"] = Macro.Placed["rotation"]

                                            }
                                        )
                                        Macro_Write()
                                        Macro.Placed = nil
                                    else
                                        Macro.Placed = nil
                                    end
                                end
                            )
                            end
                        end
                    end)
                end
            )
            setreadonly(Gets, false)
            Gets.__namecall = newcclosure(function(self, ...)
                local arg = {...}
                task.spawn(
                    function()
                        if Loader.Unloaded or not Configs["Macro Record"].Value then return
                        else
                            if self.Name == "UnitEvent" and (arg[1] == "Render" or arg[1] == "Upgrade"or arg[1] == "Sell" or arg[1] == "ChangePriority") then
                                if arg[1] == "Render" and tonumber(Yen()) >= tonumber(Unit_Data(arg[2][1]).price) then
                                    Macro_Data_World()

                                    Macro.Placed =
                                    {
                                        ["type"] = "Render",
                                        ["unit"] = tostring(Unit_Data(arg[2][1]).name),
                                        ["money"] = tostring(Money_Write(arg[2][1])),
                                        ["time"] = tostring(Time_Write()),
                                        ["cframe"] = tostring(arg[2][3]),
                                        ["rotation"] = tostring(arg[2][4])
                                    }
                                elseif arg[1] == "Upgrade" and #OwnGui.UpgradeInterfaces:GetChildren() >0  and OwnGui.UpgradeInterfaces:GetChildren()[1].Stats.UpgradeButton.Inner.Label.Text ~= "Max" and OwnGui.UpgradeInterfaces:GetChildren()[1].Stats.UpgradeButton:FindFirstChild("Dark") == nil and OwnGui.UpgradeInterfaces:GetChildren()[1].Stats.UpgradeButton.Visible == true then
                                    Macro_Data_World()
                                    Upgrade_Visible(false)

                                    Macro_Insert(
                                        {
                                            ["type"] = "Upgrade",
                                            ["unit"] = tostring(Unit_Data(OwnGui.UpgradeInterfaces:GetChildren()[1].Unit.Main.UnitFrame:FindFirstChildOfClass("Frame").Holder.Main.UnitName.Text).name),
                                            ["money"] = tostring(Money_Write("Upgrade")),
                                            ["time"] = tostring(Time_Write()),
                                            ["cframe"] = tostring(Unit_CFrame(arg[2]))
                                        }
                                    )
                                    Macro_Write()

                                    task.delay(0.065, Upgrade_Visible, true)
                                elseif arg[1] == "Sell" then
                                    Macro_Data_World()

                                    Macro_Insert(
                                        {
                                            ["type"] = "Sell",
                                            ["unit"] = tostring(Unit_Data(OwnGui.UpgradeInterfaces:GetChildren()[1].Unit.Main.UnitFrame:FindFirstChildOfClass("Frame").Holder.Main.UnitName.Text).name),
                                            ["money"] = "0",
                                            ["time"] = tostring(Time_Write()),
                                            ["cframe"] = tostring(Unit_CFrame(arg[2]))
                                        }
                                    )
                                    Macro_Write()
                                elseif arg[1] == "ChangePriority" then
                                    Macro_Data_World()

                                    Macro_Insert(
                                        {
                                            ["type"] = "ChangePriority",
                                            ["unit"] = tostring(Unit_Data(OwnGui.UpgradeInterfaces:GetChildren()[1].Unit.Main.UnitFrame:FindFirstChildOfClass("Frame").Holder.Main.UnitName.Text).name),
                                            ["money"] = "0",
                                            ["time"] = tostring(Time_Write()),
                                            ["cframe"] = tostring(Unit_CFrame(arg[2]))
                                        }
                                    )
                                    Macro_Write()
                                end
                            end
                        end
                    end
                )
                return Hook(self, ...)
            end)
        end
    )

    task.spawn(
        function()
            while true and wait() do
                if Loader.Unloaded then break
                else
                    if Configs["Macro Status"].Value then
                        if Game.Others.Notify1 then
                            Game.Others.Notify1.Title.Text = "Status : "..Macro.Status
                            Game.Others.Notify1.SubContentLabel.Text = "Game Time : "..tostring(Game_Time())..Update_Status()

                            local d, n = string.gsub(Game.Others.Notify1.SubContentLabel.Text, "\n", "")
                            Game.Others.Notify1.Holder.Size = UDim2.new(1,0,0,(80 + (10.5 * n)))
                        else
                            Game.Others.Status1:SetTitle("Status : "..Macro.Status)
                            Game.Others.Status1:SetDesc("\nGame Time : "..tostring(Game_Time())..Update_Status())
                        end
                    end
                end
            end
        end
    )

    task.spawn(
        function()
            Game.Window_Changed = Windows.Root:GetPropertyChangedSignal("Visible"):Connect(
                function()
                    if Windows.Root.Visible == false and Configs["Macro Status"].Value and not Game.Others.Notify1 then
                        Game.Others.Notify1 = Loader:Notify({Title = "Status : None", SubContent = "\n", Disable = true})
                    elseif Windows.Root.Visible == true and Game.Others.Notify1 then
                        Game.Others.Notify1:Close()
                        Game.Others.Notify1 = nil
                    end
                end
            )
        end
    )
end

function stringtopos(str)
    return Vector3.new(table.unpack(str:gsub(" ", ""):split(",")))
end

function NavigationGUISelect(Object)
    local GuiService = game:GetService("GuiService")
    repeat
        GuiService.GuiNavigationEnabled = true
        GuiService.SelectedObject = Object
    task.wait()
    until GuiService.SelectedObject == Object

    game:GetService("VirtualInputManager"):SendKeyEvent(true, "Return", false, nil)
    game:GetService("VirtualInputManager"):SendKeyEvent(false, "Return", false, nil)

    task.wait(0.0525)
    GuiService.GuiNavigationEnabled = false
    GuiService.SelectedObject = nil
end

function Create_Macro()
    local passed, error = pcall(
        function()
            local link = string.format("CrazyDay/Anime Vanguards/Macro/".."%s.json", Configs["File Name"].Value)

            if not isfile then
                error("The Excutor doesn't Support isfile", 9)
            elseif not writefile then
                error("The Excutor doesn't Support writefile", 9)
            elseif isfile(link) then
                error("This File is Already Available", 9)
            else
                SetFile:CheckFile(link, {Data = {}})

                Configs["Macro File"]:SetValues(SetFile:ListFile("CrazyDay/Anime Vanguards/Macro","json"))
                Configs["Macro File"]:SetValue(Configs["File Name"].Value)
            end
        end
    )
    if passed then
        Loader:Notify({Title = "Successful Create : "..Configs["File Name"].Value..".json", Disable = true, Duration = 5})
        Configs["File Name"]:SetValue("")
    else
        Loader:Notify({Title = "Unsuccessful Create : "..tostring(error), Disable = true, Duration = 5})
    end
end

function Delete_Macro()
    local text = Configs["Macro File"].Value
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

                Configs["Macro File"]:SetValues(list)
                Configs["Macro File"]:SetValue(#list > 0 and list[#list] or nil)
            end
        end
    )
    if passed then
        Loader:Notify({Title = "Successful Delete : "..text..".json", Disable = true, Duration = 5})
    else
        Loader:Notify({Title = "Unsuccessful Delete : "..tostring(error), Disable = true, Duration = 5})
    end
end

function Update_Lock()
    while true and wait() do
        if Loader.Unloaded then break
        else
            local A, B = Configs, Game.Buttons
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

                   Macro.Status = "Playing"
                end
                if A["Macro Record"].Value and not A["Macro Play"].IsLocked then
                   A["Macro Play"]:Lock()

                   Macro.Status = "Recording"
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

                Macro.Status = "None"
            end
        end
    end
end

function Unloaded_Loader()
    while true and wait() do
        if Loader.Unloaded then
        if Macro.Place_Toggle then Macro.Place_Toggle:Disconnect() end
        if Game.Window_Changed then Game.Window_Changed:Disconnect() end
        break
        end
    end
end

task.spawn(Update_Lock)
task.spawn(Unloaded_Loader)
