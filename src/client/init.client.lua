local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local FastCastRedux = require(ReplicatedStorage.Shared.FastCastRedux)

local caster = FastCastRedux.new()
local castParams = RaycastParams.new()
castParams.IgnoreWater = true
castParams.FilterType = Enum.RaycastFilterType.Exclude
castParams.FilterDescendantsInstances = {}

local bulletsFolder = workspace:FindFirstChild("Bullets") or Instance.new("Folder", workspace)
bulletsFolder.Name = "Bullets"

local castBehavior = FastCastRedux.newBehavior()
castBehavior.RaycastParams = castParams
castBehavior.CosmeticBulletContainer = bulletsFolder
castBehavior.CosmeticBulletTemplate = ReplicatedStorage.Assets.Bullet
castBehavior.AutoIgnoreContainer = true

caster.CastTerminating:Connect(function(cast)
    local bullet = cast.RayInfo.CosmeticBulletObject
    if bullet then
        bullet:Remove()
    end
end)

caster.LengthChanged:Connect(function(cast, origin, direction, length, velocity, bullet)
    if bullet then
        bullet.CFrame = CFrame.new(origin, origin + direction) * CFrame.new(0, 0, -length / (bullet.Size.Z / 2))
    end
end)

caster.RayHit:Connect(function(cast, raycastResult, velocity, bullet)
    if raycastResult and bullet then
        local normal = raycastResult.Normal
        local incomingDirection = velocity.Unit
        local reflection = incomingDirection - 2 * incomingDirection:Dot(normal) * normal

        local newVelocity = (reflection * velocity.Magnitude) * 0.7 -- reduce 30%
        if newVelocity.Magnitude > 10 then
            caster:Fire(raycastResult.Position, newVelocity, newVelocity.Magnitude, castBehavior)
        end
    end
end)

local camera = workspace.CurrentCamera
UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
    if gameProcessedEvent then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        local mousePos = UserInputService:GetMouseLocation()
        local ray = camera:ScreenPointToRay(mousePos.X, mousePos.Y)
        local origin = ray.Origin
        local direction = ray.Direction * 1000

        --                                         ↓ (BulletMass)    ↓ (Config 0.1 at 1)
        castBehavior.Acceleration = Vector3.new(0, 0.087 * 196.2 - 0.25 * 196.2, 0)
        local cast = caster:Fire(origin, direction, 500, castBehavior)
    end
end)
