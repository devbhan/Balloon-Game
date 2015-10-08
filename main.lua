-- Balloons Physics Game
-- Developed by Carlos Yanez

-- Hide Status Bar

display.setStatusBar(display.HiddenStatusBar) 

-- Physics

local physics = require('physics')
physics.start()
--physics.setGravity(0, 10)

-- Graphics

-- [Background]

local bg = display.newImage('gameBg.png')

-- [Title View]

local titleBg
local playBtn
local creditsBtn
local titleView



-- [Credits]

local creditsView

-- [Game View]

local gCircle
local squirrel
local infoBar
local restartBtn

-- [TextFields]

local scoreTF
local targetTF
local acornsTF

-- Load Sound

local pop = audio.loadSound('pop.mp3')

-- Variables

local titleView
local credits
local acorns = display.newGroup()
local balloons = {}
local impulse = 0
local dir = 3

-- Functions

local Main = {}
local startButtonListeners = {}
local showCredits = {}
local hideCredits = {}
local showGameView = {}
local gameListeners = {}
local startCharge = {}
local charge = {}
local shot = {}
local onCollision = {}
local startGame = {}
local createBalloons = {}
local update = {}
local restartLvl = {}
local alert = {}
local restart = {}


function Main()
	titleBg = display.newImage('titleBg.png')
	playBtn = display.newImage('playBtn.png', display.contentCenterX - 25.5, display.contentCenterY + 40)
	creditsBtn = display.newImage('creditsBtn.png', display.contentCenterX - 40.5, display.contentCenterY + 85);
	titleView = display.newGroup(titleBg, playBtn, creditsBtn)

	startButtonListeners('add')	
end


function startButtonListeners(action)
    if(action == 'add') then
	    playBtn:addEventListener('tap', showGameView)
		creditsBtn:addEventListener('tap', showCredits)
	else
	    playBtn:removeEventListener('tap', showGameView)
		creditsBtn:removeEventListener('tap', showCredits)
	end
end


function showCredits:tap(e)
    playBtn.isVisible = false
	creditsBtn.isVisible = false
	creditsView = display.newImage('credits.png')

	transition.from(creditsView, {time = 300, 
								  x = -creditsView.width, 
								  onComplete = function() 
												  creditsView:addEventListener('tap', hideCredits) 
												  creditsView.x = creditsView.x - 0.5 
											   end
							     }
				   )

    

end

function hideCredits:tap(e)
    playBtn.isVisible = true
	creditsBtn.isVisible = true
	transition.to(creditsView, {time = 300, 
								  x = -creditsView.width, 
								  onComplete = function() 
												  creditsView:removeEventListener('tap', hideCredits) 
												  display.remove(creditsView)
												  creditsView = nil
											   end
							     }
				   )
end

function showGameView:tap(e)
    transition.to(titleView, {time = 600, 
							  x = -titleView.width, 
							  onComplete = function() startButtonListeners('rmv')
												display.remove(titleView)
												titleView = nil
												startGame()
										   end
							 }
				 )

	-- add gfx
	infoBar = display.newImage('infoBar.png', 0, 276)
	restartBtn = display.newImage('restartBtn.png', 443, 286)
	squirrel = display.newImage('squirrel.png', 70, 182)
	gCircle = display.newImage('gCircle.png', 83, 216)
	gCircle:setReferencePoint(display.CenterReferencePoint)

	targetTF = display.newText('0', 123, 291, native.systemFontBold, 14)
	targetTF:setTextColor(238, 238, 238)

	scoreTF = display.newText('0', 196, 291, native.systemFontBold, 14)
	scoreTF:setTextColor(238, 238, 238)

	acornsTF = display.newText('5', 49, 291, native.systemFontBold, 13)
	acornsTF:setTextColor(238, 238, 238)


end

function gameListeners(action)
	if(action == 'add') then
	    bg:addEventListener('touch', startCharge)
		bg:addEventListener('touch', shot)
		restartBtn:addEventListener('touch', restartLvl)
		Runtime:addEventListener('enterFrame', update)
	else
		bg:removeEventListener('touch', startCharge)
		bg:removeEventListener('touch', shot)
		restartBtn:removeEventListener('touch', restartLvl)
		Runtime:removeEventListener('enterFrame', update)
	end
end

function startGame()
	--gCircle.isVisible = false

	gameListeners('add')
	createBalloons(5, 3)
end

function createBalloons(h, v)
    for i = 1, h do
		for j = 1, v do
		    local balloon = display.newImage('balloon.png', 300 + (i*20), 120 + (j*30))
			balloon.name = 'balloon'
			physics.addBody(balloon)
			balloon.bodyType = 'static'
			table.insert(balloons, balloon)
		end
	end

	targetTF.text = #balloons
end

function onCollision(e)
    if( e.other.name == 'balloon') then
	    display.remove(e.other)
		e.other = nil
		audio.play(pop)
		scoreTF.text = scoreTF.text + 50
		scoreTF:setReferencePoint(display.TopLeftReferencePoint)
		scoreTF.x = 196
		targetTF.text = targetTF.text - 1
	end

	if(targetTF.text == '0') then
	    alert('win')
	end
end


function startCharge:touch(e)
    if(e.phase == 'began') then
	    impulse = 0
		gCircle.isVisible = true;
		Runtime:addEventListener('enterFrame', charge)		
	end
end

function charge()	
    gCircle.rotation = gCircle.rotation - 3
	impulse = impulse - 0.2

	if(gCircle.rotation < -46 ) then
	    gCircle.rotation = -46
		impulse = -3.2
	end	
end

function shot:touch(e)
    if (e.phase == 'ended') then		
		Runtime:removeEventListener('enterFrame', charge)
		--gCircle.isVisible = false
		gCircle.rotation = 0

		local acorn = display.newImage('acorn.png', 84, 220)
		physics.addBody(acorn, "dynamic", {densty = 1, friction = 0, bounce = 0})
		acorns:insert(acorn)
		--print( 'insert :' .. acorns.numChildren)

		acorn:applyLinearImpulse(dir, impulse, acorn.x, acorn.y)
		--acorn:applyForce(5, impulse, acorn.x, acorn.y)

		acorn:addEventListener('collision', onCollision)

		acornsTF.text = acornsTF.text -1
	end
end


function update()
    --print( 'update :' .. acorns.numChildren)
    for i = 1, acorns.numChildren - 1 do
	    if(acorns[i].y > display.contentHeight
		   or  acorns[i].y < 0
		   or acorns[i].x > display.contentWidth
		   or  acorns[i].x < 0
		  ) then
		    display.remove(acorns[i])
			acorns[i] = nil

			if(tonumber(acornsTF.text) <= 0 ) then
			    alert('lose')
			end
		end
	end
	--print( 'updated :' .. acorns.numChildren)
end

function restartLVl()
	print( 'restarted :' )
    for i = 1, #ballons do
	    display.remove(bolloons[i])
	end

	scoreTF.text = '0'
	acornsTF.text = '5'

	balloons = {}
	createBalloons(5, 3)
end

function alert(state)
    gameListeners('rmv')

	local alert

	if(state == 'win') then
	    alert = display.newImage('win.png')
	else
	    alert = display.newImage('lose.png')
	end

	alert:setReferencePoint(display.CenterReferencePoint)
	alert.x = display.contentCenterX
	alert.y = display.contentCenterY
	transition.from(alert, {time = 300, xScale = 0.3, yScale=0.3})

	local score = display.newText(scoreTF.text, 220, 190, native.systemFontBold, 20)
	score:setTextColor(135, 75, 44)
end

Main()

