local Forward = dmz.vector.new {0, 0, -1}

local ZeroHandle = dmz.handle.new (0)

local function update_time_slice (self, time)

   local hil = dmz.object.hil ()

   if self.target and hil and self.active > 0 then

      local state = dmz.object.state (hil)

      local pos, ori = dmz.portal.get_view ()

      if pos and ori then
         local dir = ori:transform (Forward)

         dmz.isect.disable_isect (hil)

         local hits = dmz.isect.do_isect (
            { type = dmz.isect.RayTest, start = pos, vector = dir, },
            { type = dmz.isect.ClosestPoint, })

         if hits and hits[1].object and hits[1].object ~= 0 then
            dmz.overlay.enable_single_switch_state (self.target, 1)
         else
            dmz.overlay.enable_single_switch_state (self.target, 0)
         end

         dmz.isect.enable_isect (hil)
      end
   end
end

local function receive_input_event (self, event)

   if event.state then 
      if event.state.active then  self.active = self.active + 1
      else self.active = self.active - 1 end

      if self.active == 1 then
         self.timeSlice:start (self.handle)
         if self.top then
            dmz.overlay.enable_single_switch_state (self.top, 0)
         end
      elseif self.active == 0 then
         self.timeSlice:stop (self.handle)
         dmz.overlay.all_switch_state (self.top, false)
      end
   end
end

local function start (self)
   self.handle = self.timeSlice:create (update_time_slice, self, self.name)

   self.inputObs:init_channels (
      self.config,
      dmz.input.ChannelState,
      receive_input_event,
      self)

   if self.handle and self.active == 0 then self.timeSlice:stop (self.handle) end
end


local function stop (self)
   if self.handle and self.timeSlice then self.timeSlice:destroy (self.handle) end
   self.inputObs:release_all ()
end


function new (config, name)
   local self = {
      start_plugin = start,
      stop_plugin = stop,
      name = name,
      log = dmz.log.new ("lua." .. name),
      timeSlice = dmz.time_slice.new (),
      inputObs = dmz.input_observer.new (),
      active = 0,
      config = config,
      top = dmz.overlay.lookup_handle ("crosshairs switch"),
      target = dmz.overlay.lookup_handle ("crosshairs target switch"),
   }

   self.log:info ("Creating plugin: " .. name)
   
   return self
end

