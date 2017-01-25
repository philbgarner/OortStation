ai_modules = {
    mining = function (ship, dt)
        ship.rotation = ship.body:getAngle()
        
        if ship.aistate == "search" then
          
          if ship.cargo_ore >= ship.cargo_ore_max then
            ship.aistate = "sell_ore"
          elseif ship.cargo_ore < ship.cargo_ore_max then
            ship.aistate = "mine_ore"
          end
        elseif ship.aistate == "sell_ore" and ship.target == nil then
          
          local sh = ships:findInSector("Oort Station", ship.sectorX, ship.sectorY) 
          --print("FOund oort station?", sh)
          
          if sh then
            ship.target = sh           
            return
          end

          local drx = 0
          local dry = 0
          local drx = 0
          local dry = 0
          if ship.sectorX > sectorX then
            drx = -1
          end
          if ship.sectorY > sectorY then
            dry = -1
          end
          if ship.sectorX < sectorX then
            drx = 1
          end
          if ship.sectorY < sectorY then
            dry = 1
          end
          
          if drx ~= 1 and dry ~= 1 then
            drx = 0
          end
          if drx == 0 and dry == 0 then
             local dir = love.math.random(1, 4)
              
              if dir == 1 then
                drx = 1
                dry = 0
              elseif dir == 2 then
                drx = 0
                dry = 1
              elseif dir == 3 then
                drx = -1
                dry = 0
              elseif dir == 4 then
                drx = 0
                dry = -1
              end
              
          end

          
          ship.target = nil
          ship.target = { name = "Exit", hangar = {}, hangar_max = 0, sectorX = sectorX, sectorY = sectorY }
          ship.target.x = 5000 * drx
          ship.target.y = 5000 * dry
          
          ship.target.body = {}
          function ship.target.body:getX() return ship.target.x end
          function ship.target.body:getY() return ship.target.y end
          
          ship.aistate = "leave_sector"
          
        elseif ship.aistate == "sell_ore" and ship.isDocked and ship.target ~= nil then
        
    --      print("Selling ore and undocking")
          
    --      print("Sales info: ")
    --      print("  Station Price per m3: ", ship.target.market_prices.ore.buy)
    --      print("  Amount sold: ", ship.cargo_ore)
    --      print("  Total Amount Earned: ", ship.target.market_prices.ore.buy * ship.cargo_ore)
          
          print("SELLING CARGO", ship.target.cargo_ore, ship.cargo_ore)
          ship.target.cargo_ore = ship.target.cargo_ore + ship.cargo_ore
          ship.cargo_ore = 0
          print("SOLD CARGO", ship.target.cargo_ore, ship.cargo_ore)
          
          ships:unDockFromTarget(ship)
          
          ship.target = nil
          ship.aistate = "search"

        elseif (ship.target ~= nil and ship.aistate == "sell_ore" and not ship.isDocked) and distance(ship.target.body:getX(), ship.target.body:getY(), ship.body:getX(), ship.body:getY()) < 500 then
          local lvx, lvy = ship.body:getLinearVelocity()
          ship.body:setLinearVelocity(lvx * 0.1, lvy * 0.1)
          
          if lvx == 0 and lvy == 0 and ship.canDock and not ship.target.canDock and #ship.target.hangar < ship.target.hangar_max then
            ships:dockToTarget(ship)
          else
            ship.body:setLinearVelocity(lvx * 0.1, lvy * 0.1)
          end
        
        elseif ship.sectorX == sectorX and ship.sectorY == sectorY and ship.aistate == "sell_ore" and ship.target ~= nil then
          if ship.body:getAngularVelocity() >= 0.0005 then
            ship.throttle = 0
          else
            ship.throttle = 10
          end
          ship.body:setAngle(math.angle(ship.x, ship.y, ship.target.body:getX(), ship.target.body:getY()))
        elseif ship.aistate == "mine_ore" and ship.target == nil then
          local t = getAllTargets(ship)
          local asteroid = nil
          for i=1, #t do
              if t[i].name == "Asteroid" then
                asteroid = t[i]
                break
              end
          end
          if asteroid == nil then
            ship.aistate = "leave_sector"
            ship.target = nil
          else
            asteroid.body = {}
            ship.target = asteroid
            function ship.target.body:getX() return asteroid.x end 
            function ship.target.body:getY() return asteroid.y end 
          end
        elseif ship.aistate == "mine_ore" and ship.target ~= nil and distance(ship.target.body:getX(), ship.target.body:getY(), ship.body:getX(), ship.body:getY()) < 500 then
          ship.mining_beam_active = true
          local ws = res_gamedata.weapon_stats[res_text.weapon_names[ship.weapons[ship.weaponSelId]]]
          local dmg = ws.damage
          local amt = love.math.random(dmg[1], dmg[2]) * dt
          if asteroids:damage(ship.target, amt) then
            ship.mining_beam_active = false
            ship.aistate = "search"
            ship.target = nil
          end
          
          ship.cargo_ore = ship.cargo_ore + amt
          if ship.cargo_ore >= ship.cargo_ore_max then
            ship.cargo_ore = ship.cargo_ore_max
            ship.aistate = "sell_ore"
            ship.target = nil
            ship.mining_beam_active = false
          end
          
          local lvx, lvy = ship.body:getLinearVelocity()
          ship.body:setLinearVelocity(lvx * 0.1, lvy * 0.1)
        elseif ship.aistate == "mine_ore" and ship.target ~= nil then
          ship.body:setAngle(math.angle(ship.x, ship.y, ship.target.body:getX(), ship.target.body:getY()))
          if ship.body:getAngularVelocity() >= 0.0005 then
            ship.throttle = 0
          else
            ship.throttle = 6
          end
        elseif ship.aistate == "leave_sector" and ship.target == nil then
          -- Pick direction and head that way until it's possible to leave.
          local drx = love.math.random(-1, 1)
          local dry = love.math.random(-1, 1)
          
          if drx == 0 and dry == 0 then
            drx = 1
          end
          
          ship.target = { name = "Exit" }
          ship.target.x = 5000 * drx
          ship.target.y = 5000 * dry
          
          ship.target.body = {}
          function ship.target:getX() return ship.target.x end
          function ship.target:getY() return ship.target.y end

        elseif ship.aistate == "leave_sector" and ship.target ~= nil then
          print("Leaving for: ", ship.target.name, ship.target.x, ship.target.y)
          ship.body:setAngle(math.angle(ship.x, ship.y, ship.target.x, ship.target.y))
          ship.throttle = 10
          
          if ship.x < -4500 or ship.x > 4500 or ship.y < -4500 or ship.y > 4500 then            
            table.remove(sectors[ship.sectorY][ship.sectorX].ai_ships, ships:getShipIndex(sectors[ship.sectorY][ship.sectorX].ai_ships, ship))
            if ship.x < -4000 then ship.sectorX = ship.sectorX - 1 end
            if ship.y < -4000 then ship.sectorY = ship.sectorY - 1 end
            if ship.x > 4000 then ship.sectorX = ship.sectorX + 1 end
            if ship.y > 4000 then ship.sectorY = ship.sectorY + 1 end
            ship.aistate = "search"
            ship.target = nil
            local lvx, lvy = ship.body:getLinearVelocity()
            ship.body:setLinearVelocity(lvx * 0.1, lvy * 0.1)
            ship.throttle = 0
            if ship.sectorX ~= sectorX or ship.sectorY ~= sectorY then
              ship.body:setActive(false)
            else
              ship.body:setActive(true)
            end
            ship.body:setLinearVelocity(lvx * 0.1, lvy * 0.1)
            table.insert(sectors[ship.sectorY][ship.sectorX].ai_ships, ship)
          end
        
        end
      end
    -- *****************************
    -- * Frozen State AI Routines
    -- *****************************
    ,mining_frozen = function (ship, dt)
        ship.rotation = ship.body:getAngle()
        print("inactive " .. ship.name .. " ai: " .. ship.aistate .. " cargo_ore: ", ship.cargo_ore)
        if ship.aistate == "search" then
          
          if ship.cargo_ore >= ship.cargo_ore_max then
            ship.aistate = "sell_ore"
          elseif ship.cargo_ore < ship.cargo_ore_max then
            ship.aistate = "mine_ore"
          end
        elseif ship.aistate == "sell_ore" and ship.target == nil then
          
          
          local sh = ships:findInSector("Oort Station", ship.sectorX, ship.sectorY) 
          print("FOund oort station?", sh)
          
          if sh then
            ship.target = sh           
            return
          end

          local drx = 0
          local dry = 0
          if ship.sectorX > sectorX then
            drx = -1
          end
          if ship.sectorY > sectorY then
            dry = -1
          end
          if ship.sectorX < sectorX then
            drx = 1
          end
          if ship.sectorY < sectorY then
            dry = 1
          end
          
          ship.target = nil
          ship.target = { name = "Exit", hangar = {}, hangar_max = 0 }
          ship.target.x = drx
          ship.target.y = dry
          
          ship.target.body = {}
          function ship.target.body:getX() return ship.target.x end
          function ship.target.body:getY() return ship.target.y end
          
          ship.aistate = "leave_sector"
          
        elseif ship.aistate == "sell_ore" and ship.isDocked and ship.target ~= nil then
        
    --      print("Selling ore and undocking")
          
    --      print("Sales info: ")
    --      print("  Station Price per m3: ", ship.target.market_prices.ore.buy)
    --      print("  Amount sold: ", ship.cargo_ore)
    --      print("  Total Amount Earned: ", ship.target.market_prices.ore.buy * ship.cargo_ore)
          
          ship.target.cargo_ore = ship.target.cargo_ore + ship.cargo_ore
          ship.cargo_ore = 0
          
          ships:unDockFromTarget(ship)
          
          ship.target = nil
          ship.aistate = "search"

        elseif ship.target ~= nil and ship.sectorX == ship.target.sectorX and ship.sectorY == ship.target.sectorY and ship.aistate == "sell_ore" and not ship.isDocked then
        
          if ship.canDock and not ship.target.canDock and #ship.target.hangar < ship.target.hangar_max then
            --ships:dockToTarget(ship)
            print ("ai trying to dock to ", ship.target.name)
          else
            ship.body:setLinearVelocity(lvx * 0.1, lvy * 0.1)
          end
        elseif ship.aistate == "mine_ore" and ship.target == nil then
          local t = sectors[sectorY][sectorX].asteroids
          local asteroid = nil
          for i=1, #t do
              if t[i].name == "Asteroid" then
                asteroid = t[i]
                break
              end
          end
          if asteroid == nil then
            ship.aistate = "leave_sector"
            ship.target = nil
          else
            asteroid.body = {}
            ship.target = asteroid
            function ship.target.body:getX() return asteroid.x end 
            function ship.target.body:getY() return asteroid.y end 
          end
        elseif ship.aistate == "mine_ore" and ship.target ~= nil then
          local ws = res_gamedata.weapon_stats[res_text.weapon_names[ship.weapons[ship.weaponSelId]]]
          local dmg = ws.damage
          local amt = love.math.random(dmg[1], dmg[2]) * dt
          if asteroids:damage(ship.target, amt) then
            ship.aistate = "search"
            ship.target = nil
          end
          
          ship.cargo_ore = ship.cargo_ore + amt
          if ship.cargo_ore >= ship.cargo_ore_max then
            ship.cargo_ore = ship.cargo_ore_max
            ship.aistate = "sell_ore"
            ship.target = nil
          end
          
        elseif ship.aistate == "leave_sector" and ship.target == nil then
          -- Pick direction and head that way until it's possible to leave.
          local dir = love.math.random(1, 4)
          
          local drx = 0
          local dry = 0
          
          if dir == 1 then
            drx = 1
            dry = 0
          elseif dir == 2 then
            drx = 0
            dry = 1
          elseif dir == 3 then
            drx = -1
            dry = 0
          elseif dir == 4 then
            drx = 0
            dry = -1
          end
          
          local lvx, lvy = ship.body:getLinearVelocity()
          ship.body:setLinearVelocity(lvx * 0.1, lvy * 0.1)
          ship.throttle = 0
                    
          table.remove(sectors[ship.sectorY][ship.sectorX].ai_ships, ships:getShipIndex(sectors[ship.sectorY][ship.sectorX].ai_ships, ship))
          ship.sectorX = ship.sectorX + drx
          ship.sectorY = ship.sectorY + dry
          ship.aistate = "sell_ore"
          ship.target = nil
          ship.body:setActive(false)
          table.insert(sectors[ship.sectorY][ship.sectorX].ai_ships, ship)
          
        elseif ship.aistate == "leave_sector" and ship.target ~= nil then
                    
          table.remove(sectors[ship.sectorY][ship.sectorX].ai_ships, ships:getShipIndex(sectors[ship.sectorY][ship.sectorX].ai_ships, ship))
          if ship.target.x > 1 then
            ship.target.x = 1
          end
          if ship.target.x < -1 then
            ship.target.x = -1
          end
          if ship.target.y > 1 then
            ship.target.y = 1
          end
          if ship.target.y < -1 then
            ship.target.y = -1
          end
          
          ship.sectorX = ship.sectorX + ship.target.x
          ship.sectorY = ship.sectorY + ship.target.y
          ship.aistate = "sell_ore"
          ship.target = nil
          if ship.sectorX == sectorX and ship.sectorY == sectorY then
            ship.body:setActive(true)
            -- TODO: Send ui notification to user that an AI ship just arrived in the sector.
          else
            ship.body:setActive(false)
          end
          print ("leaving to ", ship.sectorX, ship.sectorY)
          table.insert(sectors[ship.sectorY][ship.sectorX].ai_ships, ship)
        end        
      end
  }