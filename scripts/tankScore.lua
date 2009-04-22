local HelpSpeed = 800.0
local SliderSpeed = 400.0
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

   dmz.overlay.enable_switch_state_single (digits[1], v1);
   dmz.overlay.enable_switch_state_single (digits[2], v2);
   dmz.overlay.enable_switch_state_single (digits[3], v3);
end

local function update_time_slice (self, time)

   local hil = dmz.object.hil ()

   for obj in pairs (self.deathList) do
      if hil == self.hitList[obj] then self.kills = self.kills + 1 end
      self.deathList[obj] = nil
      self.hitList[obj] = nil
   end

   update_digits (self.killsDigits, self.kills)
   update_digits (self.hitsDigits, self.hits)
   update_digits (self.shotsDigits, self.shots)
   update_digits (self.deathsDigits, self.deaths)

   if self.slider then
      if self.dashstate then
         local x = dmz.overlay.position (self.slider)
         if x > -256 then x = x - (time * SliderSpeed) end
         if x < -256 then x = -256 end
         dmz.overlay.position (self.slider, x, -256)
      else
         local x = dmz.overlay.position (self.slider)
         if x < 0 then x = x + (time * SliderSpeed) end
         if x > 0 then x = 0 end
         dmz.overlay.position (self.slider, x, -256)
      end
   end

   if self.helpActive then
      local x, y = dmz.overlay.position (self.help)
      if self.helpState then
         if y > 0 then y = y - (HelpSpeed * time) end
         if y <= 0 then
            y = 0
            self.helpActive = false
         end
      else
         if y < self.helpOffset then y = y + (HelpSpeed * time) end
         if y >= self.helpOffset then
            y = self.helpOffset
            self.helpActive = false
         end
      end
      dmz.overlay.position (self.help, x, y)
   end
end

local function update_channel_state (self, channel, state)

   if state then  self.active = self.active + 1
   else self.active = self.active - 1 end

   if self.active == 1 then
      self.timeSlice:start (self.handle)
   elseif self.active == 0 then
      self.timeSlice:stop (self.handle)
   end
end

local function receive_button_event (self, channel, button)
   if button.which == 1 and button.value then
      self.dashstate = not self.dashstate
   end
end

local QuestionKey = dmz.input.get_key_value ("?")
local SlashKey = dmz.input.get_key_value ("/")

local function receive_key_event (self, channel, key)
   if key.value == QuestionKey or key.value == SlashKey then
      if key.state then
         self.helpState =  not self.helpState
         self.helpActive = true
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
      if Object == hil then self.deaths = self.deaths + 1
      else self.deathList[Object] = true
      end
   end
end

local function update_ammo (self, Object, Attribute, Count)
   if Object == dmz.object.hil () then
      update_digits (self.ammoDigits, Count)
   end
end

local function update_health (self, Object, Attribute, Value)
   if Object == dmz.object.hil () then
      update_digits (self.healthDigits, Value)
   end
end

local function close_launch_event (self, EventHandle, EventType)
   local source = dmz.event.object_handle (EventHandle, dmz.event.SourceHandle)
   if source == dmz.object.hil () then
      self.shots = self.shots + 1
   end
end

local function close_detonation_event (self, EventHandle, EventType)
   
   local source = dmz.event.object_handle (EventHandle, dmz.event.SourceHandle)
   local target = dmz.event.object_handle (EventHandle, dmz.event.TargetHandle)
   if source and target then
      local hil = dmz.object.hil ()
      if source == hil and target ~= hil then
         self.hits = self.hits + 1
      end
      self.hitList[target] = source
   end
end

local function start (self)
   self.handle = self.timeSlice:create (update_time_slice, self, self.name)

   self.inputObs:register (
      self.config,
      {
         update_channel_state = update_channel_state,
         receive_button_event = receive_button_event,
         receive_key_event = receive_key_event,
      },
      self);

   if self.handle and self.active == 0 then self.timeSlice:stop (self.handle) end

   local callbacks = {
      create_object = create_object,
      destroy_object = destroy_object,
      update_object_state = update_object_state,
   }
   self.objObs:register (nil, callbacks, self)

   self.objObs:register ("Weapon_1", {update_object_counter = update_ammo,}, self)
   self.objObs:register (
      "Entity_Health_Value",
      {update_object_scalar = update_health,},
      self)

   self.eventObs:register (
      "Event_Detonation",
      {close_event = close_detonation_event,},
      self)

   self.eventObs:register (
      "Event_Launch",
      {close_event = close_launch_event,},
      self)
end

local function stop (self)
   if self.handle and self.timeSlice then self.timeSlice:destroy (self.handle) end
   self.inputObs:release_all ()
   local x = dmz.overlay.position (self.help)
   dmz.overlay.position (self.help, x, self.helpOffset)
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
      deathList = {},
      hits = 0,
      hitsDigits = {
         dmz.overlay.lookup_clone_sub_handle ("hits digit1", "switch"),
         dmz.overlay.lookup_clone_sub_handle ("hits digit2", "switch"),
         dmz.overlay.lookup_clone_sub_handle ("hits digit3", "switch"),
      },
      shots = 0,
      shotsDigits = {
         dmz.overlay.lookup_clone_sub_handle ("shots digit1", "switch"),
         dmz.overlay.lookup_clone_sub_handle ("shots digit2", "switch"),
         dmz.overlay.lookup_clone_sub_handle ("shots digit3", "switch"),
      },
      deaths = 0,
      deathsDigits = {
         dmz.overlay.lookup_clone_sub_handle ("deaths digit1", "switch"),
         dmz.overlay.lookup_clone_sub_handle ("deaths digit2", "switch"),
         dmz.overlay.lookup_clone_sub_handle ("deaths digit3", "switch"),
      },
      slider = dmz.overlay.lookup_handle ("display slider"),
      dashstate = true,
      ammoDigits = {
         dmz.overlay.lookup_clone_sub_handle ("ammo digit1", "switch"),
         dmz.overlay.lookup_clone_sub_handle ("ammo digit2", "switch"),
         dmz.overlay.lookup_clone_sub_handle ("ammo digit3", "switch"),
      },
      healthDigits = {
         dmz.overlay.lookup_clone_sub_handle ("health digit1", "switch"),
         dmz.overlay.lookup_clone_sub_handle ("health digit2", "switch"),
         dmz.overlay.lookup_clone_sub_handle ("health digit3", "switch"),
      },
      help = dmz.overlay.lookup_handle ("help slider"),
      helpState = false,
      helpActive = false,
   }

   self.log:info ("Creating plugin: " .. name)

   local x = nil
   x, self.helpOffset = dmz.overlay.position (self.help)
   
   return self
end

