local HitTime = 0.45
local SliderSpeed = 1000 -- 5000.0
local Forward = dmz.vector.new {0, 0, -1}

local function update_slider (time, timer, slider, switch)
   timer = timer - time
   if timer <= 0 then
      timer = 0
      local x = dmz.overlay.position (slider)
      x = x + (SliderSpeed * time)
      if x >= 200 then
         x = 200
         timer = nil
         dmz.overlay.switch_state_all (switch, false)
      end
      dmz.overlay.position (slider, x, 0)
   else
      dmz.overlay.switch_state_all (switch, true)
      local x = dmz.overlay.position (slider)
      x = x - (SliderSpeed * time)
      if x < 0 then x = 0 end
      local x = dmz.overlay.position (slider, x, 0)
   end

   return timer
end

local function update_time_slice (self, time)
   if self.rightTimer then
      self.rightTimer = update_slider (
         time,
         self.rightTimer,
         self.rightSlider,
         self.rightSwitch)
   end

   if self.leftTimer then
      self.leftTimer = update_slider (
         time,
         self.leftTimer,
         self.leftSlider,
         self.leftSwitch)
   end
end

local function close_detonation_event (self, EventHandle, EventType)
   
   local target = dmz.event.object_handle (EventHandle, dmz.event.TargetHandle)
   local hil = dmz.object.hil ()
   if target and (hil == target) then
      local hilPos = dmz.object.position (hil)
      local hilOri = dmz.object.orientation (hil)
      local pos = dmz.event.position (EventHandle)

      if hilPos and hilOri and pos then

         local dir = hilOri:transform (Forward)
         local vec = dir:cross (pos - hilPos)

         if vec:get_y () <= 0 then
            if self.rightTimer then self.rightTimer = self.rightTimer + HitTime
            else self.rightTimer = HitTime
            end
         else
            if self.leftTimer then self.leftTimer = self.leftTimer + HitTime
            else self.leftTimer = HitTime
            end
         end
      end
   end
end

local function start (self)
   self.handle = self.timeSlice:create (update_time_slice, self, self.name)

   self.eventObs:register (
      "Event_Detonation",
      {close_event = close_detonation_event,},
      self)
end

local function stop (self)
   if self.handle and self.timeSlice then self.timeSlice:destroy (self.handle) end
end

function new (config, name)
   local self = {
      start_plugin = start,
      stop_plugin = stop,
      name = name,
      log = dmz.log.new ("lua." .. name),
      timeSlice = dmz.time_slice.new (),
      eventObs = dmz.event_observer.new (),
      config = config,
      leftSlider = dmz.overlay.lookup_handle ("hit left overlay slider"),
      leftSwitch = dmz.overlay.lookup_handle ("hit left overlay switch"),
      rightSlider = dmz.overlay.lookup_handle ("hit right overlay slider"),
      rightSwitch = dmz.overlay.lookup_handle ("hit right overlay switch"),
   }

   self.log:info ("Creating plugin: " .. name)
   
   return self
end

