local random = math.random
local function uuid()
    local template ='xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
    return string.gsub(template, '[xy]', function (c)
        local v = (c == 'x') and random(0, 0xf) or random(8, 0xb)
        return string.format('%x', v)
    end)
end

local portrait_images = {
    ai = res_image["portrait_ai"]
    ,pilot1 = res_image["pilot_portraits"][1]
    ,pilot2 = res_image["pilot_portraits"][2]
    ,pilot3 = res_image["pilot_portraits"][3]
    ,pilot4 = res_image["pilot_portraits"][4]
    ,pilot5 = res_image["pilot_portraits"][5]
    ,pilot6 = res_image["pilot_portraits"][6]
    ,pilot7 = res_image["pilot_portraits"][7]
    ,pilot8 = res_image["pilot_portraits"][8]
    ,pilot9 = res_image["pilot_portraits"][9]
    ,pilot10 = res_image["pilot_portraits"][10]
  }
  
local portraits = {
  list = {}
}

function portraits:addAnimation(ptr, img, frameW, frameH, gridX, gridY, delay, onLoop)
  local grid = anim8.newGrid(frameW, frameH, portrait_images[img]:getWidth(), portrait_images[img]:getHeight())
  ptr.animation = { anim = anim8.newAnimation(grid(gridX, gridY), delay, onLoop), animImage = portrait_images[img], oX = 0, oY = 0 }
end

function portraits:removeKey(uid)
        
  for i=1, #portraits.list do
    if portraits.list[i] ~= nil and portraits.list[i].id == uid then
      portraits.list[i] = nil
      break
    end
  end

end

function portraits:create(ptrWorld, img, sx, sy, w, h, gridX, gridY, n, msg, d, cb)
  local uuid = uuid()
  local portrait = {
      x = sx
      ,y = sy
      ,oX = 0
      ,oY = 0
      ,id = uuid
      ,animation = nil
      ,messages = msg
      ,message_counter = 1
      ,name = n
      ,world = ptrWorld
      ,delay = d
      ,dcounter = 0
      ,endcount = 0
      ,callback = cb
  }
  portraits:addAnimation(portrait, img, w, h, gridX, gridY, 0.09)
  portrait.animation.anim:gotoFrame(1)
  
  if #portraits.list > 0 then portraits.list = {} end
  table.insert(portraits.list, portrait)
end


function portraits:say(portraitImage, name, messages, delay, callback)
  if name == "ai" then
    portraits:create(world, portraitImage, 0, 422, 128, 216, 1, '1-22', name, messages, delay, callback)
  else
    portraits:create(world, portraitImage, 0, 422, 128, 216, 1, 1, name, messages, delay, callback)
  end
end

function portraits:update(dt)
  local newlist = {}
  for i=1, #portraits.list do
    if portraits.list[i] ~= nil then
      portraits.list[i].animation.anim:update(dt)
      portraits.list[i].dcounter = portraits.list[i].dcounter + dt
      
      if portraits.list[i].dcounter > portraits.list[i].delay then
        portraits.list[i].dcounter = 0
        portraits.list[i].message_counter = portraits.list[i].message_counter + 1
        if portraits.list[i].message_counter > #portraits.list[i].messages then
          portraits.list[i].message_counter = #portraits.list[i].messages
          
          local cb = portraits.list[i].callback
          portraits.list[i] = nil
          if cb ~= nil then
            cb()
          end
        end
      end
      
      table.insert(newlist, portraits.list[i])
    end
  end
  portraits.list = newlist
end

function portraits:draw()
  for i=1, #portraits.list do
    if portraits.list[i] ~= nil then
      local dx = portraits.list[i].x
      local dy = portraits.list[i].y
      local an = portraits.list[i].animation
      an.anim:draw(an.animImage, math.floor(dx), math.floor(dy), portraits.list[i].rotation, 1, 1, an.oX, an.oY)
      
      for j=1, portraits.list[i].message_counter do
        if j == portraits.list[i].message_counter then
          love.graphics.setColor(50, 255, 75)
        else
          love.graphics.setColor(0, 200, 15)
        end
        
        local text = portraits.list[i].messages[j]
        love.graphics.print(text, dx + 130, dy + j * 14)
      end
      love.graphics.setColor(0, 200, 15)
      love.graphics.print(portraits.list[i].name, dx + 25, dy)
      
    end
  end
  love.graphics.setColor(255, 255, 255)
end


return portraits