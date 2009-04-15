local function update_time_slice (self, time)

   local hil = dmz.object.hil ()

   local pos = nil
   local ori = nil

   if hil then
      pos = dmz.object.position (hil)
      ori = dmz.object.orientation (hil)
   end

   if not pos then pos = dmz.vector.new () end
   if not ori then ori = dmz.matrix.new () end
   local xstr = tostring (pos:get_x ())
   xstr = xstr:sub (xstr:find ("^%-?%d+%.?%d?"))
   local ystr = tostring (pos:get_y ())
   ystr = ystr:sub (ystr:find ("^%-?%d+%.?%d?"))
   local zstr = tostring (pos:get_z ())
   zstr = zstr:sub (zstr:find ("^%-?%d+%.?%d?"))
   local hstr = tostring (360 * dmz.math.heading (ori) / dmz.math.TwoPi)
   hstr = hstr:sub (hstr:find ("^%-?%d+%.?%d?"))
   dmz.overlay.text (self.posx, self.posxStr .. xstr)
   dmz.overlay.text (self.posy, self.posyStr .. ystr)
   dmz.overlay.text (self.posz, self.poszStr .. zstr)
   dmz.overlay.text (self.heading, self.headingStr .. hstr)

   dmz.overlay.text (self.mode, self.modeStr .. self.modeName)
   dmz.overlay.text (self.camera, self.cameraStr .. self.cameraName)
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
      mode = dmz.overlay.lookup_handle ("mode"),
      camera = dmz.overlay.lookup_handle ("camera"),
      posx = dmz.overlay.lookup_handle ("pos x"),
      posy = dmz.overlay.lookup_handle ("pos y"),
      posz = dmz.overlay.lookup_handle ("pos z"),
      heading = dmz.overlay.lookup_handle ("heading"),
   }

   self.log:info ("Creating plugin: " .. name)

   self.modeStr = "Mode:"
   self.modeName = "Freefly"
   self.cameraStr = "Camera:"
   self.cameraName = "Fixed"
   self.posxStr = "X:"
   self.posyStr = "Y:"
   self.poszStr = "Z:"
   self.headingStr = "H:"
   
   return self
end

