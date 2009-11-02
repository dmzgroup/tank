local Highlight = dmz.handle.new ("Object_Highlight_Attribute")

function receive (self, type, data)

   if dmz.data.is_a (data) then


      local handle = data:lookup_handle ("object", 1)

      if handle and dmz.object.is_object (handle) then
         dmz.object.flag (handle, Highlight, true)
      end

      if handle ~= self.handle then
         if self.handle then
            local prev = self.handle
            self.handle = handle
            if dmz.object.is_object (prev) then
               dmz.object.flag (prev, Highlight, false)
            end
         else self.handle = handle
         end
      end

   end
end

function new (config, name)

   local self = {
      log = dmz.log.new ("lua." .. name),
      message = config:to_message ("message.name", "MouseMoveEvent"),
      obs = dmz.message_observer.new (name),
   }

   self.log:info ("Creating plugin: " .. name)
   self.obs:register (self.message, receive, self)

   return self
end
