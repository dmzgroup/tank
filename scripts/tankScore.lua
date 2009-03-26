
local SliderSpeed = 3.0
local DeadState = dmz.definitions.lookup_state ("Dead")

local function update_digits (digits, value)

   local v1 = 10
   local v2 = 10
   local v3 = 10

   local hil = dmz.object.hil ()

   if value and value <= 1000 then
      v1 = dmz.math.get_digit (value, 0)
      v2 = dmz.math.get_digit (value, 1)
      v3 = dmz.math.get_digit (value, 2)
   end

   if v3 == 0 then
      if v2 == 0 then
         v3 = v1
         v2 = 10
         v1 = 10
      else
         v3 = v2
         v2 = v1
         v1 = 10
      end
   end

   dmz.overlay.enable_single_switch_state (digits[1], v1);
   dmz.overlay.enable_single_switch_state (digits[2], v2);
   dmz.overlay.enable_single_switch_state (digits[3], v3);
end

local function update_time_slice (self, time)

   update_digits (self.killsDigits, self.kills)
   update_digits (self.hitsDigits, self.hits)
   update_digits (self.deathsDigits, self.deaths)
--[[
   if self.slider then
      --if time > 0.1 then cprint (time) time = 0.1 end
      if self.dashstate then
         local x = dmz.overlay.position (self.slider)
         if x > 0 then x = x - (400 * time * SliderSpeed) end
         if x < 0 then x = 0 end
         dmz.overlay.position (self.slider, x, 0)
      else
         local x = dmz.overlay.position (self.slider)
         if x < 300 then x = x + (400 * time * SliderSpeed) end
         if x > 300 then x = 300 end
         dmz.overlay.position (self.slider, x, 0)
      end
   end
--]]
end

local function receive_input_event (self, event)

   if event.state then 
      if event.state.active then  self.active = self.active + 1
      else self.active = self.active - 1 end

      if self.active == 1 then
         self.timeSlice:start (self.handle)
      elseif self.active == 0 then
         self.timeSlice:stop (self.handle)
      end
   end

   if event.button then
      if event.button.which == 2 and event.button.value then
         self.dashstate = not self.dashstate
      end
   end
end

local function create_object (self, Object, Type)
end

local function destroy_object (self, Object)

end

local function update_object_state (self, Object, Attribute, State, PreviousState)
   if not PreviousState then PreviousState = dmz.mask.new () end
   if State:contains (DeadState)  and not PreviousState:contains (DeadState) then
      local hil = dmz.object.hil ()
      if Object == hil then
         self.deaths = self.deaths + 1
      elseif self.hitList[Object] == hil then
         self.kills = self.kills + 1
      end
      self.hitList[Object] = nil
   end
end

local function close_detonation_event (self, EventHandle, EventType)
   
   local source = dmz.event.object_handle (EventHandle, dmz.event.SourceHandle)
   local target = dmz.event.object_handle (EventHandle, dmz.event.TargetHandle)
   if source and target then
      local hil = dmz.object.hil ()
      local dead = false
      local state = dmz.object.state (target)
      if state and state:contains (DeadState) then dead = true end
      if source == hil and target ~= hil then
         if not dead then self.hits = self.hits + 1 end
      end
      if not dead then self.hitList[target] = source end
   end
end

local function start (self)
   self.handle = self.timeSlice:create (update_time_slice, self, self.name)

   self.inputObs:init_channels (
      self.config,
      dmz.input.Button + dmz.input.ChannelState,
      receive_input_event,
      self);

   if self.handle and self.active == 0 then self.timeSlice:stop (self.handle) end

   local callbacks = {
      create_object = create_object,
      destroy_object = destroy_object,
      update_object_state = update_object_state,
   }
   self.objObs:register (nil, callbacks, self)

   self.eventObs:register (
      "Event_Detonation",
      {close_event = close_detonation_event,},
      self)
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
      eventObs = dmz.event_observer.new (),
      active = 0,
      config = config,
      kills = 0,
      killsDigits = {
         dmz.overlay.lookup_clone_sub_handle ("kills digit1", "switch"),
         dmz.overlay.lookup_clone_sub_handle ("kills digit2", "switch"),
         dmz.overlay.lookup_clone_sub_handle ("kills digit3", "switch"),
      },
      hitList = {},
      hits = 0,
      hitsDigits = {
         dmz.overlay.lookup_clone_sub_handle ("hits digit1", "switch"),
         dmz.overlay.lookup_clone_sub_handle ("hits digit2", "switch"),
         dmz.overlay.lookup_clone_sub_handle ("hits digit3", "switch"),
      },
      deaths = 0,
      deathsDigits = {
         dmz.overlay.lookup_clone_sub_handle ("deaths digit1", "switch"),
         dmz.overlay.lookup_clone_sub_handle ("deaths digit2", "switch"),
         dmz.overlay.lookup_clone_sub_handle ("deaths digit3", "switch"),
      },
      slider = dmz.overlay.lookup_handle ("dashboard slider"),
      dashstate = true,
   }

   self.log:info ("Creating plugin: " .. name)
   
   return self
end

