local Forward = dmz.vector.new {0, 0, -1}
local VehicleType = dmz.object_type.new ("vehicle")

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

         local which = 0

         if hits and hits[1].object and hits[1].object ~= 0 then
            local ot = dmz.object.type (hits[1].object)
            if ot and ot:is_of_type (VehicleType) then which = 1 end
         end
         dmz.overlay.enable_single_switch_state (self.target, which)
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


local function update_scalar (self, Object, Attr, Value)
   if self.turret and Object == dmz.object.hil () then
      dmz.overlay.rotation (self.turret, -Value)
   end
end

local function start (self)
   self.handle = self.timeSlice:create (update_time_slice, self, self.name)

   self.inputObs:init_channels (
      self.config,
      dmz.input.ChannelState,
      receive_input_event,
      self)

   self.objObs:register ("DMZ_Turret_1", {update_object_scalar = update_scalar}, self)

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
      objObs = dmz.object_observer.new (),
      active = 0,
      config = config,
      top = dmz.overlay.lookup_handle ("crosshairs switch"),
      target = dmz.overlay.lookup_handle ("crosshairs target switch"),
      turret = dmz.overlay.lookup_handle ("tank turret"),
   }

   self.log:info ("Creating plugin: " .. name)
   
   return self
end

