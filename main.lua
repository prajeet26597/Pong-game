--[[
    Game Development Class Harvard CS50

    pong-0,1,2,3,4,5,6,7,8,9,10
    "All Updates combined"

    -- Main Program --

    Author: Prajeet Rajaganesan
    prajeetrajaganesan@gmail.com

    Originally programmed by Atari in 1972. Features two
    paddles, controlled by players, with the goal of getting
    the ball past your opponent's edge. First to 10 points wins.

    This version is built to more closely resemble the NES than
    the original Pong machines or the Atari 2600 in terms of
    resolution, though in widescreen (16:9) so it looks nicer on 
    modern systems.
]]

push = require 'push'

Class = require 'class'

require 'Ball'

require 'Paddle'

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

--Multiplied by dt at update()
PADDLE_SPEED = 200

--[[
    Runs when the game first starts up, only once; used to initialize the game.
]]
function love.load()
    love.graphics.setDefaultFilter('nearest','nearest')

    love.window.setTitle('Pong')

    math.randomseed(os.time())

    --for heading text smaller size,8
    smallfont = love.graphics.newFont('font.ttf',8)
    love.graphics.setFont(smallfont)

    --for score larger font, 32
    scorefont = love.graphics.newFont('font.ttf',32)

    largefont = love.graphics.newFont('font.ttf',16)

    
    
    push:setupScreen(VIRTUAL_WIDTH,VIRTUAL_HEIGHT,WINDOW_WIDTH,WINDOW_HEIGHT,{
        fullscreen = false,
        resizable = false,
        vsync = true --Vertical sync
    })

    player1score = 0
    player2score = 0

    servingPlayer = 1

    player1 = Paddle(10,30,5,20)
    player2 = Paddle(VIRTUAL_WIDTH-10,VIRTUAL_HEIGHT - 30, 5, 20)

    --position of ball
    --ballx = VIRTUAL_WIDTH/2-2
    --bally = VIRTUAL_HEIGHT/2-2
    ball = Ball(VIRTUAL_WIDTH/2-2,VIRTUAL_HEIGHT/2-2,4,4)

    --velocity of the ball
    --balldx = math.random(2) == 1 and 100 or -100
    --balldy = math.random(-50,50)

    --[[love.window.setMode(
        WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = false,
        vsync = true
    })]]
    -- This is can be used for default programming 
    gameState = 'start'
end

function love.update(dt)
    if gameState == 'serve' then
        ball.dy = math.random(-50, 50)
        if servingPlayer == 1 then
            ball.dx = math.random(140, 200)
        else
            ball.dx = -math.random(140, 200)
        end
    elseif gameState == 'play' then
        if ball:collides(player1) then
            ball.dx = -ball.dx * 1.03 --1.03 is an arbitrary 3% increase in momentum
            ball.x = player1.x + 5 -- this is to make sure to sepparate the ball from the paddle

            if ball.dy < 0 then
                ball.dy = -math.random(10,150)
            else
                ball.dy = math.random(10,150)
            end
        end
        if ball:collides(player2) then
            ball.dx = -ball.dx * 1.03
            ball.x = player2.x - 4

            if ball.dy < 0 then
                ball.dy = -math.random(10,150)
            else
                ball.dy = math.random(10,150)
            end
        end

        -- to detect ball collision in upper or lower screen boundary
        if ball.y <=0 then
            ball.y = 0
            ball.dy = -ball.dy
        end

        if ball.y >= VIRTUAL_HEIGHT - 4 then
            ball.y = VIRTUAL_HEIGHT - 4 -- 4 is the ball size
            ball.dy = -ball.dy
        end
    

        -- Updating scores of players
        if ball.x < 0 then
            servingPlayer = 1
            player2score = player2score + 1

            if player2score == 10 then
                winningPlayer = 2
                gameState = 'done'
            else
                gameState = 'serve'
                ball:reset()
            end
            
        end

        if ball.x > VIRTUAL_WIDTH then
            servingPlayer = 2
            player1score = player1score + 1

            if player1score == 10 then
                winningPlayer = 1
                gameState = 'done'
            else
                gameState = 'serve'
                ball:reset()
            end
        end
    end

    --player1 movement
    -- by using math.min/max we can bound the paddles inside the screen
    if love.keyboard.isDown('w') then
        player1.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown('s') then
        player1.dy = PADDLE_SPEED
    else
        player1.dy = 0
    end

    --player2 movement
    if love.keyboard.isDown('up') then
        player2.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown('down') then
        player2.dy = PADDLE_SPEED
    else
        player2.dy = 0
    end
    if gameState == 'play' then
        --ballx = ballx + balldx*dt
        --bally = bally + balldy*dt
        ball:update(dt)
    end
    player1:update(dt)
    player2:update(dt)
