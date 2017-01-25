local random = math.random
local function uuid()
    local template ='xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
    return string.gsub(template, '[xy]', function (c)
        local v = (c == 'x') and random(0, 0xf) or random(8, 0xb)
        return string.format('%x', v)
    end)
end

local personae = {
  list = {}
}

local names_male = {
  "Rohn"
  ,"Anthonix"
  ,"Elliat"
  ,"Adran"
  ,"Andrex"
  ,"Dariox"
  ,"Camran"
  ,"Aedan"
  ,"Zavis"
  ,"Emex"
  ,"Karzen"
  ,"Paxt"
  ,"Aydan"
  ,"Teag"
  ,"Fyster"
  ,"Blaike"
  ,"Daerryl"
  ,"Jaeke"
  ,"Braidn"
  ,"Zavr"
  ,"Gabryel"
  ,"Kold"
  ,"Frankyl"
  ,"Alefret"
  ,"Alixandr"
  ,"Lasson"
  ,"Adrihel"
  ,"Briyan"
  ,"Tristiran"
}

local names_female = {
    "Braealyn"
    ,"Aevangelina"
    ,"Janae"
    ,"Cathrise"
    ,"Maelynn"
    ,"Allany"
    ,"Charlise"
    ,"Charleagh"
    ,"Kaela"
    ,"Breyanna"
    ,"Anka"
    ,"Jaessa"
    ,"Maelana"
    ,"Jazzly"
    ,"Evleyen"
    ,"Kaeya"
    ,"Melo"
    ,"Janiah"
    ,"Elenoh"
    ,"Saria"
    ,"Jexa"
    ,"Iyleen"
    ,"Anka"
    ,"Carlisa"
    ,"Casdy"
    ,"Arelle"
    ,"Adrana"
    ,"Makenna"
    ,"Ziahra"
    ,"Keaya"
    ,"Aesha"
    ,"Aleigha"
    ,"Natlia"
    ,"Laylah"
    ,"Fyna"
    ,"Julith"
    ,"Elaena"
    ,"Camla"
    ,"Aera"
    ,"Arbelle"
  }

local surnames = {
    "Quade"
    ,"Pearlberg"
    ,"Esparza"
    ,"Ghorai"
    ,"Midhet"
    ,"Baglivo"
    ,"Champagne"
    ,"Soule"
    ,"Peled"
    ,"Wigotsky"
    ,"Disraeli"
    ,"Tingle"
    ,"Fischbach"
    ,"Nunez-farfar"
    ,"Alt"
    ,"Schofield"
    ,"North"
    ,"Schwalenberg"
    ,"Prelich"
    ,"Defranco"
    ,"Dole"
    ,"Peebles"
    ,"Scheer"
    ,"Morrissey"
    ,"Dell'antonio"
    ,"Shea-simonds"
    ,"Salway"
    ,"England"
    ,"Slack"
    ,"Partington"
    ,"Aklog"
    ,"Doering"
    ,"Wentz"
    ,"Onley"
    ,"Shuppert"
    ,"Sorensen"
    ,"Marcillo"
    ,"Spera"
    ,"Genova"
    ,"Chiu"
    ,"Bauer"
    ,"Stukel"
    ,"Valminuto"
    ,"Dorra"
    ,"Merminod"
    ,"Welles"
    ,"Donin"
    ,"Septimus"
    ,"Calzoni"
    ,"Ekstrom"
    ,"Geidt"
    ,"Herwitz"
    ,"Gouse"
    ,"Dokidis"
    ,"Bergson"
    ,"Rosser"
    ,"Lewalski"
    ,"Rhiel"
    ,"Press"
    ,"Kenter"
    ,"Baptista"
    ,"Botosh"
  }
  
local occupations = {
    politics = {"Governor", "Constable"} -- Governor for the leader in charge of a station. Constable is a police officer.
    ,military = {"Admiral", "Captain", "Marine"} -- Admiral for the leader of a fleet, Captain for any other vessel. Marines are the grunts.
    ,civilian = {"Engineer", "Doctor", "Scientist", "Pilot", "Bartender", "Mechanic", "Privateer"}
  }
local occupations_abbr = {
    politics = {"Gov.", "Const."}
    ,military = {"Adm.", "Capt.", "Mrn."}
    ,civilian = {"Eng.", "Dr.", "Sci.", "Pil.", "Bar.", "Mech.", "Priv."}
  }
  
