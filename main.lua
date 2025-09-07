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

local function showNotification(message, duration, autoRemove)
	duration = duration or 3
	local notifGui = getNotificationGui()

	local notifFrame = Instance.new("Frame")
	notifFrame.Size = UDim2.new(0, 280, 0, 60)
	notifFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
	notifFrame.BackgroundTransparency = 0.1
	notifFrame.BorderSizePixel = 0
	notifFrame.AnchorPoint = Vector2.new(1, 0)
	notifFrame.Position = UDim2.new(1, 300, 0, 20)
	notifFrame.ZIndex = 1000
	notifFrame.Parent = notifGui

	local corner = Instance.new("UICorner", notifFrame)
	corner.CornerRadius = UDim.new(0, 14)

	local titleLabel = Instance.new("TextLabel", notifFrame)
	titleLabel.Size = UDim2.new(0, 100, 0, 20)
	titleLabel.Position = UDim2.new(0, 10, 0, 5)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = "Renz Notify"
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.TextSize = 16
	titleLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
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

	notifFrame.BackgroundTransparency = 1
	TweenService:Create(notifFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		BackgroundTransparency = 0.1,
		Position = UDim2.new(1, -20, 0, 20 + (#activeNotifications) * (notifFrame.Size.Y.Offset + 10))
	}):Play()

	table.insert(activeNotifications, notifFrame)

	if autoRemove then
		task.delay(duration, function()
			if notifFrame and notifFrame.Parent then
				TweenService:Create(notifFrame, TweenInfo.new(0.3), {
					BackgroundTransparency = 1,
					Position = UDim2.new(1, 300, 0, notifFrame.Position.Y.Offset)
				}):Play()
				task.wait(0.35)
				notifFrame:Destroy()
				for i, frame in ipairs(activeNotifications) do
					if frame == notifFrame then
						table.remove(activeNotifications, i)
						break
					end
				end
			end
		end)
	end
end

local function findTycoonStepByStep()
	local tycoons = workspace:WaitForChild("Tycoons")

	showNotification("👤 Display: " .. displayName, 4, true)
	task.wait(1.5)

	for i = 1, 10 do
		local tycoon = tycoons:FindFirstChild(tostring(i))
		local found = false

		if tycoon then
			local door = tycoon:FindFirstChild("Extras") and tycoon.Extras:FindFirstChild("Door")
			if door then
				for _, obj in ipairs(door:GetChildren()) do
					if obj:IsA("Model") and string.find(obj.Name, displayName) then
						showNotification("✅ Found at Tycoon " .. i, 1.2, false)
						found = true
						break
					end
				end
			end
		end

		if not found then
			showNotification("❌ Not Found at Tycoon " .. i, 0.4, true)
		else
			break
		end

		task.wait(0.70)
	end
end

findTycoonStepByStep()
