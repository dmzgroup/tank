local Forward = dmz.vector.new ({0, 0, -1})
local Up = dmz.vector.new ({0, 1, 0})

local function find_coord ()
   local posResult = nil
   local oriResult = nil
   local hil = dmz.object.hil ()
   local hilPos, hilOri = dmz.portal.get_view ()

   if hilPos and hilOri then
      dmz.isect.disable_isect (hil)
      local dir = hilOri:transform (Forward)
      local isect = dmz.isect.do_isect (
         { type = dmz.isect.RayTest, start = hilPos, vector = dir },
         { type = dmz.isect.CosestPoint, })

      if isect and isect[1] then
         posResult = isect[1].point
         oriResult = dmz.matrix.new (Up, isect[1].normal)
      end
      dmz.isect.enable_isect (hil)
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

local MKey = dmz.input.get_key_value ("m")
local TKey = dmz.input.get_key_value ("t")

local function receive_key_event (self, channel, key)
   if key.state then
      if MKey == key.value then
         create_tank (self, "m1a1-timeout")
      elseif TKey == key.value then
         create_tank (self, "t72m-timeout")
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
            dmz.object.state (target, nil, "Smoking")
         elseif obj.count == 2 then
            dmz.object.state (target, nil, "Dead | Smoking | Fire")
         end
      end
   end
end

local function start (self)
   self.inputObs:register (
      self.config,
      { receive_key_event = receive_key_event, },
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

