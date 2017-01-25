local ui = {
    target = 1
    ,imagelist = {
        weapons = {
            res_image["weapons"][1]
            ,res_image["weapons"][2]
            ,res_image["weapons"][3]
          }
      }
    ,weapon_names = res_text["weapon_names"]
}

function ui:drawMinimap(asteroids, ship, ai_ships)
  local mapW = 128
  local mapH = 128
  
  love.graphics.setColor(0, 200, 15)
  love.graphics.rectangle("line", 0, love.graphics.getHeight() - mapH, mapW, mapH )
  
  love.graphics.setColor(255, 200, 15)
  for i=1, #asteroids.list do
    if asteroids.list[i] ~= nil then
      local ax = asteroids.list[i].x / 64 + 64
      local ay = asteroids.list[i].y / 64 + 64 + love.graphics.getHeight() - mapH
      
      if ui.target == i then
        love.graphics.setColor(255, 255, 255)
      else
        love.graphics.setColor(255, 200, 15)
      end
      
      love.graphics.circle("line", ax, ay, 2)
    end
  end
  love.graphics.setColor(255, 0, 0)
  love.graphics.rectangle("line", ship.body:getX() / 64 + 64, ship.body:getY() / 64 + 64 + love.graphics.getHeight() - mapH, 5, 5)
  
  love.graphics.setColor(255, 255, 255);

  for i=1, #ai_ships do
    local ax = ai_ships[i].body:getX() / 64 + 64
    local ay = ai_ships[i].body:getY() / 64 + 64 + love.graphics.getHeight() - mapH
    
    if ui.target == i then
      love.graphics.setColor(255, 255, 255)
    else
      love.graphics.setColor(125, 125, 255)
    end
    
    love.graphics.circle("line", ax, ay, 5);
  end
end

function ui:sortClosest(asteroids, ship)

  newlist = {}
  
  for i=1, #asteroids.list do
    local obj = nil
    local dist = 99999
    for j=2, #asteroids.list do
      if asteroids.list[i] ~= nil then
        local d = distance(ship.body:getX(), ship.body:getY(), asteroids.list[i].x, asteroids.list[i].y)
        if d < dist then
          dist = d
          obj = asteroids.list[i]
          obj.distance = d
        end
      end
    end
    
    if obj ~= nil then
      table.insert(newlist, obj)
    end
  end
  
  return newlist
  
end

function ui:drawTargets(targets)
  if ui.target == nil then
    ui.target = 1
  end
  
  for i=1, #targets do
    if ui.target == i then
      love.graphics.setColor(255, 255, 255)
    else
      love.graphics.setColor(0, 200, 15)
    end
    love.graphics.print("" .. targets[i].name .. " - " .. math.floor(targets[i].distance) .. "m", 5, 25 + i * 14)
    love.graphics.setColor(255, 255, 255)
  end
    
end

function ui:drawComm(portrait, message)
  
end

function ui:drawWeapons(wlist, selected)
  love.graphics.setColor(255, 255, 255)  
  for i=1, #wlist do
    
    if i ~= selected then
      love.graphics.setColor(0, 200, 15)
    else
      love.graphics.setColor(255, 255, 255)
    end
  
    if wlist[i] > 0 then
      if i == selected then
        love.graphics.print(ui.weapon_names[wlist[i]], 300 + i * 64, love.graphics.getHeight() - 80)
      end
      
      love.graphics.draw(ui.imagelist.weapons[wlist[i]], 300 + i * 64, love.graphics.getHeight() - 64)
    end
      
    love.graphics.rectangle("line", 300 + i * 64, love.graphics.getHeight() - 64, 64, 64)
    love.graphics.setColor(255, 255, 255)
  
  end    

end

return ui