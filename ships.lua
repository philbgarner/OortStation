local ships = {}

local shipname_list = {
  "Machopekin"
  ,"Cape Mendocino"
  ,"Bufino"
  ,"Tours"
  ,"Patroller"
  ,"Degoutte"
  ,"Empire Goodwin"
  ,"Hida Maru"
  ,"Barth"
  ,"Past Time"
  ,"Babinda"
  ,"Chateau Larose"
  ,"Archer"
  ,"Empire Lakeland"
  ,"Ostpreussen"
  ,"St. Julien"
  ,"Stafford Maru"
  ,"Chacartegui 3"
  ,"Le Progrs"
  ,"J. L. M. Curry"
  ,"Gesto"
  ,"Diva"
  ,"Janaki"
  ,"Herta"
  ,"Mera"
  ,"Lindsey"
  ,"Balva"
  ,"Courcelles"
  ,"Korab IV"
  ,"Port Sydney"
  ,"Colombia Victory"
  ,"Potengy"
  ,"Ledokol VI"
  ,"Beiriz"
  ,"Daitojima Maru"
  ,"Ed.Munch"
  ,"Kulu"
  ,"Monn's Isle"
  ,"Briele"
  ,"Doughboy"
  ,"Frederick"
  ,"Newton Ash"
  ,"Empire Ibox"
  ,"King Cenric"
  ,"Platypus III"
  ,"Skogafoss"
  ,"Andes Marn"
  ,"NO KA OE"
  ,"Raka"
}

require "aimodules"

