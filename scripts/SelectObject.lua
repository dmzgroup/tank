local function receive (self, type, data)

   if dmz.data.is_a (data) then

      local handle = data:lookup_handle ("object", 1)

      if handle and dmz.object.is_object (handle) and
            dmz.object.locality (handle) == dmz.object.Local then
         if self.addSelection then
            if dmz.object.is_selected (handle) then dmz.object.unselect (handle)
            else dmz.object.select (handle, dmz.object.SelectAdd)
            end
         else
            dmz.object.select (handle)
         end
      elseif not self.addSelection then
         dmz.object.unselect_all ()
      end

   end
end

local ShiftKey = dmz.input.get_key_value ("shift")

local function receive_key_event (self, channel, key)
   if key.value == ShiftKey then
      if key.state then self.addSelection = true
      else self.addSelection = false
      end
   end
end

function new (config, name)

   local self = {
      log = dmz.log.new ("lua." .. name),
      message = config:to_message ("message.name", "SelectEvent"),
      obs = dmz.message_observer.new (name),
      input = dmz.input_observer.new (name),
      addSelection = false,
   }

   self.log:info ("Creating plugin: " .. name)
   self.obs:register (self.message, receive, self)
   self.input:register (config, { receive_key_event = receive_key_event, }, self)

   return self
end