end


function love.keypressed(key)

    --This function is called by love2d when a key is pressed
    if key == 'escape' then

        love.event.quit()
    elseif key == 'enter' or key == 'return' then
        if gameState == 'start' then
            gameState = 'serve'
        elseif gameState == 'serve' then
            gameState = 'play'
        elseif gameState == 'done' then
            gameState = 'serve'

            ball:reset()

            player1score = 0
            player2score = 0

            if winningPlayer == 1 then
                servingPlayer = 2
            else
                servingPlayer = 1
            end

            --[[ballx = VIRTUAL_WIDTH/2-2
            bally = VIRTUAL_HEIGHT/2-2

            balldx = math.random(2) == 1 and 100 or -100
            balldy = math.random(-50,50)*1.5]]

            --ball:reset()

        end
    end

end

--[[
    Called after update by LÖVE2D, used to draw anything to the screen, updated or otherwise.
]]
function love.draw()

    push:apply('start')

    --version 11 RGB color values go from 0 to 1 not 0 to 255
    --love.graphics.clear(40/255,45/255,52/255,1) --(r,g,b,opacity;255 means completely opaque no transparency)
    love.graphics.clear(32/255,76/255,138/255,1)

    --love.graphics.setFont(smallFont)
    

    --displaying score here
    love.graphics.setFont(scorefont)
    --love.graphics.print(tostring(player1score),VIRTUAL_WIDTH/2-50, VIRTUAL_HEIGHT/3)
    --love.graphics.print(tostring(player2score),VIRTUAL_WIDTH/2+30, VIRTUAL_HEIGHT/3)
    displayScore()

    love.graphics.setFont(smallfont)
    if gameState == 'start' then
        love.graphics.setFont(smallfont)
        love.graphics.printf('Hello Pong!',0,10,VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press Enter to start the game!', 0 ,20, VIRTUAL_WIDTH,'center')
    elseif gameState == 'serve' then
        love.graphics.setFont(smallfont)
        love.graphics.printf('Player '..tostring(servingPlayer) .. " 's serve!", 0, 10, VIRTUAL_WIDTH,'center')
        love.graphics.printf('Press Enter to serve!', 0, 20, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'play' then
        -- no UI messages to display during play
    elseif gameState == 'done' then
        love.graphics.setFont(largefont)
        love.graphics.printf('Player ' .. tostring(winningPlayer) .. ' wins!', 0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(smallfont)
        love.graphics.printf('Press Enter to restart!', 0, 30, VIRTUAL_WIDTH, 'center')

    end

    player1:render()
    player2:render()
    ball:render()


    displayFPS()
    --[[love.graphics.rectangle('fill',10,player1y,5,20)

    love.graphics.rectangle('fill',VIRTUAL_WIDTH-10,player2y, 5 , 20)

    love.graphics.rectangle('fill',ballx, bally, 4, 4)]]


    --[[love.graphics.printf(
        'Hello Pong!',          -- text to render
        0,                      -- starting X (0 since we're going to center it based on width)
        VIRTUAL_HEIGHT / 2 - 6,  -- starting Y (halfway down the screen)
        VIRTUAL_WIDTH,           -- number of pixels to center within (the entire screen here)
        'center')  ]]             -- alignment mode, can be 'center', 'left', or 'right'
    push:apply('end')
end


function displayFPS()
    love.graphics.setFont(smallfont)
    love.graphics.setColor(0,1,0,1)
    love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()),10,10)
end

function displayScore()

    love.graphics.setFont(scorefont)
    love.graphics.print(tostring(player1score), VIRTUAL_WIDTH / 2 - 50, 
        VIRTUAL_HEIGHT / 3)
    love.graphics.print(tostring(player2score), VIRTUAL_WIDTH / 2 + 30, 
        VIRTUAL_HEIGHT / 3)
end