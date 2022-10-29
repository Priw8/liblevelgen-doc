local libLevelGen = require "LibLevelGen.LibLevelGen"
local segment = require "LibLevelGen.Segment"
local room = require "LibLevelGen.Room"

local roomGenCombinations = segment.createRandLinkedRoomParameterCombinations {
    direction = {room.Direction.UP, room.Direction.DOWN, room.Direction.LEFT, room.Direction.RIGHT},
    corridorEntrance = {0.25, 0.5, 0.75},
    corridorExit = {0.25, 0.5, 0.75},
    corridorThickness = {3},
    corridorLength = {0, 1, 2},
    roomWidth = {6, 7, 8, 9},
    roomHeight = {6, 7, 8, 9},
}

local function createExit(currentRoom)
    currentRoom:makeExit { {"Dragon", 1}, {"Minotaur", 1} }
end

local function createTwoRooms(currentRoom, roomsLeft, needsExit)
    if roomsLeft > 0 then
        local newCorridor1, newRoom1 = currentRoom.segment:createRandLinkedRoom(currentRoom, false, roomGenCombinations)
        local newCorridor2, newRoom2 = currentRoom.segment:createRandLinkedRoom(currentRoom, false, roomGenCombinations)
        -- Check if the generation didn't fail:
        if newRoom1 then
            createTwoRooms(newRoom1, roomsLeft - 1, needsExit)
        end
        if newRoom2 then
            createTwoRooms(newRoom2, roomsLeft - 1, false)
        end
    elseif needsExit then
        createExit(currentRoom)
    end
end

local function placeEnemies(currentRoom)
    currentRoom:placeEntityAt(1, 1, "Skeleton", 2)
end

local function myGenerator(genParams)
    local instance = libLevelGen.new(genParams)

    local mainSegment = instance:createSegment()
    local startingRoom = mainSegment:createStartingRoom()

    createTwoRooms(startingRoom, 2, true)

    mainSegment:iterateRooms(room.Flag.ALLOW_ENEMY, placeEnemies)

    mainSegment:placeWallTorches(2)

    instance:finalize()
end

libLevelGen.registerGenerator("LibLevelGen Playground", myGenerator)
