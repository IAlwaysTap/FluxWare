local MarketplaceService = game:GetService("MarketplaceService")
local Info = MarketplaceService:GetProductInfo(game.PlaceId)

local GameInfo = {
    Name = Info.Name,
    Creator = {
        Name = Info.Creator.Name
    }
}

local Link = "https://raw.githubusercontent.com/IAlwaysTap/FluxWare/main/fluxware/"
local Name = ""

if GameInfo.Creator.Name == "Wiggity." then
    Name = "bladeball.lua"
elseif GameInfo.Name and GameInfo.Name:find("Prison Life") then
    Name = "prisonlife.lua"
elseif GameInfo.Creator.Name == "Uplift Games" then
    Name = "adotpmepetspawn.lua"
elseif GameInfo.Creator.Name == "ROLVe" then
    Name = "arsenal.lua"
elseif GameInfo.Creator.Name == "CRIMCORP" then
    Name = "criminality.lua"
elseif GameInfo.Creator.Name == "Wave of Brainrots" then
    Name = "escapeabrainrot.lua"
elseif GameInfo.Creator.Name == "Polygon Interactive" then
    Name = "defusal.lua"
elseif GameInfo.Creator.Name == "Volleyball Game Group" then
    Name = "volleyballlegends.lua"
end

if Name ~= "" then
    loadstring(game:HttpGet(Link .. Name))()
end