-- Salaries in biweekly timeperiod.
local salaries = {
    politics = {
        Governor = 1000
        ,Constable = 125
      }
    ,military = {
        Admiral = 500
        ,Captain = 250
        ,Marine = 200
      }
    ,civilian = {
        Engineer = 200
        ,Doctor = 500
        ,Scientiest = 150
        ,Pilot = 175
        ,Bartender = 50
        ,Mechanic = 75
        ,Privateer = 800
      }
  }
  
-- Menu Interactions for each Occupation
local menus = {
    politics = {
        Governor = {
            neutral = {
                {message = "Welcome to my station."}
                ,{message = "We provide habitat and infrastructure for settlers in the Oort Cloud."}
                ,{message = "Our services are highly in demand."}
              }
            ,friendly = {
              {message = "Hey, great to see you again!"}
              ,{message = "Thank you for your patronage! Enjoy your stay!"}
            }
            ,offer_mission = {
                {message = "Listen, I might have a mission for you, if you're interested."}
              }
            ,hostile = {
                {message = "Don't talk to me!"}
              }
          }
        ,Constable = {
            neutral = {
                {message = "..."}
                ,{message = "Move along, citizen."}
              }
            ,friendly = {
              {message = "Citizen."}
            }
            ,offer_mission = {
                {message = "Feel like doing some investigative work?"}
              }
            ,hostile = {
                {message = "Papers please, citizen."}
              }
          }
      }
      
    ,military = {
        Admiral = {
            neutral = {
                {message = "..."}
                ,{message = "Can I help you?"}
                ,{message = "Leave me to my thoughts."}
              }
            ,friendly = {
              {message = "Sailor."}
            }
            ,offer_mission = {
                {message = "You ready to work for me?"}
              }
            ,hostile = {
                {message = "Do you even know who I am?"}
                ,{message = "Get outta here!"}
              }
          }
        ,Captain = {
            neutral = {
                {message = "..."}
                ,{message = "It's a boring life, out here."}
                ,{message = "A ship's captain doesn't see much action out here."}
              }
            ,friendly = {
              {message = "Sir."}
            }
            ,offer_mission = {
                {message = "I have some work for you if you've got the 'right stuff'..."}
              }
            ,hostile = {
                {message = "Back off, sailor!"}
              }
          }
        ,Marine = {
            neutral = {
                {message = "..."}
                ,{message = "Evening, Citizen."}
                ,{message = "That's fine.  Move along, Citizen."}
              }
            ,friendly = {
              {message = "..."}
            }
            ,offer_mission = {
                {message = ""}
              }
            ,hostile = {
                {message = "Touch me again and you're dead!"}
              }
          }
      }
      
    ,civilian = {
        Engineer = {
            neutral = {
                {message = "Hi."}
                ,{message = "Engineers are in demand out here."}
                ,{message = "All the materials I could dream of!"}
              }
            ,friendly = {
              {message = "Hey, great to see you again!"}
            }
            ,offer_mission = {
                {message = "Listen, I might have a mission for you, if you're interested."}
              }
            ,hostile = {
                {message = "Don't talk to me!"}
              }
          }
        ,Doctor = {
            neutral = {
                {message = "Hello."}
                ,{message = "Are you well?"}
                ,{message = "Hygeine is important on a small station like this *sniff*."}
              }
            ,friendly = {
              {message = "Hi, it has been a while!"}
            }
            ,offer_mission = {
                {message = "I have something for you..."}
              }
            ,hostile = {
                {message = "Don't talk to me!"}
              }
          }
        ,Scientist = {
            neutral = {
                {message = "Hello."}
                ,{message = "My research is beginning to bear fruit."}
                ,{message = "Everyone needs a researcher on their team."}
              }
            ,friendly = {
              {message = "Good to see you again."}
            }
            ,offer_mission = {
                {message = "My research might interest you..."}
              }
            ,hostile = {
                {message = "Excuse me!"}
              }
          }
        ,Pilot = {
            neutral = {
                {message = "Hi."}
                ,{message = "Isn't, this area is pristine?"}
                ,{message = "I can't get enough of these icy asteroid fields!"}
              }
            ,friendly = {
              {message = "Good to see you again."}
            }
            ,offer_mission = {
                {message = "I'm forming a convoy to sector 2-4, you interested in joining?"}
              }
            ,hostile = {
                {message = "Back off!"}
              }
          }
        ,Bartender = {
            neutral = {
                {message = "Welcome to the Lounge!"}
                ,{message = "This is the lounge, where all the passengers hang out."}
                ,{message = "Welcome! Please relax in our lounge."}
              }
            ,friendly = {
              {message = "Welcome back to the Lounge! What can I get you?"}
            }
            ,offer_mission = {
                {message = "I came across some interesting information recently, if you're interested..."}
              }
            ,hostile = {
                {message = "Get out of my bar!"}
              }
          }
        ,Mechanic = {
            neutral = {
                {message = "Hi there."}
                ,{message = "I can fix anything they fly out here."}
              }
            ,friendly = {
              {message = "Nice to see you again."}
            }
            ,offer_mission = {
                {message = "."}
              }
            ,hostile = {
                {message = "Don't talk to me!"}
              }
          }
        ,Privateer = {
            neutral = {
                {message = "..."}
                ,{message = "Need something?"}
              }
            ,friendly = {
              {message = "'Sup?"}
            }
            ,offer_mission = {
                {message = "Hey, meet me later, I might have something you'd be interested in."}
              }
            ,hostile = {
                {message = "Piss off!"}
              }
          }
          
      }
      
  }
  
