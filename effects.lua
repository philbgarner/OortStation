local random = math.random
local function uuid()
    local template ='xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
    return string.gsub(template, '[xy]', function (c)
        local v = (c == 'x') and random(0, 0xf) or random(8, 0xb)
        return string.format('%x', v)
    end)
end

local images = {
  dust = res_image["dust"]
}

local effects = {
  list = {}
}


function effects:addAnimation(effect, img, frameW, frameH, gridX, gridY, delay, onLoop)
  local grid = anim8.newGrid(frameW, frameH, images[img]:getWidth(), images[img]:getHeight())
  effect.animation = { anim = anim8.newAnimation(grid(gridX, gridY), delay, onLoop), animImage = images[img], oX = frameW/2, oY = frameH/2 }
end

function effects:removeKey(uid)
    
  for i=1, #effects.list do
    if effects.list[i] ~= nil and effects.list[i].id == uid then
      --table.insert(newlist, effects.list[i])
      effects.list[i] = nil
      break
    end
  end

end

function effects:setText(effect, txt, x, y, dir, f, colr)
  if effect == nil then
    return
  end
  effect.text.value = txt
  effect.text.body = nil
  effect.text.fixture = nil
  effect.text.shape = nil
  effect.text.colr = colr
  effect.text.body = love.physics.newBody(effect.world, x, y, "dynamic")
  effect.text.shape = love.physics.newRectangleShape(0, 0, 8, 8)
  effect.text.fixture = love.physics.newFixture(effect.text.body, effect.text.shape, effect.text.density)
  local vectorX = math.cos(dir) * (f)
  local vectorY = math.sin(dir) * (f)

  effect.text.body:applyForce(vectorX, vectorY)
  effect.text.fixture:setRestitution(0.1)
  effect.text.fixture:setUserData(txt)
  effect.text.fixture:setFilterData(0x00f, 0x000, 0)

end

function effects:create(effectWorld, img, sx, sy, w, h, gridX, gridY, ox, oy)
  local uuid = uuid()
  local r = love.math.random(0, 359)
  local effect = {
      x = sx
      ,y = sy
      ,rotation = r
      ,id = uuid
      ,oX = ox
      ,oY = oy
      ,animation = nil
      ,text = {
          value = nil
          ,body = nil
          ,fixture = nil
          ,shape = nil
          ,density = 1
          ,colr = {255, 255, 255}
          ,iter_callback = function ()  end
        }
      ,world = effectWorld
  }
  effects:addAnimation(effect, img, w, h, gridX, gridY, 0.03, function (anim, frames) effects:removeKey(uuid) end)
  
  table.insert(effects.list, effect)
  return effect
end

function effects:update(dt)
  local newlist = {}
  for i=1, #effects.list do
    if effects.list[i] ~= nil then
      effects.list[i].animation.anim:update(dt)
      table.insert(newlist, effects.list[i])
    end
  end
  effects.list = newlist
end

function effects:draw()
  txtnodes = {}
  for i=1, #effects.list do
    if effects.list[i] ~= nil then
      local dx = effects.list[i].x
      local dy = effects.list[i].y
      local an = effects.list[i].animation
      an.anim:draw(an.animImage, math.floor(dx), math.floor(dy), effects.list[i].rotation, 1, 1, an.oX, an.oY)
      if effects.list[i].text.value ~= nil then
       table.insert(txtnodes, effects.list[i].text)
      end
    end
  end
  for i=1, #txtnodes do
      love.graphics.setColor(txtnodes[i].colr[1], txtnodes[i].colr[2], txtnodes[i].colr[3])
      love.graphics.print(txtnodes[i].value, txtnodes[i].body:getX(), txtnodes[i].body:getY())
      love.graphics.setColor(255, 255, 255)
    end
end


return effects