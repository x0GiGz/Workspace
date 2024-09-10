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

local Macro =
{
    Last_Unit = nil,
    Playing = nil,
    Connection = nil,
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
        Placeholder = "Name.",
        Numeric = false,
        Finished = false,
        Default = "",
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
            elseif Options["Play Macro"] and not Value then
                Options["Play Macro"]:UnLock()
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
            elseif Options["Record Macro"] and not Value then
                Options["Record Macro"]:UnLock()
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

do
    if Options["File Name [Main]"].Value == "" or Options["File Name [Main]"].Value == nil then
        Buttons.Create:Lock()
    end
    if Options["Selected File [Main]"].Value == "" or Options["Selected File [Main]"].Value == nil then
        Buttons.Delete:Lock()
    end

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
end

local function Money()
    local money = game:GetService("Players").LocalPlayer.PlayerGui.Hotbar.Main.Yen.Text:split("¥")[1]
    if money:find(",") then money = money:gsub(",","") end
    return tonumber(money)
end

local function UnitMoney(text)
    for _ , Unit in next, game:GetService("Players").LocalPlayer.PlayerGui.Hotbar.Main.Units:GetChildren() do
        if Unit:IsA("Frame") and Unit:FindFirstChild("UnitTemplate") and Unit.UnitTemplate.Holder.Main.UnitName.Text == text then
            local money = Unit.UnitTemplate.Holder.Main.Price.Text:split("¥")[1]
            if money:find(",") then money = money:gsub(",","") end
            return tonumber(money)
        end
    end
end

local function writemacro()
    writefile(string.format("CrazyDay/Anime Vanguards/Macro/".."%s.json", Options["Selected File [Main]"].Value), game:GetService("HttpService"):JSONEncode(Macro.Value))
end

local function stringtocf(str)
    return CFrame.new(table.unpack(str:gsub(" ", ""):split(",")))
end

local function stringtopos(str)
    return Vector3.new(table.unpack(str:gsub(" ", ""):split(",")))
end

local function macrocout()
    setmetatable(Macro.Value, Macro.Count)
    return #Macro.Value
end

local function macroinsert(idx)
    if not Macro.Value[tostring(macrocout() + 1)] then
        Macro.Value[tostring(macrocout() + 1 )] = idx
    end
end

local function upgradecost()
    local text = game:GetService("Players").LocalPlayer.PlayerGui.UpgradeInterfaces:GetChildren()[1].Stats.UpgradeButton.Inner.Label.Text:split(" ")[2]:split("¥")[1]
    if text:find(",") then text = text:gsub(",","") end
    return tonumber(text)
end

local function upgradecf(str)
    for _ , Unit in next, workspace.UnitVisuals.UnitCircles:GetChildren() do
        if Unit.Name == str then
            return Unit.Position
        end
    end
end

local function upgradepos(unt)
    if type(unt) == "string" then
        unt = stringtopos(unt)
    end
    for _ , Unit in next, workspace.UnitVisuals.UnitCircles:GetChildren() do
        if Unit.Position == unt or (Unit.Position - unt).Magnitude <= 2 then
            return Unit.Name
        end
    end
end

local function NavigationGUISelect(Object)
    local GuiService = game:GetService("GuiService")
    GuiService.GuiNavigationEnabled = true
    GuiService.SelectedObject = Object
    task.wait(0.075)
    game:GetService("VirtualInputManager"):SendKeyEvent(true, "Return", false, nil)
    game:GetService("VirtualInputManager"):SendKeyEvent(false, "Return", false, nil)
    task.wait(0.075)
    GuiService.GuiNavigationEnabled = false
    GuiService.SelectedObject = nil
end

task.spawn(
    function()
        if not getrawmetatable then return Loader:Notify({Title = "Can't Record The Excutor Doesn't Support Some Function"})
        elseif game.PlaceId == 16146832113 then return end
        local raw = getrawmetatable(game:GetService("ReplicatedStorage").Networking)
        local hook = raw.__namecall;
        setreadonly(raw,false)
        raw.__namecall = newcclosure(function(self,...)
            local arg = {...}
            local method = getnamecallmethod()
            task.spawn(
                function()
                    if Loader.Unloaded then return
                    elseif Options["Record Macro"].Value and self.Name == "UnitEvent" and (arg[1] == "Render" or arg[1] == "Upgrade" or arg[1] == "Sell") then
                        if arg[1] == "Render" and Money() >= UnitMoney(arg[2][1]) then
                            task.spawn(function()
                                Macro.Last_Unit =
                                {
                                    ["money"] = tostring(UnitMoney(arg[2][1])),
                                    ["unit"] = tostring(arg[2][1]),
                                    ["idx"] = tostring(arg[2][2]),
                                    ["cframe"] = tostring(arg[2][3]),
                                    ["rotation"] = tostring(arg[2][4])
                                }
                            end)
                        elseif arg[1] == "Upgrade" and #game:GetService("Players").LocalPlayer.PlayerGui.UpgradeInterfaces:GetChildren() > 0 and game:GetService("Players").LocalPlayer.PlayerGui.UpgradeInterfaces:GetChildren()[1].Stats.UpgradeButton:FindFirstChild("Dark") == nil then
                            task.wait(0.035)
                            if game:GetService("Players").LocalPlayer.PlayerGui.UpgradeInterfaces:GetChildren()[1].Stats.UpgradeButton.Inner.Label.Text == "Max" or game:GetService("Players").LocalPlayer.PlayerGui.UpgradeInterfaces:GetChildren()[1].Stats.UpgradeButton:FindFirstChild("Dark") then
                                return
                            end
                            local Last_Text, Last_Money, Last_Name, Last_CFrame = game:GetService("Players").LocalPlayer.PlayerGui.UpgradeInterfaces:GetChildren()[1].Stats.UpgradeButton.Inner.Label.Text, upgradecost(), game:GetService("Players").LocalPlayer.PlayerGui.UpgradeInterfaces:GetChildren()[1].Unit.Main.UnitFrame:FindFirstChildOfClass("Frame").Name, upgradecf(arg[2])
                            task.spawn(
                                function()
                                    repeat task.wait() until game:GetService("Players").LocalPlayer.PlayerGui.UpgradeInterfaces:GetChildren()[1].Stats.UpgradeButton.Inner.Label.Text ~= Last_Text
                                    macroinsert(
                                        {
                                            ["type"] = "Upgrade",
                                            ["money"] = tostring(Last_Money),
                                            ["unit"] = tostring(Last_Name),
                                            ["cframe"] = tostring(Last_CFrame)
                                        }
                                    )
                                    writemacro()
                                end
                            )
                        elseif arg[1] == "Sell" and #game:GetService("Players").LocalPlayer.PlayerGui.UpgradeInterfaces:GetChildren() > 0 then
                            macroinsert(
                                {
                                    ["type"] = "Sell",
                                    ["money"] = "0",
                                    ["unit"] = tostring(game:GetService("Players").LocalPlayer.PlayerGui.UpgradeInterfaces:GetChildren()[1].Unit.Main.UnitFrame:FindFirstChildOfClass("Frame").Name),
                                    ["cframe"] = tostring(upgradecf(arg[2]))
                                }
                            )
                            writemacro()
                        end
                    end
                end
            )
            return hook(self,...)
        end)
        setreadonly(raw,true)
    end
)

task.spawn(
    function()
        if not getrawmetatable then return Loader:Notify({Title = "Can't Record The Excutor Doesn't Support Some Function"})
        elseif game.PlaceId == 16146832113 then return end
        task.spawn(
            function()
                Options["Play Macro"]:OnChanged(
                    function(v)
                        if v then
                            wait(1)
                            repeat wait() until game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("Hotbar")
                            Macro.Playing = game:GetService("HttpService"):JSONDecode(readfile(string.format("CrazyDay/Anime Vanguards/Macro/".."%s.json", Options["Selected File [Main]"].Value)))
                            setmetatable(Macro.Playing, Macro.Count)
                            for i = 1 , #Macro.Playing do
                                local Data = Macro.Playing[tostring(i)]
                                if Data["money"] then
                                    repeat wait() until Money() >= tonumber(Data["money"]) or not Options["Play Macro"].Value
                                elseif not Options["Play Macro"].Value then
                                    break
                                end
                                wait(Options["Macro Delay"].Value)
                                if Data["type"] == "Render" then
                                    if not Options["Play Macro"].Value then
                                        break
                                    else
                                        local args = {
                                            [1] = "Render",
                                            [2] = {
                                                [1] = Data["unit"],
                                                [2] = tonumber(Data["idx"]),
                                                [3] = stringtopos(Data["cframe"]),
                                                [4] = tonumber(Data["rotation"])
                                            }
                                        }
                                        game:GetService("ReplicatedStorage").Networking.UnitEvent:FireServer(unpack(args))
                                    end
                                elseif Data["type"] == "Upgrade" then
                                    if not upgradepos(Data["cframe"]) then
                                        return warn("Error: Can't find the unit to upgrade!")
                                    elseif not Options["Play Macro"].Value then
                                        break
                                    end
                                    game:GetService("ReplicatedStorage").Networking.UnitEvent:FireServer("Upgrade", upgradepos(Data["cframe"]))
                                elseif Data["type"] == "Sell" then
                                    if not upgradepos(Data["cframe"]) then
                                        return warn("Error: Can't find the unit to sell!")
                                    elseif not Options["Play Macro"].Value then
                                        break
                                    end
                                    game:GetService("ReplicatedStorage").Networking.UnitEvent:FireServer("Sell", upgradepos(Data["cframe"]))
                                end
                                wait(0.275)
                                if not Options["Play Macro"].Value then
                                    break
                                end
                            end
                        end
                    end
                )
            end
        )
        Macro.Connection = workspace.UnitVisuals.UnitCircles.ChildAdded:Connect(function (v)
            if Loader.Unloaded or not Options["Record Macro"].Value then
                return
            end
            if Macro.Last_Unit then
                macroinsert(
                    {
                        ["type"] = "Render",
                        ["money"] = Macro.Last_Unit["money"],
                        ["unit"] = Macro.Last_Unit["unit"],
                        ["idx"] = Macro.Last_Unit["idx"],
                        ["cframe"] = Macro.Last_Unit["cframe"],
                        ["rotation"] = Macro.Last_Unit["rotation"]

                    }
                )
                writemacro()
                Macro.Last_Unit = nil
            end
        end)
    end
)


task.spawn(
    function()
        if game.PlaceId == 16146832113 then return end
        while true and wait() do
            if Loader.Unloaded then Macro.Connection:Disconnect() break end
            if #workspace.Camera:GetChildren() > 0 then
                game:GetService("VirtualInputManager"):SendMouseButtonEvent(5, 5, 0, not game:GetService("UserInputService"):IsMouseButtonPressed(Enum.UserInputType.MouseButton1), game, 0)
            end
        end
    end
)

task.spawn(
    function()
        if game.PlaceId == 16146832113 then return end
        local EndFrame = game:GetService("Players").LocalPlayer.PlayerGui:WaitForChild("EndScreen")
        while true and wait() do
            if Loader.Unloaded then break end
            pcall(
                function()
                    if Options["Auto Leave"].Value and EndFrame.Enabled and EndFrame.Background.Visible and EndFrame.ShowEndScreen.Visible and EndFrame.Container.EndScreen:FindFirstChild("Leave") and EndFrame.Container.EndScreen:FindFirstChild("Leave").Visible then
                        NavigationGUISelect(game:GetService("Players").LocalPlayer.PlayerGui.EndScreen.Container.EndScreen.Leave.Button)
                    elseif Options["Auto Next"].Value and EndFrame.Enabled and EndFrame.Background.Visible and EndFrame.ShowEndScreen.Visible and EndFrame.Container.EndScreen:FindFirstChild("Next") and EndFrame.Container.EndScreen:FindFirstChild("Next").Visible then
                        repeat
                            NavigationGUISelect(game:GetService("Players").LocalPlayer.PlayerGui.EndScreen.Container.EndScreen.Next.Button)
                            warn("Nexting . . .")
                            wait(0.25)
                        until not game:GetService("Players").LocalPlayer.PlayerGui.EndScreen.ShowEndScreen.Visible or Loader.Unloaded
                        if Options["Play Macro"].Value then
                            Options["Play Macro"].Value = false
                            task.wait(0.075)
                            Options["Play Macro"]:SetValue(true)
                        end
                    elseif Options["Auto Retry"].Value and EndFrame.Enabled and EndFrame.Background.Visible and EndFrame.ShowEndScreen.Visible and EndFrame.Container.EndScreen:FindFirstChild("Retry") and EndFrame.Container.EndScreen:FindFirstChild("Retry").Visible then
                        repeat
                            NavigationGUISelect(game:GetService("Players").LocalPlayer.PlayerGui.EndScreen.Container.EndScreen.Retry.Button)
                            warn("Retrying . . .")
                            wait(0.25)
                        until not game:GetService("Players").LocalPlayer.PlayerGui.EndScreen.ShowEndScreen.Visible or Loader.Unloaded
                        if Options["Play Macro"].Value then
                            Options["Play Macro"].Value = false
                            task.wait(0.075)
                            Options["Play Macro"]:SetValue(true)
                        end
                    end
                end
            )
        end
    end
)
