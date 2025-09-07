local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local displayName = player.DisplayName

local function getNotificationGui()
	local notifGui = player:WaitForChild("PlayerGui"):FindFirstChild("AdvancedNotificationGui")
	if not notifGui then
		notifGui = Instance.new("ScreenGui")
		notifGui.Name = "AdvancedNotificationGui"
		notifGui.ResetOnSpawn = false
		notifGui.IgnoreGuiInset = true
		notifGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		notifGui.Parent = player:WaitForChild("PlayerGui")
	end
	return notifGui
end

local activeNotifications = {}

local function showNotification(message, duration, type)
	duration = duration or 3
	local notifGui = getNotificationGui()

	local notifFrame = Instance.new("Frame")
	notifFrame.Size = UDim2.new(0, 280, 0, 60)
	notifFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	notifFrame.BackgroundTransparency = 0
	notifFrame.BorderSizePixel = 0
	notifFrame.AnchorPoint = Vector2.new(1, 0)
	notifFrame.Position = UDim2.new(1, 300, 0, 20)
	notifFrame.ZIndex = 1000
	notifFrame.Parent = notifGui

	local corner = Instance.new("UICorner", notifFrame)
	corner.CornerRadius = UDim.new(0, 14)

	local stroke = Instance.new("UIStroke", notifFrame)
	stroke.Thickness = 2

	if type == "display" then
		stroke.Color = Color3.fromRGB(0, 170, 255)
	elseif type == "found" then
		stroke.Color = Color3.fromRGB(0, 200, 0)
	elseif type == "notfound" then
		stroke.Color = Color3.fromRGB(200, 0, 0)
	elseif type == "running" then
		stroke.Color = Color3.fromRGB(255, 165, 0) -- turuncu
	elseif type == "loaded" then
		stroke.Color = Color3.fromRGB(0, 200, 0) -- yeşil
	end

	local titleLabel = Instance.new("TextLabel", notifFrame)
	titleLabel.Size = UDim2.new(0, 100, 0, 20)
	titleLabel.Position = UDim2.new(0, 10, 0, 5)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = "Renz Notify"
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.TextSize = 16
	titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.ZIndex = 1001

	local label = Instance.new("TextLabel", notifFrame)
	label.Size = UDim2.new(1, -30, 0, 40)
	label.Position = UDim2.new(0, 10, 0, 25)
	label.BackgroundTransparency = 1
	label.Text = message
	label.Font = Enum.Font.GothamBold
	label.TextSize = 14
	label.TextColor3 = Color3.fromRGB(230, 230, 255)
	label.TextWrapped = true
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.ZIndex = 1001

	table.insert(activeNotifications, notifFrame)

	for i, frame in ipairs(activeNotifications) do
		local targetY = 20 + (i - 1) * (frame.Size.Y.Offset + 10)
		TweenService:Create(frame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Position = UDim2.new(1, -20, 0, targetY)
		}):Play()
	end

	task.delay(duration, function()
		if notifFrame and notifFrame.Parent then
			local tweenOut = TweenService:Create(notifFrame, TweenInfo.new(0.3), {
				BackgroundTransparency = 1,
				Position = UDim2.new(1, 300, 0, notifFrame.Position.Y.Offset)
			})
			tweenOut:Play()
			tweenOut.Completed:Wait()
			notifFrame:Destroy()

			for i, frame in ipairs(activeNotifications) do
				if frame == notifFrame then
					table.remove(activeNotifications, i)
					break
				end
			end

			for i, frame in ipairs(activeNotifications) do
				local targetY = 20 + (i - 1) * (frame.Size.Y.Offset + 10)
				TweenService:Create(frame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
					Position = UDim2.new(1, -20, 0, targetY)
				}):Play()
			end
		end
	end)
end

local function startAutoClicker(tycoonNum)
	local clickerPath = workspace.Tycoons:FindFirstChild(tostring(tycoonNum))
	if not clickerPath then return end

	local clickDetector = clickerPath:WaitForChild("Extras"):WaitForChild("IgnoredBase")
		:WaitForChild("1stFloorClickToEarn"):WaitForChild("clicker"):WaitForChild("ClickDetector")

	showNotification("⚡ Running Auto Clicker...", 1.3, "running")
	task.wait(1.3)
	showNotification("✅ Loaded!", 1.3, "loaded")
	task.wait(1.3)

	while true do
		if clickDetector then
			fireclickdetector(clickDetector)
		end
		task.wait(0.35)
	end
end

local function findTycoonStepByStep()
	local tycoons = workspace:WaitForChild("Tycoons")
	local foundTycoonNum = nil

	showNotification("👤 Display: " .. displayName, 1.5, "display")
	task.wait(1.5)

	for i = 1, 10 do
		local tycoon = tycoons:FindFirstChild(tostring(i))
		local found = false

		if tycoon then
			local door = tycoon:FindFirstChild("Extras") and tycoon.Extras:FindFirstChild("Door")
			if door then
				for _, obj in ipairs(door:GetChildren()) do
					if obj:IsA("Model") and string.find(obj.Name, displayName) then
						showNotification("✅ Found at Tycoon " .. i, 2.5, "found")
						found = true
						foundTycoonNum = i
						break
					end
				end
			end
		end

		if not found then
			showNotification("❌ Not Found at Tycoon " .. i, 0.4, "notfound")
		else
			task.wait(0.5)
			break
		end

		task.wait(0.40)
	end

	if foundTycoonNum then
		startAutoClicker(foundTycoonNum)
	end
end

findTycoonStepByStep()