function personae:getMenu(occup, category)
  if menus.politics[occup] ~= nil and menus.politics[occup][category] ~= nil  then
    return menus.politics[occup][category][love.math.random(1, #menus.politics[occup][category])]
  elseif menus.military[occup] ~= nil and menus.military[occup][category] ~= nil  then
    return menus.military[occup][category][love.math.random(1, #menus.military[occup][category])]
  elseif menus.civilian[occup] ~= nil and menus.civilian[occup][category] ~= nil  then
    return menus.civilian[occup][category][love.math.random(1, #menus.civilian[occup][category])]
  else
    return {message = "[ERROR: Menu dialog not found.]", actions = {}}
  end
end
 
function personae:create(sectX, sectY, vehicle, occup)
  local pid = uuid()
  local portraitNo = love.math.random(1, 10)
  local name = ""
  if portraitNo <= 5 then
    name = names_male[love.math.random(1, #names_male)]
  elseif portraitNo > 5 then
    name = names_female[love.math.random(1, #names_female)]
  end
  local surname = surnames[love.math.random(1, #surnames)]

  local persona = {
      name = name
      ,surname = surname
      ,uuid = pid
      ,account_balance = 0
      ,portraitid = portraitNo
      ,occupation = nil
      ,work_vehicle = nil
      ,sectorX = sectX
      ,sectorY = sectY
      ,vehicle = vehicle
      ,owned_vehicle = nil
    }
    
  if occup == nil then    
    local branch = love.math.random(1, 3)
    local occ = nil
    local bal = nil
    
    if branch == 1 then
      local n = occupations.politics[love.math.random(1, #occupations.politics)]
      occ = occupations.politics[n]
      bal = salaries.politics[n]
    elseif branch == 2 then
      local n = occupations.military[love.math.random(1, #occupations.military)]
      occ = occupations.military[love.math.random(1, #occupations.military)]
      bal = salaries.military[n]
    elseif branch == 3 then
      local n = occupations.civilian[love.math.random(1, #occupations.civilian)]
      occ = occupations.civilian[love.math.random(1, #occupations.civilian)]
      bal = salaries.civilian[n]
    end
    persona.occupation = occ
    persona.account_balance = bal
  else
    local bal = nil

    if salaries.politics[occup] ~= nil then
      bal = salaries.politics[occup]
    elseif salaries.military[occup] ~= nil then
      bal = salaries.military[occup]
    elseif salaries.civilian[occup] ~= nil then
      bal = salaries.civilian[occup]
    end
    persona.occupation = occup
    persona.account_balance = bal
  end
  
  if persona.occupation == nil then
    persona.occupation = "Pilot"
  end
    
  if personae.list[pid] == nil then
    personae.list[pid] = persona
    vehicle.passengers[pid] = persona
  else
    print("Persona Create Error: uuid already in use!")
    return false
  end
  
  return persona
end

return personae