function ships:createShip(shipWorld, shipName, x, y)
  if shipName == nil then
    shipName = shipname_list[love.math.random(1, #shipname_list)]
  end
  local ship = {
      name = shipName
      ,portraitid = 1
      ,passengers = {}
      ,hangar = {}
      ,hangar_max = 0
      ,station = false
      ,health = 100
      ,velocity = 0
      ,throttle = 0
      ,vectorX = 0
      ,vectorY = 0
      ,rotation = 0
      ,animation = {}
      ,animationId = nil
      ,body = nil
      ,shape = nil
      ,fixture = nil
      ,density = 1
      ,weapons = {1, 0, 0, 0, 0}
      ,weaponSelId = 1
      ,world = shipWorld
      ,cargo_ore = 0
      ,cargo_ore_max = 50
      ,cargo_inv = {}
      ,cargo_inv_max = 10
      ,credits = 2500
      ,aiship = false
      ,canDock = true
      ,isDocked = false
      ,target = nil
      ,location = nil 
      ,market_prices = nil -- Ship, not a station.
  }
  ship.body = love.physics.newBody(shipWorld, x, y, "dynamic")
  ship.shape = love.physics.newCircleShape(-20, -20, 40)
  ship.fixture = love.physics.newFixture(ship.body, ship.shape, ship.density)
  ship.fixture:setRestitution(0.1)
  ship.fixture:setUserData("Ship")
  ship.fixture:setFilterData(0x001, 0x002, 0)
    
  local prs = personae:create(sectorX, sectorY, ship)
  prs.name = "Player"
  prs.surname = "One"
  ship.portraitid = prs.portraitid
  table.insert(ship.passengers, prs)
    
  return ship
end

function ships:getShipIndex(list, ship)
  for i=1, #list do
    if list[i] == ship then
      return i
    end
  end
  return false
end

function ships:dockToTarget(ship)
    
  if ship.target ~= nil then
    ship.isDocked = true
    table.insert(ship.target.hangar, ship)
    table.remove(ai_ships, ships:getShipIndex(ai_ships, ship))
    print ("Post-Dock Hangar Space:", #ship.target.hangar)
  end
end
function ships:unDockFromTarget(ship)
    
  if ship.target ~= nil then
    ship.isDocked = false
    local hangarShipIndex = ships:getShipIndex(ship.target.hangar, ship)
    table.insert(ai_ships, ship.target.hangar[hangarShipIndex])
    table.remove(ship.target.hangar, ships:getShipIndex(ship.target.hangar, ship))
  end
end

function ships:createAIShip(shipWorld, shipName, x, y)
  if shipName == nil then
    shipName = shipname_list[love.math.random(1, #shipname_list)]
  end
  local ship = {
      name = shipName
      ,portraitid = 1
      ,passengers = {}
      ,hangar = {}
      ,hangar_max = 0
      ,station = false
      ,health = 100
      ,health_max = 100
      ,velocity = 0
      ,throttle = 0
      ,vectorX = 0
      ,vectorY = 0
      ,sectorX = 5
      ,sectorY = 5
      ,rotation = 0
      ,animation = {}
      ,animationId = nil
      ,body = nil
      ,shape = nil
      ,fixture = nil
      ,density = 1
      ,weapons = {1, 0, 0, 0, 0}
      ,weaponSelId = 1
      ,world = shipWorld
      ,cargo_ore = 40
      ,cargo_ore_max = 50
      ,cargo_inv = {}
      ,cargo_inv_max = 10
      ,credits = 2500
      ,aiship = true
      ,canDock = true
      ,isDocked = false
      ,aistate = "search"
      ,target = nil
      ,mining_beam_active = false
      ,location = nil
      ,benevolent = true
      ,market_prices = nil -- Ship, not a station.
  }
  ship.body = love.physics.newBody(shipWorld, x, y, "dynamic")
  ship.shape = love.physics.newCircleShape(-20, -20, 40)
  ship.fixture = love.physics.newFixture(ship.body, ship.shape, ship.density)
  ship.fixture:setRestitution(0.1)
  ship.fixture:setUserData("AI Ship: " .. shipName)
  ship.fixture:setFilterData(0x001, 0x000, 0)
    
  local prs = personae:create(sectorX, sectorY, ship)
  ship.portraitid = prs.portraitid
  table.insert(ship.passengers, prs)
    
  return ship
end

function ships:createAIStation(shipWorld, shipName, x, y)
  if shipName == nil then
    shipName = shipname_list[love.math.random(1, #shipname_list)]
  end
  local ship = {
      name = shipName
      ,portraitid = 1
      ,passengers = {}
      ,hangar = {}
      ,hangar_max = 10
      ,station = false
      ,health = 1000
      ,health_max = 1000
      ,velocity = 0
      ,throttle = 0
      ,vectorX = 0
      ,vectorY = 0
      ,x = 0
      ,y = 0
      ,rotation = 0
      ,animation = {}
      ,animationId = nil
      ,body = nil
      ,shape = nil
      ,fixture = nil
      ,density = 1
      ,weapons = {1, 2, 3, 0, 0}
      ,weaponSelId = 1
      ,world = shipWorld
      ,cargo_ore = 0
      ,cargo_ore_max = 100000
      ,market_prices = {
          ore = {buy = 3, sell = 0}
          ,weapons = {
            {buy = 25, sell = 40}
            ,{buy = 50, sell = 80}
            ,{buy = 60, sell = 130}
          }
        }
      ,cargo_inv = {1, 2, 3}
      ,cargo_inv_max = 100
      ,credits = 250000
      ,aiship = true
      ,canDock = false
      ,isDocked = false
      ,aistate = "stationary"
      ,target = nil
      ,location = nil
      ,benevolent = true
      ,mining_beam_active = false
  }
  ship.body = love.physics.newBody(shipWorld, x, y, "dynamic")
  ship.shape = love.physics.newCircleShape(-256, -256, 512)
  ship.fixture = love.physics.newFixture(ship.body, ship.shape, ship.density)
  ship.fixture:setRestitution(0.1)
  ship.fixture:setUserData("Station: " .. shipName)
  ship.fixture:setFilterData(0x002, 0x002, 0)
  
  for pc=1, love.math.random(1, 8) do
    local prs = personae:create(sectorX, sectorY, ship)
    if pc == 1 then
      ship.portraitid = prs.portraitid
    end
    table.insert(ship.passengers, prs)
  end
  
  local prs = personae:create(sectorX, sectorY, ship, "Bartender")
  prs.work_vehicle = ship
  table.insert(ship.passengers, prs)
  
  return ship
end
function ships:addAnimation(ship, img, name, frameW, frameH, gridX, gridY, delay, onLoop)
  local image = img

  local grid = anim8.newGrid(frameW, frameH, image:getWidth(), image:getHeight())
   
  ship.animation[name] = { anim = anim8.newAnimation(grid(gridX, gridY), delay, onLoop), animImage = image, oX = frameW/2, oY = frameH/2 }
  if ship.animationId == nil then
    ship.animationId = name
  end
end

function ships:changeAnimation(ship, name)
  if ship.animation[name] ~= nil then
    ship.animationId = name
    ship.animation[name].anim:gotoFrame(1)
    return true
  end
  return false
end

function ships:find(shipName)
  
  for i=1, #sectors[sectorY][sectorX].ai_ships do
    if sectors[sectorY][sectorX].ai_ships[i].name == shipName then
      return sectors[sectorY][sectorX].ai_ships[i]
    end
  end
  return false
end

function ships:findInSector(shipName, sX, sY)
  
  for i=1, #sectors[sY][sX].ai_ships do
    if sectors[sY][sX].ai_ships[i].name == shipName then
      return sectors[sY][sX].ai_ships[i]
    end
  end
  return false
end

function ships:updateShip(ship, dt)
  if ship == nil then return end
  
  if ship.hangar_max > 0 then  
    for i=1, #ship.hangar do
      ships:updateShip(ship.hangar[i], dt)
    end
  end
  
  ship.x = ship.body:getX()
  ship.y = ship.body:getY()
  
  if ship.body:isActive() then
  
    ship.vectorX = math.cos(ship.rotation) * (ship.throttle * dt)
    ship.vectorY = math.sin(ship.rotation) * (ship.throttle * dt)

    ship.body:applyForce(ship.vectorX, ship.vectorY)

    ships:updateAnimation(ship, dt)
  end

  if ship.aiship and ship.body:isActive() then
    ai_modules.mining(ship, dt)
  elseif ship.aiship and not ship.body:isActive() then
    print("inactive ai", ship.x, ship.y)
    ai_modules.mining_frozen(ship, dt)
  end
  
end

function ships:setAllInactive(sl)
  for i=1, #sl do
    sl[i].body:setActive(false)
  end
end

function ships:setAllActive(sl)
  for i=1, #sl do
    sl[i].body:setActive(true)
  end
end

function ships:updateAnimation(ship, dt)
  if ship.animationId == nil then return end
  ship.animation[ship.animationId].anim:update(dt)
end

function ships:drawShip(ship, dx, dy, target)
  if not ship.body:isActive() then return end
  if ship.animationId == nil then return end
  local an = ship.animation[ship.animationId]
  an.anim:draw(an.animImage, math.floor(dx), math.floor(dy), ship.rotation, 1, 1, an.oX, an.oY)
  love.graphics.print(ship.name, math.floor(dx), math.floor(dy) + 33)
  if ship.aistate ~= nil then love.graphics.print(ship.aistate, math.floor(dx), math.floor(dy) + 88) end

  -- love.graphics.circle("line", ship.body:getX(), ship.body:getY(), ship.shape:getRadius()) -- Show bounding box for debug purposes.
  if ship.aiship and ship.mining_beam_active then
    local tg = ship.target
    -- Draw effect if using laser weapon.
    drawLaser(ship.body:getX(), ship.body:getY(), tg)
  end

  if target ~= nil then
    love.graphics.draw(target.img, target.x, target.y)
  end
end

function ships:drawShipList(sl)
  for i=1, #sl do
    ships:drawShip(sl[i], sl[i].body:getX(), sl[i].body:getY())
  end
  
end

function ships:updateShipList(sl, dt)
  for i=1, #sl do
    ships:updateShip(sl[i], dt)
  end
  
end

function ships:checkCollide(sh, ailist)
  
  for i=1, #ailist do
    if ailist[i].fixture:testPoint(sh.body:getX(), sh.body:getY()) then
      return {sh.fixture:getUserData(), ailist[i].fixture:getUserData(), ailist[i]}
    end
  end
  return false
end


return ships