mapper = require "mapper"

EXIT_COLOR_STYLE = 8421376

last_known_room_id = nil
room_list = {}

local my_config = {
  -- assorted colours
  BACKGROUND_COLOUR       = { name = "Background",        colour =  ColourNameToRGB "black", },
  ROOM_COLOUR             = { name = "Room",              colour =  ColourNameToRGB "cyan", },
  EXIT_COLOUR             = { name = "Exit",              colour =  ColourNameToRGB "darkgreen", },
  EXIT_COLOUR_UP_DOWN     = { name = "Exit up/down",      colour =  ColourNameToRGB "darkmagenta", },
  EXIT_COLOUR_IN_OUT      = { name = "Exit in/out",       colour =  ColourNameToRGB "#3775E8", },
  UNKNOWN_ROOM_COLOUR     = { name = "Unknown room",      colour =  ColourNameToRGB "#00CACA", },
  MAPPER_NOTE_COLOUR      = { name = "Messages",          colour =  ColourNameToRGB "lightgreen" },
  
  ROOM_NAME_TEXT          = { name = "Room name text",    colour = ColourNameToRGB "#BEF3F1", },
  ROOM_NAME_FILL          = { name = "Room name fill",    colour = ColourNameToRGB "#105653", },
  ROOM_NAME_BORDER        = { name = "Room name box",     colour = ColourNameToRGB "black", },
  
  AREA_NAME_TEXT          = { name = "Area name text",    colour = ColourNameToRGB "#BEF3F1",},
  AREA_NAME_FILL          = { name = "Area name fill",    colour = ColourNameToRGB "#105653", },   
  AREA_NAME_BORDER        = { name = "Area name box",     colour = ColourNameToRGB "black", },
               
  FONT = { name =  get_preferred_font {"Dina",  "Lucida Console",  "Fixedsys", "Courier", "Sylfaen",} ,
           size = 8
         } ,
         
  -- size of map window
  WINDOW = { width = 400, height = 400 },
  
  -- how far from where we are standing to draw (rooms)
  SCAN = { depth = 30 },
  
  -- speedwalk delay
  DELAY = { time = 0.3 },
  
  -- how many seconds to show "recent visit" lines (default 3 minutes)
  LAST_VISIT_TIME = { time = 60 * 3 },  
  
  }

function reset_map() {
	room_list = {}
}
  
function enter_room()

	local direction_moved = world.GetCommandList(1)[1]
	
	if((direction_moved == "n") or (direction_moved == "s") or (direction_moved == "e") or (direction_moved == "w")) 
		or (direction_moved == "nw") or (direction_moved == "ne") or (direction_moved == "sw") or (direction_moved == "se") then

		local exit_string = world.GetLineInfo(world.GetLineCount(), 1)
		local room_description = world.GetLineInfo(world.GetLineCount()-2, 1)
		
		if (exit_string ~= nil) and (room_description ~= nil) then
			local room_id = (utils.tohex(utils.md5(exit_string .. room_description)))
		
			save_room(room_id, direction_moved)
			mapper.draw(room_id)
		end
	end
end
  
function inverse_direction(direction)
	
	local inverse_direction = nil

	if direction == "n" then
		inverse_direction = "s"
	elseif direction == "s" then
		inverse_direction = "n"
	elseif direction == "e" then
		inverse_direction = "w"
	elseif direction == "w" then
		inverse_direction = "e"
	elseif direction == "nw" then
		inverse_direction = "se"
	elseif direction == "ne" then
		inverse_direction = "sw"
	elseif direction == "sw" then
		inverse_direction = "se"
	elseif direction == "se" then
		inverse_direction = "sw"
	end
	
	return inverse_direction
end
  
function save_room (uid, direction_moved)

	if last_known_room_id ~= nil then
	
		if room_list[uid] == nil then
			room_list[uid] = {area = "x", exits = {n = -1, s = -1, e = -1, w = -1, nw = -1, ne = -1, sw = -1, se = -1}}
		end
	
		if room_list[last_known_room_id] == nil then
			room_list[last_known_room_id] = {area = "x", exits = {n = -1, s = -1, e = -1, w = -1, nw = -1, ne = -1, sw = -1, se = -1}}
		end
		
		world.Note("entered " .. uid .. " from " .. inverse_direction(direction_moved) .. ". Last known room was " .. last_known_room_id)
		
		room_list[uid]["exits"][inverse_direction(direction_moved)] = last_known_room_id
		room_list[last_known_room_id]["exits"][direction_moved] = uid
	end
	
	last_known_room_id = uid
end
  
local function get_roomz0r (uid)

  local room = room_list[uid]
  
  if not room then
     return nil  -- room does not exist
  end -- if

  room.hovermessage = uid   -- for hovering the mouse

  -- desired colours
  room.bordercolour = ColourNameToRGB "green"
  room.borderpen = 0 -- solid
  room.borderpenwidth = 1
  room.fillcolour = ColourNameToRGB "red"
  room.fillbrush = 0 -- solid

  return room
end

function print_rooms()
	for key,value in pairs(room_list) do
		world.Note(key)
		world.Note("\tn:" .. value["exits"]["n"])
		world.Note("\ts:" .. value["exits"]["s"])
		world.Note("\te:" .. value["exits"]["e"])
		world.Note("\tw" .. value["exits"]["w"])
		world.Note("\tne" .. value["exits"]["ne"])
		world.Note("\tnw" .. value["exits"]["nw"])
		world.Note("\tse" .. value["exits"]["se"])
		world.Note("\tsw" .. value["exits"]["sw"])
	end
end

mapper.init { config = my_config, get_room = get_roomz0r, show_help = OnHelp, room_click = room_click  } 
mapper.mapprint ("Xception's SWMUD Mapper Loaded")
