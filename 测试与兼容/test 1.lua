local unpack = unpack or table.unpack
local select = select

local function createCurry(fn, ...)
    local initialArgs = {...}
    local initialCount = select("#", ...)
    return function(...)
        local currentArgs = {}
        for i = 1, initialCount do
            currentArgs[i] = initialArgs[i]
        end
        local newArgs = {...}
        local newCount = select("#", ...)
        for i = 1, newCount do
            currentArgs[initialCount + i] = newArgs[i]
        end
        return fn(unpack(currentArgs, 1, initialCount + newCount))
    end
end

local Vector2D
Vector2D = function(x, y)
    local self = { x = x or 0, y = y or 0 }
    local mt = {
        __add = function(a, b)
            return Vector2D(a.x + b.x, a.y + b.y)
        end,
        __sub = function(a, b)
            return Vector2D(a.x - b.x, a.y - b.y)
        end,
        __mul = function(a, b)
            if type(b) == "number" then
                return Vector2D(a.x * b, a.y * b)
            end
            return Vector2D(a.x * b.x, a.y * b.y)
        end,
        __eq = function(a, b)
            return a.x == b.x and a.y == b.y
        end,
        __tostring = function(t)
            return t.x .. "," .. t.y
        end
    }
    return setmetatable(self, mt)
end

local function parseAndEval(str)
    local index = 1
    local length = #str

    local function peek()
        if index > length then return nil end
        return str:sub(index, index)
    end

    local function consume()
        local char = peek()
        index = index + 1
        return char
    end

    local function parseNumber()
        local start = index
        while peek() and peek():match("%d") do
            consume()
        end
        return tonumber(str:sub(start, index - 1)) or 0
    end

    local parseExpression

    local function parseFactor()
        local char = peek()
        if char == "(" then
            consume()
            local val = parseExpression()
            consume()
            return val
        elseif char and char:match("%d") then
            return parseNumber()
        end
        return 0
    end

    local function parseTerm()
        local val = parseFactor()
        while true do
            local char = peek()
            if char == "*" then
                consume()
                val = val * parseFactor()
            elseif char == "/" then
                consume()
                val = val / parseFactor()
            else
                break
            end
        end
        return val
    end

    parseExpression = function()
        local val = parseTerm()
        while true do
            local char = peek()
            if char == "+" then
                consume()
                val = val + parseTerm()
            elseif char == "-" then
                consume()
                val = val - parseTerm()
            else
                break
            end
        end
        return val
    end

    return parseExpression()
end

