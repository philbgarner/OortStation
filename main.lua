
game_settings = {

  resolution = {1024, 768}
  ,sfx_volume = 0.33

  ,key_bindings = {

    quest = "q"
    ,left = "left"
    ,right = "right"
    ,shoot = "space"
    ,throttle_up = "up"
    ,throttle_down = "down"
    ,throttle_zero = "lctrl"
    ,dock = "d"
  }
}

sectors = {
}
sectorX = 5
sectorY = 5

-- Returns the angle between two points.
function math.angle(x1,y1, x2,y2) return math.atan2(y2-y1, x2-x1) end

function round(num, numDecimalPlaces)
  local mult = 10^(numDecimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
end

anim8 = require "anim8"

require("resources")

local audio_ship_background = nil
local audio_ship_engine = nil
local audio_ship_laser = nil
local audio_ship_laser_end = nil
local audio_destroy_rubble = nil
local audio_menu_change = nil

function distance ( x1, y1, x2, y2 )
  local dx = x1 - x2
  local dy = y1 - y2
  return math.sqrt ( dx * dx + dy * dy )
end

local galaxy = nil
local oortstation = nil
local target = nil

local station_ui = nil

local ship = nil
ai_ships = {}
local effects = {}
local world = nil

local beam_impact = nil

local blur1 = nil
local blur2 = nil
local bloom = nil

local font = nil
local fontheader1 = nil

local sectors_timer = 0

local weapon_active_laser = false

local oortstation_vehicle = nil


function getAllTargets(sh)

  if sh == nil then sh = ship end

  local t = ui:sortClosest(asteroids, sh)

  for i=1, #ai_ships do
    local d = distance(ship.body:getX(), ship.body:getY(), ai_ships[i].body:getX(), ai_ships[i].body:getY())
    ai_ships[i].distance = d
    table.insert(t, ai_ships[i])
  end

  return t
end


function drawLaser(sx, sy, tg)
  local lns = {sx, sy, ((tg.x - sx) / 2 + sx + math.random(-15, 15)), ((tg.y - sy) / 2 + sy + math.random(-15, 15)), tg.x, tg.y}

  local offx = love.math.random(-1, 1)
  local offy = love.math.random(-1, 1)

  local dx = tg.x + offx
  local dy = tg.y + offy

  love.graphics.setShader(blur2)
  love.graphics.draw(beam_impact, dx, dy, 0, 10, 10, 10, 10)
  love.graphics.setShader(blur1)
  love.graphics.draw(beam_impact, dx, dy, 0, 7, 7, 10, 10)
  love.graphics.setShader()

  love.graphics.setColor(0, 25, 150, 60)
  love.graphics.setLineWidth(8)
  love.graphics.line(lns)

  love.graphics.setColor(0, 110, 200, 123)
  love.graphics.setLineWidth(3)
  love.graphics.line(lns)

  love.graphics.setLineWidth(1)
  love.graphics.setColor(255, 255, 255)

end

personae = require "personae"
ships = require "ships"
asteroids = require "asteroids"
ui = require "ui"
effects = require "effects"
portraits = require "portraits"
scenes = require "scenes"

function loadSector(sx, sy)

  print("Loading sector " .. sx .. ", " .. sy)

  ai_ships = sectors[sy][sx].ai_ships
  asteroids.list = sectors[sy][sx].asteroids 
  ships:setAllActive(ai_ships)
  asteroids:setActive()

end

function populateSectors()

  local x = 1
  local y = 1
  local x2 = sectorX * 2
  local y2 = sectorY * 2

  local station = ships:createAIStation(world, 'Oort Station', 0, 0)
  ships:addAnimation(station, res_image.stations[1], "idle", 1024, 1024, 1, 1, 0.001)
  oortstation_vehicle = station
  sectors = {}

  for j=y, y2 do

    local row = {}

    for i=x, x2 do   
      local col = {}

      if i == sectorX and j == sectorY then
        
        local ac = love.math.random(1, 2)
        for a=1, ac do
          asteroids:create(world)
        end
      
        table.insert(ai_ships, station)

        for ais=1, 5 do
          local pnum = love.math.random(1, 10)
          local ai1 = ships:createAIShip(world, nil, 1500, 1500)
          ships:addAnimation(ai1, res_image["salvager_idle"], "idle", 198, 81, 1, 1, 0.001)
          ships:addAnimation(ai1, res_image["salvager_forward"], "forward", 198, 81, 1, '1-31', 0.001)
          ships:addAnimation(ai1, res_image["salvager_forward_release"], "forward_release", 196, 81, 1, '1-31', 0.001, function (anim, loopcount) ships:changeAnimation(ship, "idle") end )
          ships:addAnimation(ai1, res_image["salvager_reverse"], "reverse", 198, 79, 1, '1-31', 0.001)
          ships:addAnimation(ai1, res_image["salvager_reverse_release"], "reverse_release", 198, 79, 1, '1-31', 0.001, function (anim, loopcount) ships:changeAnimation(ship, "idle") end )

          table.insert(ai_ships, ai1)
        end
        
        
      else
    
        local ac = love.math.random(3, 12)
        for a=1, ac do
          asteroids:create(world)
        end
    
        ships:setAllInactive(ai_ships)
        asteroids:setInactive()
      end

      col.ai_ships = ai_ships
      col.asteroids = asteroids.list
      ai_ships = {}
      asteroids.list = {}
      table.insert(row, col)
  
    end

    table.insert(sectors, row)
    row = {}

  end

  ship = ships:createShip(world, "Salvager", 100, 100, 50)
  ships:addAnimation(ship, res_image["salvager_idle"], "idle", 198, 81, 1, 1, 0.001)
  ships:addAnimation(ship, res_image["salvager_forward"], "forward", 198, 81, 1, '1-31', 0.001)
  ships:addAnimation(ship, res_image["salvager_forward_release"], "forward_release", 196, 81, 1, '1-31', 0.001, function (anim, loopcount) ships:changeAnimation(ship, "idle") end )
  ships:addAnimation(ship, res_image["salvager_reverse"], "reverse", 198, 79, 1, '1-31', 0.001)
  ships:addAnimation(ship, res_image["salvager_reverse_release"], "reverse_release", 198, 79, 1, '1-31', 0.001, function (anim, loopcount) ships:changeAnimation(ship, "idle") end )
end

function changeSector(nx, ny)

  ships:setAllInactive(ai_ships)
  asteroids:setInactive()

  sectors[sectorY][sectorX].ai_ships = ai_ships
  sectors[sectorY][sectorX].asteroids = asteroids.list

  sectorX = nx
  sectorY = ny
  
  ui.target = 1

  loadSector(nx, ny)

end

local quests = {
  intro = {
    accepted = false
    ,completed = false
    ,stateid = 1
  }
}
function quests.intro:checkComplete()
  print ("Check complete on intro quest.")
  return false
end
function quests.intro:visit()
  quests.intro.accepted = true
  quests.intro.completed = true
  --[[if not quests.intro.accepted and quests.intro.stateid == 1 then
    quests.intro.accepted = true
  
    portraits:say("pilot6", "ONA", {"Hi my name is ONA: Onboard Navigational Assistant, your ship's AI."
        ,"I'll help you get started in this unexplored fringe of our solar system."
        ,"This station - Oort Station - is humanity's first outpost in the kuiper belt."
        ,"You can sell the materials you mine from asteroids there, and in time when the"
        ,"economy improves companies will offer some services at Oort Station."
        ,"Press Q (Quests) to consult with me and review your missions."
        ,"# END TRANSMISSION #"
        }, 3, function() quests.intro:visit() end)
  elseif quests.intro.accepted and quests.intro.stateid == 1 then
    
    portraits:say("ai", "ONA", {"There are three different asteroid types (1, 2 and 3), which offer "
        ,"different concentrations of elements.  Efficient mining takes this into account: mine only"
        ,"those which suit your current mission or personal objective."
        ,"To begin, let's gather 200m3 of ore material from any asteroid you can find."
        ,"Harvest by pressing they SPACE key once you have targeted an asteroid, press N key to cycle"
        ,"through targets in your sector until you've selected the correct one."
        ,"Press Q when you have enough ore."
        ,"# END TRANSMISSION #"
        }, 3)
    
    quests.intro.stateid = 2
  elseif quests.intro.accepted and quests.intro.stateid == 2 and ship.cargo_ore < 200 then
  
    portraits:say("ai", "ONA", {"You currently have only collected " .. round(ship.cargo_ore, 2) .. " of 200m3 material."
        ,"Please continue mining asteroids in this sector."
        ,"# END TRANSMISSION #"
        }, 2)
  elseif quests.intro.accepted and quests.intro.stateid == 2 and ship.cargo_ore >= 200 then
    portraits:say("ai", "ONA", {"200m3 collected! Good work.  Let's return to Oort Station and press"
        ,"D when prompted to dock.  We'll sell this ore and upgrade our equipment."
        ,"# END TRANSMISSION #"
        }, 2)
    quests.intro.stateid = 3
  end--]]

end

function beginContact(a, b, coll)
  print(a:getUserData(),b:getUserData())
end

function endContact(a, b, coll)

end

function preSolve(a, b, coll)

end

function postSolve(a, b, coll, normalimpulse, tangentimpulse)

end

function sceneOortStation(shipObj)

  local vars = {    }

  scenes:create("Oort Station"
    ,function()
      -- fnInit

      audio_menu_change = love.audio.newSource(res_audio.menu_change)
      audio_menu_change:setVolume(game_settings.sfx_volume)
      audio_menu_change:setLooping(false)
      audio_menu_change:pause()

      vars.menuId = 1  -- 1 = left menu, 2 = inventory.
      vars.shopMethod = 1 -- 1 = Buy, 2 = Sell
      vars.menuInvSel = 1
      vars.menuLoungeSel = 1
      vars.smelterSel = 1
      vars.menuSel = 1
      vars.vehicle = oortstation_vehicle
      local vc = 0
      for key in pairs(vars.vehicle.passengers) do
        vc = vc + 1
      end
      vars.menuLoungeMax = vc
      vars.menutext = {
        "Ore Processing"
        ,"Weapons Market"
        ,"Lounge"
      }
      vars.menuCount = #vars.menutext
    end
    ,function(dt)
      -- fnUpdate

      portraits:update(dt)

    end
    ,function()
      -- fnDraw

      local methodPoints = {
        {190, 130}, {390, 130}
      }

      local smelterPoints = {
        {190, 220, 108, 28}
        ,{330, 220, 200, 28}
        ,{190, 400, 80, 28}
        ,{330, 400, 170, 28}
      }

      local stx = love.graphics.getWidth() - station_ui:getWidth() - 64
      local sty = love.graphics.getHeight() - station_ui:getHeight() - 64

      love.graphics.draw(oortstation, 0, 0)
      love.graphics.draw(station_ui, stx, sty)

      love.graphics.setFont(fontheader1)
      love.graphics.print("Oort Station", stx + 164, sty + 18)

      love.graphics.setColor(255, 255, 255)
      love.graphics.setLineWidth(2)

      if vars.menuId == 1 then
        love.graphics.rectangle("line", stx + 22, sty + 131 + (vars.menuSel - 1) * 72, 52, 52)
      end

      love.graphics.print(vars.menutext[vars.menuSel], stx + 130, sty + 83)

      if vars.menutext[vars.menuSel] == "Ore Processing" then
        love.graphics.setFont(fontheader1)
        love.graphics.print("Smelt Ore", stx + 140, sty + 130)        
        love.graphics.setFont(font)

        love.graphics.print("Smelt your collected ore for a fee and receive material capsules.", stx + 140, sty + 160)
        love.graphics.print("This station charges 10Cr per m3 to smelt and refine it for you.", stx + 140, sty + 180)
        love.graphics.print("Capacity: " .. math.floor(vars.vehicle.cargo_ore) .. "/" .. math.floor(vars.vehicle.cargo_ore_max) .. "m3", stx + 325, sty + 130)

        love.graphics.setFont(fontheader1)
        love.graphics.print("Smelt All", stx + 190, sty + 220)
        love.graphics.print("Smelt Amount...", stx + 330, sty + 220)
        love.graphics.setFont(font)


        love.graphics.setFont(fontheader1)
        love.graphics.print("Sell Ore", stx + 140, sty + 310)
        love.graphics.setFont(font)

        love.graphics.print("Sell your ore directly and get paid!", stx + 140, sty + 340)
        love.graphics.print("This station pays 3Cr per m3 of ore.", stx + 140, sty + 360)

        love.graphics.setFont(fontheader1)
        love.graphics.print("Sell All", stx + 190, sty + 400)
        love.graphics.print("Sell Amount...", stx + 330, sty + 400)
        love.graphics.setFont(font)


        if vars.menuSel == 1 and vars.menuId == 2 then
          for i=1, #smelterPoints do
            if i == vars.smelterSel then
              love.graphics.setColor(255, 255, 255, 100)
              love.graphics.rectangle("line", stx + smelterPoints[i][1], sty + smelterPoints[i][2], smelterPoints[i][3], smelterPoints[i][4])
              love.graphics.setColor(255, 255, 255, 255)
            end
          end
        end       
      elseif vars.menutext[vars.menuSel] == "Weapons Market" then
        local inv = shipObj.cargo_inv

        love.graphics.setFont(fontheader1)
        love.graphics.print("Buy", stx + 190, sty + 130)        
        love.graphics.print("Sell", stx + 390, sty + 130)        
        love.graphics.setFont(font)

        love.graphics.setLineWidth(1)

        love.graphics.print("Weapon Type", stx + 155, sty + 170)
        love.graphics.print("Price", stx + 400, sty + 170)

        love.graphics.line(stx + 150, sty + 185, stx + 570, sty + 185)

        if (vars.menuSel == 2 and vars.menuId == 3) or (vars.menuId == 2 and vars.shopMethod == 1) then
          for i=1, #inv do
            if i == vars.menuInvSel and vars.menuId == 3 then
              love.graphics.setColor(255, 255, 255, 100)
              love.graphics.rectangle("fill", stx + 155, sty + 190 + (i - 1) * 18, 400, 14)
              love.graphics.setColor(255, 255, 255, 255)
              love.graphics.rectangle("line", stx + 155, sty + 190 + (i - 1) * 18, 400, 14)
            end
            love.graphics.print(res_text.weapon_names[inv[i]], stx + 155, sty + 190 + (i - 1) * 18)
          love.graphics.setColor(255, 255, 255, 255)
        end
      end
    elseif vars.menutext[vars.menuSel] == "Lounge" then
      love.graphics.setFont(font)

      local c = 1
      local dx = 0
      local dy = 0
      love.graphics.setColor(255, 255, 255, 255)

      for key in pairs(vars.vehicle.passengers) do
        local pers = vars.vehicle.passengers[key]
        if pers.portraitid ~= nil then
          love.graphics.draw(res_image.pilot_portraits[pers.portraitid], stx + 140 + dx, sty + 140 + dy, 0, 0.33, 0.33)
        end

        if vars.menuLoungeSel == c and vars.menuId > 1 then
          love.graphics.rectangle("line", stx + 140 + dx, sty + 140 + dy, 42, 72)

          love.graphics.print("Name: " .. pers.name .. " " .. pers.surname, stx + 140, sty + 400)
          love.graphics.print("Occupation: " .. pers.occupation, stx + 140, sty + 416)
        end

        dx = dx + 45
        c = c + 1
      end

      love.graphics.print("There are " .. c - 1 .. " other passengers.", stx + 140, sty + 125)

    end

    portraits:draw()

  end
  ,function(key, scancode)
    -- fnKeyPress
    if scancode == "escape" and vars.menuId == 1 then
      scenes:pop()
    elseif scancode == "escape" and vars.menuId > 1 then
      vars.menuId = vars.menuId - 1
    elseif scancode == "down" then
      if vars.menuId == 1 then
        vars.menuSel = vars.menuSel + 1
        if vars.menuSel > vars.menuCount then
          vars.menuSel = 1
        end
      elseif vars.menuId == 2 and vars.menuSel == 1 then
        vars.smelterSel = vars.smelterSel + 1
        if vars.smelterSel > 4 then
          vars.smelterSel = 1
        end
      elseif vars.menuId == 3 and vars.menuSel == 2 then
        vars.menuInvSel = vars.menuInvSel + 1
        if vars.menuInvSel > vars.menuCount then
          vars.menuInvSel = 1
        end
      elseif vars.menuId == 3 and vars.menuSel == 1 then
        vars.menuInvSel = vars.menuInvSel + 1
        if vars.menuInvSel > vars.menuCount then
          vars.menuInvSel = 1
        end
        vars.shopMethod = vars.shopMethod + 1
        if vars.shopMethod > 2 then
          vars.shopMethod = 1
        end
      end
      audio_menu_change:play()
    elseif scancode == "up" then
      if vars.menuId == 1 then
        vars.menuSel = vars.menuSel - 1
        if vars.menuSel < 1 then
          vars.menuSel = vars.menuCount
        end
      elseif vars.menuId == 2 and vars.menuSel == 1 then
        vars.smelterSel = vars.smelterSel - 1
        if vars.smelterSel < 1 then
          vars.smelterSel = 4
        end
      elseif vars.menuId == 3 then
        vars.menuInvSel = vars.menuInvSel - 1
        if vars.menuInvSel < 1 then
          vars.menuInvSel = vars.menuCount
        end
      end
      audio_menu_change:play()
    elseif scancode == "right" then
      if vars.menuId == 2 and vars.menuSel == 2 then
        vars.shopMethod = vars.shopMethod + 1
        if vars.shopMethod > 2 then
          vars.shopMethod = 1
        end
      elseif vars.menuId == 2 and vars.menuSel == 3 then
        vars.menuLoungeSel = vars.menuLoungeSel + 1
        if vars.menuLoungeSel > vars.menuLoungeMax then
          vars.menuLoungeSel = 1
        end
      end
      if vars.menuId ~= 2 then vars.menuId = vars.menuId + 1 end
      if vars.menuId > 3 then
        vars.menuId = 1
      end
      audio_menu_change:play()
    elseif scancode == "left" then
      if vars.menuId == 2 and vars.menuSel == 2 then
        vars.shopMethod = vars.shopMethod - 1
        if vars.shopMethod < 1 then
          vars.shopMethod = 2
        end
      elseif vars.menuId == 2 and vars.menuSel == 3 then
        vars.menuLoungeSel = vars.menuLoungeSel - 1
        if vars.menuLoungeSel < 1 then
          vars.menuLoungeSel = vars.menuLoungeMax
        end
      end
      if vars.menuId ~= 2 then vars.menuId = vars.menuId - 1 end
      if vars.menuId < 1 then
        vars.menuId = 3
      end
      audio_menu_change:play()
    elseif scancode == "space" then
      -- Menu Select
      if vars.menuId == 2 and vars.menuSel == 1 then
        if vars.smelterSel == 1 then
          print("Refining all " .. ship.cargo_ore .. "m3 of ore, costing you 10Cr/m3.")
        elseif vars.smelterSel == 3 then
          print("Selling all " .. ship.cargo_ore .. "m3 of ore, earning you 3Cr/m3.")
        end
      elseif vars.menuId == 2 and vars.menuSel == 2 then
        vars.menuId = 3
      elseif vars.menuId == 2 and vars.menuSel == 3 then
        local prs = nil
        local cc = 1
        for key in pairs(vars.vehicle.passengers) do
          if cc == vars.menuLoungeSel then
            prs = vars.vehicle.passengers[key] 
            local typeid = prs.portraitid
            portraits:say("pilot" .. typeid, prs.name .. " " .. prs.surname, {
                personae:getMenu(prs.occupation, "neutral").message
                }, 2)
            break
          end
          cc = cc + 1
        end
      end
    end        
  end
  ,function()
    -- fnDestroy
  end

)

end

function love.load()

  blur1 = love.graphics.newShader [[

		vec4 effect(vec4 color, Image texture, vec2 vTexCoord, vec2 pixel_coords)
		{
			vec4 sum = vec4(0.0);
			number blurSize = 0.005;

			// take nine samples, with the distance blurSize between them
			sum += texture2D(texture, vec2(vTexCoord.x - 4.0*blurSize, vTexCoord.y)) * 0.05;
			sum += texture2D(texture, vec2(vTexCoord.x - 3.0*blurSize, vTexCoord.y)) * 0.09;
			sum += texture2D(texture, vec2(vTexCoord.x - 2.0*blurSize, vTexCoord.y)) * 0.12;
			sum += texture2D(texture, vec2(vTexCoord.x - blurSize, vTexCoord.y)) * 0.15;
			sum += texture2D(texture, vec2(vTexCoord.x, vTexCoord.y)) * 0.16;
			sum += texture2D(texture, vec2(vTexCoord.x + blurSize, vTexCoord.y)) * 0.15;
			sum += texture2D(texture, vec2(vTexCoord.x + 2.0*blurSize, vTexCoord.y)) * 0.12;
			sum += texture2D(texture, vec2(vTexCoord.x + 3.0*blurSize, vTexCoord.y)) * 0.09;
			sum += texture2D(texture, vec2(vTexCoord.x + 4.0*blurSize, vTexCoord.y)) * 0.05;
			
			
			return sum;
		}
		]]
  blur2 = love.graphics.newShader [[
		
		vec4 effect(vec4 color, Image texture, vec2 vTexCoord, vec2 pixel_coords)
		{
			vec4 sum = vec4(0.0);
			number blurSize = 0.03;

			// take nine samples, with the distance blurSize between them
			sum += texture2D(texture, vec2(vTexCoord.x, vTexCoord.y - 4.0*blurSize)) * 0.05;
			sum += texture2D(texture, vec2(vTexCoord.x, vTexCoord.y - 3.0*blurSize)) * 0.09;
			sum += texture2D(texture, vec2(vTexCoord.x, vTexCoord.y - 2.0*blurSize)) * 0.12;
			sum += texture2D(texture, vec2(vTexCoord.x, vTexCoord.y- blurSize)) * 0.15;
			sum += texture2D(texture, vec2(vTexCoord.x, vTexCoord.y)) * 0.16;
			sum += texture2D(texture, vec2(vTexCoord.x, vTexCoord.y + blurSize)) * 0.15;
			sum += texture2D(texture, vec2(vTexCoord.x, vTexCoord.y + 2.0*blurSize)) * 0.12;
			sum += texture2D(texture, vec2(vTexCoord.x, vTexCoord.y + 3.0*blurSize)) * 0.09;
			sum += texture2D(texture, vec2(vTexCoord.x, vTexCoord.y + 4.0*blurSize)) * 0.05;

			return sum;
		}
		]]


  font = love.graphics.newFont(12)
  fontheader1 = love.graphics.newFont(24)
  love.graphics.setFont(font)

  love.physics.setMeter(1000)
  world = love.physics.newWorld(world, 0, 0, true)

  beam_impact = love.graphics.newImage("assets/images/bluelight.png")
  galaxy = love.graphics.newImage("assets/images/galaxy.png")
  oortstation = love.graphics.newImage("assets/images/oortstation.png")
  target = love.graphics.newImage("assets/images/triangle-05.png")
  station_ui = love.graphics.newImage("assets/images/ui_station.png")

  local sectorChangeTicks = 0
  local sectorChangeMax = 100

  scenes:create("sectormap"
    ,function()
      -- fnInit

      populateSectors()
      loadSector(5, 5)

      quests.intro:visit()

      audio_ship_background = love.audio.newSource(res_audio.ship_background)
      audio_ship_background:setVolume(game_settings.sfx_volume)
      audio_ship_background:setLooping(true)
      audio_ship_background:play()

      audio_ship_engine = love.audio.newSource(res_audio.ship_engine)
      audio_ship_engine:setVolume(0.1)
      audio_ship_engine:setLooping(true)
      audio_ship_engine:pause()

      audio_ship_laser = love.audio.newSource(res_audio.laser_operation)
      audio_ship_laser:setVolume(game_settings.sfx_volume)
      audio_ship_laser:setLooping(true)
      audio_ship_laser:pause()

      audio_ship_laser_end = love.audio.newSource(res_audio.laser_end)
      audio_ship_laser_end:setVolume(game_settings.sfx_volume)
      audio_ship_laser_end:setLooping(false)
      audio_ship_laser_end:pause()

      audio_destroy_rubble = love.audio.newSource(res_audio.destroy_rubble)
      audio_destroy_rubble:setVolume(game_settings.sfx_volume)
      audio_destroy_rubble:setLooping(false)
      audio_destroy_rubble:pause()

    end
    ,function(dt)
      -- fnUpdate

      sectors_timer = sectors_timer + dt -- Used to know when to update the physics frozen sectors

      if love.keyboard.isDown("up") then  
        -- Increase Velocity.   
        ship.throttle = ship.throttle + 20 * dt
        if ship.animationId ~= "forward" and ship.throttle > 0 then
          ships:changeAnimation(ship, "forward")
        end
        v = math.abs(ship.throttle) / 100
        if v > 0.66 then v = 0.66 end
        audio_ship_engine:setVolume(0.1 + v)
        audio_ship_engine:play()
      end
      if love.keyboard.isDown("down") then
        -- Decrease Velocity.
        ship.throttle = ship.throttle - 20 * dt  
        if ship.animationId ~= "reverse" and ship.throttle < 0 then
          ships:changeAnimation(ship, "reverse")
        end
        v = math.abs(ship.throttle) / 100
        if v > 0.66 then v = 0.66 end
        audio_ship_engine:setVolume(0.1 + v)
        audio_ship_engine:play()
      end

      if love.keyboard.isDown("space") then
        weapon_active_laser = true
        audio_ship_laser:play()
        local t = getAllTargets()
        local nx = t[ui.target].x + love.math.random(-5, 5)
        local ny = t[ui.target].y + love.math.random(-5, 5)
        local tg = {
          img = target
          ,x = nx
          ,y = ny
          ,w = target:getWidth()
          ,h = target:getHeight()
        }
        local ws = res_gamedata.weapon_stats[res_text.weapon_names[ship.weapons[ship.weaponSelId]]]
        local dmg = ws.damage
        local amt = love.math.random(dmg[1], dmg[2]) * dt
        local pref = ""
        local colour = {255, 255, 255}
        if amt > 0 then
          pref = "-"
          colour = {255, 0, 0}
        end
        local effdust = effects:create(world, "dust", tg.x, tg.y, 414, 403, 1, '1-8', 212, 201)
        effects:setText(effdust, pref .. round(amt, 2), tg.x, tg.y, 159, 1.66, colour)
        if asteroids:damage(t[ui.target], amt) then
          audio_destroy_rubble:play()
        end

        ship.cargo_ore = ship.cargo_ore + amt
        if ship.cargo_ore == ship.cargo_ore_max then
          ship.cargo_ore = ship.cargo_ore_max
        end
      elseif not love.keyboard.isDown("space") then
        audio_ship_laser:pause()
        if weapon_active_laser then audio_ship_laser_end:play() end
        weapon_active_laser = false
      end

      if love.keyboard.isDown("left") then
        -- Turn left.
        ship.rotation = ship.rotation - 3 * dt
      end
      if love.keyboard.isDown("right") then
        -- Turn right.
        ship.rotation = ship.rotation + 3 * dt
      end
      if love.keyboard.isDown("lctrl") then
        ship.throttle = 0
      end

      if not love.keyboard.isDown("up") and ship.animationId == "forward" and ship.throttle == 0 then
        audio_ship_engine:pause()
        ships:changeAnimation(ship, "forward_release")
      end
      if not love.keyboard.isDown("up") and ship.animationId == "reverse" and ship.throttle == 0 then
        audio_ship_engine:pause()    
        ships:changeAnimation(ship, "reverse_release")
      end

      world:update(dt)

      ships:updateShip(ship, dt)


      for j=1, 10 do
        for i=1, 10 do
          if i == sectorX and j == sectorY then
            --print("Updating active bodies: ", #sectors[sectorY][sectorX].ai_ships)
            ships:updateShipList(sectors[sectorY][sectorX].ai_ships, dt)
          else
            -- 30 second frozen physics bodies updates simulation
            if sectors_timer > 10 and #sectors[j][i].ai_ships > 0 then
              print("Updating inactive bodies: ", sectors[j][i].ai_ships[1].name, i, j)
              ships:updateShipList(sectors[j][i].ai_ships, sectors_timer)
            end
          end
        end
      end
      if sectors_timer > 10 then
        sectors_timer = 0
      end

      asteroids:update(dt)

      effects:update(dt)

      portraits:update(dt)

    end
    ,function()
      -- fnDraw

      love.graphics.draw(galaxy, 0, 0)

      love.graphics.push()
      local trX = (ship.body:getX() - love.graphics.getWidth() / 2 ) * -1
      local trY = (ship.body:getY() - love.graphics.getHeight() / 2) * -1
      love.graphics.translate(math.floor(trX), math.floor(trY))
      local t = getAllTargets()
      local tg = nil
      if ui.target > #t then
        ui.target = 1
      end
      if #t > 0 then
        tg = {
          img = target
          ,portr = res_image.pilot_portraits[t[ui.target].portraitid]
          ,name = t[ui.target].name
          ,health = t[ui.target].health
          ,health_max = t[ui.target].health_max
          ,x = t[ui.target].x
          ,y = t[ui.target].y
          ,w = target:getWidth()
          ,h = target:getHeight()
        }
      end

      asteroids:draw()
      ships:drawShipList(ai_ships)
      effects:draw()

      if tg ~= nil then
        if tg.portr ~= nil then
          love.graphics.draw(tg.portr, tg.x - target:getWidth() / 2 + 25, tg.y - target:getHeight() / 2 + 25, 0, 0.36, 0.36)
        end
        love.graphics.draw(tg.img, tg.x - target:getWidth() / 2, tg.y - target:getHeight() / 2)
        love.graphics.print(math.floor(tg.health) .. " / " .. math.floor(tg.health_max), tg.x, tg.y + 64)
      end

      -- Draw effect if using laser weapon.
      if (weapon_active_laser) then
        drawLaser(ship.body:getX(), ship.body:getY(), tg)
      end

      ships:drawShip(ship, ship.body:getX(), ship.body:getY())

      love.graphics.pop()

      --tg.x = tg.x - ship.body:getX() + tg.w / 2
      --tg.y = tg.y - ship.body:getY() + tg.h / 2

      love.graphics.print("X" .. math.floor(ship.body:getX()) .. ", Y" .. math.floor(ship.body:getY()) .. " T" .. math.floor(ship.throttle), 10, 3)

      ui:drawMinimap(asteroids, ship, ai_ships)

      ui:drawTargets(getAllTargets())

      ui:drawWeapons(ship.weapons, ship.weaponSelId)

      portraits:draw()

      if (ship.x < -5000 or ship.x > 5000 or ship.y < -5000 or ship.y > 5000) and sectorChangeTicks == 0 then
        sectorChangeTicks = 1
      end

      if sectorChangeTicks > 0 then
        sectorChangeTicks = sectorChangeTicks + 1
        local msg = "Leaving Sector " .. sectorX .. ", " .. sectorY .. "."
        local fw = fontheader1:getWidth(msg) / 2
        love.graphics.setFont(fontheader1)
        love.graphics.print(msg, love.graphics.getWidth() / 2 - fw, 200)
        love.graphics.setFont(font)
      end

      if sectorChangeTicks > sectorChangeMax then
        sectorChangeTicks = 0

        local dirx = 0
        local diry = 0

        if ship.x < -5000 then
          dirx = -1
        elseif ship.x > 5000 then
          dirx = 1
        elseif ship.y < -5000 then
          diry = -1
        elseif ship.y > 5000 then
          diry = 1
        end

        ship.body:setLinearVelocity(0, 0)
        ship.x = 4000 * dirx * -1
        ship.y = 4000 * diry * -1
        ship.body:setPosition(ship.x, ship.y)
        changeSector(sectorX + dirx, sectorY + diry)

      end

      local collres = ships:checkCollide(ship, ai_ships)
      if collres and string.sub(collres[2],1, 7) == 'Station' then
        local w = font:getWidth("Press D to Request Permission to Dock") / 2
        love.graphics.print('Press D to Request Permission to Dock', love.graphics.getWidth() / 2 - w, love.graphics.getHeight() / 2)
      end

    end
    ,function(key, scancode)
      -- fnKeyPress

      if key == "n" then
        ui.target = ui.target + 1
        if ui.target > #getAllTargets() then
          ui.target = 1
        end
      end

      local collres = ships:checkCollide(ship, ai_ships)
      if key == "d" and collres and string.sub(collres[2],1, 7) == 'Station' then
        sceneOortStation(collres[3])
      end

      if key == "q" then
        quests.intro:visit()
      end

      if key == "1" then
        ship.weaponSelId = 1
      end
      if key == "2" then
        ship.weaponSelId = 2
      end
      if key == "3" then
        ship.weaponSelId = 3
      end
      if key == "4" then
        ship.weaponSelId = 4
      end
      if key == "5" then
        ship.weaponSelId = 5
      end

    end
    ,function()
      -- fnDestroy
    end

  )




  love.window.setMode(game_settings.resolution[1], game_settings.resolution[2])

  world:setCallbacks(beginContact, endContact, preSolve, postSolve)
end

function love.update(dt)

  scenes:update(dt)

end


function love.keypressed( key, scancode )

  scenes:keyPressed(key, scancode)

end
function love.draw()

  scenes:draw()

end

