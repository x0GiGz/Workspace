--[[
    Edek Drawling Library

    Author: edek1004
    Youtube: https://www.youtube.com/@edek1004
    Discord: https://discordapp.com/users/599152972206702593
--]]

local Utility = {}
local Library = {
	Version = "1.0",
	Options = {},
	Dropdown = {},
	Window = {},
	Unloaded = false,
	CallbackUnloaded = {},
	MinimizeKey = Enum.KeyCode.LeftControl,
	NotifyPage = {Left = nil, Right = nil},
	ToggleGUI = nil,
	Signals = {},
	GUI = nil,
	SelectTab = 0,
	Menuinfo = {},
	Info = nil,
	Position = nil,
	AutoSave = {
		Value = false,
		IsFolder = false
	},
	Ignore = {},
	Start = tick()
}

Library.Parser = {
	Dropdown = {
		Save = function(idx, object)
			local encode, decond = {}, 0
			if object.Multi and object.Value then
				for inx, data in next, object.Value do
					decond += 1
					if type(data) == "string" then
						table.insert(encode, data)
					else
						table.insert(encode, {idx = inx, value = data.Number, min = data.Min, max = data.Max, rounding = data.Rounding})
					end
				end
			elseif not object.Multi and object.Value and type(object.Value) == "table" then
				decond += 1
				local data = object.Value
				encode[data.Name] = {idx = data.Name, value = data.Number, min = data.Min, max = data.Max, rounding = data.Rounding}
			end
			return {type = "Dropdown", idx = idx, value = decond > 0 and encode or object.Value, multi = object.Multi}
		end,
		Load = function(idx, object)
			if not Library.Options[idx] then
				return
			end
			local encode, decond = {}, 0
			if object.value and type(object.value) == "table" then
				for inx, data in next, object.value do
					decond += 1
					if type(data) == "table" then
						encode[data.idx] = {Value = true, Number = data.value, Min = data.min, Max = data.max, Rounding = data.rounding}
					elseif type(data) == "string" then
						table.insert(encode, data)
					end
				end
			end
			Library.Options[idx]:SetValue(decond > 0 and encode or object.value)
		end
	},
	Toggle = {
		Save = function(idx, object)
			return {type = "Toggle", idx = idx, value = object.Value}
		end,
		Load = function(idx, object)
			if not Library.Options[idx] then
				return
			end
			Library.Options[idx]:SetValue(object.value or false)
		end
	},
	Slider = {
		Save = function(idx, object)
			return {type = "Slider", idx = idx, value = tostring(object.Value)}
		end,
		Load = function(idx, object)
			if not Library.Options[idx] then
				return
			end
			Library.Options[idx]:SetValue(object.value or 0)
		end
	},
	TextBox = {
		Save = function(idx, object)
			return {type = "TextBox", idx = idx, value = object.Value}
		end,
		Load = function(idx, object)
			if not Library.Options[idx] then
				return
			end
			Library.Options[idx]:SetValue(object.value or "")
		end
	},
	Keybind = {
		Save = function(idx, object)
			return {type = "Keybind", idx = idx, mode = object.Mode, key = object.Value}
		end,
		Load = function(idx, object)
			if not Library.Options[idx] then
				return
			end
			Library.Options[idx]:SetValue(object.key, object.mode)
		end
	},
	ColorPicker = {
		Save = function(idx, object)
			return {type = "ColorPicker", idx = idx, value = object.Value:ToHex()}
		end,
		Load = function(idx, object)
			if not Library.Options[idx] then
				return
			end
			Library.Options[idx]:SetValueRGB(Color3.fromHex(object.value))
		end
	}
}

do
	function Utility.Round(z, x)
		if x == 0 then
			return math.floor(z)
		end
		z = tostring(z)
		return z:find "%." and tonumber(z:sub(1, z:find "%." + x)) or z
	end

	function Utility.Create(instance, property, children)
		local object = Instance.new(instance)

		if table.find({"Frame", "ScrollingFrame", "CanvasGroup"}, instance) then
			object.BorderColor3 = Color3.fromRGB(0, 0, 0)
			object.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			object.BorderSizePixel = 0
		elseif table.find({"UIStroke"}, instance) then
			object.Color = Color3.fromRGB(0, 0, 0)
			object.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		elseif table.find({"UIListLayout"}, instance) then
			object.SortOrder = Enum.SortOrder.LayoutOrder
			object.FillDirection = Enum.FillDirection.Vertical
		end

		for i,v in next, property or {} do
			object[i] = v
		end

		for i,v in next, children or {} do
			v.Parent = object
		end

		return object
	end

	function Utility.Tween(instance, properties, duration, completed, ...)
        local tween = game:GetService "TweenService":Create(instance, TweenInfo.new(duration, ...), properties)

		tween:Play()
		if completed then
			tween.Completed:Wait()
		end
    end

	function Utility.DraggingEnabled(frame, parent)

        parent = parent or frame

        local dragging = false
        local dragInput, mousePos, framePos

		Library.AddSignal(frame.InputBegan, function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                mousePos = input.Position
                framePos = parent.Position

                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                    end
                end)
            end
		end)

		Library.AddSignal(frame.InputChanged, function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                dragInput = input
            end
		end)

		Library.AddSignal(game:GetService "UserInputService".InputChanged, function(input)
			if input == dragInput and dragging then
                local delta = input.Position - mousePos
				parent.Position = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y)
            end
		end)

    end

	function Utility.MakeTextButton(Configs)
		local e, t = Utility.Create, {Title = Configs.Title or "", SubTiltle = Configs.Description or "", Locked = false}

		t.Frame = e("TextButton",
			{
				TextSize = 14,
				BackgroundTransparency = 1,
				AutomaticSize = Enum.AutomaticSize.Y,
				Size = UDim2.new(1, -4, 0, 0),
				Text = ""
			},
			{
				e("Frame",
					{
						BackgroundColor3 = Color3.fromRGB(45, 45, 45),
						Size = UDim2.fromScale(1, 1)
					},
					{
						e("UICorner", {CornerRadius = UDim.new(0, 4)}),
						e("UIStroke",
							{
								ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
								Thickness = 1,
								Color = Color3.fromRGB(25, 25, 25)
							}
						)
					}
				)
			}
		)

		local Title = e("TextLabel",
			{
				TextXAlignment = Enum.TextXAlignment.Left,
				TextSize = 15,
				FontFace = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Bold, Enum.FontStyle.Normal),
				TextColor3 = Color3.fromRGB(200, 200, 200),
				RichText = true,
				Size = UDim2.new(1, -50, 0, 14),
				BackgroundTransparency = 1,
				Text = Configs.Title or "",
				AutomaticSize = Enum.AutomaticSize.Y,
				TextWrapped = true
			}
		)

		local SubTitle = e("TextLabel",
			{
				TextWrapped = true,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextSize = 14,
				FontFace = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Bold, Enum.FontStyle.Normal),
				TextColor3 = Color3.fromRGB(115, 115, 115),
				RichText = true,
				Size = UDim2.new(1, -50, 0, 14),
				BackgroundTransparency = 1,
				Visible = Configs.Description and true or false,
				AutomaticSize = Enum.AutomaticSize.Y,
				Text = Configs.Description or ""
			}
		)

		if Configs.DisableDescription then
			SubTitle.Visible = false
		end

		e("Frame",
			{
				Parent = t.Frame,
				AutomaticSize =  Enum.AutomaticSize.Y,
				Size = UDim2.new(1, -10, 0, 0),
				Position = UDim2.new(0, 5, 0, 0),
				BackgroundTransparency = 1
			},
			{
				e("UIPadding",
					{
						PaddingTop = UDim.new(0, 10),
						PaddingBottom = UDim.new(0, 10)
					}
				),
				e("UIListLayout", {Padding = UDim.new(0, 2)}),
				Title,
				SubTitle
			}
		)

		t.LockLabel = e("ImageLabel",
			{
				ZIndex = 2,
				Parent = t.Frame,
				Visible = false,
				BackgroundColor3 = Color3.fromRGB(0, 0, 0),
				BackgroundTransparency = 1,
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(0, 0),
				ScaleType = Enum.ScaleType.Fit,
				Image = "rbxassetid://115887800941692"
			},
			{
				e("UICorner", {CornerRadius = UDim.new(0, 4)})
			}
		)

		t.LockButton = e("TextButton",
			{
				ZIndex = 2,
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(1, 1),
				Parent = t.Frame,
				Visible = false,
				Text = ""
			}
		)

		function t:SetTitle(text)
			Title.Text = tostring(text)

			t.Title = tostring(Title.Text)
		end

		function t:SetSubTitle(text)
			SubTitle.Text = tostring(text)

			if not Configs.DisableDescription then
				SubTitle.Visible = SubTitle.Text:len() > 0 and true or false
			end

			t.SubTiltle = tostring(SubTitle.Text)
		end

		function t.LockState()
			return t.Locked
		end

		function t.Lock()
			t.Locked = true
			t.LockButton.Visible = true
			t.LockLabel.Visible = true
			Utility.Tween(t.LockLabel, {BackgroundTransparency = 0.75, Size = UDim2.fromScale(1, 1)}, 0.35, true)
		end

		function t.Unlock()
			t.Locked = false
			t.LockButton.Visible = false
			Utility.Tween(t.LockLabel, {BackgroundTransparency = 1, Size = UDim2.fromScale(0, 0)}, 0.35, true)
			t.LockLabel.Visible = false
		end

		t.TitleContent = Title
		t.SubTiltleContent = SubTitle
		return t
	end
end

local Page = {}

