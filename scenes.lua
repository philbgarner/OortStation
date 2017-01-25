local scenes = {
    list = {}
  }
  
function scenes:create(name, fnInit, fnUpdate, fnDraw, fnKeyPress, fnDestroy)
  local scene = {
      name = name
      ,paused = false
      ,fnInit = fnInit
      ,fnUpdate = fnUpdate
      ,fnDraw = fnDraw
      ,fnKeyPress = fnKeyPress
      ,fnDestroy = fnDestroy
    }
    
    table.insert(scenes.list, scene)
    
    scene.fnInit()
end

function scenes:keyPressed(key, scancode)
  scenes.list[#scenes.list].fnKeyPress(key, scancode)
end

function scenes:pop()
  scenes.list[#scenes.list] = nil
end

function scenes:update(dt)
  scenes.list[#scenes.list].fnUpdate(dt)
end

function scenes:draw()
  scenes.list[#scenes.list].fnDraw()
end

return scenes