local function runTests()
    local function recurse(depth, ...)
        if depth <= 0 then
            return ...
        end
        return recurse(depth - 1, depth, ...)
    end
    local r1, r2, r3 = recurse(3, "a", "b")
    if r1 ~= 1 or r2 ~= 2 or r3 ~= 3 then
        return false, "T1"
    end

    local function makeNest(val)
        return function(a)
            return function(b)
                return function(c)
                    return val + a + b + c
                end
            end
        end
    end
    local val = makeNest(10)(20)(30)(40)
    if val ~= 100 then
        return false, "T2"
    end

    local errObj = setmetatable({ msg = "custom_err" }, {
        __tostring = function(self)
            return self.msg
        end
    })
    local xpSuccess, xpErr = xpcall(function()
        error(errObj)
    end, function(err)
        return "handled_" .. tostring(err)
    end)
    if xpSuccess or xpErr ~= "handled_custom_err" then
        return false, "T3"
    end

    local state = { val = 5 }
    local mt = {
        __index = state,
        __call = function(self, inc)
            state.val = state.val + inc
            return state.val
        end
    }
    local trackerObj = setmetatable({}, mt)
    trackerObj(10)
    if trackerObj.val ~= 15 then
        return false, "T4"
    end

    local loopTbl = { k1 = 1, k2 = 2 }
    local loopCount = 0
    for k, v in next, loopTbl do
        loopCount = loopCount + 1
        if k == "k1" then
            loopTbl.k3 = 3
        end
    end
    if loopCount < 2 then
        return false, "T5"
    end

    local function targetFn(...)
        local sum = 0
        for i = 1, select("#", ...) do
            sum = sum + (select(i, ...) or 0)
        end
        return sum
    end
    local curried = createCurry(targetFn, 1, 2)
    local curryRes = curried(3, 4)
    if curryRes ~= 10 then
        return false, "T6"
    end

    local shared_var = 10
    local co1 = coroutine.create(function()
        shared_var = shared_var + 5
        coroutine.yield()
        shared_var = shared_var + 10
    end)
    local co2 = coroutine.create(function()
        shared_var = shared_var * 2
        coroutine.yield()
        shared_var = shared_var * 3
    end)
    coroutine.resume(co1)
    coroutine.resume(co2)
    coroutine.resume(co1)
    coroutine.resume(co2)
    if shared_var ~= 120 then
        return false, "T7"
    end

    local function runEnvTest()
        local success = pcall(function()
            local originalG = getfenv(0)
            local newEnv = setmetatable({}, {
                __index = function(_, k)
                    if k == "secretValue" then
                        return 42
                    end
                    return originalG[k]
                end
            })
            local f = function()
                return secretValue
            end
            setfenv(f, newEnv)
            if f() ~= 42 then
                error()
            end
        end)
        return success
    end
    if not runEnvTest() then
        return false, "T8"
    end

    local function tailNested(n, acc)
        if n <= 0 then
            return unpack(acc)
        end
        table.insert(acc, n)
        return tailNested(n - 1, acc)
    end
    local tailSuccess, tr1, tr2, tr3 = pcall(function()
        return tailNested(3, {})
    end)
    if not tailSuccess or tr1 ~= 3 or tr2 ~= 2 or tr3 ~= 1 then
        return false, "T9"
    end

    local function repeatScope()
        local a = 0
        repeat
            local b = a + 5
            a = a + 1
        until b > 8
        return a
    end
    if repeatScope() ~= 5 then
        return false, "T10"
    end

    local v1 = Vector2D(10, 20)
    local v2 = Vector2D(5, 5)
    local v3 = v1 - v2
    if v3.x ~= 5 or v3.y ~= 15 then
        return false, "T11"
    end

    return true, "All Tests Passed"
end

local isRoblox = false
pcall(function()
    if game and game.GetService then
        isRoblox = true
    end
end)

