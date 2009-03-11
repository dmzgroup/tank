local function receive_message (self, message, data)
   if dmz.data.is_a (data) then
      local target = data:lookup_handle ("object", 1)
      local pos = data:lookup_vector ("position", 1)
      if not pos then pos = dmz.vector.new (0, 0, 0) end

      local event = dmz.event.open_detonation (0, target)
      if event then
         dmz.event.position (event, nil, pos)
         dmz.event.object_type (event, dmz.event.MunitionsHandle, "m830a1")
         dmz.event.close (event)
      end
   end
end

local function start (self)
end


local function stop (self)
end


function new (config, name)
   local self = {
      start_plugin = start,
      stop_plugin = stop,
      name = name,
      log = dmz.log.new ("lua." .. name),
      message = config:to_message ("message.name", "CreateDetonationMessage"),
      obs = dmz.message_observer.new (name),
   }

   self.log:info ("Creating plugin: " .. name)
   self.obs:register (self.message, receive_message, self)
   
   return self
end