do
	local Create = Utility.Create
	local Protect = protectgui or (syn and syn.protect_gui) or function() end

	local i, j, k, m =
		game:GetService "RunService",
		game:GetService "Players".LocalPlayer,
		game:GetService "UserInputService",
		game:GetService "Workspace".CurrentCamera

	Library.GUI = Create("ScreenGui", {Name = game:GetService "HttpService":GenerateGUID(false), Parent = i:IsStudio() and j.PlayerGui or game:GetService "CoreGui"})

	Protect(Library.GUI)

	if getgenv then
		getgenv().edeklibrary = Library.GUI
	end

	function Library.AddSignal(property, functions)
		table.insert(Library.Signals, property:Connect(functions))
	end

	function Library.AddConfigs(index, value)
		Library.Options[index] = value
	end

	function Library.SafeCallback(functions, ...)
		if not functions then
			return
		end

		if (...) == nil then
			pcall(function()
				return nil
			end)
		end

		local passes, fails = pcall(functions, ...)

		if not passes then
			error(fails)
		end
	end

	function Library:Destroy()
		Library.Unloaded = true
		if Library.GUI.Parent then
			Library.GUI:Destroy()
		end
		for o,v in next, Library.Signals do
			v:Disconnect()
			Library.Signals[o]:Disconnect()
		end
		for o,v in next, Library.CallbackUnloaded do
			if type(v) ~= "function" then
				return
			end
			task.spawn(v)
		end
	end

	function Library:Callback(functions)
		functions = functions or function() end

		table.insert(Library.CallbackUnloaded, type(functions) == "function" and functions or function() end)
	end

	Library.AddSignal(Library.GUI:GetPropertyChangedSignal("Parent"), function()
		if not Library.GUI.Parent then
			Library:Destroy()
		end
	end)

	Library.NotifyPage.Left = Create("Frame",
		{
			ZIndex = 3,
			Parent = Library.GUI,
			Size = UDim2.new(0.275, 0, 1, -20),
			Position = UDim2.new(0, 6, 0, 10),
			BackgroundTransparency = 1
		},
		{
			Create("UIListLayout",
				{
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					SortOrder = Enum.SortOrder.LayoutOrder,
					VerticalAlignment = Enum.VerticalAlignment.Bottom,
					Padding = UDim.new(0, 6)
				}
			)
		}
	)

	Library.NotifyPage.Right = Create("Frame",
		{
			ZIndex = 3,
			Parent = Library.GUI,
			AnchorPoint = Vector2.new(1, 0),
			Size = UDim2.new(0.275, 0, 1, -20),
			Position = UDim2.new(1, -6, 0, 10),
			BackgroundTransparency = 1
		},
		{
			Create("UIListLayout",
				{
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					SortOrder = Enum.SortOrder.LayoutOrder,
					VerticalAlignment = Enum.VerticalAlignment.Bottom,
					Padding = UDim.new(0, 6)
				}
			)
		}
	)

	function Library:Notify(Options)
		local e, s =
				Create,
				{Parent = Library.NotifyPage[Options.Parent or "Right"]}

		s.Title = e("TextLabel",
			{
				ZIndex = 3,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextSize = 13,
				FontFace = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Bold, Enum.FontStyle.Normal),
				RichText = true,
				TextColor3 = Color3.fromRGB(82, 255, 255),
				BackgroundTransparency = 1,
				Text = Options.Title or "Interface  Notification",
				Size = UDim2.fromScale(1, 1)
			}
		)

		s.Content = e("TextLabel",
			{
				ZIndex = 3,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextTransparency = 0.5,
				TextSize = 12,
				FontFace = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Bold, Enum.FontStyle.Normal),
				TextColor3 = Color3.fromRGB(82, 255, 255),
				BackgroundTransparency = 1,
				RichText = true,
				TextWrapped = true,
				Size = UDim2.new(1, 0, 0, 30),
				Text = Options.Content or "",
				Visible = Options.Content or false,
				AutomaticSize = Enum.AutomaticSize.Y
			}
		)

		s.SubTitle = e("TextLabel",
			{
				ZIndex = 3,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextSize = 14,
				FontFace = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Bold, Enum.FontStyle.Normal),
				TextColor3 = Color3.fromRGB(82, 255, 255),
				TextTransparency = 0.35,
				BackgroundTransparency = 1,
				RichText = true,
				TextWrapped = true,
				Size = UDim2.new(1, 0, 0, 30),
				Text = Options.SubTitle or "SubTitle",
				AutomaticSize = Enum.AutomaticSize.Y
			}
		)

		s.Button = e("TextButton",
			{
				ZIndex = 3,
				AnchorPoint = Vector2.new(1, 0),
				Text = "",
				Size = UDim2.new(0, 34, 1, -8),
				Position = UDim2.new(1, -40, 0, 4) ,
				BackgroundTransparency = 1
			},
			{
				e("ImageLabel",
					{
						ZIndex = 3,
						Name = "Icon",
						ImageColor3 = Color3.fromRGB(220, 220, 220),
						AnchorPoint = Vector2.new(0.5, 0.5),
						Image = "rbxassetid://9886659671",
						Size = UDim2.fromOffset(16, 16),
						BackgroundTransparency = 1,
						Position = UDim2.fromScale(0.5, 0.5)
					}
				)
			}
		)

		s.Holder = e("Frame",
			{
				ZIndex = 3,
				Parent = s.Parent,
				AutomaticSize = Enum.AutomaticSize.Y,
				Size = UDim2.new(0.1, 0, 0, 100),
				BackgroundColor3 = Color3.fromRGB(22, 22, 22)
			},
			{
				e("UICorner",
					{
						CornerRadius = UDim.new(0, 6)
					}
				),
				e("UIStroke",
					{
						Transparency = 0.5,
						ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
						Color = Color3.fromRGB(82, 255, 255)
					}
				),
				e("ImageLabel",
					{
						ZIndex = 3,
						ScaleType = Enum.ScaleType.Tile,
						ImageTransparency = 0.92,
						Image = "rbxassetid://9968344227",
						BackgroundTransparency = 1,
						Size = UDim2.fromScale(1, 1),
						TileSize = UDim2.fromOffset(128, 128)
					},
					{e("UICorner", {CornerRadius = UDim.new(0, 6)})}
				),
				e("ImageLabel",
					{
						ZIndex = 3,
						ScaleType = Enum.ScaleType.Tile,
						ImageTransparency = 0.98,
						Image = "rbxassetid://9968344105",
						BackgroundTransparency = 1,
						Size = UDim2.fromScale(1, 1),
						TileSize = UDim2.fromOffset(128, 128)
					},
					{e("UICorner", {CornerRadius = UDim.new(0, 6)})}
				),
				e("ImageLabel",
					{
						ZIndex = 3,
						ScaleType = Enum.ScaleType.Slice,
						ImageTransparency = 0.7,
						Image = "rbxassetid://8992230677",
						BackgroundTransparency = 1,
						Size = UDim2.fromScale(1, 1),
						SliceCenter = Rect.new(99, 99, 99, 99),
						ImageColor3 = Color3.fromRGB(0, 0, 0)
					},
					{e("UICorner", {CornerRadius = UDim.new(0, 6)})}
				),
				e("Frame",
					{
						ZIndex = 3,
						Size = UDim2.new(1, 0, 0, 42),
						BackgroundTransparency = 1
					},
					{
						s.Button,
						e("Frame",
							{
								ZIndex = 3,
								Size = UDim2.new(1, -80, 1, 0),
								BackgroundTransparency = 1,
								Position = UDim2.fromOffset(10, 0)
							},
							{s.Title}
						),
						e("Frame",
							{
								ZIndex = 3,
								BackgroundColor3 = Color3.fromRGB(45, 45, 45),
								Size = UDim2.new(1, 0, 0, 1),
								Position = UDim2.fromScale(0, 1),
								BackgroundTransparency = 0.5
							}
						),
						e("TextLabel",
							{
								ZIndex = 3,
								Text = "",
								Size = UDim2.new(0, 34, 1, -8),
								Position = UDim2.new(1, -4, 0, 4),
								AnchorPoint = Vector2.new(1, 0),
								BackgroundTransparency = 1
							},
							{
								e("UICorner", {CornerRadius = UDim.new(1, 0)}),
								e("UIStroke",
									{
										ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
										Color = Color3.fromRGB(82, 255, 255),
										Thickness = 1,
										Transparency = 0.5
									}
								),
								e("ImageLabel",
									{
										ZIndex = 3,
										Image = Options.Logo or "rbxassetid://78484575433047",
										AnchorPoint = Vector2.new(0.5, 0.5),
										ImageColor3 = Color3.fromRGB(230, 230, 230),
										BackgroundTransparency = 1,
										Name = "Icon",
										Position = UDim2.fromScale(0.5, 0.5),
										Size = UDim2.new(1, -1, 1, -1),
									},
									{
										e("UICorner", {CornerRadius = UDim.new(1, 0)}),
									}
								),
								e("ImageLabel",
									{
										ZIndex = 3,
										ScaleType = Enum.ScaleType.Tile,
										ImageTransparency = 0.92,
										Image = "rbxassetid://9968344227",
										BackgroundTransparency = 1,
										Size = UDim2.fromScale(1, 1),
										TileSize = UDim2.fromOffset(128, 128)
									},
									{e("UICorner", {CornerRadius = UDim.new(0, 6)})}
								),
								e("ImageLabel",
									{
										ZIndex = 3,
										ScaleType = Enum.ScaleType.Tile,
										ImageTransparency = 0.98,
										Image = "rbxassetid://9968344105",
										BackgroundTransparency = 1,
										Size = UDim2.fromScale(1, 1),
										TileSize = UDim2.fromOffset(128, 128)
									},
									{e("UICorner", {CornerRadius = UDim.new(0, 6)})}
								),
								e("ImageLabel",
									{
										ZIndex = 3,
										ScaleType = Enum.ScaleType.Slice,
										ImageTransparency = 0.7,
										Image = "rbxassetid://8992230677",
										BackgroundTransparency = 1,
										Size = UDim2.fromScale(1, 1),
										SliceCenter = Rect.new(99, 99, 99, 99),
										ImageColor3 = Color3.fromRGB(0, 0, 0)
									},
									{e("UICorner", {CornerRadius = UDim.new(0, 6)})}
								)
							}
						)
					}
				),
				e("Frame",
					{
						ZIndex = 3,
						AutomaticSize = Enum.AutomaticSize.Y,
						Size = UDim2.fromScale(1, 1),
						Position = UDim2.fromOffset(0, 42),
						BackgroundTransparency = 1
					},
					{
						s.SubTitle, s.Content,
						e("UIPadding",
							{
								PaddingTop = UDim.new(0,6),
								PaddingLeft = UDim.new(0, 10)
							}
						),
						e("UIListLayout",
							{
								Padding = UDim.new(0, 0),
								SortOrder = Enum.SortOrder.LayoutOrder
							}
						)
					}
				)
			}
		)

		function s.Open()
			Utility.Tween(s.Holder, {Size = UDim2.new(1, 0, 0, 100)}, 0.5, true)
		end
		s.Open()
		function s.Close()
			s.Closed = true
			Utility.Tween(s.Holder, {Size = UDim2.new(0.2, 0, 0, 100)}, 0.5, true)
			s.Holder:Destroy()
		end

		if Options.Duration and type(Options.Duration) == "number" then
			task.delay(Options.Duration, s.Close)
		elseif Options.Duration and type(Options.Duration) == "function" then
			task.spawn(function()
				Library.SafeCallback(Options.Duration)
				s.Close()
			end)
		end

		Library.AddSignal(s.Button.MouseButton1Click, function()
			if Options.DisableClose or s.Closed then
				return
			end
			s.Close()
		end)

		return s
	end

	function Library:CreateWindow(Options)
		local e, t =
			Create,
			{
				TabCount = 0,
			}

		Library.Window.Root = e("Frame", {
			Parent = Library.GUI,
			BackgroundTransparency = 1,
			Size = UDim2.fromOffset(m.ViewportSize.X / 1.75, m.ViewportSize.Y / 1.5)
		})

		if Library.Window.Root.Size.X.Offset > 900 then
		   Library.Window.Root.Size = UDim2.fromOffset(900, Library.Window.Root.Size.Y.Offset)
		end

		if Library.Window.Root.Size.Y.Offset > 650 then
		   Library.Window.Root.Size = UDim2.fromOffset(Library.Window.Root.Size.X.Offset, 650)
		end

		Library.Window.Root.Position = UDim2.fromOffset(
			m.ViewportSize.X / 2 - Library.Window.Root.Size.X.Offset / 2,
			m.ViewportSize.Y / 2 - Library.Window.Root.Size.Y.Offset / 2
		)

		if Options.Hide then
			Library.Window.Root.Visible = false
		end

		Options.Ignore = Options.Ignore or {}

		function t:LoadMinimize()
			if Options.Hide then
				local tIck = tick() - Library.Start
				local secs = math.floor(tIck) % ((9e9 * 9e9) + (9e9 * 9e9))
				local mils = string.format(".%.03d", (tIck % 1) * 1000)
				Library:Notify({
					DisableClose = true,
					Title = "Successful Loaded",
					SubTitle = "Loaded Ui In "..tostring(secs..mils).."s Press "..(Options.MinimizeKey and Options.MinimizeKey.Name or Library.MinimizeKey.Name).." For Show, Hide Ui",
					Duration = function()
						repeat task.wait() until Library.Window.Root.Visible
					end
				})
			end
		end

		function t:AutoSave(value)
			Library.AutoSave.Value = value or false
		end

		function t:SaveConfigs()
			if Library.AutoSave.Value and Options.Save and writefile and isfolder and makefolder then
				local fullPath, DncodePath = Options.Save.."/Configs.json", Options.Save

				if not Library.AutoSave.IsFolder then
					local makePath = {}
					local decoded = {fullPath}

					if DncodePath:find("/") then
						decoded = DncodePath:split("/")
					end
					for idx = 1, #decoded do
						makePath[idx] = table.concat(decoded, "/", 1, idx)
					end
					for idx = 1, #makePath do
						local folder = makePath[idx]
						if not isfolder(folder) then
							   makefolder(folder)
						end
					end
					Library.AutoSave.IsFolder = true
				end

				local data = {objects = {}}

				for idx, option in next, Library.Options do
					if not Library.Parser[option.Type] then continue end
					if Library.Ignore[idx] then continue end
					if Options.Ignore[idx] then continue end

					table.insert(data.objects, Library.Parser[option.Type].Save(idx, option))
				end
				local success, encoded = pcall(game:GetService "HttpService".JSONEncode, game:GetService "HttpService", data)
				if not success then
					return
				end
				writefile(fullPath, encoded)
			end
		end

		function t:LoadConfigs()
			if Options.Save and readfile and isfile then
				local fullPath = Options.Save.."/Configs.json"

				if not isfile(fullPath) then
					return
				end

				local success, decoded = pcall(game:GetService "HttpService".JSONDecode, game:GetService "HttpService", readfile(fullPath))
				if not success then
					return
				end

				for idx, option in next, decoded.objects do
					if Library.Parser[option.type] then
						task.spawn(function()
							Library.Parser[option.type].Load(option.idx, option)
						end)
					end
				end
			end
		end

		Library.AddSignal(m:GetPropertyChangedSignal("ViewportSize"), function()
			local x, y = m.ViewportSize.X / 1.75, m.ViewportSize.Y / 1.5

			if x > 900 then
			   x = 900
			end
			if y > 650 then
			   y = 650
			end

			Library.Window.Root.Size = UDim2.fromOffset(x, y)
			Library.Window.Root.Position = UDim2.fromOffset(
				m.ViewportSize.X / 2 - Library.Window.Root.Size.X.Offset / 2,
				m.ViewportSize.Y / 2 - Library.Window.Root.Size.Y.Offset / 2
			)

			if Library.ToggleGUI then
				Library.ToggleGUI.Size = UDim2.fromOffset((x / 10) - 2, (x / 10) - 5)
			end
		end)

		t.Holder = e("Frame",
			{
				Parent = Library.Window.Root,
				Size = UDim2.fromScale(1, 1),
				Name = "Holder",
				BackgroundColor3 = Color3.fromRGB(35, 35, 35)
			},
			{
				e("UICorner",
					{
						CornerRadius = UDim.new(0, 5)
					}
				),
				e("ImageLabel",
					{
						ImageColor3 = Color3.fromRGB(0, 0, 0),
						AnchorPoint = Vector2.new(0.5, 0.5),
						ScaleType = Enum.ScaleType.Slice,
						SliceCenter = Rect.new(99, 99, 99, 99),
						ImageTransparency = 0.7,
						Image = "rbxassetid://8992230677",
						Size = UDim2.new(1, 120, 1, 120),
						BackgroundTransparency = 1,
						Position = UDim2.fromScale(0.5, 0.5)
					}
				),
				e("ImageLabel",
					{
						Size = UDim2.fromScale(1, 1),
						BackgroundTransparency = 1,
						ScaleType = Enum.ScaleType.Tile,
						TileSize = UDim2.new(0, 128, 0, 128),
						ImageTransparency = 0.98,
						Image = "rbxassetid://9968344105"
					},
					{e("UICorner", {CornerRadius = UDim.new(0, 8)})}
				),
				e("ImageLabel",
					{
						ScaleType = Enum.ScaleType.Tile,
						TileSize = UDim2.new(0, 128, 0, 128),
						Size = UDim2.fromScale(1, 1),
						BackgroundTransparency = 1,
						ImageTransparency = 0.92,
						Image = "rbxassetid://9968344227"
					},
					{e("UICorner", {CornerRadius = UDim.new(0, 8)})}
				)
			}
		)

		local ClientHolder = e("Frame",
			{
				Parent = Library.Window.Root,
				Size = UDim2.new(1, 0, 0, 42),
				BackgroundTransparency = 1
			},
			{
				e("Frame",
					{
						Size = UDim2.new(1, -6, 0, 1),
						Position = UDim2.new(0, 3, 1, 0),
						BackgroundColor3 = Color3.fromRGB(45, 45, 45),
						BackgroundTransparency = 0
					}
				),
				e("Frame",
					{
						Size = UDim2.new(1, -16, 1, 0),
						Position = UDim2.new(0, 16, 0, 0),
						BackgroundTransparency = 1
					},
					{
						e("UIListLayout",
							{
								SortOrder = Enum.SortOrder.LayoutOrder,
								Padding = UDim.new(0, 5),
								FillDirection = Enum.FillDirection.Horizontal
							}
						),
						e("TextLabel",
							{
								LayoutOrder = 1,
								AutomaticSize = Enum.AutomaticSize.XY,
								TextSize = 12,
								TextColor3 = Color3.fromRGB(82, 255, 255),
								BackgroundTransparency = 1,
								RichText = true,
								FontFace = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Bold, Enum.FontStyle.Normal),
								Text = Options.Title or "Moonless Hub - Client",
								Size = UDim2.new(0, 0, 1, 0)
							}
						),
						e("TextLabel",
							{
								LayoutOrder = 2,
								AutomaticSize = Enum.AutomaticSize.XY,
								TextSize = 12,
								TextColor3 = Color3.fromRGB(82, 255, 255),
								TextTransparency = 0.5,
								BackgroundTransparency = 1,
								RichText = true,
								FontFace = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Bold, Enum.FontStyle.Normal),
								Text = Options.SubTitle or "by @edek1004",
								Size = UDim2.new(0, 0, 1, 0)
							}
						)
					}
				),
				e("TextLabel",
					{
						BackgroundTransparency = 1,
						AnchorPoint = Vector2.new(1, 0),
						Position = UDim2.new(1, -6, 0, 6),
						Size = UDim2.new(0, 32, 1, -10),
						Text = ""
					},
					{
						e("UICorner", {CornerRadius = UDim.new(1, 0)}),
						e("UIStroke",
							{
								ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
								Color = Color3.fromRGB(82, 255, 255),
								Thickness = 1,
								Transparency = 0.5
							}
						),
						e("ImageLabel",
							{
								AnchorPoint = Vector2.new(0.5, 0.5),
								Image = Options.Logo or "rbxassetid://78484575433047",
								Size = UDim2.new(1, -1, 1, -1),
								BackgroundTransparency = 1,
								Name = "Icon",
								Position = UDim2.fromScale(0.5, 0.5),
								ImageColor3 = Color3.fromRGB(235, 235, 235)
							}
						),
						e("ImageLabel",
							{
								ScaleType = Enum.ScaleType.Tile,
								ImageTransparency = 0.92,
								Image = "rbxassetid://9968344227",
								BackgroundTransparency = 1,
								Size = UDim2.fromScale(1, 1),
								TileSize = UDim2.fromOffset(128, 128)
							},
							{e("UICorner", {CornerRadius = UDim.new(0, 6)})}
						),
						e("ImageLabel",
							{
								ScaleType = Enum.ScaleType.Tile,
								ImageTransparency = 0.98,
								Image = "rbxassetid://9968344105",
								BackgroundTransparency = 1,
								Size = UDim2.fromScale(1, 1),
								TileSize = UDim2.fromOffset(128, 128)
							},
							{e("UICorner", {CornerRadius = UDim.new(0, 6)})}
						),
						e("ImageLabel",
							{
								ScaleType = Enum.ScaleType.Slice,
								ImageTransparency = 0.7,
								Image = "rbxassetid://8992230677",
								BackgroundTransparency = 1,
								Size = UDim2.fromScale(1, 1),
								SliceCenter = Rect.new(99, 99, 99, 99),
								ImageColor3 = Color3.fromRGB(0, 0, 0)
							},
							{e("UICorner", {CornerRadius = UDim.new(0, 6)})}
						)
					}
				)
			}
		)

		local ClientMenubar = e("TextButton",
			{
				Parent = ClientHolder,
				BackgroundTransparency = 1,
				AnchorPoint = Vector2.new(1, 0),
				Position = UDim2.new(1, -40, 0, 4),
				Size = UDim2.new(0, 34, 1, -8),
				Text = ""
			},
			{
				e("UICorner", {CornerRadius = UDim.new(0, 8)}),
				e("ImageLabel",
				{
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0.5),
					Image = "rbxassetid://93156192020705",
					Size = UDim2.fromOffset(16, 16),
					Name = "Icon",
					BackgroundTransparency = 1,
					ImageColor3 = Color3.fromRGB(220, 220, 220),
				})
			}
		)

		local ClientClosebar = e("TextButton",
			{
				Parent = ClientHolder,
				BackgroundTransparency = 1,
				AnchorPoint = Vector2.new(1, 0),
				Position = UDim2.new(1, -76, 0, 4),
				Size = UDim2.new(0, 26, 1, -8),
				Text = ""
			},
			{
				e("UICorner", {CornerRadius = UDim.new(0, 8)}),
				e("ImageLabel",
				{
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0.5),
					Image = "rbxassetid://128839975867114",
					Size = UDim2.fromOffset(16, 16),
					Name = "Icon",
					BackgroundTransparency = 1,
					ImageColor3 = Color3.fromRGB(220, 220, 220),
				})
			}
		)

		local TabsFrame = e("ScrollingFrame",
			{
				ScrollingDirection = Enum.ScrollingDirection.X,
				AutomaticCanvasSize = Enum.AutomaticSize.X,
				Position = UDim2.new(0, 16, 0, 0),
				Size = UDim2.new(1, -28, 1, 0),
				ScrollBarThickness = 0,
				ScrollBarImageTransparency = 1,
				CanvasSize = UDim2.fromScale(0, 0),
				BackgroundTransparency = 1
			},
			{
				e("UIPadding",
				{
					PaddingTop = UDim.new(0, 2),
					PaddingLeft = UDim.new(0, 1)
				}),
				e("UIListLayout",
				{
					SortOrder = Enum.SortOrder.LayoutOrder,
					Padding = UDim.new(0, 6),
					FillDirection = Enum.FillDirection.Horizontal
				})
			}
		)

		e("Frame",
			{
				Parent = Library.Window.Root,
				Size = UDim2.new(1, 0, 0, 35),
				Position = UDim2.fromOffset(0, 50),
				BackgroundTransparency = 1
			},
			{
				e("Frame",
					{
						Size = UDim2.new(1, -28, 1, 0),
						Position = UDim2.new(0, 14, 0, 0),
						BackgroundTransparency = 1
					},
					{
						e("UICorner", {CornerRadius = UDim.new(0, 8)}),
						e("UIStroke", {Color = Color3.fromRGB(50, 50, 50), ApplyStrokeMode = Enum.ApplyStrokeMode.Border})
					}
				),
				TabsFrame
			}
		)

		local ContainerGroup = e("CanvasGroup",
			{
				Parent = Library.Window.Root,
				Size = UDim2.new(1, -28, 1, -105),
				BackgroundColor3 = Color3.fromRGB(45, 45, 45),
				Position = UDim2.new(0, 14, 0, 95),
				BackgroundTransparency = 0.5
			},
			{
				e("UICorner", {CornerRadius = UDim.new(0, 8)})
			}
		)

		local SearchbarInput = e("TextBox",
			{
				TextColor3 = Color3.fromRGB(200, 200, 200),
				PlaceholderColor3 = Color3.fromRGB(100, 100, 100),
				PlaceholderText = "Search ...",
				Position = UDim2.new(0, 28, 0, 0),
				Size = UDim2.new(1, -28, 1, 0),
				FontFace = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Bold, Enum.FontStyle.Normal),
				TextTruncate = Enum.TextTruncate.AtEnd,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextSize = 14,
				Text = "",
				BackgroundTransparency = 1,
				ClearTextOnFocus = false
			}
		)

		e("Frame",
			{
				Parent = ContainerGroup,
				BackgroundTransparency = 1,
				Position = UDim2.fromOffset(5, 5),
				Size = UDim2.new(1, -10, 0, 30)
			},
			{
				SearchbarInput,
				e("UICorner", {CornerRadius = UDim.new(0, 8)}),
				e("UIStroke",
					{
						Thickness = 0.75,
						Color = Color3.fromRGB(100, 100, 100),
						ApplyStrokeMode = Enum.ApplyStrokeMode.Border
					}
				),
				e("ImageLabel",
					{
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.new(0, 16, 0.5, 0),
						Size = UDim2.new(0, 16, 0, 16),
						Image = "rbxassetid://135103976674786",
						BackgroundTransparency = 1
					}
				)
			}
		)

		Library.AddSignal(SearchbarInput.Focused, function()
			SearchbarInput:CaptureFocus()
		end)

		Library.AddSignal(SearchbarInput:GetPropertyChangedSignal("Text"), function()
			if not Page[Library.SelectTab] or (Page[Library.SelectTab] and #Page[Library.SelectTab].Data <= 0) then
				return
			end
			for l,v in next, Page[Library.SelectTab].Data do
				local text = SearchbarInput.Text:lower()
				local title = v.Title():lower()

				if text == "" or title:find(text, 1, true) or title:match(text, 1, true) or title:find(text) or title:match(text) or text == title then
					v.Container.Visible = true
				else
					v.Container.Visible = false
				end
			end
		end)

		local Return1 = e("TextButton",
			{
				AnchorPoint = Vector2.new(1, 0.5),
				Text = "",
				Size = UDim2.new(0, 80, 0, 30),
				Position = UDim2.new(1, -2, 0.5, 1),
				BackgroundTransparency = 1,
				ZIndex = 5
			},
			{
				e("UICorner", {CornerRadius = UDim.new(0, 6)}),
				e("UIStroke",
					{
						ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
						Color = Color3.fromRGB(100, 100, 100)
					}
				),
				e("ImageLabel",
					{
						ZIndex = 3,
						ImageColor3 = Color3.fromRGB(200, 200, 200),
						AnchorPoint = Vector2.new(0, 0.5),
						Image = "rbxassetid://113510079889014",
						Size = UDim2.new(0, 14, 0.5, 0),
						Position = UDim2.new(0, 6, 0.5, 0),
						BackgroundTransparency = 1
					}
				),
				e("TextLabel",
					{
						ZIndex = 3,
						TextXAlignment = Enum.TextXAlignment.Left,
						TextSize = 13,
						FontFace = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Heavy, Enum.FontStyle.Normal),
						RichText = true,
						AnchorPoint = Vector2.new(0, 0.5),
						Position = UDim2.new(0, 26, 0.5, 0),
						AutomaticSize = Enum.AutomaticSize.X,
						Size = UDim2.new(0, 0, 1, 0),
						Text = "RETURN",
						BackgroundTransparency = 1,
						TextColor3 = Color3.fromRGB(200, 200, 200)
					}
				)
			}
		)

		local Keytext = e("TextLabel",
			{
				ZIndex = 3,
				AnchorPoint = Vector2.new(0.5, 0),
				AutomaticSize = Enum.AutomaticSize.X,
				TextSize = 13,
				TextColor3 = Color3.fromRGB(200, 200, 200),
				TextXAlignment = Enum.TextXAlignment.Center,
				RichText = true,
				FontFace = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Heavy, Enum.FontStyle.Normal),
				BackgroundTransparency = 1,
				TextTruncate = Enum.TextTruncate.AtEnd,
				Text = (Options.MinimizeKey and Options.MinimizeKey.Name) or Library.MinimizeKey.Name,
				Size = UDim2.fromScale(0, 1),
				Position = UDim2.fromScale(0.5, 0)
			},
			{
				e("UICorner", {CornerRadius = UDim.new(0, 6)})
			}
		)

		local Keybind = e("TextButton",
			{
				ZIndex = 3,
				AnchorPoint = Vector2.new(1, 0.5),
				Text = "",
				AutomaticSize = Enum.AutomaticSize.X,
				Size = UDim2.fromOffset(80, 30),
				Position = UDim2.new(1, -90, 0.5, 1),
				BackgroundTransparency = 1
			},
			{
				Keytext,
				e("UICorner", {CornerRadius = UDim.new(0, 6)}),
				e("UIStroke",
					{
						ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
						Color = Color3.fromRGB(100, 100, 100)
					}
				)
			}
		)

		function t.Minimize()
			Library.Window.Root.Visible = not Library.Window.Root.Visible
		end

		Library.AddSignal(Keybind.MouseButton1Click, function()
			Keytext.Text = "..."
			wait(0.2)
			local ec
			ec = k.InputBegan:Connect(function(type)
				local cp
				if type.UserInputType == Enum.UserInputType.Keyboard then
					cp = type.KeyCode.Name
				elseif type.UserInputType == Enum.UserInputType.MouseButton1 then
					cp = "MouseLeft"
				elseif type.UserInputType == Enum.UserInputType.MouseButton2 then
					cp = "MouseRight"
				end
				local en
				en = k.InputEnded:Connect(function(value)
					if value.KeyCode.Name == cp or
					(
						cp == "MouseLeft" and value.UserInputType == Enum.UserInputType.MouseButton1
						or
						cp == "MouseRight" and value.UserInputType == Enum.UserInputType.MouseButton2
					)
					then
						Keytext.Text = cp
						Library.MinimizeKey = cp
						en:Disconnect()
						ec:Disconnect()
					end
				end)
			end)
		end)
		Library.AddSignal(k.InputBegan, function(input)
			if not k:GetFocusedTextBox() then
				local ne = Keytext.Text
				if ne == "MouseLeft" or ne == "MouseRight" then
					if ne == "MouseLeft" and input.UserInputType == Enum.UserInputType.MouseButton1 or
						ne == "MouseRight" and input.UserInputType == Enum.UserInputType.MouseButton2
					then
						if Library.ToggleGUI and not Library.ToggleGUI.Visible then
							return
						end
						t:Minimize()
					end
				elseif input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode.Name == ne then
						if Library.ToggleGUI and not Library.ToggleGUI.Visible then
							return
						end
						t:Minimize()
				end
			end
		end)

		local ex = m.ViewportSize.X / 1.75

		if ex > 900 then
			ex = 900
		end

		Library.ToggleGUI = e("ImageButton",
			{
				Parent = Library.GUI,
				Image = "rbxassetid://78484575433047",
				Size = UDim2.fromOffset((ex / 10) - 2, (ex / 10) - 5),
				BackgroundTransparency = 1,
				ZIndex = 5,
				AnchorPoint = Vector2.new(0, 1),
				Position = UDim2.new(0, 6, 1, -6)
			},
			{
				e("UICorner", {CornerRadius = UDim.new(1, 0)}),
				e("UIStroke",
					{
						ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
						Color = Color3.fromRGB(82, 255, 255),
						Thickness = 2,
						Transparency = 0.45
					}
				),
				e("Frame",
					{
						BackgroundColor3 = Color3.fromRGB(22, 22, 22),
						Size = UDim2.fromScale(1, 1)
					},
					{
						e("UICorner", {CornerRadius = UDim.new(1, 0)})
					}
				)
			}
		)

		Utility.DraggingEnabled(Library.ToggleGUI)

		Library.AddSignal(Library.ToggleGUI.MouseButton1Click, t.Minimize)

		local Youtube = e("TextButton",
			{
				ZIndex = 3,
				Text = "",
				AutomaticSize = Enum.AutomaticSize.Y,
				Size = UDim2.new(1, 0, 0.45, 0),
				BackgroundTransparency = 1
			},
			{
				e("ImageLabel",
					{
						ZIndex = 3,
						Image = "rbxassetid://133428541702863",
						AnchorPoint = Vector2.new(0, 0.5),
						Position = UDim2.fromScale(0, 0.5),
						Size = UDim2.new(0.045, 0, 1, 0),
						BackgroundTransparency = 1
					},
					{e("UICorner", {CornerRadius = UDim.new(1, 0)})}
				),
				e("TextLabel",
					{
						ZIndex = 3,
						TextXAlignment = Enum.TextXAlignment.Left,
						TextSize = 14,
						FontFace = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Bold, Enum.FontStyle.Normal),
						TextColor3 = Color3.fromRGB(82, 255, 255),
						AutomaticSize = Enum.AutomaticSize.Y,
						AnchorPoint = Vector2.new(0, 0.5),
						Position = UDim2.new(0.05, 5, 0.5, 0),
						BackgroundTransparency = 1,
						TextStrokeTransparency = 0.75,
						Size = UDim2.new(1, 0, 1, 0),
						TextWrapped = true,
						Text = Options.YTLink or "https://www.youtube.com/@edek1004"
					}
				)
			}
		)

		local Discord = e("TextButton",
			{
				ZIndex = 3,
				Text = "",
				AutomaticSize = Enum.AutomaticSize.Y,
				Size = UDim2.new(1, 0, 0.45, 0),
				BackgroundTransparency = 1
			},
			{
				e("ImageLabel",
					{
						ZIndex = 3,
						Image = "rbxassetid://124174209182027",
						AnchorPoint = Vector2.new(0, 0.5),
						Position = UDim2.fromScale(0, 0.5),
						Size = UDim2.new(0.045, 0, 1, 0),
						BackgroundTransparency = 1
					},
					{e("UICorner", {CornerRadius = UDim.new(1, 0)})}
				),
				e("TextLabel",
					{
						ZIndex = 3,
						TextXAlignment = Enum.TextXAlignment.Left,
						TextSize = 14,
						FontFace = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Bold, Enum.FontStyle.Normal),
						TextColor3 = Color3.fromRGB(82, 255, 255),
						AutomaticSize = Enum.AutomaticSize.Y,
						AnchorPoint = Vector2.new(0, 0.5),
						Position = UDim2.new(0.05, 5, 0.5, 0),
						BackgroundTransparency = 1,
						TextStrokeTransparency = 0.75,
						Size = UDim2.new(1, 0, 1, 0),
						TextWrapped = true,
						Text = Options.DCLink or "https://discordapp.com/users/599152972206702593"
					}
				)
			}
		)

		local ScrollVesrion = e("ScrollingFrame",
			{
				ZIndex = 3,
				ScrollingDirection = Enum.ScrollingDirection.Y,
				BackgroundTransparency = 1,
				CanvasSize = UDim2.new(0, 0, 0, 0),
				ScrollBarImageTransparency = 1,
				AutomaticCanvasSize = Enum.AutomaticSize.Y,
				Size = UDim2.fromScale(1, 1),
				ScrollBarThickness = 1
			},
			{
				e("UICorner", {CornerRadius = UDim.new(0, 8)}),
				e("UIPadding",
					{
						PaddingTop = UDim.new(0, 6),
						PaddingLeft = UDim.new(0, 6),
						PaddingRight = UDim.new(0, 6),
						PaddingBottom = UDim.new(0, 6)
					}
				),
				e("UIListLayout",
					{
						Padding = UDim.new(0, 5),
						SortOrder = Enum.SortOrder.LayoutOrder
					}
				)
			}
		)

		local ScrollChanlog = e("ScrollingFrame",
			{
				ZIndex = 3,
				ScrollingDirection = Enum.ScrollingDirection.Y,
				BackgroundTransparency = 1,
				CanvasSize = UDim2.new(0, 0, 0, 0),
				ScrollBarImageTransparency = 1,
				AutomaticCanvasSize = Enum.AutomaticSize.Y,
				Size = UDim2.fromScale(1, 1),
				ScrollBarThickness = 1
			},
			{
				e("UICorner", {CornerRadius = UDim.new(0, 8)}),
				e("UIPadding",
					{
						PaddingTop = UDim.new(0, 6),
						PaddingLeft = UDim.new(0, 6),
						PaddingRight = UDim.new(0, 6),
						PaddingBottom = UDim.new(0, 6)
					}
				),
				e("UIListLayout",
					{
						Padding = UDim.new(0, 5),
						SortOrder = Enum.SortOrder.LayoutOrder
					}
				)
			}
		)

		local InfoFrame = e("Frame",
			{
				ZIndex = 3,
				BackgroundColor3 = Color3.fromRGB(45, 45, 45),
				Size = UDim2.fromScale(1, 0.75),
				BackgroundTransparency = 0.5
			},
			{
				e("UIListLayout",
					{
						Padding = UDim.new(0, 6),
						FillDirection = Enum.FillDirection.Horizontal,
						SortOrder = Enum.SortOrder.LayoutOrder
					}
				),
				e("UICorner", {CornerRadius = UDim.new(0, 8)}),
				e("Frame",
					{
						ZIndex = 3,
						Size = UDim2.fromScale(0.2, 1),
						BackgroundTransparency = 1
					},
					{
						ScrollVesrion,
						e("UICorner", {CornerRadius = UDim.new(0, 8)}),
						e("UIStroke",
							{
								ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
								Color = Color3.fromRGB(100, 100, 100),
								Thickness = 1
							}
						)
					}
				),
				e("Frame",
					{
						ZIndex = 3,
						Size = UDim2.new(0.8, -8, 1, 0),
						BackgroundTransparency =1
					},
					{
						ScrollChanlog,
						e("UICorner", {CornerRadius = UDim.new(0, 8)}),
						e("UIStroke",
							{
								ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
								Color = Color3.fromRGB(100, 100, 100),
								Thickness = 1
							}
						)
					}
				)
			}
		)

		local MenuFrame = e("TextButton",
			{
				ZIndex = 3,
				Parent = Library.Window.Root,
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				Visible = false,
				Text = ""
			},
			{
				e("Frame",
					{
						ZIndex = 3,
						Name = "Background",
						Size = UDim2.fromScale(1, 1),
						BackgroundColor3 = Color3.fromRGB(35, 35, 35),
						BackgroundTransparency = 0.25
					},
					{
						e("UICorner", {CornerRadius = UDim.new(0, 4)}),
					}
				),
				e("Frame",
					{
						ZIndex = 3,
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.fromScale(0.5, 0.5),
						Size = UDim2.fromScale(0.185, 0.185),
						BackgroundColor3 = Color3.fromRGB(35, 35, 35)
					},
					{
						e("UICorner", {CornerRadius = UDim.new(0, 4)}),
						e("UIPadding",
							{
								PaddingTop = UDim.new(0, 5),
								PaddingBottom = UDim.new(0, 5),
								PaddingLeft = UDim.new(0, 6),
								PaddingRight = UDim.new(0, 6)
							}
						),
						e("UIStroke",
							{
								Color = Color3.fromRGB(100, 100, 100),
								ApplyStrokeMode = Enum.ApplyStrokeMode.Border
							}
						),
						e("UIListLayout",
							{
								Padding = UDim.new(0, 6),
								SortOrder = Enum.SortOrder.LayoutOrder,
								FillDirection = Enum.FillDirection.Vertical
							}
						),
						e("Frame",
							{
								ZIndex = 3,
								BackgroundTransparency = 1,
								Size = UDim2.fromScale(1, 0.075)
							},
							{

								e("Frame",
									{
										ZIndex = 3,
										Size = UDim2.fromScale(1, 1),
										AutomaticSize = Enum.AutomaticSize.Y,
										BackgroundTransparency = 1
									},
									{
										Return1,
										Keybind,
										e("TextLabel",
											{
												ZIndex = 3,
												AnchorPoint = Vector2.new(0, 0.5),
												BackgroundTransparency = 1,
												Position = UDim2.new(0, 4, 0.5, 0),
												Size = UDim2.new(0, 30, 0, 30),
												Text = ""
											},
											{
												e("UICorner", {CornerRadius = UDim.new(1, 0)}),
												e("UIStroke",
													{
														ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
														Color = Color3.fromRGB(82, 255, 255),
														Thickness = 1,
														Transparency = 0.4
													}
												),
												e("ImageLabel",
													{
														ZIndex = 3,
														AnchorPoint = Vector2.new(0.5, 0.5),
														Image = Options.Logo or "rbxassetid://78484575433047",
														Size = UDim2.new(1, -1, 1, -1),
														BackgroundTransparency = 1,
														Name = "Icon",
														Position = UDim2.fromScale(0.5, 0.5),
														ImageColor3 = Color3.fromRGB(235, 235, 235)
													}
												),
												e("ImageLabel",
													{
														ZIndex = 3,
														ScaleType = Enum.ScaleType.Tile,
														ImageTransparency = 0.92,
														Image = "rbxassetid://9968344227",
														BackgroundTransparency = 1,
														Size = UDim2.fromScale(1, 1),
														TileSize = UDim2.fromOffset(128, 128)
													},
													{e("UICorner", {CornerRadius = UDim.new(0, 6)})}
												),
												e("ImageLabel",
													{
														ZIndex = 3,
														ScaleType = Enum.ScaleType.Tile,
														ImageTransparency = 0.98,
														Image = "rbxassetid://9968344105",
														BackgroundTransparency = 1,
														Size = UDim2.fromScale(1, 1),
														TileSize = UDim2.fromOffset(128, 128)
													},
													{e("UICorner", {CornerRadius = UDim.new(0, 6)})}
												),
												e("ImageLabel",
													{
														ZIndex = 3,
														ScaleType = Enum.ScaleType.Slice,
														ImageTransparency = 0.7,
														Image = "rbxassetid://8992230677",
														BackgroundTransparency = 1,
														Size = UDim2.fromScale(1, 1),
														SliceCenter = Rect.new(99, 99, 99, 99),
														ImageColor3 = Color3.fromRGB(0, 0, 0)
													},
													{e("UICorner", {CornerRadius = UDim.new(0, 6)})}
												)
											}
										),
										e("TextLabel",
											{
												ZIndex = 3,
												AnchorPoint = Vector2.new(0, 0.5),
												BackgroundTransparency = 1,
												Position = UDim2.new(0, 42, 0.5, 0),
												Size = UDim2.new(0, 60, 0, 30),
												Text = "Menubar",
												TextSize = 14,
												AutomaticSize = Enum.AutomaticSize.XY,
												TextXAlignment = Enum.TextXAlignment.Left,
												TextWrapped = true,
												FontFace = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Bold, Enum.FontStyle.Normal),
												TextColor3 = Color3.fromRGB(82, 255, 255),
												RichText = true,
												TextTransparency = 0.2
											}
										)
									}
								)
							}
						),
						InfoFrame,
						e("Frame",
							{
								ZIndex = 3,
								BackgroundColor3 = Color3.fromRGB(45, 45, 45),
								Size = UDim2.fromScale(1, 0.15),
								BackgroundTransparency = 0.5
							},
							{
								e("UICorner", {CornerRadius = UDim.new(0, 8)}),
								e("UIListLayout",
									{
										Padding = UDim.new(0, 0),
										SortOrder = Enum.SortOrder.LayoutOrder
									}
								),
								e("UIStroke",
									{
										ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
										Color = Color3.fromRGB(100, 100, 100),
										Thickness = 1
									}
								),
								e("UIPadding",
									{
										PaddingTop = UDim.new(0, 2),
										PaddingLeft = UDim.new(0, 10)
									}
								),
								Youtube,
								Discord
							}
						)
					}
				)
			}
		)

		task.spawn(function()
			local sx = 0
			for o,v in pairs(Options.Menuinfo or {}) do
				sx += 1
				local scrollinsert = e("ScrollingFrame",
					{
						ZIndex = 3,
						Parent = InfoFrame,
						ScrollingDirection = Enum.ScrollingDirection.Y,
						BackgroundTransparency = 1,
						CanvasSize = UDim2.new(0, 0, 0, 0),
						ScrollBarImageTransparency = 1,
						AutomaticCanvasSize = Enum.AutomaticSize.Y,
						Size = UDim2.fromScale(1, 1),
						ScrollBarThickness = 1
					},
					{
						e("UICorner", {CornerRadius = UDim.new(0, 8)}),
						e("UIPadding",
							{
								PaddingTop = UDim.new(0, 6),
								PaddingLeft = UDim.new(0, 6),
								PaddingRight = UDim.new(0, 6),
								PaddingBottom = UDim.new(0, 6)
							}
						),
						e("UIListLayout",
							{
								Padding = UDim.new(0, 5),
								SortOrder = Enum.SortOrder.LayoutOrder
							}
						)
					}
				)
				Library.Menuinfo[v.Name] = {
					Text = e("TextButton",
						{
							ZIndex = 3,
							Parent = ScrollVesrion,
							AutomaticSize = Enum.AutomaticSize.XY,
							BackgroundTransparency = 1,
							Size = UDim2.new(1, 0, 0, 10),
							Text = v.Name,
							TextWrapped = true,
							TextXAlignment = Enum.TextXAlignment.Center,
							FontFace = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Bold, Enum.FontStyle.Normal),
							TextColor3 = Color3.fromRGB(235, 235, 235),
							RichText = true,
							TextSize = 14
						},
						{
							e("UICorner", {CornerRadius = UDim.new(0, 8)}),
							e("UIStroke",
								{
									ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
									Color = Color3.fromRGB(100, 100, 100),
									Thickness = 1
								}
							)
						}
					),
					Container = e("Frame",
						{
							ZIndex = 3,
							Visible = false,
							Parent = InfoFrame,
							Size = UDim2.new(0.8, -8, 1, 0),
							BackgroundTransparency =1
						},
						{
							scrollinsert,
							e("UICorner", {CornerRadius = UDim.new(0, 8)}),
							e("UIStroke",
								{
									ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
									Color = Color3.fromRGB(100, 100, 100),
									Thickness = 1
								}
							)
						}
					)
				}

				if ScrollChanlog then
					ScrollChanlog.Parent:Destroy()
					ScrollChanlog = nil
				end
				if not Library.Info and sx >= #(Options.Menuinfo or {}) then
						Library.Info = Library.Menuinfo[v.Name]
				end
				for h = 1, #v.Content do
					e("TextLabel",
						{
							ZIndex = 3,
							Parent = scrollinsert,
							AutomaticSize = Enum.AutomaticSize.Y,
							BackgroundTransparency = 1,
							Size = UDim2.new(1, 0, 0, 18),
							Text = v.Content[h].Title,
							TextWrapped = true,
							TextXAlignment = Enum.TextXAlignment.Left,
							FontFace = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Bold, Enum.FontStyle.Normal),
							TextColor3 = Color3.fromRGB(235, 235, 235),
							RichText = true,
							TextSize = 16
						}
					)
					e("TextLabel",
						{
							ZIndex = 3,
							Parent = scrollinsert,
							AutomaticSize = Enum.AutomaticSize.Y,
							BackgroundTransparency = 1,
							Size = UDim2.new(1, 0, 0, 16),
							Text = v.Content[h].SubTitle,
							TextWrapped = true,
							TextXAlignment = Enum.TextXAlignment.Left,
							FontFace = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Bold, Enum.FontStyle.Normal),
							TextColor3 = Color3.fromRGB(175, 175, 175),
							RichText = true,
							TextSize = 14
						}
					)
				end
				Library.AddSignal(Library.Menuinfo[v.Name].Text.MouseButton1Click, function()
					for h,d in next, Library.Menuinfo do
						d.Container.Visible = false
						d.Text.TextColor3 = Color3.fromRGB(235, 235, 235)
					end
					Library.Menuinfo[v.Name].Container.Visible = true
					Library.Menuinfo[v.Name].Text.TextColor3 = Color3.fromRGB(82, 255, 255)
				end)
			end
			if Library.Info then
				Library.Info.Container.Visible = true
				Library.Info.Text.TextColor3 = Color3.fromRGB(82, 255, 255)
			end
		end)

		Library.AddSignal(Youtube.MouseButton1Click, function()
			if not setclipboard then
				return
			end
			setclipboard(Options.YTLink or "https://www.youtube.com/@edek1004")
			Library:Notify({
				Title = "Youtube",
				SubTitle = (Options.YTLink or "https://www.youtube.com/@edek1004").." Just setclipboard",
				Duration = 2.5
			})
		end)

		Library.AddSignal(Discord.MouseButton1Click, function()
			if not setclipboard then
				return
			end
			setclipboard(Options.DCLink or "https://discordapp.com/users/599152972206702593")
			Library:Notify({
				Title = "Discord",
				SubTitle = (Options.DCLink or "https://discordapp.com/users/599152972206702593").." Just setclipboard",
				Duration = 2.5
			})
		end)

		function t.Open()
			MenuFrame.Visible = true
			Utility.Tween(MenuFrame.Frame, {Size = UDim2.new(0.95, 0, 0.95, 0)}, 0.5, true)
		end

		function t.Close()
			Utility.Tween(MenuFrame.Frame, {Size = UDim2.new(0.185, 0, 0.185, 0)}, 0.5, true)
			MenuFrame.Visible = false
		end

		Library.AddSignal(ClientMenubar.MouseButton1Click, t.Open)
		Library.AddSignal(Return1.MouseButton1Click, t.Close)

		Utility.DraggingEnabled(ClientHolder, Library.Window.Root)

		function t:Dialog(Configs)
			local s = {
				Buttons = 0
			}
			s.Holder = e("Frame",
				{
					ZIndex = 3,
					Size = UDim2.new(1, -40, 1, -40),
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0.5),
					BackgroundTransparency = 1,
				},
				{
					e(
						"UIListLayout",
						{
							Padding = UDim.new(0, 10),
							FillDirection = Enum.FillDirection.Horizontal,
							HorizontalAlignment = Enum.HorizontalAlignment.Center,
						    SortOrder = Enum.SortOrder.LayoutOrder
						}
					)
				}
			)
			s.HolderFrame = e("Frame",
				{
					ZIndex = 3,
					Size = UDim2.new(1, 0, 0, 70),
					Position = UDim2.new(0, 0, 1, -70),
					BackgroundColor3 = Color3.fromRGB(35, 35, 35)
				},
				{
					s.Holder,
					e("Frame",
						{
							ZIndex = 3,
							Size = UDim2.new(1, -6, 0, 1),
							Position = UDim2.new(0, 3, 0, 0),
							BackgroundColor3 = Color3.fromRGB(82, 255, 255),
							Transparency = 0.5
						}
					)
				}
			)
			s.ContainerFrame = e("TextButton",
				{
					ZIndex = 3,
					Parent = Library.Window.Root,
					Visible = true,
					Size = UDim2.fromScale(1, 1),
					BackgroundTransparency = 1,
					Text = "",
					AutomaticSize = Enum.AutomaticSize.Y
				},
				{
					e("Frame",
						{
							ZIndex = 3,
							Name = "Background",
							Size = UDim2.fromScale(1, 1),
							BackgroundColor3 = Color3.fromRGB(35, 35, 35),
							BackgroundTransparency = 0.25
						},
						{
							e("UICorner", {CornerRadius = UDim.new(0, 4)})
						}
					),
					e("CanvasGroup",
						{
							ZIndex = 3,
							AnchorPoint = Vector2.new(0.5, 0.5),
							Position = UDim2.fromScale(0.5, 0.5),
							Size = UDim2.fromOffset(20, 20),
							AutomaticSize = Enum.AutomaticSize.Y,
							BackgroundColor3 = Color3.fromRGB(45, 45, 45),
							BackgroundTransparency = 0
						}
					)
				}
			)

			function s.Open()
				Utility.Tween(s.ContainerFrame.CanvasGroup, {Size = UDim2.fromOffset(Library.Window.Root.Size.X.Offset / 2, Library.Window.Root.Size.Y.Offset / 4)}, 0.5, true)
				e("UIScale",
					{
						Parent = s.ContainerFrame.CanvasGroup,
						Scale = 1
					}
				)
				e("UICorner",
					{
						Parent = s.ContainerFrame.CanvasGroup,
						CornerRadius = UDim.new(0, 8)
					}
				)
				e("UIStroke",
					{
						Parent = s.ContainerFrame.CanvasGroup,
						Transparency = 0.65,
						Color = Color3.fromRGB(50, 50, 50)
					}
				)
				e("Frame",
					{
						ZIndex = 3,
						Parent = s.ContainerFrame.CanvasGroup,
						AutomaticSize = Enum.AutomaticSize.Y,
						Size = UDim2.fromScale(1, 0),
						BackgroundTransparency = 1
					},
					{
						e("UIPadding",
							{
								PaddingBottom = UDim.new(0, 80),
								PaddingLeft = UDim.new(0, 20),
								PaddingTop = UDim.new(0, 10)
							}
						),
						e("UIListLayout",
							{
								SortOrder = Enum.SortOrder.LayoutOrder,
								Padding = UDim.new(0, 6),
								FillDirection = Enum.FillDirection.Vertical
							}
						),
						e("TextLabel",
							{
								ZIndex = 3,
								Parent = s.ContainerFrame.CanvasGroup,
								TextXAlignment = Enum.TextXAlignment.Left,
								AutomaticSize = Enum.AutomaticSize.Y,
								Size = UDim2.new(1, -25, 0, 0),
								BackgroundTransparency = 1,
								TextWrapped = true,
								TextSize = 22,
								FontFace = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Bold, Enum.FontStyle.Normal),
								TextColor3 = Color3.fromRGB(235, 235, 235),
								RichText = true,
								Text = Configs.Title or "",
							}
						),
						e("TextLabel",
							{
								ZIndex = 3,
								Parent = s.ContainerFrame.CanvasGroup,
								TextXAlignment = Enum.TextXAlignment.Left,
								AutomaticSize = Enum.AutomaticSize.Y,
								Size = UDim2.new(1, -25, 0, 0),
								BackgroundTransparency = 1,
								TextWrapped = true,
								TextSize = 18,
								FontFace = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Bold, Enum.FontStyle.Normal),
								TextColor3 = Color3.fromRGB(155, 155, 155),
								RichText = true,
								Text = Configs.SubTitle or "",
							}
						),
						s.HolderFrame
					}
				)
				s.HolderFrame.Parent = s.ContainerFrame.CanvasGroup
			end

			function s.Close()
				Utility.Tween(s.ContainerFrame.CanvasGroup, {Size = UDim2.fromOffset(s.ContainerFrame.CanvasGroup.Size.X.Offset / 2, s.ContainerFrame.CanvasGroup.Size.Y.Offset / 2)}, 0.5, true)
				s.ContainerFrame:Destroy()
			end
			s.Open()
			function s.Button(title, callback)
				s.Buttons += 1
				title = title or "Button"
				callback = callback or function ()
					end
				local C = e("TextButton",
					{
						ZIndex = 3,
						Parent = s.Holder,
						BackgroundColor3 = Color3.fromRGB(45, 45, 45),
						Size = UDim2.new(0.5, -5, 0, 32),
						Text = ""
					},
					{
						e("UICorner", {CornerRadius = UDim.new(0, 4)}),
						e("UIStroke",
							{
								Color = Color3.fromRGB(50, 50, 50),
								ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
								Transparency = 0,
								Thickness = 1
							}
						),
						e("TextLabel",
							{
								ZIndex = 3,
								AutomaticSize = Enum.AutomaticSize.Y,
								Size = UDim2.fromScale(1, 1),
								BackgroundTransparency = 1,
								TextWrapped = true,
								TextSize = 14,
								FontFace = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Bold, Enum.FontStyle.Normal),
								TextColor3 = Color3.fromRGB(235, 235, 235),
								RichText = true,
								Text = title
							}
						)
					}
				)
				for o,v in next ,s.Holder:GetChildren() do
                    if v:IsA "TextButton" then
                        v.Size = UDim2.new(1 / s.Buttons, -(((s.Buttons - 1) * 10) / s.Buttons), 0, 32)
                    end
				end
				Library.AddSignal(C.MouseButton1Click, function()
					s.Close()
					Library.SafeCallback(callback)
				end)
				return C
			end
			for o,v in next, Configs.Buttons or {} do
				s.Button(v.Title, v.Callback)
			end
			return s
		end

		Library.AddSignal(ClientClosebar.MouseButton1Click, function()
			t:Dialog({
				Title = "Close",
				SubTitle = "Are you sure ypu want to unload the interface?",
				Buttons = {
					{Title = "Yes", Callback = function()
						Library:Destroy()
					end},
					{Title = "No"}
				}
			})
		end)

		function t:AddTab(Title)
			local c, h = {Page = {}},
						 {}

			t.TabCount += 1
			h.Tab = t.TabCount

			Page[h.Tab] = {
				Container = nil, Data = {}, Page = {
					[1] = {count = nil, container = nil},
					[2] = {count = nil, container = nil}
				}
			}

			c.Tab = e("TextButton",
				{
					Parent = TabsFrame,
					TextWrapped = true,
					RichText = true,
					TextTransparency = 1,
					BackgroundColor3 = Color3.fromRGB(100, 100 ,100),
					AutomaticSize = Enum.AutomaticSize.X,
					TextSize = 20,
					Size = UDim2.new(0, 0, 1, -2),
					Text = Title and Title or "Tabs "..tostring(h.Tab),
					BackgroundTransparency = 1
				},
				{
					e("UICorner", {CornerRadius = UDim.new(0, 6)}),
					e("UIStroke",
						{
							Color = Color3.fromRGB(100, 100 ,100),
							ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
							Transparency = 0.5
						}
					),
					e("TextLabel",
						{
							TextWrapped = true,
							TextSize = 14,
							FontFace = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Bold, Enum.FontStyle.Normal),
							TextColor3 = Color3.fromRGB(235, 235, 235),
							BackgroundTransparency = 1,
							RichText = true,
							Size = UDim2.fromScale(1, 1),
							Text = Title and Title or "Tabs "..tostring(h.Tab),
						}
					)
				}
			)

			c.TabFrame = e("Frame",
				{
					Parent = c.Tab,
					AnchorPoint = Vector2.new(0, 0.5),
					Position = UDim2.new(0, 4, 1, -3),
					BackgroundColor3 = Color3.fromRGB(82 ,255, 255),
					BackgroundTransparency = 1,
					Size = UDim2.new(0, 0, 0, 1)
				},
				{
					e("UICorner", {CornerRadius = UDim.new(0, 6)})
				}
			)

			Library.AddSignal(c.Tab.MouseButton1Click, function()
				t:SelectTab(h.Tab)
			end)

			c.ContainerFrame = e("Frame",
				{
					Parent = ContainerGroup,
					Position = UDim2.new(0, 5, 0, 40),
					Visible = false,
					Size = UDim2.new(1, -10, 1, -40),
					BackgroundTransparency = 1
				},
				{
					e("UIListLayout",
						{
							SortOrder = Enum.SortOrder.LayoutOrder,
							Padding = UDim.new(0, 5),
							FillDirection = Enum.FillDirection.Horizontal
						}
					)
				}
			)

			c.Page[1] = e("ScrollingFrame",
				{
					Parent = c.ContainerFrame,
					ScrollingDirection = Enum.ScrollingDirection.Y,
					AutomaticCanvasSize = Enum.AutomaticSize.Y,
					Size = UDim2.fromScale(0.5, 1),
					CanvasSize = UDim2.new(0, 0, 0, 0),
					ScrollBarImageTransparency = 1,
					ScrollBarThickness = 0,
					BackgroundTransparency = 1
				},
				{
					e("UIPadding",
						{
							PaddingBottom = UDim.new(0, 6)
						}
					),
					e("Frame",
						{
							Size = UDim2.new(1, 0, 0, 0),
							Visible = false,
							AutomaticSize = Enum.AutomaticSize.Y,
							BackgroundColor3 = Color3.fromRGB(25, 25, 25)
						},
						{
							e("UICorner"),
							e("UIPadding",
								{
									PaddingTop = UDim.new(0, 5),
									PaddingBottom = UDim.new(0, 6),
									PaddingLeft = UDim.new(0, 5),
									PaddingRight = UDim.new(0, 2)
								}
							),
							e("UIListLayout",
								{
									Padding = UDim.new(0, 5),
									SortOrder = Enum.SortOrder.LayoutOrder,
									FillDirection = Enum.FillDirection.Vertical
								}
							)
						}
					)
				}
			)

			c.Page[2] = e("ScrollingFrame",
				{
					Parent = c.ContainerFrame,
					ScrollingDirection = Enum.ScrollingDirection.Y,
					AutomaticCanvasSize = Enum.AutomaticSize.Y,
					Size = UDim2.fromScale(0.5, 1),
					CanvasSize = UDim2.new(0, 0, 0, 0),
					ScrollBarImageTransparency = 1,
					ScrollBarThickness = 0,
					BackgroundTransparency = 1
				},
				{
					e("UIPadding",
						{
							PaddingBottom = UDim.new(0, 6)
						}
					),
					e("Frame",
						{
							Size = UDim2.new(1, 0, 0, 0),
							Visible = false,
							AutomaticSize = Enum.AutomaticSize.Y,
							BackgroundColor3 = Color3.fromRGB(25, 25, 25)
						},
						{
							e("UICorner"),
							e("UIPadding",
								{
									PaddingTop = UDim.new(0, 5),
									PaddingBottom = UDim.new(0, 6),
									PaddingLeft = UDim.new(0, 5),
									PaddingRight = UDim.new(0, 2)
								}
							),
							e("UIListLayout",
								{
									Padding = UDim.new(0, 5),
									SortOrder = Enum.SortOrder.LayoutOrder,
									FillDirection = Enum.FillDirection.Vertical
								}
							)
						}
					)
				}
			)

			setmetatable(Page[h.Tab].Page[1], {
				__newindex = function(a, b, x)
					if b == "count" and x > 0 and not c.Page[1].Frame.Visible then
						c.Page[1].Frame.Visible = true
					end
				end
			})
			setmetatable(Page[h.Tab].Page[2], {
				__newindex = function(a, b, x)
					if b == "count" and x > 0 and not c.Page[2].Frame.Visible then
						c.Page[2].Frame.Visible = true
					end
				end
			})

			Page[h.Tab].Page[1].count = 0
			Page[h.Tab].Page[2].count = 0

			Page[h.Tab].Container = c.ContainerFrame

			Page[h.Tab].Point = c.TabFrame
			Page[h.Tab].TabFrame = c.Tab

			Page[h.Tab].Page[1].container = c.Page[1].Frame
			Page[h.Tab].Page[2].container = c.Page[2].Frame

			function h:AddButton(l)
				local s = {
					Title = l.Title or ""
				}

				l.Page = l.Page and l.Page or 1
				l.Page = (l.Page > 3 or l.Page == 0) and 1 or l.Page

				l.currentPage = Page[h.Tab].Page[l.Page]
				l.currentPage.count = l.currentPage.count and l.currentPage + 1 or 1

				local Locked = false

				local Frame = e("Frame",
					{
						Size = UDim2.new(1, 0, 0, 28),
						BackgroundColor3 = Color3.fromRGB(82, 255, 255),
						AutomaticSize = Enum.AutomaticSize.Y
					},
					{
						e("UIPadding",
							{
								PaddingBottom = UDim.new(0, 6),
								PaddingTop = UDim.new(0, 6)
							}
						),
						e("UICorner", {CornerRadius = UDim.new(0, 4)}),
						e("TextLabel",
							{
								TextSize = 15,
								FontFace = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Bold, Enum.FontStyle.Normal),
								TextColor3 = Color3.fromRGB(235, 235, 235),
								RichText = true,
								Size = UDim2.new(1, -10, 0, 1),
								Position = UDim2.fromOffset(5, 0),
								BackgroundTransparency = 1,
								Text = l.Title or "",
								TextWrapped = true,
								AutomaticSize = Enum.AutomaticSize.Y
							}
						)
					}
				)

				s.Frame = e("TextButton",
					{
						Parent = c.Page[l.Page].Frame,
						TextSize = 15,
						BackgroundTransparency = 1,
						AutomaticSize = Enum.AutomaticSize.Y,
						Size = UDim2.new(1, -4, 0, 28),
						Text = ""
					},
					{
						e("UICorner", {CornerRadius = UDim.new(0, 4)}),
						e("UIStroke",
							{
								ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
								Color = Color3.fromRGB(25, 25, 25)
							}
						),
						Frame
					}
				)

				table.insert(Page[h.Tab].Data, {Container = s.Frame, Title = function()
					return s.Title
				end})

				function s:SetTitle(text)
					s.Title = tostring(text)
					Frame.TextLabel.Text = tostring(text)
				end

				Library.AddSignal(s.Frame.MouseButton1Click, function()
					if Locked then
						return
					end
					Library.SafeCallback(l.Callback)
				end)

				local LockLabel = e("ImageLabel",
					{
						ZIndex = 2,
						Parent = s.Frame,
						Visible = false,
						BackgroundColor3 = Color3.fromRGB(0, 0, 0),
						BackgroundTransparency = 1,
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.fromScale(0.5, 0.5),
						Size = UDim2.fromScale(0, 0),
						ScaleType = Enum.ScaleType.Fit,
						Image = "rbxassetid://115887800941692"
					},
					{
						e("UICorner", {CornerRadius = UDim.new(0, 4)})
					}
				)

				local LockButton = e("TextButton",
					{
						ZIndex = 2,
						BackgroundTransparency = 1,
						Size = UDim2.fromScale(1, 1),
						Parent = s.Frame,
						Visible = false,
						Text = ""
					}
				)

				function s:LockState()
					return Locked
				end

				function s:Lock()
					Locked = true
					LockButton.Visible = true
					LockLabel.Visible = true
					Utility.Tween(LockLabel, {BackgroundTransparency = 0.75, Size = UDim2.fromScale(1, 1)}, 0.35, true)
				end

				function s:Unlock()
					Locked = false
					LockButton.Visible = false
					Utility.Tween(LockLabel, {BackgroundTransparency = 1, Size = UDim2.fromScale(0, 0)}, 0.35, true)
					LockLabel.Visible = false
				end

				return s
			end

			function h:AddParagraph(l)
				local s = {
					Title = l.Title or "",
					SubTiltle = l.Description
				}

				l.Page = l.Page and l.Page or 1
				l.Page = (l.Page > 3 or l.Page == 0) and 1 or l.Page

				l.currentPage = Page[h.Tab].Page[l.Page]
				l.currentPage.count = l.currentPage.count and l.currentPage + 1 or 1

				local Locked = false

				local Text = e("TextLabel",
					{
						LayoutOrder = 1,
						TextWrapped = true,
						TextXAlignment =  Enum.TextXAlignment.Left,
						TextSize = 15,
						FontFace = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Bold, Enum.FontStyle.Normal),
						TextColor3 = Color3.fromRGB(82, 255, 255),
						Text = s.Title or "",
						RichText = true,
						AutomaticSize = Enum.AutomaticSize.Y,
						Size = UDim2.new(1, 0, 0, 0),
						BackgroundTransparency = 1,
						Visible = s.Title and true or false
					}
				)

				local SubText = e("TextLabel",
					{
						LayoutOrder = 2,
						TextWrapped = true,
						TextXAlignment =  Enum.TextXAlignment.Left,
						TextSize = 14,
						FontFace = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Bold, Enum.FontStyle.Normal),
						TextColor3 = Color3.fromRGB(115, 115, 115),
						Text = s.SubTiltle or "",
						RichText = true,
						AutomaticSize = Enum.AutomaticSize.Y,
						Size = UDim2.new(1, 0, 0, 0),
						BackgroundTransparency = 1,
						Visible = s.SubTiltle and true or false
					}
				)

				s.Frame = e("TextButton",
					{
						Parent = c.Page[l.Page].Frame,
						Text = s.Title,
						TextTransparency = 1,
						TextSize = 17,
						AutomaticSize = Enum.AutomaticSize.Y,
						Size = UDim2.new(1, -4, 0, 0),
						BackgroundTransparency = 1,
						TextWrapped = true
					},
					{
						e("Frame",
							{
								BackgroundColor3 = Color3.fromRGB(45, 45, 45),
								Size = UDim2.fromScale(1, 1),
								AutomaticSize = Enum.AutomaticSize.Y,
								BackgroundTransparency = l.Background and 0 or 1
							},
							{
								e("UICorner", {CornerRadius = UDim.new(0, 6)}),
								e("UIStroke",
									{
										ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
										Thickness = 1,
										Color = Color3.fromRGB(25, 25, 25)
									}
								),
								e("UIPadding",
									{
										PaddingTop = UDim.new(0, 10),
										PaddingBottom = UDim.new(0, 10),
										PaddingLeft = UDim.new(0, 4)
									}
								),
								e("UIListLayout",
									{
										Padding = UDim.new(0, 2),
										SortOrder = Enum.SortOrder.LayoutOrder,
										FillDirection = Enum.FillDirection.Vertical
									}
								),
								Text,
								SubText
							}
						)
					}
				)

				table.insert(Page[h.Tab].Data, {Container = s.Frame, Title = function()
					return s.Title
				end})

				function s:SetTitle(text)
					     s.Title = tostring(text)
					     Text.Text = tostring(text)
				end
				function s:SetSubTitle(text)
					     s.SubTiltle = SubText
					     SubText.Text = tostring(text)

					     SubText.Visible = s.SubTiltle.Text:len() > 0 and true or false
		   		end

				local LockLabel = e("ImageLabel",
				    {
					   ZIndex = 2,
					   Parent = s.Frame,
					   Visible = false,
					   BackgroundColor3 = Color3.fromRGB(0, 0, 0),
					   BackgroundTransparency = 1,
					   AnchorPoint = Vector2.new(0.5, 0.5),
					   Position = UDim2.fromScale(0.5, 0.5),
					   Size = UDim2.fromScale(0, 0),
					   ScaleType = Enum.ScaleType.Fit,
					   Image = "rbxassetid://115887800941692"
				    },
				    {
					   e("UICorner", {CornerRadius = UDim.new(0, 4)})
				    }
			    )

			    local LockButton = e("TextButton",
				    {
					   ZIndex = 2,
					   BackgroundTransparency = 1,
					   Size = UDim2.fromScale(1, 1),
					   Parent = s.Frame,
					   Visible = false,
					   Text = ""
				    }
			    )

				function s:LockState()
					return Locked
				end

				function s:Lock()
					Locked = true
					LockButton.Visible = true
					LockLabel.Visible = true
					Utility.Tween(LockLabel, {BackgroundTransparency = 0.75, Size = UDim2.fromScale(1, 1)}, 0.35, true)
				end

				function s:Unlock()
					Locked = false
					LockButton.Visible = false
					Utility.Tween(LockLabel, {BackgroundTransparency = 1, Size = UDim2.fromScale(0, 0)}, 0.35, true)
					LockLabel.Visible = false
				end

				return s
			end

			function h:AddSlider(n, l)
				local d = Utility.MakeTextButton(l)
				local s = {
					Name = n,
					Frame = d.Frame,
					Value = l.Default or 0,
					Min = l.Min or 0,
					Max = l.Max or 10,
					Rounding = l.Rounding or 0,
					Type = "Slider"
				}

				local changedD

				local drag = false

				l.Page = l.Page and l.Page or 1
				l.Page = (l.Page > 3 or l.Page == 0) and 1 or l.Page

				l.currentPage = Page[h.Tab].Page[l.Page]
				l.currentPage.count = l.currentPage.count and l.currentPage + 1 or 1

				d.Frame.Parent = c.Page[l.Page].Frame

				d.TitleContent.Size = UDim2.new(1, -150, 0, 14)
				d.SubTiltleContent.Size = UDim2.new(1, -150, 0, 14)

				s.LockState = d.LockState
				s.Lock = d.Lock
				s.Unlock = d.Unlock

				table.insert(Page[h.Tab].Data, {Container = d.Frame, Title = function()
					return d.Title
				end})

				local SliderLine = e("Frame",
					{
						Parent = d.Frame,
						BackgroundColor3 = Color3.fromRGB(200, 200, 200),
						AnchorPoint = Vector2.new(1, 0.5),
						Size = UDim2.fromOffset(105, 4),
						Position = UDim2.new(1, -38, 0.5, -1)
					},
					{
						e("UICorner", {CornerRadius = UDim.new(1, 0)}),
						e("Frame",
							{
								Name = "Point",
								BackgroundColor3 = Color3.fromRGB(82, 255, 255),
								Size = UDim2.new(0, 0, 1, 0)
							},
							{
								e("UICorner", {CornerRadius = UDim.new(1, 0)})
							}
						),
						e("Frame",
							{
								Size = UDim2.new(1, -8, 1, 0),
								Position = UDim2.new(0, 4, 0, 0),
								BackgroundTransparency = 1
							},
							{
								e("ImageLabel",
									{
										AnchorPoint = Vector2.new(0, 0.5),
										ImageColor3 = Color3.fromRGB(82, 255, 255),
										Size = UDim2.fromOffset(8, 8),
										Position = UDim2.new(0, -4, 0.5, 0),
										Image = "rbxassetid://12266946128",
										BackgroundTransparency = 1
									}
								),
								e("TextLabel",
									{
										AnchorPoint = Vector2.new(0, 0.5),
										Position = UDim2.new(0, -4, 0.5, 0),
										BackgroundTransparency = 1,
										TextXAlignment = Enum.TextXAlignment.Left,
										TextSize = 13,
										FontFace = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Bold, Enum.FontStyle.Normal),
										RichText = true,
										TextColor3 = Color3.fromRGB(200, 200, 200),
										Size = UDim2.new(0, 20, 0, 20),
										Text = tostring(s.Value),
										AutomaticSize = Enum.AutomaticSize.X
									}
								)
							}
						)
					}
				)

				local SliderInput = e("Frame",
					{
						Parent = d.Frame,
						AnchorPoint = Vector2.new(1, 0.5),
						Size = UDim2.new(0, 20, 0, 20),
						Position = UDim2.new(1, -10, 0.5, 0),
						BackgroundTransparency = 1
					},
					{
						e("UICorner", {CornerRadius = UDim.new(0, 4)}),
						e("UIStroke",
							{
								Color = Color3.fromRGB(100, 100, 100)
							}
						),
						e("TextBox",
							{
								Text = s.Value,
								TextColor3 = Color3.fromRGB(200, 200, 200),
								PlaceholderColor3 = Color3.fromRGB(100, 100, 100),
								TextTruncate = Enum.TextTruncate.AtEnd,
								TextSize = 12,
								FontFace = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Bold, Enum.FontStyle.Normal),
								RichText = true,
								Position = UDim2.fromOffset(0, 0),
								PlaceholderText = "0",
								Size = UDim2.new(1, 0, 1, 0),
								BackgroundTransparency = 1
							}
						)
					}
				)

				Library.AddSignal(SliderInput.TextBox.Focused, function()
					SliderInput.TextBox:CaptureFocus()
				end)

				Library.AddSignal(SliderInput.TextBox.FocusLost, function()
					if SliderInput.TextBox.Text:find(".") and s.Rounding == 0 then
					   SliderInput.TextBox.Text = SliderInput.TextBox.Text:split(".")[1]
					end
					s:SetValue(SliderInput.TextBox.Text)
				end)

				Library.AddSignal(SliderLine.Frame.ImageLabel.InputBegan, function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						drag = true
					end
				end)

				Library.AddSignal(SliderLine.Frame.ImageLabel.InputEnded, function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						drag = false
					end
				end)

				Library.AddSignal(k.InputChanged, function(input)
					if drag and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
						local value = math.clamp((input.Position.X - SliderLine.Frame.AbsolutePosition.X) / SliderLine.Frame.AbsoluteSize.X, 0, 1)
						s:SetValue(s.Min + ((s.Max - s.Min) * value))
					end
				end)

				function s:SetValue(value)
					if s:LockState() then
						SliderInput.TextBox.Text = s.Value
						return
					end
					if (not tonumber(value)) and value:len() > 0 then
						value = s.Value
					else
						if value == "" then
						   value = 0
						end
						s.Value = Utility.Round(math.clamp(value, s.Min, s.Max), s.Rounding)
						SliderLine.Frame.ImageLabel.Position = UDim2.new((s.Value - s.Min) / (s.Max - s.Min), -4, 0.5, 0)
						SliderLine.Point.Size = UDim2.fromScale((s.Value - s.Min) / (s.Max - s.Min), 1)
						SliderLine.Frame.TextLabel.Position = UDim2.new((s.Value - s.Min) / (s.Max - s.Min), -4, 0.5, -12)

						SliderInput.TextBox.Text = s.Value
						SliderLine.Frame.TextLabel.Text = tostring(s.Value)
					end
					Library.SafeCallback(changedD, s.Value)
					Library.SafeCallback(l.Callback, s.Value)
					if Library.AutoSave.Value then
						t:SaveConfigs()
					end
				end

				function s:OnChanged(changed)
					changedD = changed
					changed(s.Value)
				end

				function s:SetTitle(text)
					     d:SetTitle(text)
						 s:SetValue(s.Value)
				end

				function s:SetSubTitle(text)
					     d:SetSubTitle(text)
				end

				s:SetValue(s.Value)
				Library.AddConfigs(n, s)
				return s
			end

			function h:AddTextBox(n, l)
				local d = Utility.MakeTextButton(l)
				local s = {
					Name = n,
					Frame = d.Frame,
					Numeric = l.Numeric or false,
					Finished = l.Finished or false,
					Type = "TextBox",
					Value = l.Default or ""
				}

				local changedD

				l.Page = l.Page and l.Page or 1
				l.Page = (l.Page > 3 or l.Page == 0) and 1 or l.Page

				l.currentPage = Page[h.Tab].Page[l.Page]
				l.currentPage.count = l.currentPage.count and l.currentPage + 1 or 1

				d.Frame.Parent = c.Page[l.Page].Frame

				d.TitleContent.Size = UDim2.new(1, -150, 0, 14)
				d.SubTiltleContent.Size = UDim2.new(1, -150, 0, 14)

				s.LockState = d.LockState
				s.Lock = d.Lock
				s.Unlock = d.Unlock

				table.insert(Page[h.Tab].Data, {Container = d.Frame, Title = function()
					return d.Title
				end})

				local Input = e("TextBox",
					{
						TextColor3 = Color3.fromRGB(200, 200, 200),
						PlaceholderColor3 = Color3.fromRGB(100, 100, 100),
						TextTruncate = Enum.TextTruncate.AtEnd,
						TextSize = 14,
						FontFace = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Bold, Enum.FontStyle.Normal),
						RichText = true,
						PlaceholderText = l.Placeholder or "",
						Size = UDim2.fromScale(1, 1),
						Text = s.Value,
						TextXAlignment = Enum.TextXAlignment.Center,
						ClearTextOnFocus = l.Clear or false,
						BackgroundTransparency = 1
					}
				)

				e("Frame",
					{
						Parent = d.Frame,
						AnchorPoint = Vector2.new(1, 0.5),
						Size = UDim2.new(0, 135, 0, 24),
						Position = UDim2.new(1, -10, 0.5, 0),
						BackgroundTransparency = 1
					},
					{
						e("UICorner", {CornerRadius = UDim.new(0, 6)}),
						e("UIStroke",
							{
								ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
								Color = Color3.fromRGB(100, 100, 100)
							}
						),
						e("Frame",
							{
								Size = UDim2.new(1, -10, 1, 0),
								Position = UDim2.fromOffset(5, 0),
								BackgroundTransparency = 1
							},
							{Input}
						)
					}
				)

				Library.AddSignal(Input.Focused, function()
					Input:CaptureFocus()
				end)

				function s:SetValue(value)
					if s:LockState() then
						Input.Text = s.Value
						return
					end
					if s.Numeric then
						if (not tonumber(value)) and value:len() > 0 then
							value = s.Value
						end
					end
					s.Value = value
					Input.Text = value
					Library.SafeCallback(changedD, s.Value)
					Library.SafeCallback(l.Callback, s.Value)
					if Library.AutoSave.Value then
						t:SaveConfigs()
					end
				end

				function s:OnChanged(changed)
					changedD = changed
					changed(s.Value)
				end

				if s.Finished then
					Library.AddSignal(Input.FocusLost, function()
						s:SetValue(Input.Text)
					end)
				else
					Library.AddSignal(Input:GetPropertyChangedSignal("Text"), function()
						s:SetValue(Input.Text)
					end)
				end

				function s:SetTitle(text)
					     d:SetTitle(text)
				end

				function s:SetSubTitle(text)
					     d:SetSubTitle(text)
				end

				s:SetValue(s.Value)
				Library.AddConfigs(n, s)
				return s
			end

			function h:AddToggle(n, l)
				local d = Utility.MakeTextButton(l)
				local s = {
					Name = n,
					Frame = d.Frame,
					Value = l.Default or false,
					Type = "Toggle"
				}

                local changedD

				l.Page = l.Page and l.Page or 1
				l.Page = (l.Page > 3 or l.Page == 0) and 1 or l.Page

				l.currentPage = Page[h.Tab].Page[l.Page]
				l.currentPage.count = l.currentPage.count and l.currentPage + 1 or 1

				d.Frame.Parent = c.Page[l.Page].Frame

				s.LockState = d.LockState
				s.Lock = d.Lock
				s.Unlock = d.Unlock

				table.insert(Page[h.Tab].Data, {Container = d.Frame, Title = function()
					return d.Title
				end})

				local Toggle = e("Frame",
					{
						Parent = d.Frame,
						BackgroundColor3 = Color3.fromRGB(82, 255 ,255),
						AnchorPoint = Vector2.new(1, 0.5),
						Size = UDim2.new(0, 20, 0, 20),
						Position = UDim2.new(1, -10, 0.5, 0),
						BackgroundTransparency = 1
					},
					{
						e("UICorner", {CornerRadius = UDim.new(0, 4)}),
						e("UIStroke",
							{
								ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
								Transparency = 1,
								Color = Color3.fromRGB(100, 100, 100)
							}
						),
						e("ImageLabel",
							{
								Size = UDim2.new(1, -10, 1, -10),
								Position = UDim2.new(0, 5, 0, 5),
								BackgroundTransparency = 1,
								Image = "rbxassetid://132585292193326",
								ImageColor3 = Color3.fromRGB(35, 35, 35)
							},
							{
								e("UICorner", {CornerRadius = UDim.new(0, 4)})
							}
						)
					}
				)

				Library.AddSignal(d.Frame.MouseButton1Click, function()
					if s:LockState() then
						return
					end
					s:SetValue(not s.Value)
				end)

				function s:SetValue(value)
					if s:LockState() then
						return
					end
					value = not (not value)
					s.Value = value

					Toggle.BackgroundTransparency = value and 0 or 1
					Toggle.UIStroke.Transparency = value and 1 or 0
					Toggle.ImageLabel.Visible = value and true or false
					Library.SafeCallback(changedD, s.Value)
					Library.SafeCallback(l.Callback, s.Value)
					if Library.AutoSave.Value then
						t:SaveConfigs()
					end
				end

				function s:OnChanged(changed)
					changedD = changed
					changed(s.Value)
				end


				function s:SetTitle(text)
						 d:SetTitle(text)
				end

				function s:SetSubTitle(text)
						 d:SetSubTitle(text)
				end

				s:SetValue(s.Value)
				Library.AddConfigs(n, s)
				return s
			end

			function h:AddDropdown(n, l)
				local d = Utility.MakeTextButton(l)
				local s = {
					Name = n,
					List = l.List,
					Frame = d.Frame,
					Multi = l.Multi,
					Value = l.Multi and {} or nil,
					MultiValue = {},
					Default = l.Default or nil,
					Type = "Dropdown"
				}

				local Locked = false
				local changedD

				if l.Multi and type(s.Value) ~= "table" then
					s.Value = {}
				end

				if l.Multi and (not s.Default or type(s.Default) ~= "table") then
					s.Default = {}
				end

				l.Page = l.Page and l.Page or 1
				l.Page = (l.Page > 3 or l.Page == 0) and 1 or l.Page

				l.currentPage = Page[h.Tab].Page[l.Page]
				l.currentPage.count = l.currentPage.count and l.currentPage + 1 or 1

				d.Frame.Parent = c.Page[l.Page].Frame

				d.TitleContent.Size = UDim2.new(1, -150, 0, 14)
				d.SubTiltleContent.Size = UDim2.new(1, -150, 0, 14)

				if s.Multi and s.Default and type(s.Default) ~= "table" then
					s.Default = {}
				end

				table.insert(Page[h.Tab].Data, {Container = d.Frame, Title = function()
					return d.Title
				end})

				function s:LockState()
					return Locked
				end

				local Text = e("TextLabel",
					{
						TextTruncate = Enum.TextTruncate.AtEnd,
						TextXAlignment = Enum.TextXAlignment.Center,
						TextSize = 14,
						RichText = true,
						FontFace = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Bold, Enum.FontStyle.Normal),
						TextColor3 = Color3.fromRGB(100, 100, 100),
						AnchorPoint = Vector2.new(0, 0.5),
						Size = UDim2.new(1, -36, 0, 16),
						Position = UDim2.new(0, 16, 0.5, 0),
						Text = l.Placeholder or "N/A",
						BackgroundTransparency = 1
					}
				)

				local Button = e("TextButton",
					{
						BackgroundTransparency = 1,
						Text = "",
						TextTransparency = 1,
						Size = UDim2.fromScale(1, 1)
					},
					{
						Text,
						e("ImageLabel",
							{
								AnchorPoint = Vector2.new(1, 0.5),
								ImageColor3 = Color3.fromRGB(100, 100, 100),
								BackgroundTransparency = 1,
								Size = UDim2.fromOffset(16, 16),
								Position = UDim2.new(1, -8, 0.5, 0),
								Image = "rbxassetid://10709790948"
							},
							{
								e("UICorner", {CornerRadius = UDim.new(0, 4)})
							}
						)
					}
				)

				e("Frame",
					{
						Parent = d.Frame,
						AnchorPoint = Vector2.new(1, 0.5),
						Size = UDim2.new(0, 135, 0, 24),
						Position = UDim2.new(1, -10, 0.5, 0),
						BackgroundTransparency = 1
					},
					{
						e("UICorner", {CornerRadius = UDim.new(0, 6)}),
						e("UIStroke",
							{
								ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
								Color = Color3.fromRGB(100, 100, 100)
							}
						),
						Button
					}
				)

				local Return = e("TextButton",
					{
						Text = "",
						Size = UDim2.new(0, 80, 0, 30),
						Position = UDim2.new(1, -10, 0, 5),
						BackgroundTransparency = 1,
						AnchorPoint = Vector2.new(1, 0),
						ZIndex = 5
					},
					{
						e("UICorner", {CornerRadius = UDim.new(0, 6)}),
						e("UIStroke",
							{
								ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
								Color = Color3.fromRGB(100, 100, 100)
							}
						),
						e("ImageLabel",
							{
								ZIndex = 3,
								ImageColor3 = Color3.fromRGB(200, 200, 200),
								AnchorPoint = Vector2.new(0, 0.5),
								Image = "rbxassetid://113510079889014",
								Size = UDim2.new(0, 14, 0.5, 0),
								Position = UDim2.new(0, 6, 0.5, 0),
								BackgroundTransparency = 1
							}
						),
						e("TextLabel",
							{
								ZIndex = 3,
								TextXAlignment = Enum.TextXAlignment.Left,
								TextSize = 12,
								FontFace = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Heavy, Enum.FontStyle.Normal),
								RichText = true,
								AnchorPoint = Vector2.new(0, 0.5),
								Position = UDim2.new(0, 26, 0.5, 0),
								AutomaticSize = Enum.AutomaticSize.X,
								Size = UDim2.new(0, 0, 1, 0),
								Text = "RETURN",
								BackgroundTransparency = 1,
								TextColor3 = Color3.fromRGB(200, 200, 200)
							}
						)
					}
				)

				local Titleinfo = e("TextLabel",
					{
						ZIndex = 3,
						TextXAlignment = Enum.TextXAlignment.Left,
						AutomaticSize = Enum.AutomaticSize.Y,
						TextColor3 = Color3.fromRGB(200, 200, 200),
						TextSize = 15,
						FontFace = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Bold, Enum.FontStyle.Normal),
						RichText = true,
						Size = UDim2.new(1, 0, 0, 14),
						Text = d.Title.. " : "..(l.Placeholder or "N/A"),
						TextWrapped = true,
						BackgroundTransparency = 1
					}
				)

				local Descriptioninfo = e("TextLabel",
					{
						ZIndex = 3,
						TextXAlignment = Enum.TextXAlignment.Left,
						AutomaticSize = Enum.AutomaticSize.Y,
						TextColor3 = Color3.fromRGB(115, 115, 115),
						TextSize = 14,
						FontFace = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Bold, Enum.FontStyle.Normal),
						RichText = true,
						Size = UDim2.new(1, 0, 0, 14),
						Text = d.SubTiltle,
						TextWrapped = true,
						BackgroundTransparency = 1,
						Visible = #d.SubTiltle > 0 and true or false
					}
				)

				local DropdownFrame = e("Frame",
					{
						ZIndex = 3,
						AutomaticSize = Enum.AutomaticSize.Y,
						BackgroundTransparency = 1,
						Size = UDim2.new(1, -20, 0, 0),
						Position = UDim2.fromOffset(10, 0)
					},
					{
						e("UICorner",
							{
								CornerRadius = UDim.new(0, 4)
							}
						),
						e("UIStroke",
							{
								Color = Color3.fromRGB(100, 100, 100),
								ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
								Thickness = 1,
								Transparency = 0
							}
						),
						e("UIPadding",
							{
								PaddingTop = UDim.new(0, 8),
								PaddingBottom = UDim.new(0, 8),
								PaddingLeft = UDim.new(0, 8)
							}
						),
						e("UIListLayout",
							{
								Padding = UDim.new(0, 8),
								SortOrder = Enum.SortOrder.LayoutOrder,
								FillDirection = Enum.FillDirection.Vertical
							}
						)
					}
				)

				local DropdownSearch = e("TextBox",
					{
						ZIndex = 3,
						TextColor3 = Color3.fromRGB(200, 200, 200),
						PlaceholderColor3 = Color3.fromRGB(100, 100, 100),
						PlaceholderText = "Search ...",
						Position = UDim2.new(0, 28, 0, 0),
						Size = UDim2.new(1, -28, 1, 0),
						FontFace = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Bold, Enum.FontStyle.Normal),
						TextTruncate = Enum.TextTruncate.AtEnd,
						TextXAlignment = Enum.TextXAlignment.Left,
						TextSize = 14,
						Text = "",
						BackgroundTransparency = 1,
						ClearTextOnFocus = false
					}
				)

				e("Frame",
					{
						ZIndex = 3,
						Parent = DropdownFrame,
						BackgroundTransparency = 1,
						Size = UDim2.new(1, -10, 0, 30)
					},
					{
						DropdownSearch,
						e("UICorner", {CornerRadius = UDim.new(0, 8)}),
						e("UIStroke",
							{
								Thickness = 1,
								Color = Color3.fromRGB(100, 100, 100),
								ApplyStrokeMode = Enum.ApplyStrokeMode.Border
							}
						),
						e("ImageLabel",
							{
								ZIndex = 3,
								AnchorPoint = Vector2.new(0.5, 0.5),
								Position = UDim2.new(0, 16, 0.5, 0),
								Size = UDim2.new(0, 16, 0, 16),
								Image = "rbxassetid://135103976674786",
								BackgroundTransparency = 1
							}
						)
					}
				)

				local MaxSelect = e("TextLabel",
					{
						ZIndex = 3,
						TextXAlignment = Enum.TextXAlignment.Center,
						FontFace = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Bold, Enum.FontStyle.Normal),
						TextColor3 = Color3.fromRGB(200, 200, 200),
						TextSize = 14,
						Size = UDim2.new(0, 45, 0, 30),
						Position = UDim2.new(1, -90, 0, 4),
						BackgroundTransparency = 1,
						AnchorPoint = Vector2.new(1, 0),
						Text = "(0/0)",
						RichText = true,
						AutomaticSize = Enum.AutomaticSize.Y,
						TextWrapped = true
					}
				)

				Library.AddSignal(DropdownSearch.Focused, function()
					DropdownSearch:CaptureFocus()
				end)

				Library.AddSignal(DropdownSearch:GetPropertyChangedSignal("Text"), function()
					for o,v in next, Library.Dropdown[n].List do
						local text = DropdownSearch.Text:lower()
						local title = o:lower()

						if text == "" or title:find(text, 1, true) or title:match(text, 1, true) or title:find(text) or title:match(text) or text == title then
							v.Container.Visible = true
						else
							v.Container.Visible = false
						end
					end
				end)

				Library.Dropdown[n] = {
					List = {},
					Value = {},
					Container = e("TextButton",
						{
							ZIndex = 3,
							Visible = false,
							Parent = Library.Window.Root,
							Size = UDim2.fromScale(1, 1),
							BackgroundTransparency = 1,
							Text = ""
						},
						{
							e("Frame",
								{
									ZIndex = 3,
									Name = "Background",
									Size = UDim2.fromScale(1, 1),
									BackgroundColor3 = Color3.fromRGB(35, 35, 35),
									BackgroundTransparency = 0.25
								},
								{
									e("UICorner", {CornerRadius = UDim.new(0, 4)})
								}
							),
							e("Frame",
								{
									ZIndex = 3,
									AnchorPoint = Vector2.new(0.5, 0.5),
									Position = UDim2.fromScale(0.5, 0.5),
									Size = UDim2.fromScale(0.185, 0.185),
									BackgroundColor3 = Color3.fromRGB(35, 35, 35)
								},
								{
									e("UICorner", {CornerRadius = UDim.new(0, 4)}),
									e("UIPadding",
										{
											PaddingTop = UDim.new(0, 5)
										}
									),
									e("UIStroke",
										{
											Color = Color3.fromRGB(100, 100, 100),
											ApplyStrokeMode = Enum.ApplyStrokeMode.Border
										}
									),
									e("UIListLayout",
										{
											Padding = UDim.new(0, 6),
											SortOrder = Enum.SortOrder.LayoutOrder,
											FillDirection = Enum.FillDirection.Vertical
										}
									),
									e("ScrollingFrame",
										{
											ZIndex = 3,
											LayoutOrder = 2,
											Size = UDim2.new(1, 0, 1, -50),
											CanvasSize = UDim2.fromScale(0, 0),
											ScrollingDirection = Enum.ScrollingDirection.Y,
											AutomaticCanvasSize = Enum.AutomaticSize.Y,
											ScrollBarImageTransparency = 1,
											ScrollBarThickness = 0,
											BackgroundTransparency = 1
										},
										{
											DropdownFrame,
											e("UIPadding",
												{
													PaddingTop = UDim.new(0, 6),
													PaddingBottom = UDim.new(0, 6)
												}
											)
										}
									),
									e("Frame",
										{
											ZIndex = 3,
											Size = UDim2.new(1, 0, 0, 0),
											AutomaticSize = Enum.AutomaticSize.Y,
											BackgroundTransparency = 1
										},
										{
											e("Frame",
												{
													ZIndex = 3,
													Position = UDim2.new(0, 3, 1, 8),
													Size = UDim2.new(1, -6, 0, 1),
													BackgroundColor3 = Color3.fromRGB(100, 100, 100),
													BorderSizePixel = 0
												}
											),
											e("Frame",
												{
													ZIndex = 3,
													Size = UDim2.new(1, -10, 0, 0),
													AutomaticSize = Enum.AutomaticSize.Y,
													BackgroundTransparency = 1,
													Position = UDim2.fromOffset(10, 0)
												},
												{
													Return,
													MaxSelect,
													e("Frame",
														{
															ZIndex = 3,
															Size = UDim2.new(1, -125, 1, 0),
															AutomaticSize = Enum.AutomaticSize.Y,
															BackgroundTransparency = 1
														},
														{
															e("UIPadding",
																{
																	PaddingTop = UDim.new(0, 5),
																	PaddingBottom = UDim.new(0, 5)
																}
															),
															e("UIListLayout",
																{
																	Padding = UDim.new(0, 2),
																	SortOrder = Enum.SortOrder.LayoutOrder,
																	FillDirection = Enum.FillDirection.Vertical
																}
															),
															Titleinfo,
															Descriptioninfo
														}
													)
												}
											)
										}
									)
								}
							)
						}
					)
				}

				setmetatable(s.List, {
					__len = function(tables)
						local count = 0
						for ll,vv in next, tables do
							count += 1
						end
						return count
					end
				})

				function s.Open()
					if s:LockState() then
						return
					end
					Library.Dropdown[n].Container.Visible = true
					Utility.Tween(Library.Dropdown[n].Container.Frame, {Size = UDim2.new(0.95, 0, 0.95, 0)}, 0.5, true)
				end

				function s.Close()
					Utility.Tween(Library.Dropdown[n].Container.Frame, {Size = UDim2.new(0.185, 0, 0.185, 0)}, 0.5, true)
					Library.Dropdown[n].Container.Visible = false
					DropdownSearch.Text = ""
				end

				function s.GetActiveValues()
					if s.Multi and s.Value then
						local dd = {}
						for o,v in next, s.Value do
							if type(v) == "table" then
								table.insert(dd, o.." : ".. tostring(v.Number or 0))
							else
								table.insert(dd, v)
							end
						end
						return dd
					else
						return s.Value and 1 or 0
					end
				end

				function s.UpdateTextDisplay()
					if s.Multi and s.Value then
						local text = l.Placeholder or "N/A"
						if #s.GetActiveValues() > 0 then
							text = table.concat(s.GetActiveValues(), ",  ")

							Text.TextColor3 = Color3.fromRGB(200, 200, 200)
						else
							Text.TextColor3 = Color3.fromRGB(100, 100, 100)
						end
						Text.Text = text
						Titleinfo.Text = d.Title.." : "..text

						MaxSelect.Text = "("..tostring(#s.GetActiveValues()).."/"..tostring(l.MaxSelect or #s.List)..")"
					else
						if not s.Value then
							Text.Text = l.Placeholder or "N/A"
							Text.TextColor3 = Color3.fromRGB(100, 100, 100)

							Titleinfo.Text = d.Title.." : "..(l.Placeholder or "N/A")
						elseif type(s.Value) == "table" then
							Text.Text = tostring(s.Value.Name).." : "..tostring(s.Value.Number)
							Text.TextColor3 = Color3.fromRGB(200, 200, 200)

							Titleinfo.Text = d.Title.." : "..tostring(s.Value.Name).." : "..tostring(s.Value.Number)
						else
							Text.Text = tostring(s.Value)
							Text.TextColor3 = Color3.fromRGB(200, 200, 200)

							Titleinfo.Text = d.Title.." : "..tostring(s.Value)
						end

						MaxSelect.Text = "("..tostring(s.GetActiveValues())..(#s.List == 0 and "/0)" or "/1)")
					end
				end

				function s:OnChanged(changed)
					changedD = changed
					changed(s.Value)
				end

				Library.AddSignal(Button.MouseButton1Click, s.Open)
				Library.AddSignal(Return.MouseButton1Click, s.Close)

				function s:Lock()
					s:Close()
					Locked = true
					d.LockButton.Visible = true
					d.LockLabel.Visible = true
					Utility.Tween(d.LockLabel, {BackgroundTransparency = 0.75, Size = UDim2.fromScale(1, 1)}, 0.35, true)
				end

				function s:Unlock()
					Locked = false
					d.LockButton.Visible = false
					Utility.Tween(d.LockLabel, {BackgroundTransparency = 1, Size = UDim2.fromScale(0, 0)}, 0.35, true)
					d.LockLabel.Visible = false
				end

				local function ToggleVisible(name, value)
					if not Library.Dropdown[n].List[name] then
						return
					end
					local yw = Library.Dropdown[n].List[name]
					yw.Toggle.ImageLabel.Visible = value and true or false
					yw.Toggle.UIStroke.Transparency = value and 1 or 0
					yw.Toggle.BackgroundTransparency = value and 0 or 1
				end

				local function BuildDropdownList(lk1)
					local slow = 0
					for o,v in next, lk1 or s.List do
						local f = type(o) == "string" and o or v

						if not Library.Dropdown[n].List[f] then
							slow += 1
							Library.Dropdown[n].List[f] = {}

							if type(v) == "table" then
								s.List[f] = {
									Value = false,
									Number = s.List[f].Number or 0,
									Min = s.List[f].Min or 0,
									Max = s.List[f].Max or 10,
									Rounding = s.List[f].Rounding or 0,
									Name = f,
								}
								v = s.List[f]
							end
							s.MultiValue[f] = false

							Library.Dropdown[n].List[f].Toggle = e("Frame",
								{
									ZIndex = 3,
									Parent = d.Frame,
									BackgroundColor3 = Color3.fromRGB(82, 255 ,255),
									AnchorPoint = Vector2.new(1, 0.5),
									Size = UDim2.new(0, 20, 0, 20),
									Position = UDim2.new(1, -10, 0.5, 0),
									BackgroundTransparency = 1
								},
								{
									e("UICorner", {CornerRadius = UDim.new(0, 4)}),
									e("UIStroke",
										{
											ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
											Color = Color3.fromRGB(100, 100, 100),
											Thickness = 1.5
										}
									),
									e("ImageLabel",
										{
											ZIndex = 3,
											Size = UDim2.new(1, -10, 1, -10),
											Position = UDim2.new(0, 5, 0, 5),
											BackgroundTransparency = 1,
											Image = "rbxassetid://132585292193326",
											Visible = false,
											ImageColor3 = Color3.fromRGB(35, 35, 35)
										},
										{
											e("UICorner", {CornerRadius = UDim.new(0, 4)})
										}
									)
								}
							)
							Library.Dropdown[n].List[f].Container = e("TextButton",
								{
									ZIndex = 3,
									Parent = DropdownFrame,
									Size = UDim2.new(1, -10, 0, 30),
									AutomaticSize = Enum.AutomaticSize.Y,
									BackgroundTransparency = 1,
									Text = ""
								},
								{
									Library.Dropdown[n].List[f].Toggle,
									e("UICorner", {CornerRadius = UDim.new(0, 8)}),
									e("UIStroke",
										{
											Thickness = 1,
											Color = Color3.fromRGB(100, 100, 100),
											ApplyStrokeMode = Enum.ApplyStrokeMode.Border
										}
									),
									e("UIPadding",
										{
											PaddingTop = UDim.new(0, 4),
											PaddingBottom = UDim.new(0, 4)
										}
									),
									e("TextLabel",
										{
											ZIndex = 3,
											FontFace = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Bold, Enum.FontStyle.Normal),
											Text = f,
											TextColor3 = Color3.fromRGB(200, 200, 200),
											TextSize = 14,
											TextXAlignment = Enum.TextXAlignment.Left,
											BackgroundTransparency = 1,
											Size = UDim2.new(1, -50, 1, 0),
											Position = UDim2.fromOffset(10, 0),
											AutomaticSize = Enum.AutomaticSize.Y,
											RichText = true,
											TextWrapped = true
										},
										{
											e("UICorner", {CornerRadius = UDim.new(0, 8)})
										}
									)
								}
							)
							if type(v) == "table" then
								Library.Dropdown[n].List[f].SliderLine = e("Frame",
									{
										ZIndex = 3,
										Parent = Library.Dropdown[n].List[f].Container,
										BackgroundColor3 = Color3.fromRGB(200, 200, 200),
										AnchorPoint = Vector2.new(1, 0.5),
										Size = UDim2.fromOffset(105, 4),
										Position = UDim2.new(1, -38, 0.5, -1)
									},
									{
										e("UICorner", {CornerRadius = UDim.new(1, 0)}),
										e("Frame",
											{
												ZIndex = 3,
												Name = "Point",
												BackgroundColor3 = Color3.fromRGB(82, 255, 255),
												Size = UDim2.new(0, 0, 1, 0)
											},
											{
												e("UICorner", {CornerRadius = UDim.new(1, 0)})
											}
										),
										e("Frame",
											{
												ZIndex = 3,
												Size = UDim2.new(1, -8, 1, 0),
												Position = UDim2.new(0, 4, 0, 0),
												BackgroundTransparency = 1
											},
											{
												e("ImageLabel",
													{
														ZIndex = 3,
														AnchorPoint = Vector2.new(0, 0.5),
														ImageColor3 = Color3.fromRGB(82, 255, 255),
														Size = UDim2.fromOffset(8, 8),
														Position = UDim2.new(0, -4, 0.5, 0),
														Image = "rbxassetid://12266946128",
														BackgroundTransparency = 1
													}
												),
												e("TextLabel",
													{
														ZIndex = 3,
														AnchorPoint = Vector2.new(0, 0.5),
														Position = UDim2.new(0, -4, 0.5, -10),
														BackgroundTransparency = 1,
														TextXAlignment = Enum.TextXAlignment.Left,
														TextSize = 13,
														FontFace = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Bold, Enum.FontStyle.Normal),
														RichText = true,
														TextColor3 = Color3.fromRGB(200, 200, 200),
														Size = UDim2.new(0, 20, 0, 20),
														Text = tostring(v.Number),
														AutomaticSize = Enum.AutomaticSize.X
													}
												)
											}
										)
									}
								)
								Library.Dropdown[n].List[f].SliderInput = e("Frame",
									{
										ZIndex = 3,
										Parent = Library.Dropdown[n].List[f].Container,
										AnchorPoint = Vector2.new(1, 0.5),
										Size = UDim2.new(0, 20, 0, 20),
										Position = UDim2.new(1, -155, 0.5, 0),
										BackgroundTransparency = 1
									},
									{
										e("UICorner", {CornerRadius = UDim.new(0, 4)}),
										e("UIStroke",
											{
												Color = Color3.fromRGB(100, 100, 100)
											}
										),
										e("TextBox",
											{
												ZIndex = 3,
												Text = v.Number,
												TextColor3 = Color3.fromRGB(200, 200 ,200),
												PlaceholderColor3 = Color3.fromRGB(100, 100, 100),
												TextTruncate = Enum.TextTruncate.AtEnd,
												TextSize = 12,
												FontFace = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Bold, Enum.FontStyle.Normal),
												RichText = true,
												PlaceholderText = "0",
												Size = UDim2.new(1, 0, 1, 0),
												BackgroundTransparency = 1
											}
										)
									}
								)

								Library.Dropdown[n].List[f].Container.TextLabel.Size = UDim2.new(1, -155, 1, 0)
								local W, K, D, T = Library.Dropdown[n].List[f].SliderLine, Library.Dropdown[n].List[f].SliderInput, false, s.List[f]

								Library.Dropdown[n].List[f].SliderChanged = function(value)
									if s:LockState() then
										K.TextBox.Text = T.Number
										return
									end
									if (not tonumber(value)) and value:len() > 0 then
										value = T.Number
									else
										if value == "" then
										value = 0
										end
										T.Number = Utility.Round(math.clamp(value, T.Min, T.Max), T.Rounding)
										W.Frame.ImageLabel.Position = UDim2.new((T.Number - T.Min) / (T.Max - T.Min), -4, 0.5, 0)
										W.Point.Size = UDim2.fromScale((T.Number - T.Min) / (T.Max - T.Min), 1)
										W.Frame.TextLabel.Position = UDim2.new((T.Number - T.Min) / (T.Max - T.Min), -4, 0.5, -10)

										K.TextBox.Text = T.Number
										W.Frame.TextLabel.Text = tostring(T.Number)

										if not s.Multi and type(s.Value) == "table" then
											s.Value.Number = T.Number
										elseif s.Multi and s.Value[f] then
											s.Value[f].Number = T.Number
										end
									end
									s.UpdateTextDisplay()
									Library.SafeCallback(changedD, s.Value)
									Library.SafeCallback(l.Callback, s.Value)
									if Library.AutoSave.Value then
										t:SaveConfigs()
									end
								end

								Library.AddSignal(K.TextBox.Focused, function()
									K.TextBox:CaptureFocus()
								end)

								Library.AddSignal(K.TextBox.FocusLost, function()
									if K.TextBox.Text:find(".") and T.Rounding == 0 then
										K.TextBox.Text = K.TextBox.Text:split(".")[1]
									end
									Library.Dropdown[n].List[f].SliderChanged(K.TextBox.Text)
								end)

								Library.AddSignal(W.Frame.ImageLabel.InputBegan, function(input)
									if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
										D = true
									end
								end)

								Library.AddSignal(W.Frame.ImageLabel.InputEnded, function(input)
									if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
										D = false
									end
								end)

								Library.AddSignal(k.InputChanged, function(input)
									if D and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
										local value = math.clamp((input.Position.X - W.Frame.AbsolutePosition.X) / W.Frame.AbsoluteSize.X, 0, 1)
										Library.Dropdown[n].List[f].SliderChanged(T.Min + ((T.Max - T.Min) * value))
									end
								end)
							end
							local y = Library.Dropdown[n].List
							local Y = type(v) == "table" and Library.Dropdown[n].List[f].Container.TextLabel or Library.Dropdown[n].List[f].Container
							Library.AddSignal(Y.InputBegan, function(input)
								if (input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch) or s:LockState() then
									return
								end
								if s.Multi then
									if type(s.Value) ~= "table" then
										s.Value = {}
									end
									if l.MaxSelect and #s.GetActiveValues() >= l.MaxSelect then
										if table.find(s.Value, f) or s.Value[f] then
											ToggleVisible(f, false)
											if s.Value[f] then
											s.Value[f] = nil
											else
												table.remove(s.Value, table.find(s.Value, f))
											end
											s.MultiValue[f] = false
											s.UpdateTextDisplay()
										end
										return
									end
									if table.find(s.Value, f) or s.Value[f] then
										ToggleVisible(f, false)
										if s.Value[f] then
										s.Value[f] = nil
										else
											table.remove(s.Value, table.find(s.Value, f))
										end
										s.MultiValue[f] = false
									else
										if type(v) == "string" and not table.find(s.Value, f) then
											ToggleVisible(f, true)
											table.insert(s.Value, f)
										end
										if type(o) == "string" and not s.Value[f] then
											ToggleVisible(f, true)
											s.Value[f] = v
										end
										s.MultiValue[f] = true
									end
								else
									local kj = type(s.Value) == "table" and s.Value.Name or s.Value
									if s.GetActiveValues() >= 1 and not l.AllowNull and kj == f then
										return
									end
									local N = false
									local R = s.Value and (type(s.Value) == "table" and s.Value.Name or s.Value) or nil
									if R and y[R] then
										N = l.AllowNull and true or false
										if N and R ~= f then
										N = false
										end
										ToggleVisible(R, false)
										s.Value = nil
										s.MultiValue[f] = false
									end
									s.Value = (not N) and f or nil
									s.Value = ((s.Value and type(v) == "table") and v or nil) or s.Value

									R = s.Value and (type(s.Value) == "table" and s.Value.Name or s.Value) or nil

									if R and y[R] then
										ToggleVisible(R, true)
										s.MultiValue[f] = true
									end
								end
								s.UpdateTextDisplay()
								Library.SafeCallback(changedD, s.Value)
								Library.SafeCallback(l.Callback, s.Value)
								if Library.AutoSave.Value then
									t:SaveConfigs()
								end
								local textdesb = Descriptioninfo.Visible and Descriptioninfo.TextBounds.Y or 6

								DropdownFrame.Parent.Size = UDim2.new(1, 0, 1, -(Titleinfo.TextBounds.Y + textdesb + 30))
							end)
							if slow >= 10 then
								task.wait()
								slow = 0
							end
						end
					end
					local textdesb = Descriptioninfo.Visible and Descriptioninfo.TextBounds.Y or 6

					DropdownFrame.Parent.Size = UDim2.new(1, 0, 1, -(Titleinfo.TextBounds.Y + textdesb + 30))
				end

				Library.AddSignal(Titleinfo.Changed, function()
					local textdesb = Descriptioninfo.Visible and Descriptioninfo.TextBounds.Y or 6

					DropdownFrame.Parent.Size = UDim2.new(1, 0, 1, -(Titleinfo.TextBounds.Y + textdesb + 30))
				end)
				Library.AddSignal(Descriptioninfo.Changed, function()
					local textdesb = Descriptioninfo.Visible and Descriptioninfo.TextBounds.Y or 6

					DropdownFrame.Parent.Size = UDim2.new(1, 0, 1, -(Titleinfo.TextBounds.Y + textdesb + 30))
				end)

				function s:NewList(list)
					local concatlist = {}
					for o,v in next, list do
						if type(o) == "string" then
							table.insert(concatlist, o)
						else
							table.insert(concatlist, v)
						end
					end
					if s.Multi then
						for o,v in next, s.List do
							if type(o) == "string" and not table.find(concatlist, o) then
								if Library.Dropdown[n].List[o] then
									Library.Dropdown[n].List[o].Container:Destroy()
									Library.Dropdown[n].List[o] = nil
								end

								if s.Value[o] then
									s.Value[o] = nil
									s.MultiValue[o] = nil
								end
							elseif type(v) == "string" and not table.find(concatlist, v) then
								if Library.Dropdown[n].List[v] then
									Library.Dropdown[n].List[v].Container:Destroy()
									Library.Dropdown[n].List[v] = nil
								end

								if table.find(s.Value, v) then
									table.remove(s.Value, table.find(s.Value, v))
									s.MultiValue[v] = nil
								end
							end
						end
					else
						for o,v in next, s.List do
							if type(o) == "string" and not table.find(concatlist, o) then
								if Library.Dropdown[n].List[o] then
									Library.Dropdown[n].List[o].Container:Destroy()
									Library.Dropdown[n].List[o] = nil
								end

								if type(s.Value) == "table" and s.Value.Name == o then
									s.Value = nil
								end
							elseif type(v) == "string" and not table.find(concatlist, v) then
								if Library.Dropdown[n].List[v] then
									Library.Dropdown[n].List[v].Container:Destroy()
									Library.Dropdown[n].List[v] = nil
								end

								if type(s.Value) == "string" and s.Value == v then
									s.Value = nil
								end
							end
						end
					end
					s.List = list
					BuildDropdownList(list)
					s.UpdateTextDisplay()
					setmetatable(s.List, {
						__len = function(tables)
							local count = 0
							for ll,vv in next, tables do
								count += 1
							end
							return count
						end
					})
				end

				function s:SetValue(value)
					if s:LockState() then
						return
					end
					if value and type(value) == "table" then
						for o,v in next, value do
							if type(o) == "string" and s.List[o] then
								if s.Multi then
									if s.Value then
										for ee,vv in next, s.Value do
											if type(ee) == "string" and not value[ee] then
												s.Value[ee] = nil
												ToggleVisible(ee, false)
												s.MultiValue[ee] = false
											end
										end
									end
									s.Value[o] = {}
									for ll,dd in next, v do
										s.Value[o][ll] = dd
									end
									do
										s.Value[o].Min = s.Value[o].Min or 0
										s.Value[o].Max = s.Value[o].Max or 10
										s.Value[o].Name = s.Value[o].Name or o
										s.Value[o].Value = s.Value[o].Value or false
										s.Value[o].Number = s.Value[o].Number or 0
										s.Value[o].Rounding = s.Value[o].Rounding or 0
									end
									Library.Dropdown[n].List[o].SliderChanged(s.Value[o].Number)

									if s.Value[o].Value then
										ToggleVisible(o, true)
										s.MultiValue[o] = true
									else
										s.Value[o] = nil
										ToggleVisible(o, false)
										s.MultiValue[o] = false
									end
								else
									if s.Value then
										if type(s.Value) == "table" then
											ToggleVisible(s.Value.Name, false)
											s.MultiValue[s.Value.Name] = false
										else
											ToggleVisible(s.Value, false)
											s.MultiValue[s.Value] = false
										end
									end
									s.Value = {}
									for ll,dd in next, v do
										s.Value[ll] = dd
									end
									do
										s.Value.Min = s.Value.Min or 0
										s.Value.Max = s.Value.Max or 10
										s.Value.Name = s.Value.Name or o
										s.Value.Value = s.Value.Value or false
										s.Value.Number = s.Value.Number or 0
										s.Value.Rounding = s.Value.Rounding or 0
									end
									Library.Dropdown[n].List[o].SliderChanged(s.Value.Number)

									if s.Value.Value then
										ToggleVisible(o, true)
										s.MultiValue[o] = true
									else
										s.Value = nil
										ToggleVisible(o, false)
										s.MultiValue[o] = false
									end
								end
							elseif type(v) == "string" and table.find(s.List, v) and not table.find(s.Value, v) then
								if s.Value then
									for ee,vv in next, s.Value do
										if type(vv) == "string" and not table.find(value, vv) then
											table.remove(s.Value, table.find(s.Value, vv))
											ToggleVisible(vv, false)
											s.MultiValue[vv] = false
										end
									end
								end
								if s.Multi then
									ToggleVisible(v, true)
									table.insert(s.Value, v)
									s.MultiValue[v] = true
								else
									s.Value = v
									ToggleVisible(v, true)
									s.MultiValue[v] = true
									break
								end
							elseif type(v) == "string" and table.find(s.List, v) and table.find(s.Value, v) then
								local ew = {}
								for ee,vv in next, s.Value do
									if type(vv) == "string" and not table.find(value, vv) then
										table.insert(ew, vv)
									end
								end
								for ee,vv in next, ew do
									table.remove(s.Value, table.find(s.Value, vv))
									ToggleVisible(vv, false)
									s.MultiValue[vv] = false
								end
							end
						end
					else
						if not value then
							if s.Value then
								local real = type(s.Value) == "table" and s.Value.Name or s.Value
								ToggleVisible(real, false)
								s.MultiValue[real] = false
							end
							s.Value = nil
						elseif table.find(s.List, value) then
							if s.Value then
								local real = type(s.Value) == "table" and s.Value.Name or s.Value
								ToggleVisible(real, false)
								s.MultiValue[real] = false
							end
							s.Value = value
							ToggleVisible(s.Value, true)
							s.MultiValue[s.Value] = true
						elseif type(value) == "number" and s.List[value] then
							if s.Value then
								local real = type(s.Value) == "table" and s.Value.Name or s.Value
								ToggleVisible(real, false)
								s.MultiValue[real] = false
							end
							s.Value = s.List[value]
							ToggleVisible(s.Value, true)
							s.MultiValue[s.Value] = true
						else
							if s.Value then
								local real = type(s.Value) == "table" and s.Value.Name or s.Value
								ToggleVisible(real, false)
								s.MultiValue[real] = false
							end
							s.Value = nil
						end
					end
					s.UpdateTextDisplay()
					Library.SafeCallback(changedD, s.Value)
					Library.SafeCallback(l.Callback, s.Value)
					if Library.AutoSave.Value then
						t:SaveConfigs()
					end
				end

				function s:SetTitle(text)
						 d:SetTitle(text)
						 Titleinfo.Text = text
						 s.UpdateTextDisplay()
		  		end

				function s:SetSubTitle(text)
						 d:SetSubTitle(text)
						 Descriptioninfo.Text = text
						 s.UpdateTextDisplay()
						 Descriptioninfo.Visible = #text > 0 and true or false
				end

				BuildDropdownList()
				s:SetValue(s.Default)
				s.UpdateTextDisplay()
				Library.AddConfigs(n, s)
				return s
			end

			function h:AddKeybind(n, l)
				local d = Utility.MakeTextButton(l)
				local s = {
					Name = n,
					Frame = d.Frame,
					Value = l.Default,
					Mode = l.Mode or "Toggle",
					OnClick = false,
					Type = "Keybind"
				}

				local changedD

				l.Page = l.Page and l.Page or 1
				l.Page = (l.Page > 3 or l.Page == 0) and 1 or l.Page

				l.currentPage = Page[h.Tab].Page[l.Page]
				l.currentPage.count = l.currentPage.count and l.currentPage + 1 or 1

				d.Frame.Parent = c.Page[l.Page].Frame

				d.TitleContent.Size = UDim2.new(1, -150, 0, 14)
				d.SubTiltleContent.Size = UDim2.new(1, -150, 0, 14)

				s.LockState = d.LockState
				s.Lock = d.Lock
				s.Unlock = d.Unlock

				table.insert(Page[h.Tab].Data, {Container = d.Frame, Title = function()
					return d.Title
				end})

				local Text = e("TextLabel",
					{
						TextTruncate = Enum.TextTruncate.AtEnd,
						TextXAlignment = Enum.TextXAlignment.Center,
						TextSize = 14,
						RichText = true,
						FontFace = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Bold, Enum.FontStyle.Normal),
						TextColor3 = Color3.fromRGB(100, 100, 100),
						AnchorPoint = Vector2.new(0, 0.5),
						Size = UDim2.new(1, 0, 1, 0),
						Position = UDim2.new(0, 0, 0.5, 0),
						Text = "Left",
						BackgroundTransparency = 1
					}
				)

				local Button = e("TextButton",
					{
						BackgroundTransparency = 1,
						Text = "",
						TextTransparency = 1,
						Size = UDim2.fromScale(1, 1)
					},
					{
						Text
					}
				)

				e("Frame",
					{
						Parent = d.Frame,
						AnchorPoint = Vector2.new(1, 0.5),
						Size = UDim2.new(0, 135, 0, 24),
						Position = UDim2.new(1, -10, 0.5, 0),
						BackgroundTransparency = 1
					},
					{
						e("UICorner", {CornerRadius = UDim.new(0, 6)}),
						e("UIStroke",
							{
								ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
								Color = Color3.fromRGB(100, 100, 100)
							}
						),
						Button
					}
				)

				Library.AddSignal(Button.InputBegan, function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						s.OnClick = true
						local old = {text = Text.Text, value = s.Value}
						Text.Text = "..."
						Text.TextColor3 = Color3.fromRGB(100, 100, 100)
						wait(0.2)
						local ec
						ec = k.InputBegan:Connect(function(types)
							local cp
							if types.UserInputType == Enum.UserInputType.Keyboard then
								cp = types.KeyCode.Name
							elseif types.UserInputType == Enum.UserInputType.MouseButton1 then
								cp = "MouseLeft"
							elseif types.UserInputType == Enum.UserInputType.MouseButton2 then
								cp = "MouseRight"
							end
							local en
							en = k.InputEnded:Connect(function(value)
								if value.KeyCode.Name == cp or
								(
									cp == "MouseLeft" and value.UserInputType == Enum.UserInputType.MouseButton1
									or
									cp == "MouseRight" and value.UserInputType == Enum.UserInputType.MouseButton2
								)
								then
									if s:LockState() then
										Text.Text = old.text
										Text.TextColor3 = old.text == "None" and Color3.fromRGB(100, 100, 100) or Color3.fromRGB(200, 200, 200)
										return
									end
									s.OnClick = false
									Text.Text = cp
									s.Value = cp
									Text.TextColor3 = Color3.fromRGB(200, 200, 200)
									en:Disconnect()
									ec:Disconnect()
									Library.SafeCallback(changedD, value.KeyCode or value.UserInputType)
									Library.SafeCallback(l.Callback, value.KeyCode or value.UserInputType)
									if Library.AutoSave.Value then
										t:SaveConfigs()
									end
								end
							end)
						end)
					end
				end)
				Library.AddSignal(k.InputBegan, function(input)
					if s:LockState() then
						return
					end
					if not s.OnClick and not k:GetFocusedTextBox() then
						if s.Mode == "Toggle" then
							local ne = s.Value
							if ne == "MouseLeft" or ne == "MouseRight" then
								if ne == "MouseLeft" and input.UserInputType == Enum.UserInputType.MouseButton1 or
									ne == "MouseRight" and input.UserInputType == Enum.UserInputType.MouseButton2
								then
									s.Toggled = not s.Toggled
									s:DoClick()
								end
							elseif input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode.Name == ne then
								s.Toggled = not s.Toggled
								s:DoClick()
							end
						end
					end
				end)

				function s:GetState()
					if k:GetFocusedTextBox() and s.Mode ~= "Always" then
						return false
					end
					if s.Mode == "Always" then
						return true
					elseif s.Mode == "Hold" then
						if not s.Value then
							return false
						end
						local ch = s.Value
						if ch == "MouseLeft" or ch == "MouseRight" then
							return (ch == "MouseLeft" and k:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)) or
								(ch == "MouseRight" and k:IsMouseButtonPressed(Enum.UserInputType.MouseButton2))
						else
							return k:IsKeyDown(Enum.KeyCode[s.Value])
						end
					else
						return s.Toggled
					end
				end

				function s:SetValue(value, mode)
					if s:LockState() then
						return
					end
					value = value or s.Value
					mode = mode or s.Mode
					Text.Text = value or "None"
					if Text.Text == "None" then
						Text.TextColor3 = Color3.fromRGB(100, 100, 100)
					else
						Text.TextColor3 = Color3.fromRGB(200, 200, 200)
					end
					s.Value = value
					s.Mode = mode
					if Library.AutoSave.Value then
						t:SaveConfigs()
					end
				end
				function s:DoClick()
					if not s.Value then
						return
					end
					if s.Value == "MouseLeft" or s.Value == "MouseRight" then
						Library.SafeCallback(changedD, Enum.KeyCode["Unknown"])
						Library.SafeCallback(l.Callback, Enum.KeyCode["Unknown"])
					else
						Library.SafeCallback(changedD, Enum.KeyCode[s.Value])
						Library.SafeCallback(l.Callback, Enum.KeyCode[s.Value])
					end
				end
				function s:OnChanged(changed)
					s.Changed = changed
					changed(s.Value)
				end

				function s:SetTitle(text)
						 d:SetTitle(text)
				end

				function s:SetSubTitle(text)
						 d:SetSubTitle(text)
				end

				s:SetValue(s.Default, s.Mode)
				Library.AddConfigs(n, s)
				return s
			end

			function h:AddColorPicker(n, l)
				local d = Utility.MakeTextButton(l)
				local s = {
					Name = n,
					Frame = d.Frame,
					Value = l.Default or Color3.fromRGB(15, 25, 15),
					Type = "ColorPicker",
					InputValue = {
						R = 0,
						G = 0,
						B = 0
					},
					DataValue = {
						Pos1 = nil,
						Pos2 = nil,
						Pos3 = nil,

						Code = {},
						Last = {["1"] = 0,["2"] = 0, ["3"] = 0}
					}

				}

				local Locked = false
				local changedD

				function s:LockState()
					return Locked
				end
				function s.SetHSVFromRGB(code)
					if s:LockState() then
						s.Value = s.Value
						return
					end
					local C, D, E = Color3.toHSV(code)
					s.DataValue.Pos1 = C
					s.DataValue.Pos2 = D
					s.DataValue.Pos3 = E

					s.Value = Color3.fromHSV(C, D, E)

					if Library.AutoSave.Value then
						t:SaveConfigs()
					end
				end
				s.SetHSVFromRGB(s.Value)

				for R = 0, 1, 0.1 do
					table.insert(s.DataValue.Code, ColorSequenceKeypoint.new(R, Color3.fromHSV(R, 1, 1)))
                end

				l.Page = l.Page and l.Page or 1
				l.Page = (l.Page > 3 or l.Page == 0) and 1 or l.Page

				l.currentPage = Page[h.Tab].Page[l.Page]
				l.currentPage.count = l.currentPage.count and l.currentPage + 1 or 1

				d.Frame.Parent = c.Page[l.Page].Frame

				d.TitleContent.Size = UDim2.new(1, -150, 0, 14)
				d.SubTiltleContent.Size = UDim2.new(1, -150, 0, 14)

				table.insert(Page[h.Tab].Data, {Container = d.Frame, Title = function()
					return d.Title
				end})

				local Return = e("TextButton",
					{
						Text = "",
						Size = UDim2.new(0, 80, 0, 30),
						Position = UDim2.new(1, -10, 0, 5),
						BackgroundTransparency = 1,
						AnchorPoint = Vector2.new(1, 0),
						ZIndex = 5
					},
					{
						e("UICorner", {CornerRadius = UDim.new(0, 6)}),
						e("UIStroke",
							{
								ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
								Color = Color3.fromRGB(100, 100, 100)
							}
						),
						e("ImageLabel",
							{
								ZIndex = 3,
								ImageColor3 = Color3.fromRGB(200, 200, 200),
								AnchorPoint = Vector2.new(0, 0.5),
								Image = "rbxassetid://113510079889014",
								Size = UDim2.new(0, 14, 0.5, 0),
								Position = UDim2.new(0, 6, 0.5, 0),
								BackgroundTransparency = 1
							}
						),
						e("TextLabel",
							{
								ZIndex = 3,
								TextXAlignment = Enum.TextXAlignment.Left,
								TextSize = 12,
								FontFace = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Heavy, Enum.FontStyle.Normal),
								RichText = true,
								AnchorPoint = Vector2.new(0, 0.5),
								Position = UDim2.new(0, 26, 0.5, 0),
								AutomaticSize = Enum.AutomaticSize.X,
								Size = UDim2.new(0, 0, 1, 0),
								Text = "RETURN",
								BackgroundTransparency = 1,
								TextColor3 = Color3.fromRGB(200, 200, 200)
							}
						)
					}
				)

				local Titleinfo = e("TextLabel",
					{
						ZIndex = 3,
						TextXAlignment = Enum.TextXAlignment.Left,
						AutomaticSize = Enum.AutomaticSize.Y,
						TextColor3 = Color3.fromRGB(200, 200, 200),
						TextSize = 15,
						FontFace = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Bold, Enum.FontStyle.Normal),
						RichText = true,
						Size = UDim2.new(1, 0, 0, 14),
						Text = d.Title.. " : (82, 255, 255)",
						TextWrapped = true,
						BackgroundTransparency = 1
					}
				)

				local Descriptioninfo = e("TextLabel",
					{
						ZIndex = 3,
						TextXAlignment = Enum.TextXAlignment.Left,
						AutomaticSize = Enum.AutomaticSize.Y,
						TextColor3 = Color3.fromRGB(115, 115, 115),
						TextSize = 14,
						FontFace = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Bold, Enum.FontStyle.Normal),
						RichText = true,
						Size = UDim2.new(1, 0, 0, 14),
						Text = d.SubTiltle,
						TextWrapped = true,
						BackgroundTransparency = 1,
						Visible = #d.SubTiltle > 0 and true or false
					}
				)

				local ColorFrame1 = e("Frame",
					{
						Size = UDim2.fromScale(1, 1),
						BackgroundColor3 = Color3.fromRGB(82, 255, 255)
					},
					{
						e("UICorner", {CornerRadius = UDim.new(0, 6)})
					}
				)

				local ColorButton = e("ImageLabel",
					{
						Parent = d.Frame,
						AnchorPoint = Vector2.new(1, 0.5),
						Size = UDim2.new(0, 135, 0, 24),
						Position = UDim2.new(1, -10, 0.5, 0),
						BackgroundTransparency = 1,
						Image = "rbxassetid://14204231522",
						ImageTransparency = 0.45,
						ScaleType = Enum.ScaleType.Tile,
						TileSize = UDim2.new(0, 40, 0, 40)
					},
					{
						ColorFrame1,
						e("UICorner", {CornerRadius = UDim.new(0, 6)})
					}
				)

				local ColorPickerPoint = e("ImageLabel",
					{
						ZIndex = 3,
						Size = UDim2.new(0, 28, 0, 28),
						ScaleType = Enum.ScaleType.Fit,
						AnchorPoint = Vector2.new(0.5, 0.5),
						BackgroundTransparency = 1,
						Image = "rbxassetid://4805639000"
					}
				)

				local ColorPickerFrame = e("ImageLabel",
					{
						ZIndex = 3,
						Size = UDim2.new(1, -50, 1, -180),
						Position = UDim2.fromOffset(25, 0),
						Image = "rbxassetid://4155801252",
						BackgroundColor3 = s.Value,
						BackgroundTransparency = 0,
					},
					{e("UICorner", {CornerRadius = UDim.new(0, 8)}), ColorPickerPoint}
				)

				local ColorPickerView = e("ImageLabel",
					{
						ZIndex = 3,
						AnchorPoint = Vector2.new(0, 1),
						Position = UDim2.new(0, 25, 1, -90),
						Size = UDim2.new(1, -50, 0, 50),
						BackgroundTransparency = 1,
						Image = "rbxassetid://14204231522",
						ImageTransparency = 0.45,
						ScaleType = Enum.ScaleType.Tile,
						TileSize = UDim2.new(0, 40, 0, 40)
					},
					{
						e("UICorner", {CornerRadius = UDim.new(0, 8)}),
						e("Frame",
							{
								ZIndex = 3,
								BackgroundColor3 = s.Value,
								Size = UDim2.fromScale(1, 1)
							},
							{
								e("UICorner", {CornerRadius = UDim.new(0, 8)})
							}
						)
					}
				)

				local RedInput = e("TextBox",
					{
						ZIndex = 3,
						Size = UDim2.fromScale(1, 1),
						TextColor3 = Color3.fromRGB(115, 115, 115),
						PlaceholderColor3 = Color3.fromRGB(100, 100, 100),
						TextTruncate = Enum.TextTruncate.AtEnd,
						BackgroundTransparency = 1,
						TextSize = 18,
						FontFace = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Bold, Enum.FontStyle.Normal),
						RichText = true,
						Text = ""
					}
				)

				local GreenInput = e("TextBox",
					{
						ZIndex = 3,
						Size = UDim2.fromScale(1, 1),
						TextColor3 = Color3.fromRGB(115, 115, 115),
						PlaceholderColor3 = Color3.fromRGB(100, 100, 100),
						TextTruncate = Enum.TextTruncate.AtEnd,
						BackgroundTransparency = 1,
						TextSize = 18,
						FontFace = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Bold, Enum.FontStyle.Normal),
						RichText = true,
						Text = ""
					}
				)

				local BlueInput = e("TextBox",
					{
						ZIndex = 3,
						Size = UDim2.fromScale(1, 1),
						TextColor3 = Color3.fromRGB(115, 115, 115),
						PlaceholderColor3 = Color3.fromRGB(100, 100, 100),
						TextTruncate = Enum.TextTruncate.AtEnd,
						BackgroundTransparency = 1,
						TextSize = 18,
						FontFace = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Bold, Enum.FontStyle.Normal),
						RichText = true,
						Text = ""
					}
				)

				local PointSelect = e("ImageLabel",
					{
						ZIndex = 3,
						Size = UDim2.fromOffset(14, 14),
						Image = "rbxassetid://12266946128"
					},
					{
						e("UICorner", {CornerRadius = UDim.new(0, 8)})
					}
				)

				local ColorSelect = e("Frame",
					{
						ZIndex = 3,
						AnchorPoint = Vector2.new(0, 1),
						Position = UDim2.new(0, 25, 1, -150),
						Size = UDim2.new(1, -50, 0, 25)
					},
					{
						e("UICorner", {CornerRadius = UDim.new(1, 0)}),
						e("UIGradient", {Color = ColorSequence.new(s.DataValue.Code), Rotation = 90}),
						e("Frame",
							{
								ZIndex = 3,
								Position = UDim2.fromOffset(0, 5),
								Size = UDim2.new(1, 0, 1, -10),
								BackgroundTransparency = 1
							},
							{PointSelect}
						)
					}
				)

				local ContainerFrame = e("TextButton",
					{
						ZIndex = 3,
						Parent = Library.Window.Root,
						Visible = false,
						Size = UDim2.fromScale(1, 1),
						BackgroundTransparency = 1,
						Text = ""
					},
					{
						e("Frame",
							{
								ZIndex = 3,
								Name = "Background",
								Size = UDim2.fromScale(1, 1),
								BackgroundColor3 = Color3.fromRGB(35, 35, 35),
								BackgroundTransparency = 0.25
							},
							{
								e("UICorner", {CornerRadius = UDim.new(0, 4)})
							}
						),
						e("Frame",
							{
								ZIndex = 3,
								AnchorPoint = Vector2.new(0.5, 0.5),
								Position = UDim2.fromScale(0.5, 0.5),
								Size = UDim2.fromScale(0.185, 0.185),
								BackgroundColor3 = Color3.fromRGB(35, 35, 35)
							},
							{
								e("UICorner", {CornerRadius = UDim.new(0, 4)}),
								e("UIPadding",
									{
										PaddingTop = UDim.new(0, 5)
									}
								),
								e("UIStroke",
									{
										Color = Color3.fromRGB(100, 100, 100),
										ApplyStrokeMode = Enum.ApplyStrokeMode.Border
									}
								),
								e("UIListLayout",
									{
										Padding = UDim.new(0, 6),
										SortOrder = Enum.SortOrder.LayoutOrder,
										FillDirection = Enum.FillDirection.Vertical
									}
								),
								e("Frame",
									{
										ZIndex = 3,
										Size = UDim2.new(1, 0, 0, 0),
										AutomaticSize = Enum.AutomaticSize.Y,
										BackgroundTransparency = 1
									},
									{
										e("Frame",
											{
												ZIndex = 3,
												Position = UDim2.new(0, 3, 1, 8),
												Size = UDim2.new(1, -6, 0, 1),
												BackgroundColor3 = Color3.fromRGB(100, 100, 100),
												BorderSizePixel = 0
											}
										),
										e("Frame",
											{
												ZIndex = 3,
												Size = UDim2.new(1, -10, 0, 0),
												AutomaticSize = Enum.AutomaticSize.Y,
												BackgroundTransparency = 1,
												Position = UDim2.fromOffset(10, 0)
											},
											{
												Return,
												e("Frame",
													{
														ZIndex = 3,
														LayoutOrder = -1,
														Size = UDim2.new(1, -125, 1, 0),
														AutomaticSize = Enum.AutomaticSize.Y,
														BackgroundTransparency = 1
													},
													{
														e("UIPadding",
															{
																PaddingTop = UDim.new(0, 5),
																PaddingBottom = UDim.new(0, 5)
															}
														),
														e("UIListLayout",
															{
																Padding = UDim.new(0, 2),
																SortOrder = Enum.SortOrder.LayoutOrder,
																FillDirection = Enum.FillDirection.Vertical
															}
														),
														Titleinfo,
														Descriptioninfo
													}
												)
											}
										)
									}
								),
								e("Frame",
									{
										ZIndex = 3,
										Size = UDim2.new(1, 0, 1, -45),
										BackgroundTransparency = 1
									},
									{
										ColorSelect,
										ColorPickerView,
										ColorPickerFrame,
										e("Frame",
											{
												ZIndex = 3,
												AnchorPoint = Vector2.new(0, 1),
												Position = UDim2.new(0, 25, 1, -30),
												Size = UDim2.new(1, -50, 0, 50),
												BackgroundTransparency = 1
											},
											{
												e("UICorner", {CornerRadius = UDim.new(0, 8)}),
												e("UIListLayout",
													{
														Padding = UDim.new(0, 6),
														SortOrder = Enum.SortOrder.LayoutOrder,
														FillDirection = Enum.FillDirection.Horizontal,
														HorizontalAlignment = Enum.HorizontalAlignment.Center
													}
												),
												e("Frame",
													{
														ZIndex = 3,
														Size = UDim2.new(0.33, -1, 1, 0),
														BackgroundTransparency = 1
													},
													{
														RedInput,
														e("UICorner", {CornerRadius = UDim.new(0, 6)}),
														e("UIStroke",
															{
																Color = Color3.fromRGB(100, 100, 100),
																ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
																Thickness = 1
															}
														)
													}
												),
												e("Frame",
													{
														ZIndex = 3,
														Size = UDim2.new(0.33, -1, 1, 0),
														BackgroundTransparency = 1
													},
													{
														GreenInput,
														e("UICorner", {CornerRadius = UDim.new(0, 6)}),
														e("UIStroke",
															{
																Color = Color3.fromRGB(100, 100, 100),
																ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
																Thickness = 1
															}
														)
													}
												),
												e("Frame",
													{
														ZIndex = 3,
														Size = UDim2.new(0.33, -1, 1, 0),
														BackgroundTransparency = 1
													},
													{
														BlueInput,
														e("UICorner", {CornerRadius = UDim.new(0, 6)}),
														e("UIStroke",
															{
																Color = Color3.fromRGB(100, 100, 100),
																ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
																Thickness = 1
															}
														)
													}
												)
											}
										)
									}
								)
							}
						)
					}
				)

				local J = function()
					local J = Color3.fromHSV(s.DataValue.Pos1, s.DataValue.Pos2, s.DataValue.Pos3)
					return {R = math.floor(J.r * 255), G = math.floor(J.g * 255), B = math.floor(J.b * 255)}
				end

				function s.UpdateColor()
					if s:LockState() then
						return
					end
					ColorPickerFrame.BackgroundColor3 = Color3.fromHSV(s.DataValue.Pos1, 1, 1)
					PointSelect.Position = UDim2.new(s.DataValue.Pos1, 0, 0, 0)
					ColorPickerPoint.Position = UDim2.new(s.DataValue.Pos2, 0, 1 - s.DataValue.Pos3, 0)
					ColorPickerView.Frame.BackgroundColor3 = Color3.fromHSV(s.DataValue.Pos1, s.DataValue.Pos2, s.DataValue.Pos3)
					ColorFrame1.BackgroundColor3 = Color3.fromHSV(s.DataValue.Pos1, s.DataValue.Pos2, s.DataValue.Pos3)
					RedInput.Text = J().R
					GreenInput.Text = J().G
					BlueInput.Text = J().B

					s.DataValue.Last["1"] = RedInput.Text
					s.DataValue.Last["2"] = GreenInput.Text
					s.DataValue.Last["3"] = BlueInput.Text

					Titleinfo.Text = d.Title.. " : ("..RedInput.Text..", "..GreenInput.Text..", "..BlueInput.Text..")"
					s.SetHSVFromRGB(Color3.fromRGB(J().R, J().G, J().B))
					local textdesb = Descriptioninfo.Visible and Descriptioninfo.TextBounds.Y or 6

					ColorPickerFrame.Parent.Size = UDim2.new(1, 0, 1, -(Titleinfo.TextBounds.Y + textdesb + 30))
				end

				Library.AddSignal(Titleinfo.Changed, function()
					local textdesb = Descriptioninfo.Visible and Descriptioninfo.TextBounds.Y or 6

					ColorPickerFrame.Parent.Size = UDim2.new(1, 0, 1, -(Titleinfo.TextBounds.Y + textdesb + 30))
				end)
				Library.AddSignal(Descriptioninfo.Changed, function()
					local textdesb = Descriptioninfo.Visible and Descriptioninfo.TextBounds.Y or 6

					ColorPickerFrame.Parent.Size = UDim2.new(1, 0, 1, -(Titleinfo.TextBounds.Y + textdesb + 30))
				end)

				Library.AddSignal(RedInput:GetPropertyChangedSignal("Text"), function()
					if RedInput.Text:len() > 0 and not tonumber(RedInput.Text) then
						RedInput.Text = s.DataValue.Last["1"]
					end
				end)

				Library.AddSignal(GreenInput:GetPropertyChangedSignal("Text"), function()
					if GreenInput.Text:len() > 0 and not tonumber(GreenInput.Text) then
						GreenInput.Text = s.DataValue.Last["2"]
					end
				end)

				Library.AddSignal(BlueInput:GetPropertyChangedSignal("Text"), function()
					if BlueInput.Text:len() > 0 and not tonumber(BlueInput.Text) then
						BlueInput.Text = s.DataValue.Last["3"]
					end
				end)

				Library.AddSignal(RedInput.FocusLost, function()
					if s:LockState() then
						RedInput.Text = s.DataValue.Last["1"]
						return
					end
					local ae = J()
					local af, ag = pcall(Color3.fromRGB, RedInput.Text, ae.G, ae.B)
					if af and typeof(ag) == "Color3" then
						if tonumber(RedInput.Text) <= 255 then
							s.DataValue.Pos1, s.DataValue.Pos2, s.DataValue.Pos3 = Color3.toHSV(ag)
						end
					end
					s.UpdateColor()
				end)

				Library.AddSignal(GreenInput.FocusLost, function()
					if s:LockState() then
						GreenInput.Text = s.DataValue.Last["2"]
						return
					end
					local ae = J()
					local af, ag = pcall(Color3.fromRGB, ae.R, GreenInput.Text, ae.B)
					if af and typeof(ag) == "Color3" then
						if tonumber(GreenInput.Text) <= 255 then
							s.DataValue.Pos1, s.DataValue.Pos2, s.DataValue.Pos3 = Color3.toHSV(ag)
						end
					end
					s.UpdateColor()
				end)

				Library.AddSignal(BlueInput.FocusLost, function()
					if s:LockState() then
						BlueInput.Text = s.DataValue.Last["3"]
						return
					end
					local ae = J()
					local af, ag = pcall(Color3.fromRGB, ae.R, ae.G, BlueInput.Text)
					if af and typeof(ag) == "Color3" then
						if tonumber(BlueInput.Text) <= 255 then
							s.DataValue.Pos1, s.DataValue.Pos2, s.DataValue.Pos3 = Color3.toHSV(ag)
						end
					end
					s.UpdateColor()
				end)

				Library.AddSignal(ColorSelect.InputBegan, function(input)
					if s:LockState() then
						return
					end
					if
						input.UserInputType == Enum.UserInputType.MouseButton1 or
							input.UserInputType == Enum.UserInputType.Touch
					then
						while k:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
							local ne = game:GetService "Players".LocalPlayer:GetMouse()
							local ae = ColorSelect.AbsolutePosition.X
							local af = ae + ColorSelect.AbsoluteSize.X
							local ag = math.clamp(ne.X, ae, af)
							s.DataValue.Pos1 = ((ag - ae) / (af - ae))
							s.UpdateColor()
							game:GetService "RunService".RenderStepped:Wait()
						end
					end
				end)

				Library.AddSignal(ColorPickerFrame.InputBegan, function(input)
					if s:LockState() then
						return
					end
					if
						input.UserInputType == Enum.UserInputType.MouseButton1 or
							input.UserInputType == Enum.UserInputType.Touch
					then
						while k:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
							local ne = game:GetService "Players".LocalPlayer:GetMouse()
							local ae = ColorPickerFrame.AbsolutePosition.X
							local af = ae + ColorPickerFrame.AbsoluteSize.X
							local ag, ah = math.clamp(ne.X, ae, af), ColorPickerFrame.AbsolutePosition.Y
							local ai = ah + ColorPickerFrame.AbsoluteSize.Y
							local aj = math.clamp(ne.Y, ah, ai)
							s.DataValue.Pos2 = (ag - ae) / (af - ae)
							s.DataValue.Pos3 = 1 - ((aj - ah) / (ai - ah))
							s.UpdateColor()
							game:GetService "RunService".RenderStepped:Wait()
						end
					end
				end)

				function s.Open()
					if s:LockState() then
						return
					end
					ContainerFrame.Visible = true
					Utility.Tween(ContainerFrame.Frame, {Size = UDim2.new(0.95, 0, 0.95, 0)}, 0.5, true)
				end

				function s.Close()
					Library.SafeCallback(changedD, s.Value)
					Library.SafeCallback(l.Callback, s.Value)

					Utility.Tween(ContainerFrame.Frame, {Size = UDim2.new(0.185, 0, 0.185, 0)}, 0.5, true)
					ContainerFrame.Visible = false
				end

				function s:Lock()
					s:Close()
					Locked = true
					d.LockButton.Visible = true
					d.LockLabel.Visible = true
					Utility.Tween(d.LockLabel, {BackgroundTransparency = 0.75, Size = UDim2.fromScale(1, 1)}, 0.35, true)
				end

				function s:Unlock()
					Locked = false
					d.LockButton.Visible = false
					Utility.Tween(d.LockLabel, {BackgroundTransparency = 1, Size = UDim2.fromScale(0, 0)}, 0.35, true)
					d.LockLabel.Visible = false
				end

				Library.AddSignal(Return.MouseButton1Click, s.Close)

				Library.AddSignal(ColorButton.InputBegan, function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						s.Open()
					end
				end)

				function s:OnChanged(changed)
					changedD = changed
					changed(s.Value)
				end
				function s:Display()
					s.Value = Color3.fromHSV(s.DataValue.Pos1, s.DataValue.Pos2, s.DataValue.Pos3)
					ColorFrame1.BackgroundColor3 = s.Value
					s.UpdateColor()
					Library.SafeCallback(changedD, s.Value)
					Library.SafeCallback(l.Callback, s.Value)
				end
				function s:SetValue(value)
					local af = Color3.fromHSV(value[1], value[2], value[3])
					s.SetHSVFromRGB(af)
					s:Display()
				end

				function s:SetValueRGB(ad)
					s.SetHSVFromRGB(ad)
					s:Display()
				end

				function s:SetTitle(text)
						 d:SetTitle(text)
						 Titleinfo.Text = text
						 s.UpdateColor()
				end

		   		function s:SetSubTitle(text)
						 d:SetSubTitle(text)
						 Descriptioninfo.Text = text
						 s.UpdateColor()

						 Descriptioninfo.Visible = #text > 0 and true or false
		   		end
				s:SetValueRGB(s.Value)
				Library.AddConfigs(n, s)
				s.UpdateColor()
				return s
			end

			function h:AddSection(Configs)
				local n, s = {},
							 {}

				Configs.Page = Configs.Page and Configs.Page or 1
				Configs.Page = Configs.Page > 3 and 1 or Configs.Page == 0 and 1 or Configs.Page

				local CurrentPage = Page[h.Tab].Page[Configs.Page]
					  CurrentPage.count = (CurrentPage.count and CurrentPage.count + 1) or 1

				s.SectionFrame = e("Frame",
					{
						Size = UDim2.new(1, 0, 1, -24),
						Position = UDim2.fromOffset(0, 24),
						BackgroundTransparency = 1
					},
					{
						e("UIStroke",
							{
								Color = Color3.fromRGB(100, 100, 100),
								ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
								Thickness = 1,
								Transparency = 0
							}
						),
						e("UICorner",
							{
								CornerRadius = UDim.new(0, 4)
							}
						),
						e("UIPadding",
							{
								PaddingBottom = UDim.new(0, 6),
								PaddingTop = UDim.new(0, 6),
								PaddingLeft = UDim.new(0, 6)
							}
						),
						e("UIListLayout",
							{
								SortOrder = Enum.SortOrder.LayoutOrder,
								Padding = UDim.new(0, 5),
								FillDirection = Enum.FillDirection.Vertical
							}
						)
					}
				)

				n.SectionContent = e("TextLabel",
					{
						TextWrapped = true,
						TextXAlignment = Enum.TextXAlignment.Left,
						TextSize = 16,
						BackgroundTransparency = 1,
						Size = UDim2.new(1, -2, 0, 0),
						Position = UDim2.fromOffset(2, 0),
						Text = Configs.Title or "Section "..tostring(h.Tab),
						AutomaticSize = Enum.AutomaticSize.Y,
						FontFace = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Bold, Enum.FontStyle.Normal),
						TextColor3 = Color3.fromRGB(175, 175, 175)
					}
				)

				e("Frame",
					{
						Parent = c.Page[Configs.Page].Frame,
						AutomaticSize = Enum.AutomaticSize.Y,
						Size = UDim2.new(1, -4, 0, 0),
						BackgroundTransparency = 1
					},
					{
						s.SectionFrame,
						n.SectionContent
					}
				)

				function s:SetTitle(text)
					n.SectionContent.Text = tostring(text)
					n.SectionContent.TextLabel.Text = tostring(text)
				end

				function s:AddButton(v)
					local d = h:AddButton(v)

					d.Frame.Parent = s.SectionFrame
					return d
				end

				function s:AddParagraph(v)
					local d = h:AddParagraph(v)

					d.Frame.Parent = s.SectionFrame
					return d
				end

				function s:AddTextBox(v, o)
					local d = h:AddTextBox(v, o)

					d.Frame.Parent = s.SectionFrame
					return d
				end

				function s:AddSlider(v, o)
					local d = h:AddSlider(v, o)

					d.Frame.Parent = s.SectionFrame
					return d
				end

				function s:AddToggle(v, o)
					local d = h:AddToggle(v, o)

					d.Frame.Parent = s.SectionFrame
					return d
				end

				function s:AddDropdown(v, o)
					local d = h:AddDropdown(v, o)

					d.Frame.Parent = s.SectionFrame
					return d
				end

				function s:AddKeybind(v, o)
					local d = h:AddKeybind(v, o)

					d.Frame.Parent = s.SectionFrame
					return d
				end

				function s:AddColorPicker(v, o)
					local d = h:AddColorPicker(v, o)

					d.Frame.Parent = s.SectionFrame
					return d
				end

				return s
			end
			return h
		end

		function t:SelectTab(Tab)
			if Tab == Library.SelectTab then
				return
			end
			task.spawn(function()
				repeat
					SearchbarInput.Text = ""
					task.wait()
				until SearchbarInput.Text == "" or Library.Unloaded
				Library.SelectTab = Tab
			end)
			if Tab > 0 then
				Page[Tab].Container.Visible = true

				Utility.Tween(Page[Tab].TabFrame, {BackgroundTransparency = 0.875}, 0.4)
				Utility.Tween(Page[Tab].TabFrame.TextLabel, {TextColor3 = Color3.fromRGB(82, 255, 255)}, 0.4)

				Utility.Tween(Page[Tab].Point, {Size = UDim2.new(1, -8, 0, 1), BackgroundTransparency = 0.25}, 0.4)
			end
			for l,v in next, Page do
				if l ~= Tab then
					v.Container.Visible = false

					Utility.Tween(v.TabFrame, {BackgroundTransparency = 1}, 0.4)
					Utility.Tween(v.TabFrame.TextLabel, {TextColor3 = Color3.fromRGB(200, 200, 200)}, 0.4)

					Utility.Tween(v.Point, {Size = UDim2.new(0, 0, 0, 1), BackgroundTransparency = 1}, 0.4)
				end
			end
		end

		return t
	end
	return Library
end
