--Modules
local json = require( "json" ) 
local loadsave = require( "loadsave" ) 
local widget = require("widget")

--Display Setup
local titleLbl = display.newText("Can I have something to eat?", 160, 0, native.systemFont, 20)
local answerLbl = display.newText("", 160, 25, native.systemFont, 20) --Yes, No, Maybe

local locationLbl = display.newText("Your Location", 160, 70, native.systemFont, 20)
local locationTxtField = native.newTextField(160,110,250,40) --where the user enters their information
locationTxtField.placeholder = "Cleveland" --initial text in the textbox


local restaurantsLbl = display.newText("Restaurant Choices in Your Area:", 160, 350, native.systemFont, 20)
local listRestaurantsLbl = display.newText("", 160, 400, native.systemFont, 22) --the Yelp data

--handles runtime errors
local function myUnhandledErrorListener( event )
 
    local iHandledTheError = true
 
    if iHandledTheError then
        print( "Handling the unhandled error", event.errorMessage ) --prints to the console (what the developer sees)
        answerLbl.text = "Try asking again" --prints to the simulator (what the user sees)
         listRestaurantsLbl.text = ""
    else
        print( "Not handling the unhandled error", event.errorMessage )
    end
    
    return iHandledTheError
end
 
Runtime:addEventListener("unhandledError", myUnhandledErrorListener)

--Loads the Yelp responses into a table
local function networkListener( event )
 
    if ( event.isError ) then
        print( "Network error: ", event.response )
    else
        local yelpString = event.response 
        local restaurants = json.decode(event.response) --must convert the response string into a "table-like" format
        loadsave.saveTable( restaurants, "restaurants.json" ) --also save response into an external file for record keeping        
    end
end

--Sends Yelp credentials to authorize API usage
network.request( "https://api.yelp.com/oauth2/token?client_id=ZhdYx8Gz_vid_XIMqhxVAA&client_secret=XXiKS22i6mVDOY0DnWWZyA0ELL7mrbaofbcY6P0qPvu2OMkogf9DtOPXct1US5pH", "POST", networkListener)


--Calls the Yelp API based on the user's location, stores it
local function loadAndSaveRestaurants(userLocationInput)  

	local headers = {} --uses credentials to ask Yelp for information
	  
	headers["Authorization"] = "Bearer GbpgynaTG0yTA5NL9otVauf1D74e5XafzG768oFZRC19-Lp7UlMVGLnuR0t6B_uFW_nGbOKqzt0SYZNAoH0Vfm-p72Ghf9NwDbKJUathcWL98iHCOy7-ddhxBQnwWHYx"
	  
	local params = {} --load the authorization into parameters for the Network Listener Get request
	params.headers = headers

    -- call the NetworkListener function to get the yelp info based on the term "restaurants" and the users location input
	network.request( "https://api.yelp.com/v3/businesses/search?term=restaurants&location=".. userLocationInput, "GET", networkListener, params)


	return loadsave.loadTable( "restaurants.json" ) --return the response saved in the file from the NetworkListener function
end	


--randomizes each index without repeating a number
local function shuffle(t)
    local iterations = #t  --iterations = length of t (table parameter)
    local j

    for i = iterations, 2, -1 do
        j = math.random(i)
        t[i], t[j] = t[j], t[i]   --changes the values of 2 indices at the same time
    end
end


--global variables
loadedRestaurants = {}
inputText = ""
textEntered = false --boolean to check if the user has entered a location

--other ways to call this method: loadAndSaveRestaurants"Cleveland" OR loadAndSaveRestaurants[[Cleveland]] OR loadedRestaurants:loadAndSaveRestaurants("Cleveland")
loadedRestaurants = loadAndSaveRestaurants("Cleveland") --Get request to match the initial place holder text

loadsave.print_r(loadedRestaurants)

--clears the loadedRestaurants table to make room for data from a new location
local function clearRestaurants()
    loadedRestaurants = {}
end

