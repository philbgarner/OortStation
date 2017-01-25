local asteroids = {

  list = {}

}

function asteroids:addAnimation(asteroid, img, name, frameW, frameH, gridX, gridY, delay, onLoop)
  local image = img

  local grid = anim8.newGrid(frameW, frameH, image:getWidth(), image:getHeight())
   
  asteroid.animation[name] = { anim = anim8.newAnimation(grid(gridX, gridY), delay, onLoop), animImage = image, oX = frameW/2, oY = frameH/2 }
  if asteroid.animationId == nil then
    asteroid.animationId = name
  end
end

function asteroids:damage(asteroid, amt)
  asteroid.health = asteroid.health - amt
  if asteroid.health < 0 then
    asteroid.health = 0
    asteroids:destroy(asteroid)
    return true
  end
  return false
end

function asteroids:setInactive()
  for i=1, #asteroids.list do
    asteroids.list[i].active = false
  end
end

function asteroids:setActive()
  for i=1, #asteroids.list do
    asteroids.list[i].active = true
  end
end


function asteroids:destroy(asteroid, amt)
  for i=1, #asteroids.list do
  
    if asteroids.list[i] == asteroid then
      
      asteroids.list[i] = nil
      return
      
    end
  
  end
  
end

function asteroids:create(asteroidWorld)
  sx = love.math.random(-2500, 2500)
  sy = love.math.random(-2500, 2500)
  v = love.math.random(1, 5)
  rot = love.math.random(1, 359)
  tid = love.math.random(1, 3)
  h = 100 + love.math.random(-25, 25)
  local asteroid = {
      health = h
      ,health_max = h
      ,name = "Asteroid"
      ,typeid = tid
      ,x = sx
      ,y = sy
      ,velocity = v
      ,rotation = rot
      ,animation = {}
      ,animationId = nil
      ,body = nil
      ,shape = nil
      ,fixture = nil
      ,density = 1
      ,world = asteroidWorld
      ,active = true
  }
  asteroids:addAnimation(asteroid, res_image["asteroids"][tid], "idle", 320, 240, 1, 1, 0.2)
  
  table.insert(asteroids.list, asteroid)
end

function asteroids:changeAnimation(asteroid, name)
  if asteroid.animation[name] ~= nil then
    asteroid.animationId = name
    asteroid.animation[name].anim:gotoFrame(1)
    return true
  end
  return false
end

function asteroids:updateAsteroid(asteroid, dt)
  asteroid.x = asteroid.x + math.cos(asteroid.rotation) * (asteroid.velocity * dt)
  asteroid.y = asteroid.y + math.sin(asteroid.rotation) * (asteroid.velocity * dt)
    
  asteroids:updateAnimation(asteroid, dt)

end

function asteroids:updateAnimation(ship, dt)
  if ship.animationId == nil then return end
  ship.animation[ship.animationId].anim:update(dt)
end

function asteroids:drawAsteroid(asteroid)
  if asteroid.animationId == nil then return end
  local an = asteroid.animation[asteroid.animationId]
  an.anim:draw(an.animImage, math.floor(asteroid.x), math.floor(asteroid.y), asteroid.rotation, 1, 1, an.oX, an.oY)

end

function asteroids:update(dt)

  newlist = {}

  for i=1, #asteroids.list do
    if asteroids.list[i] ~= nil and asteroids.list[i].active then
      asteroids:updateAsteroid(asteroids.list[i], dt)
      table.insert(newlist, asteroids.list[i])
    end
  end

  asteroids.list = newlist

end

function asteroids:draw()

  for i=1, #asteroids.list do
    if asteroids.list[i].active then
      asteroids:drawAsteroid(asteroids.list[i])
    end
  end

end


return asteroids