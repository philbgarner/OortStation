res_image = {
  salvager_idle = love.graphics.newImage("assets/images/ship_idle.png")
  ,salvager_forward = love.graphics.newImage("assets/images/ship_forward.png")
  ,salvager_forward_release = love.graphics.newImage("assets/images/ship_forward_release.png")
  ,salvager_reverse = love.graphics.newImage("assets/images/ship_reverse.png")
  ,salvager_reverse_release = love.graphics.newImage("assets/images/ship_reverse_release.png")
  
  ,dust = love.graphics.newImage("assets/images/dustx4_large.png")
  
  ,portrait_ai = love.graphics.newImage("assets/images/portraits_ai.png")
  
  ,pilot_portraits = {
      love.graphics.newImage("assets/images/portraits_pilot1.png")
      ,love.graphics.newImage("assets/images/portraits_pilot2.png")
      ,love.graphics.newImage("assets/images/portraits_pilot3.png")
      ,love.graphics.newImage("assets/images/portraits_pilot4.png")
      ,love.graphics.newImage("assets/images/portraits_pilot5.png")
      ,love.graphics.newImage("assets/images/portraits_pilot6.png")
      ,love.graphics.newImage("assets/images/portraits_pilot7.png")
      ,love.graphics.newImage("assets/images/portraits_pilot8.png")
      ,love.graphics.newImage("assets/images/portraits_pilot9.png")
      ,love.graphics.newImage("assets/images/portraits_pilot10.png")
    }
  
  ,stations = {
      love.graphics.newImage("assets/images/station1.png")
    }
  
  ,asteroids = {
    love.graphics.newImage("assets/images/asteroid1.png")
    ,love.graphics.newImage("assets/images/asteroid2.png")
    ,love.graphics.newImage("assets/images/asteroid3.png")
  }
  ,weapons = {
    love.graphics.newImage("assets/images/weapon1.png")
    ,love.graphics.newImage("assets/images/weapon2.png")
    ,love.graphics.newImage("assets/images/weapon3.png")
  }
}

res_text = {
  weapon_names = {
    "Mining Beam"
    ,"Cannons"
    ,"Plasma Charge"
  }
}

res_gamedata = {
    weapon_stats = {}
  
  }

res_gamedata.weapon_stats["Mining Beam"] = {
      damage = {0, 5}
      ,damage_type = "beam"
    }

res_audio = {
    laser_operation = "assets/audio/laser_operation.ogg"
    ,laser_end = "assets/audio/laser_end.ogg"
    ,ship_background = "assets/audio/background-ship.ogg"
    ,ship_engine = "assets/audio/ship_engine.ogg"
    ,destroy_rubble = "assets/audio/destroy_rubble.ogg"
    ,menu_change = "assets/audio/menu_change.ogg"
  }