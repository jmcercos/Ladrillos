-- ____________________________   Platform    ________________________________
local platform = {}
platform.position_x = 500
platform.position_y = 550
platform.speed_x = 300
platform.width = 60
platform.height = 20

function platform.update(dt)
   if love.keyboard.isDown("right") then
      platform.position_x = platform.position_x + (platform.speed_x * dt)
   end
   if love.keyboard.isDown("left") then
      platform.position_x = platform.position_x - (platform.speed_x * dt)
   end
end

function platform.draw()
   love.graphics.rectangle('line',
      platform.position_x,
      platform.position_y,
      platform.width,
      platform.height)
end

function platform.bounce_from_wall(shift_platform_x, shift_platform_y)
   platform.position_x = platform.position_x + shift_platform_x
end

-- _______________________________  Bricks  ______________________________________
local bricks = {}
bricks.rows = 4
bricks.columns = 10
bricks.top_left_position_x = 150
bricks.top_left_position_y = 20
bricks.brick_width = 60
bricks.brick_height = 30
bricks.horizontal_distance = 3
bricks.vertical_distance = 5
bricks.current_level_bricks = {}

function bricks.new_brick(position_x, position_y, width, height)
   return ({ position_x = position_x,
      position_y = position_y,
      width = width or bricks.brick_width,
      height = height or bricks.brick_height })
end

function bricks.add_to_current_level_bricks(brick)
   table.insert(bricks.current_level_bricks, brick)
end

function bricks.update_brick(single_brick)
end

function bricks.draw_brick(single_brick)
   love.graphics.rectangle('line',
      single_brick.position_x,
      single_brick.position_y,
      single_brick.width,
      single_brick.height)
end

function bricks.construct_level()
   for row = 1, bricks.rows do
      for col = 1, bricks.columns do
         local new_brick_position_x = bricks.top_left_position_x +
             (col - 1) *
             (bricks.brick_width + bricks.horizontal_distance)
         local new_brick_position_y = bricks.top_left_position_y +
             (row - 1) *
             (bricks.brick_height + bricks.vertical_distance)
         local new_brick = bricks.new_brick(new_brick_position_x,
            new_brick_position_y)
         bricks.add_to_current_level_bricks(new_brick)
      end
   end
end

function bricks.update(dt)
   for _, brick in pairs(bricks.current_level_bricks) do
      bricks.update_brick(brick)
   end
end

function bricks.draw()
   for _, brick in pairs(bricks.current_level_bricks) do
      bricks.draw_brick(brick)
   end
end

-- _____________________________  Walls   _________________________________
local walls = {}
walls.wall_thickness = 20
walls.current_level_walls = {}

function walls.new_wall(position_x, position_y, width, height)
   return ({ position_x = position_x,
      position_y = position_y,
      width = width,
      height = height })
end

function walls.update_wall(single_wall)
end

function walls.draw_wall(single_wall)
   love.graphics.rectangle('line',
      single_wall.position_x,
      single_wall.position_y,
      single_wall.width,
      single_wall.height)
end

function walls.construct_walls()
   local left_wall = walls.new_wall(
      0,
      0,
      walls.wall_thickness + 125,
      love.graphics.getHeight()
   )
   local right_wall = walls.new_wall(
      love.graphics.getWidth() - walls.wall_thickness,
      0,
      walls.wall_thickness,
      love.graphics.getHeight()
   )
   local top_wall = walls.new_wall(
      0,
      0,
      love.graphics.getWidth(),
      walls.wall_thickness
   )
   local bottom_wall = walls.new_wall(
      0,
      love.graphics.getHeight() - walls.wall_thickness,
      love.graphics.getWidth(),
      walls.wall_thickness
   )
   walls.current_level_walls["left"] = left_wall
   walls.current_level_walls["right"] = right_wall
   walls.current_level_walls["top"] = top_wall
   walls.current_level_walls["bottom"] = bottom_wall
end

function walls.update(dt)
   for _, wall in pairs(walls.current_level_walls) do
      walls.update_wall(wall)
   end
end

function walls.draw()
   for _, wall in pairs(walls.current_level_walls) do
      walls.draw_wall(wall)
   end
end

-- ___________________________________________Collisions  _________________________________________
local collisions = {}

function collisions.resolve_collisions()
   collisions.platform_walls_collision(platform, walls)
end

function collisions.check_rectangles_overlap(a, b)
   local overlap = false
   local shift_b_x, shift_b_y = 0, 0
   if not (a.x + a.width < b.x or b.x + b.width < a.x or
          a.y + a.height < b.y or b.y + b.height < a.y) then
      overlap = true
      if (a.x + a.width / 2) < (b.x + b.width / 2) then
         shift_b_x = (a.x + a.width) - b.x
      else
         shift_b_x = a.x - (b.x + b.width)
      end
      if (a.y + a.height / 2) < (b.y + b.height / 2) then
         shift_b_y = (a.y + a.height) - b.y
      else
         shift_b_y = a.y - (b.y + b.height)
      end
   end
   return overlap, shift_b_x, shift_b_y
end

function collisions.platform_walls_collision()
   local overlap, shift_platform_x, shift_platform_y
   local b = {
      x = platform.position_x,
      y = platform.position_y,
      width = platform.width,
      height = platform.height
   }
   for _, wall in pairs(walls.current_level_walls) do
      local a = {
         x = wall.position_x,
         y = wall.position_y,
         width = wall.width,
         height = wall.height
      }
      overlap, shift_platform_x, shift_platform_y =
          collisions.check_rectangles_overlap(a, b)
      if overlap then
         platform.bounce_from_wall(shift_platform_x,
            shift_platform_y)
      end
   end
end

-- _______________________________________   En Linea   __________________________________________

function enLinea()
   if love.keyboard.isDown("up") then

   elseif love.keyboard.isDown("down") then

   end
end

-- _______________________________________   LOAD  ________________________________________________
function love.load()
   local love_window_width = 800
   local love_window_height = 600
   love.window.setMode(love_window_width,
      love_window_height,
      { fullscreen = false })

   bricks.construct_level()
   walls.construct_walls()
end

-- _______________________________________   UPDATE  ________________________________________________
function love.update(dt)
   platform.update(dt)
   bricks.update(dt)
   walls.update(dt)
   collisions.resolve_collisions()
end

-- _______________________________________   DRAW  ________________________________________________
function love.draw()
   platform.draw()
   bricks.draw()
   walls.draw()
end

-- _______________________________________   QUIT  ________________________________________________
function love.keyreleased(key, code)
   if key == 'escape' then
      love.event.quit()
   end
end

function love.quit()
   print("Thanks for playing! Come back soon!")
end
