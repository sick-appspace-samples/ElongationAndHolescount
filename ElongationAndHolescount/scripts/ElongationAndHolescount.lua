--[[----------------------------------------------------------------------------

  Application Name:
  ElongationAndHolescount
                                                                                             
  Summary: 
  Finding DIN rail nuts independent on size.
  
  How to Run:
  Starting this sample is possible either by running the app (F5) or
  debugging (F7+F10). Setting breakpoint on the first row inside the
  'main' function allows debugging step-by-step.
  Results can be seen in the image viewer on the DevicePage.
  Restarting the Sample may be necessary to show images after loading the webpage.
  To run this Sample a device with SICK Algorithm API and AppEngine >= V2.5.0 is
  required. For example SIM4000 with latest firmware. Alternatively the Emulator
  in AppStudio 2.3 or higher can be used.
     
  More Information: 
  Tutorial "Algorithms - Blob Analysis".

------------------------------------------------------------------------------]]
--Start of Global Scope---------------------------------------------------------

print('AppEngine Version: ' .. Engine.getVersion())

-- Delay in ms between visualization steps for demonstration purpose
local DELAY = 1000

-- Creating viewer
local viewer = View.create()
viewer:setID('viewer2D')

-- Setting up graphical overlay attributes
local decoration = View.PixelRegionDecoration.create()
decoration:setColor(0, 255, 0, 80) -- Transparent green

--End of Global Scope-----------------------------------------------------------

--Start of Function and Event Scope---------------------------------------------

local function main()
  viewer:clear()
  local img = Image.load('resources/ElongationAndHolescount.bmp')
  viewer:addImage(img)
  viewer:present()
  Script.sleep(DELAY) -- for demonstration purpose only

  -- Reducing noise using a median filter
  local img2 = img:median(3)

  -- Finding blobs
  local objectRegion = img2:threshold(0, 150)
  viewer:addImage(objectRegion:toImage(img))
  viewer:present()
  Script.sleep(DELAY) -- for demonstration purpose only
  local blobs = objectRegion:findConnected(50)

  -- Filtering blobs to find DIN-rail nuts ("rectangles with one hole")
  local objectFilter = Image.PixelRegion.Filter.create()
  objectFilter:setCondition('HOLESCOUNT', 1)
  objectFilter:setRange('ELONGATION', 1.2, 2)
  local holeblobs = objectFilter:apply(blobs, img2)

  -- Visualizing all DIN-rail nuts
  viewer:clear()
  local imageID = viewer:addImage(img)
  for _, blob in ipairs(holeblobs) do
    viewer:addPixelRegion(blob, decoration, nil, imageID)
  end
  viewer:present()

  print(#holeblobs .. ' DIN-rail nuts found')
  print('App finished.')
end
--The following registration is part of the global scope which runs once after startup
--Registration of the 'main' function to the 'Engine.OnStarted' event
Script.register('Engine.OnStarted', main)

--End of Function and Event Scope--------------------------------------------------
