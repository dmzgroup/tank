local Forward = dmz.vector.new ({0, 0, -1})
local Up = dmz.vector.new ({0, 1, 0})

local function find_coord ()
   local posResult = nil
   local oriResult = nil
   local hil = dmz.object.hil ()
   local hilPos = dmz.object.position (hil)
   local hilOri = dmz.object.orientation (hil)

   if hilPos and hilOri then
      local dir = hilOri:transform (Forward)
      local isect = dmz.isect.do_isect (
         { type = dmz.isect.RayTest, start = hilPos, vector = dir },
         { type = dmz.isect.CosestPoint, })

      if isect and isect[1] then
         posResult = isect[1].point
         oriResult = dmz.matrix.new (Up, isect[1].normal)
      end
   end

   return posResult, oriResult
end

local function create_tank (self, name)
   local obj = dmz.object.create (name)
   local pos, ori = find_coord ()
   if pos then dmz.object.position (obj, nil, pos) end
   if ori then dmz.object.orientation (obj, nil, ori) end
   dmz.object.activate (obj)
   dmz.object.set_temporary (obj)
   self.objects[obj] = { count = 0, }
   cprint ("Created:", name, "with handle:", obj)
end

local MKey = 109
local TKey = 116

local function receive_input_event (self, event)
   if event.key and event.key.state then
      if MKey == event.key.value then
         create_tank (self, "m1a1")
      elseif TKey == event.key.value then
         create_tank (self, "t72m")
      end
   end
end

local function close_event (self, EventHandle)
   local target = dmz.event.object_handle (EventHandle, dmz.event.TargetHandle)
   if target then
      local obj = self.objects[target]
      if obj then
         obj.count = obj.count + 1
         if obj.count == 1 then
            dmz.object.state (target, nil, "Dead | Smoking")
         elseif obj.count == 2 then
            dmz.object.state (target, nil, "Dead | Smoking | Fire")
         end
      end
   end
end

local function start (self)
   self.inputObs:init_channels (
      self.config,
      dmz.input.Key,
      receive_input_event,
      self);
   self.eventObs:register ("Event_Detonation", {close_event = close_event}, self)
end


local function stop (self)
   self.inputObs:release_all ()
end


function new (config, name)
   local self = {
      start_plugin = start,
      stop_plugin = stop,
      name = name,
      log = dmz.log.new ("lua." .. name),
      inputObs = dmz.input_observer.new (),
      eventObs = dmz.event_observer.new (),
      config = config,
      objects = {},
   }

   self.log:info ("Creating plugin: " .. name)
   
   return self
end

