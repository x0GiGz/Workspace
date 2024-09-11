repeat wait(0.25) until game:IsLoaded()
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
    [1] = Windows:AddTab({Title = "Macro", Name = nil, Icon = "video"}),
    [2] = Windows:AddTab({Title = "Game", Name = nil, Icon = "layers"}),
    [3] = Windows:AddTab({Title = "Settings", Name = nil, Icon = "settings"})
}

local Tabs_Secs =
{
    [1] = {Tabs_Main[1]:AddSection("Config"), Tabs_Main[1]:AddSection("Macro")},
    [2] = {Tabs_Main[2]:AddSection("Game")}
}

local Buttons =
{
    Create = nil,
    Delete = nil
}

local Game =
{
    Reward_Claim = false
}

local Macro =
{
    Last_Unit = nil,
    Playing = nil,
    Placed_Check = nil,
    Replay_Check = nil,
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
    "Selected File [Main]",
    {
        Title = "Selected File",
        Values = SetFile:ListFile("CrazyDay/Anime Vanguards/Macro","json"),
        Multi = false,
        Default = "Starter",
        Callback = function(Value)
            if Buttons.Delete and (Value == "" or Value == nil) then
                Buttons.Delete:Lock()
            elseif Buttons.Delete and Value ~= "" and Value ~= nil then
                Buttons.Delete:UnLock()
            end
        end
    }
)

Tabs_Secs[1][1]:AddInput(
    "File Name [Main]",
    {
        Title = "Create File",
        Placeholder = "Name Here",
        Numeric = false,
        Finished = false,
        Default = nil,
        Callback = function(Value)
            if Buttons.Create and (Value == "" or Value == nil) then
                Buttons.Create:Lock()
            elseif Buttons.Create and Value ~= "" and Value ~= nil then
                Buttons.Create:UnLock()
            end
        end
    }
)

