bomb = {}

local function kill_em_all (munition)
   local hil = dmz.object.hil ()
   local targetList = dmz.object.get_all ()
   for _, target in pairs (targetList) do
      if target ~= hil then
         local event = dmz.event.open_detonation (hil, target)
         if event then
            dmz.event.position (event, nil, dmz.object.position (target))
            dmz.event.object_type (event, dmz.event.MunitionsHandle, munition)
            dmz.event.close (event)
         end
      end
   end
end

function new (config, name)
   local self = {
      log = dmz.log.new ("lua." .. name),
      munition = config:to_string ("munition", "m830a1"),
   }
   bomb.kill_em_all = function () kill_em_all (self.munition) end
   self.log:info ("Creating plugin: " .. name)
   return self
end