--what to do once a user starts typing
function locationTxtField:userInput(event)
    --user clicks inside the text box but has not started typing
    if ( event.phase == "began" ) then
        answerLbl.text = "No"

    --user is currently typing in the textbox
    elseif ( event.phase == "editing" ) then
        answerLbl.text = "Maybe"

    --user has clicked outside of the textbox or has pressed enter
    elseif (event.phase == "ended" or event.phase == "submitted") then
    	loadedRestaurants = loadAndSaveRestaurants(event.target.text) --get Yelp data based on user input, save it into a table
        shuffle(loadedRestaurants.businesses) 
        
        textEntered = true

        listRestaurantsLbl.text = "Pull the string to find out what!", 160, 300, native.systemFont, 20

        answerLbl.text = "Yes"
        inputText = event.target.text
    end
end

locationTxtField:addEventListener("userInput", locationTxtField) --tells the textbox to do something


--what to do when the redo button is clicked
local function handleButtonEvent( event )
    --if the user has stopped clicking the button
    if ( event.phase == "ended"  ) then
        clearRestaurants()
        locationTxtField.text = ""
        answerLbl.text = "No"
        for i=1,20 do
            listRestaurantsLbl.text = ""
        end
        textEntered = false
        locationTxtField.placeholder = "Cleveland" --set initial text back to Cleveland
    end
end
 
-- Create the redo button
local redoButton = widget.newButton(
    {
        label = "Redo",
        onEvent = handleButtonEvent,
        --visual aspects
        emboss = false,
        shape = "roundedRect",
        width = 200,
        height = 40,
        cornerRadius = 2,
        fillColor = { default={.7,.7,1,1}, over={1,0.1,0.7,0.4} }, --RGB on a decimal scale. Ex. 255 = 1 or 177 = 0.5
        strokeColor = { default={.4,.3,.8,1}, over={0.8,0.8,1,1} }, --RGB on a decimal scale
        strokeWidth = 4
    }
)
 
-- Center the button
redoButton.x = 160
redoButton.y = 475
 
-- Change the button's label text
redoButton:setLabel( "Redo" )


--display the magic conch image
local conch = display.newImageRect( "magicConch.png", 150, 150 ) --file name, height, width
--where to display it on the screen
conch.x = display.contentCenterX
conch.y = display.contentCenterY
--object opacity
conch.alpha = 0.8

--creates a "string" when a user touches/clicks the conch image and drags away from it
local function pullString( event )

    local t = event.target --where the user clicks
    local phase = event.phase --what stage of a click they are in (just began clicking, in the middle of clicking/dragging, unclicked)
    
    --if the user clicks/touches the screen    
    if "began" == phase then
        display.getCurrentStage():setFocus( t )
        t.isFocus = true
        
        event.target.x = t.x --x coordinate in connection to the conch object
        event.target.y = t.y --y coordinate in connection to the conch object

        myLine = nil

    --if the appropriate image (target) is touched/clicked
    elseif t.isFocus then
        --if the screen is in the process of being dragged
        if "moved" == phase then
            
            if ( myLine ) then
                myLine.parent:remove( myLine ) -- erase previous line, if any
            end
            myLine = display.newLine( t.x+45,t.y-25, event.x,event.y )
            myLine:setStrokeColor( 1, 1, 1,1)
            myLine.strokeWidth = 5

        --if user stops dragging the screen
        elseif "ended" == phase or "cancelled" == phase then
            --remove line, reset starting points
            display.getCurrentStage():setFocus( nil )
            t.isFocus = false
    
            if ( myLine ) then
                myLine.parent:remove( myLine )
            end   

            -- --load and save Yelp data, shuffle the options
            loadedRestaurants = loadAndSaveRestaurants(inputText)
            shuffle(loadedRestaurants.businesses)  

            --only display restaurant choices if the user has entered a location
            if textEntered == true then
                for i=1,20 do
                    listRestaurantsLbl.text = loadedRestaurants.businesses[i].name
                end
            else
                listRestaurantsLbl.text = "Please enter your location" 
            end 
        end
    end

    return true -- Stop touch event
end

conch:addEventListener("touch",pullString) --calls the function