Buttons.Create = Tabs_Secs[1][1]:AddButton(
    {
        Title = "Create",
        Callback = function()
            local succs, error = pcall(
                function()
                    local text = string.format("CrazyDay/Anime Vanguards/Macro/".."%s.json", Options["File Name [Main]"].Value)
                    if not isfile then
                        error("The excutor does not support isfile", 9)
                    elseif not writefile then
                        error("The excutor does not support writefile", 9)
                    elseif isfile(text) then
                        error("This file is already available", 9)
                    else
                        SetFile:CheckFile(text, {})
                        Options["Selected File [Main]"]:SetValues(SetFile:ListFile("CrazyDay/Anime Vanguards/Macro","json"))
                        Options["Selected File [Main]"]:SetValue(Options["File Name [Main]"].Value)
                    end
                end
            )
            if succs then
                Loader:Notify(
                    {
                        Title = "Successful Create: " .. tostring(Options["File Name [Main]"].Value),
                        Disable = true,
                        Duration = 5
                    }
                )
                Options["File Name [Main]"]:SetValue("")
            elseif error then
                Loader:Notify(
                    {
                        Title = "Unsuccessful Create: " .. tostring(error),
                        Disable = true,
                        Duration = 5
                    }
                )
            end
        end
    }
)
Buttons.Delete = Tabs_Secs[1][1]:AddButton(
    {
        Title = "Delete",
        Callback = function()
            Windows:Dialog(
                {
                    Title = "Delete",
                    Content = "Are you sure you want to delete "..tostring(Options["Selected File [Main]"].Value).."?",
                    Buttons = {
                        {
                            Title = "Yes",
                            Callback = function()
                                local names = Options["Selected File [Main]"].Value
                                local succs, error = pcall(
                                    function()
                                        local text = string.format("CrazyDay/Anime Vanguards/Macro/".."%s.json", names)
                                        if names == nil then
                                            error("The name of the selected file is empty", 9)
                                        elseif not isfile then
                                            error("The excutor does not support isfile", 9)
                                        elseif not delfile then
                                            error("The excutor does not support delfile", 9)
                                        elseif not isfile(text) then
                                            error("Unable to find the file", 9)
                                        else
                                            SetFile:DeleteFile(text)
                                            local list = SetFile:ListFile("CrazyDay/Anime Vanguards/Macro","json")
                                            Options["Selected File [Main]"]:SetValues(list)
                                            Options["Selected File [Main]"]:SetValue(#list > 0 and list[#list] or nil)
                                        end
                                    end
                                )
                                if succs then
                                    Loader:Notify(
                                        {
                                            Title = "Successful Delete: " .. tostring(names),
                                            Disable = true,
                                            Duration = 5
                                        }
                                    )
                                elseif error then
                                    Loader:Notify(
                                        {
                                            Title = "Unsuccessful Delete: " .. tostring(error),
                                            Disable = true,
                                            Duration = 5
                                        }
                                    )
                                end
                            end
                        },
                        {
                            Title = "No"
                        }
                    }
                }
            )
        end
    }
)

Tabs_Secs[1][2]:AddToggle(
    "Record Macro",
    {
        Title = "Record",
        Default = false,
        Callback = function(Value)
            if Options["Play Macro"] and Value then
                Options["Play Macro"]:Lock()
                Options["Selected File [Main]"]:Lock()
                Options["File Name [Main]"]:Lock()
                Buttons.Delete:Lock()
                Buttons.Create:Lock()
            elseif Options["Play Macro"] and not Value then
                Options["Play Macro"]:UnLock()
                Options["Selected File [Main]"]:UnLock()
                Options["File Name [Main]"]:UnLock()
                Buttons.Delete:UnLock()
                Buttons.Create:UnLock()
            end
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
    "Play Macro",
    {
        Title = "Play",
        Default = false,
        Callback = function(Value)
            if Options["Record Macro"] and Value then
                Options["Record Macro"]:Lock()
                Options["Selected File [Main]"]:Lock()
                Options["File Name [Main]"]:Lock()
                Buttons.Delete:Lock()
                Buttons.Create:Lock()
            elseif Options["Record Macro"] and not Value then
                Options["Record Macro"]:UnLock()
                Options["Selected File [Main]"]:UnLock()
                Options["File Name [Main]"]:UnLock()
                Buttons.Delete:UnLock()
                Buttons.Create:UnLock()
            end
        end
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
    Saveed:IgnoreThemeSettings()
    Saveed:SetIgnoreIndexes({"File Name [Main]", "Record Macro"})
    Saveed:BuildConfigSection(Tabs_Main[#Tabs_Main])

    Windows:SelectTab(1)
    Windows:Minimize("Loaded")

    if Options["File Name [Main]"].Value == "" or Options["File Name [Main]"].Value == nil then
        Buttons.Create:Lock()
    end
    if Options["Selected File [Main]"].Value == "" or Options["Selected File [Main]"].Value == nil then
        Buttons.Delete:Lock()
    end
end


local Players, LocalPlayer, PlayerGui, ReplicatedStorage, HttpService, VirtualInputManager, UserInputService =
    game:GetService("Players"),
    game:GetService("Players").LocalPlayer,
    game:GetService("Players").LocalPlayer.PlayerGui,
    game:GetService("ReplicatedStorage"),
    game:GetService("HttpService"),
    game:GetService("VirtualInputManager"),
    game:GetService("UserInputService")

    local function macro_write()
        writefile(string.format("CrazyDay/Anime Vanguards/Macro/".."%s.json", Options["Selected File [Main]"].Value), HttpService:JSONEncode(Macro.Value))
    end

    local function macro_count()
        setmetatable(Macro.Value, Macro.Count)
        return #Macro.Value
    end

    local function macro_insert(data)
        if not Macro.Value[tostring(macro_count() + 1)] then
            Macro.Value[tostring(macro_count() + 1 )] = data
        end
    end

    local function NavigationGUISelect(Object)
        local GuiService = game:GetService("GuiService")
        repeat
            GuiService.GuiNavigationEnabled = true
            GuiService.SelectedObject = Object
            wait()
        until GuiService.SelectedObject == Object
        VirtualInputManager:SendKeyEvent(true, "Return", false, nil)
        VirtualInputManager:SendKeyEvent(false, "Return", false, nil)
        task.wait(0.25)
        GuiService.GuiNavigationEnabled = false
        GuiService.SelectedObject = nil
    end

    local function stringtocf(str)
        return CFrame.new(table.unpack(str:gsub(" ", ""):split(",")))
    end

    local function stringtopos(str)
        return Vector3.new(table.unpack(str:gsub(" ", ""):split(",")))
    end

    local function cash()
        local yen = PlayerGui.Hotbar.Main.Yen.Text:split("¥")[1]
        if yen:find(",") then yen = yen:gsub(",","")
        end
        return yen
    end

    local function upgrade_visible(v)
        if #PlayerGui.UpgradeInterfaces:GetChildren() > 0 then
            PlayerGui.UpgradeInterfaces:GetChildren()[1].Stats.UpgradeButton.Visible = v
        end
    end

    local function unit_data(unt, ugp)
        for _, Data in next, ReplicatedStorage.Modules.Data.Entities.UnitsData:GetDescendants() do
            if Data.ClassName == "ModuleScript" then
                local require_data = require(Data)
                local unt_data =
                {
                    upgradeprice = tostring(require_data.Upgrades[(ugp and ugp + 2) or 2].Price),

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

    local function unit_cframe(unt)
        for _, Unit in next, workspace.UnitVisuals.UnitCircles:GetChildren() do
            if Unit.Name == unt then
                return Unit.Position
            end
        end
    end

    local function unit_position(unt)
        if type(unt) == "string" then
            unt = stringtopos(unt)
        end
        for _, Unit in next, workspace.UnitVisuals.UnitCircles:GetChildren() do
            if Unit.Position == unt or (Unit.Position - unt).Magnitude <= 2 then
                return Unit.Name
            end
        end
    end

    task.spawn(
        function()
            while true and wait() do
                if Loader.Unloaded then
                    if Macro.Replay_Check then Macro.Replay_Check:Disconnect() end
                    if Macro.Placed_Check then Macro.Placed_Check:Disconnect() end
                    break
                end
            end
        end
    )

    task.spawn(
        function()
            if game.PlaceId == 16146832113 then return end
            Macro.Replay_Check = PlayerGui:WaitForChild("Hotbar"):WaitForChild("Main"):WaitForChild("Yen"):GetPropertyChangedSignal("Text"):Connect(function()
                if PlayerGui.Hotbar.Main.Yen.Text == "0¥" and PlayerGui.Guides.List.StageInfo.Enemies.Amount.Text == "x0" and PlayerGui.Guides.List.StageInfo.Takedowns.Amount.Text == "x0" and PlayerGui.Guides.List.StageInfo.Units.Amount.Text == "x0" and Options["Play Macro"].Value then
                    Options["Play Macro"]:SetValue(false)
                    Loader:Notify({Title = "Replaying Macro", Duration = 5, Disable = true})
                    Options["Play Macro"]:SetValue(true)
                end
            end
            )
        end
    )

    task.spawn(
        function()
            if not getrawmetatable then return Loader:Notify({Title = "Error", SubContent = "Can't Record Macro The Excutor Doesn't Support [getrawmetatable]"})
            elseif game.PlaceId == 16146832113 then return end

            task.spawn(
                function()
                    Macro.Placed_Check = workspace.UnitVisuals.UnitCircles.ChildAdded:Connect(function (v)
                        if Loader.Unloaded or not Options["Record Macro"].Value then
                            return
                        else
                            if Macro.Last_Unit then task.spawn(
                                function()
                                    macro_insert(
                                        {
                                            ["type"] = Macro.Last_Unit["type"],
                                            ["unit"] = Macro.Last_Unit["unit"],
                                            ["money"] = Macro.Last_Unit["money"],
                                            ["cframe"] = Macro.Last_Unit["cframe"],
                                            ["rotation"] = Macro.Last_Unit["rotation"]

                                        }
                                    )
                                    macro_write() Macro.Last_Unit = nil
                                end
                            )
                            end
                        end
                    end)
                end
            )
            local raw = getrawmetatable(ReplicatedStorage.Networking)
            local hook = raw.__namecall
            setreadonly(raw, false)
            raw.__namecall = newcclosure(function(self, ...)
                local arg = {...}
                task.spawn(
                    function()
                        if Loader.Unloaded or not Options["Record Macro"].Value then return end

                        if self.Name == "UnitEvent" and (arg[1] == "Render" or arg[1] == "Upgrade" or arg[1] == "Sell") then
                            if arg[1] == "Render" and tonumber(cash()) >= tonumber(unit_data(arg[2][1]).price) then
                                Macro.Last_Unit =
                                {
                                    ["type"] = "Render",
                                    ["unit"] = tostring(unit_data(arg[2][1]).name),
                                    ["money"] = tostring(unit_data(arg[2][1]).price),
                                    ["cframe"] = tostring(arg[2][3]),
                                    ["rotation"] = tostring(arg[2][4])
                                }
                            elseif arg[1] == "Upgrade" then
                                if #PlayerGui.UpgradeInterfaces:GetChildren() > 0 and (PlayerGui.UpgradeInterfaces:GetChildren()[1].Stats.UpgradeButton.Inner.Label.Text == "Max" or PlayerGui.UpgradeInterfaces:GetChildren()[1].Stats.UpgradeButton:FindFirstChild("Dark") or PlayerGui.UpgradeInterfaces:GetChildren()[1].Stats.UpgradeButton.Visible == false) then
                                    return warn("Max Upgrade / Not Enough / Upgrade To Fast")
                                else
                                    upgrade_visible(false) local num = PlayerGui.UpgradeInterfaces:GetChildren()[1].Stats.UpgradeLabel.Label.Text:split(" ")[2]
                                    if num:find("[") then num = num:gsub("[","") end if num:find("]") then num = num:gsub("]","") end
                                    local unit_data_I = unit_data(PlayerGui.UpgradeInterfaces:GetChildren()[1].Unit.Main.UnitFrame:FindFirstChildOfClass("Frame").Holder.Main.UnitName.Text, tonumber(num))
                                    macro_insert(
                                        {
                                            ["type"] = "Upgrade",
                                            ["unit"] = tostring(unit_data_I.name),
                                            ["money"] = tostring(unit_data_I.upgradeprice),
                                            ["cframe"] = tostring(unit_cframe(arg[2]))
                                        }
                                    )
                                    macro_write()
                                    task.delay(0.25, upgrade_visible, true)
                                end
                            elseif arg[1] == "Sell" and #PlayerGui.UpgradeInterfaces:GetChildren() > 0 then
                                macro_insert(
                                    {
                                        ["type"] = "Sell",
                                        ["unit"] = tostring(unit_data(PlayerGui.UpgradeInterfaces:GetChildren()[1].Unit.Main.UnitFrame:FindFirstChildOfClass("Frame").Holder.Main.UnitName.Text).name),
                                        ["money"] = "0",
                                        ["cframe"] = tostring(unit_cframe(arg[2]))
                                    }
                                )
                                macro_write()
                            end
                        end
                    end
                )
                return hook(self, ...)
            end)
        end
    )

    task.spawn(
        function()
            if not isfile or not readfile then return Loader:Notify({Title = "Error", SubContent = "Can't Play Macro The Excutor Doesn't Support [isfile / readfile]"})
            elseif game.PlaceId == 16146832113 then return end

            task.spawn(
                function()
                    Options["Play Macro"]:OnChanged(
                        function(Value)
                            if Value == true then repeat task.wait() until PlayerGui:FindFirstChild("Hotbar") wait(1)
                                if not isfile(string.format("CrazyDay/Anime Vanguards/Macro/".."%s.json", Options["Selected File [Main]"].Value)) then
                                    return Loader:Notify({Title = "Error", SubContent = tostring(Options["Selected File [Main]"].Value)..".json is empty"})
                                else
                                    Macro.Playing = HttpService:JSONDecode(readfile(string.format("CrazyDay/Anime Vanguards/Macro/".."%s.json", Options["Selected File [Main]"].Value)))
                                    setmetatable(Macro.Playing, Macro.Count)

                                    for i = 1, #Macro.Playing do
                                        wait(Options["Macro Delay"].Value)
                                        local data = Macro.Playing[tostring(i)]

                                        if data["money"] then
                                            repeat task.wait() until tonumber(cash()) >= tonumber(data["money"]) or not Options["Play Macro"].Value or Loader.Unloaded
                                        end
                                        if not Options["Play Macro"].Value or Loader.Unloaded then
                                            break
                                        else
                                            if data["type"] == "Render" then
                                                if not Options["Play Macro"].Value or Loader.Unloaded then
                                                    break
                                                else repeat task.wait() until tonumber(cash()) >= tonumber(data["money"])
                                                    ReplicatedStorage.Networking.UnitEvent:FireServer(
                                                        "Render",
                                                        {
                                                            data["unit"],
                                                            unit_data(data["unit"]).id,
                                                            stringtopos(data["cframe"]),
                                                            tonumber(data["rotation"] or 0)
                                                        }
                                                    )
                                                end
                                            elseif data["type"] == "Upgrade" then
                                                if not Options["Play Macro"].Value or Loader.Unloaded then
                                                    break
                                                elseif not unit_position(data["cframe"]) then
                                                    return warn("Upgrade Failed - Can't find the unit")
                                                else repeat task.wait() until tonumber(cash()) >= tonumber(data["money"])
                                                    ReplicatedStorage.Networking.UnitEvent:FireServer("Upgrade", unit_position(data["cframe"]))
                                                end
                                            elseif data["type"] == "Sell" then
                                                if not Options["Play Macro"].Value or Loader.Unloaded then
                                                    break
                                                elseif not unit_position(data["cframe"]) then
                                                    return warn("Sell Failed - Can't find the unit")
                                                else repeat task.wait() until tonumber(cash()) >= tonumber(data["money"])
                                                    ReplicatedStorage.Networking.UnitEvent:FireServer("Sell", unit_position(data["cframe"]))
                                                end
                                            end
                                        end
                                        task.wait(0.375)
                                        if not Options["Play Macro"].Value or Loader.Unloaded then
                                            break
                                        end
                                    end
                                end
                            end
                        end
                    )
                end
            )
        end
    )

    task.spawn(
        function()
            if game.PlaceId == 16146832113 then return end
            while true and wait() do
                if Loader.Unloaded then break
                else
                    if #workspace.Camera:GetChildren() > 0 then
                        for _, ItemInfo in next, workspace.Camera:GetChildren() do
                            if ItemInfo:IsA("Model") and #workspace.Camera:GetChildren() > 1 then
                                VirtualInputManager:SendMouseButtonEvent(5, 5, 0, not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1), game, 0) Game.Reward_Claim = true
                            elseif not ItemInfo:IsA("Model") and #workspace.Camera:GetChildren() > 0 then
                                VirtualInputManager:SendMouseButtonEvent(5, 5, 0, not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1), game, 0) Game.Reward_Claim = true
                            else Game.Reward_Claim = false
                            end
                        end
                    else Game.Reward_Claim = false
                    end
                end
            end
        end
    )

    task.spawn(
        function()
            if game.PlaceId == 16146832113 then return end
            while true and wait() do
                if Loader.Unloaded then break
                else
                    if Options["Auto Start Game / Skip Wave"].Value and PlayerGui:FindFirstChild("SkipWave") then
                        ReplicatedStorage.Networking.SkipWaveEvent:FireServer("Skip")
                        wait(2)
                    end
                end
            end
        end
    )

    task.spawn(
        function()
            if game.PlaceId == 16146832113 then return end
            while true and wait() do
                if Loader.Unloaded then break
                else
                    pcall(
                        function()
                            local Visual = PlayerGui.EndScreen
                            if Options["Auto Leave"].Value and not Game.Reward_Claim and Visual.Enabled and Visual.ShowEndScreen.Visible and Visual.Container.EndScreen:FindFirstChild("Leave") and Visual.Container.EndScreen:FindFirstChild("Leave").Visible then
                                NavigationGUISelect(Visual.Container.EndScreen.Leave.Button)
                            elseif Options["Auto Next"].Value and not Game.Reward_Claim and Visual.Enabled and Visual.ShowEndScreen.Visible and Visual.Container.EndScreen:FindFirstChild("Next") and Visual.Container.EndScreen:FindFirstChild("Next").Visible then
                                NavigationGUISelect(Visual.Container.EndScreen.Next.Button)
                            elseif Options["Auto Retry"].Value and not Game.Reward_Claim and Visual.Enabled and Visual.ShowEndScreen.Visible and Visual.Container.EndScreen:FindFirstChild("Retry") and Visual.Container.EndScreen:FindFirstChild("Retry").Visible then
                                NavigationGUISelect(Visual.Container.EndScreen.Retry.Button)
                            end
                        end
                    )
                end
            end
        end
    )