if isRoblox then
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    local CoreGui = game:GetService("CoreGui")
    local UserInputService = game:GetService("UserInputService")

    local function getUIParent()
        local success, parent = pcall(function()
            return CoreGui
        end)
        if success and parent then
            return parent
        end
        return LocalPlayer:WaitForChild("PlayerGui")
    end

    local parent = getUIParent()

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "Test_Compatibility_Suite"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = parent

    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 350, 0, 250)
    mainFrame.Position = UDim2.new(0.5, -175, 0.5, -125)
    mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    mainFrame.BorderSizePixel = 0
    mainFrame.Active = true
    mainFrame.Parent = screenGui

    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = UDim.new(0, 8)
    uiCorner.Parent = mainFrame

    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 40)
    titleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainFrame

    local barCorner = Instance.new("UICorner")
    barCorner.CornerRadius = UDim.new(0, 8)
    barCorner.Parent = titleBar

    local fixCorner = Instance.new("Frame")
    fixCorner.Size = UDim2.new(1, 0, 0, 10)
    fixCorner.Position = UDim2.new(0, 0, 1, -10)
    fixCorner.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    fixCorner.BorderSizePixel = 0
    fixCorner.Parent = titleBar

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 1, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "Obfuscation Suite (Draggable)"
    titleLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
    titleLabel.TextSize = 16
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.Parent = titleBar

    local statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(1, -20, 0, 30)
    statusLabel.Position = UDim2.new(0, 10, 0, 50)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "Status: Ready"
    statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    statusLabel.TextSize = 14
    statusLabel.Font = Enum.Font.SourceSans
    statusLabel.Parent = mainFrame

    local runButton = Instance.new("TextButton")
    runButton.Size = UDim2.new(1, -20, 0, 40)
    runButton.Position = UDim2.new(0, 10, 0, 90)
    runButton.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
    runButton.Text = "Execute VM Test"
    runButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    runButton.TextSize = 16
    runButton.Font = Enum.Font.SourceSansBold
    runButton.Parent = mainFrame

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = runButton

    local inputField = Instance.new("TextBox")
    inputField.Size = UDim2.new(1, -20, 0, 40)
    inputField.Position = UDim2.new(0, 10, 0, 140)
    inputField.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    inputField.Text = "5+10*2+3"
    inputField.TextColor3 = Color3.fromRGB(255, 255, 255)
    inputField.TextSize = 14
    inputField.Font = Enum.Font.SourceSans
    inputField.Parent = mainFrame

    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0, 6)
    inputCorner.Parent = inputField

    local resultLabel = Instance.new("TextLabel")
    resultLabel.Size = UDim2.new(1, -20, 0, 40)
    resultLabel.Position = UDim2.new(0, 10, 0, 190)
    resultLabel.BackgroundTransparency = 1
    resultLabel.Text = "Result: -"
    resultLabel.TextColor3 = Color3.fromRGB(0, 255, 128)
    resultLabel.TextSize = 16
    resultLabel.Font = Enum.Font.SourceSansBold
    resultLabel.Parent = mainFrame

    local dragging = false
    local dragInput
    local dragStart = Vector2D(0, 0)
    local startPos = Vector2D(0, 0)

    local function updateDrag(input)
        local delta = Vector2D(input.Position.x, input.Position.y) - dragStart
        local newPos = startPos + delta
        mainFrame.Position = UDim2.new(0, newPos.x, 0, newPos.y)
    end

    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragInput = input
            local mouseLoc = UserInputService:GetMouseLocation()
            dragStart = Vector2D(mouseLoc.X, mouseLoc.Y)
            startPos = Vector2D(mainFrame.AbsolutePosition.X, mainFrame.AbsolutePosition.Y)

            local connection
            connection = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    connection:Disconnect()
                end
            end)
        end
    end)

    titleBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local mouseLoc = UserInputService:GetMouseLocation()
            updateDrag({ Position = Vector2D(mouseLoc.X, mouseLoc.Y) })
        end
    end)

    runButton.MouseEnter:Connect(function()
        runButton.BackgroundColor3 = Color3.fromRGB(0, 140, 240)
    end)

    runButton.MouseLeave:Connect(function()
        runButton.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
    end)

    runButton.MouseButton1Click:Connect(function()
        coroutine.wrap(function()
            local ok, err = pcall(function()
                local success, msg = runTests()
                if success then
                    statusLabel.Text = "Status: Verification Complete"
                    resultLabel.Text = "Result: SUCCESS (" .. msg .. ")"
                    resultLabel.TextColor3 = Color3.fromRGB(0, 255, 128)
                else
                    statusLabel.Text = "Status: Verification Failed"
                    resultLabel.Text = "Result: FAIL (" .. msg .. ")"
                    resultLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
                end
            end)
            if not ok then
                statusLabel.Text = "Status: Run Error"
                resultLabel.Text = "Result: CRASH (" .. tostring(err):sub(1, 30) .. ")"
                resultLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
            end
        end)()
    end)

    inputField.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            local expr = inputField.Text:gsub("%s+", "")
            local ok, val = pcall(function()
                return parseAndEval(expr)
            end)
            if ok then
                resultLabel.Text = "Parsed Result: " .. tostring(val)
                resultLabel.TextColor3 = Color3.fromRGB(0, 255, 128)
            else
                resultLabel.Text = "Parse Error!"
                resultLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
            end
        end
    end)
else
    local success, msg = runTests()
    if success then
        print("SUCCESS: " .. msg)
        local expr = "5+10*2+3"
        print("Parsed expression '" .. expr .. "': " .. tostring(parseAndEval(expr)))
    else
        print("FAIL: " .. msg)
    end
end
