local loadsave = require( "loadsave" )  -- Require the 'loadsave' module

local conch = display.newImageRect( "magicConch.png", 150, 150 )
conch.x = display.contentCenterX
conch.y = display.contentCenterY
conch.alpha = 0.8


local function pullString( event )

	local t = event.target
	local phase = event.phase
	
		
	if "began" == phase then
		display.getCurrentStage():setFocus( t )
		t.isFocus = true
		
		event.target.x = t.x
		event.target.y = t.y

		myLine = nil

	elseif t.isFocus then
		
		if "moved" == phase then
			
			if ( myLine ) then
				myLine.parent:remove( myLine ) -- erase previous line, if any
			end
			myLine = display.newLine( t.x+45,t.y-25, event.x,event.y )
			myLine:setStrokeColor( 1, 1, 1,1)
			myLine.strokeWidth = 5

		elseif "ended" == phase or "cancelled" == phase then
		
			display.getCurrentStage():setFocus( nil )
			t.isFocus = false
	
			if ( myLine ) then
				myLine.parent:remove( myLine )
			end		
		end
	end

	return true	-- Stop further propagation of touch event
end

conch:addEventListener("touch",pullString)
