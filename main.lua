-- ____________________________   plataforma    ________________________________
local plataforma = {}
plataforma.position_x = 500
plataforma.position_y = 550
plataforma.speed_x = 300
plataforma.width = 60
plataforma.height = 20

function plataforma.update(dt)
   if love.keyboard.isDown("right") then
      plataforma.position_x = plataforma.position_x + (plataforma.speed_x * dt)
   end
   if love.keyboard.isDown("left") then
      plataforma.position_x = plataforma.position_x - (plataforma.speed_x * dt)
   end
   -- _______________________________________   En Linea   __________________________________________
   if love.keyboard.isDown("up") then
      x = plataforma.position_x
      i = #ladrillos.nivel_actual_ladrillos
      j = i - 10
      print(x)
      print(i)
      print(j)

      for i = #ladrillos.nivel_actual_ladrillos, j, -1 do
         if ladrillos.top_left_position_x >= plataforma.position_x - 10 or ladrillos.top_left_position_x <= plataforma.position_x + 10 then
            c = ladrillos.nivel_actual_ladrillos
            print(i)
            --print(brick.position_x)
            print(ladrillos.top_left_position_x)
         end
      end
   end
end

function plataforma.draw()
   love.graphics.rectangle('line',
      plataforma.position_x,
      plataforma.position_y,
      plataforma.width,
      plataforma.height)
end

function plataforma.rebote_desde_la_pared(shift_plataforma_x, shift_plataforma_y)
   plataforma.position_x = plataforma.position_x + shift_plataforma_x
end

-- _______________________________  ladrillos  ______________________________________
ladrillos = {}
ladrillos.rows = 4
ladrillos.columns = 10
ladrillos.top_left_position_x = 150
ladrillos.top_left_position_y = 20
ladrillos.brick_width = 60
ladrillos.brick_height = 30
ladrillos.distancia_horizontal = 3
ladrillos.distancia_vertical = 5
ladrillos.nivel_actual_ladrillos = {}
ladrillos.no_more_bricks = false

function ladrillos.new_brick(position_x, position_y, width, height)
   return ({ position_x = position_x,
      position_y = position_y,
      width = width or ladrillos.brick_width,
      height = height or ladrillos.brick_height })
end

function ladrillos.añadirLadrillosNivelActual(brick)
   table.insert(ladrillos.nivel_actual_ladrillos, brick)
end

function ladrillos.update_brick(single_brick)
end

function ladrillos.draw_brick(single_brick)
   love.graphics.rectangle('line',
      single_brick.position_x,
      single_brick.position_y,
      single_brick.width,
      single_brick.height)
end

function ladrillos.construct_level(level_bricks_arrangement)
   ladrillos.no_more_ladrillos = false
   for row_index, row in ipairs(level_bricks_arrangement) do
      for col_index, bricktype in ipairs(row) do
         if bricktype ~= 0 then
            local new_brick_position_x = ladrillos.top_left_position_x +
                (col_index - 1) *
                (ladrillos.brick_width + ladrillos.distancia_horizontal)
            local new_brick_position_y = ladrillos.top_left_position_y +
                (row_index - 1) *
                (ladrillos.brick_height + ladrillos.distancia_vertical)
            local new_brick = ladrillos.new_brick(new_brick_position_x,
               new_brick_position_y)
            ladrillos.añadirLadrillosNivelActual(new_brick)
         end
      end
   end
end

function ladrillos.update(dt)
   if #ladrillos.nivel_actual_ladrillos == 0 then
      ladrillos.no_more_bricks = true
   else
      for _, brick in pairs(ladrillos.nivel_actual_ladrillos) do
         ladrillos.update_brick(brick)
      end
   end
end

function ladrillos.draw()
   for _, brick in pairs(ladrillos.nivel_actual_ladrillos) do
      ladrillos.draw_brick(brick)
   end
end

function ladrillos.brick_hit_by_ball(i, brick, shift_ball_x, shift_ball_y)
   table.remove(ladrillos.nivel_actual_ladrillos, i)
end

-- _____________________________  Paredes   _________________________________
local paredes = {}
paredes.espesor_de_pared = 20
paredes.nivel_actual_paredes = {}

function paredes.nueva_pared(position_x, position_y, width, height)
   return ({ position_x = position_x,
      position_y = position_y,
      width = width,
      height = height })
end

function paredes.update_wall(pared_sencilla)
end

function paredes.draw_wall(pared_sencilla)
   love.graphics.rectangle('line',
      pared_sencilla.position_x,
      pared_sencilla.position_y,
      pared_sencilla.width,
      pared_sencilla.height)
end

function paredes.construcion_paredes()
   local left_wall = paredes.nueva_pared(
      0,
      0,
      paredes.espesor_de_pared + 125,
      love.graphics.getHeight()
   )
   local right_wall = paredes.nueva_pared(
      love.graphics.getWidth() - paredes.espesor_de_pared,
      0,
      paredes.espesor_de_pared,
      love.graphics.getHeight()
   )
   local top_wall = paredes.nueva_pared(
      0,
      0,
      love.graphics.getWidth(),
      paredes.espesor_de_pared
   )
   local bottom_wall = paredes.nueva_pared(
      0,
      love.graphics.getHeight() - paredes.espesor_de_pared,
      love.graphics.getWidth(),
      paredes.espesor_de_pared
   )
   paredes.nivel_actual_paredes["left"] = left_wall
   paredes.nivel_actual_paredes["right"] = right_wall
   paredes.nivel_actual_paredes["top"] = top_wall
   paredes.nivel_actual_paredes["bottom"] = bottom_wall
end

function paredes.update(dt)
   for _, wall in pairs(paredes.nivel_actual_paredes) do
      paredes.update_wall(wall)
   end
end

function paredes.draw()
   for _, wall in pairs(paredes.nivel_actual_paredes) do
      paredes.draw_wall(wall)
   end
end

-- ___________________________________________Colisiones  _________________________________________
local colisiones = {}

function colisiones.resolver_colisiones()
   colisiones.colision_plataforma_paredes(plataforma, paredes)
end

function colisiones.check_rectangles_overlap(a, b)
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

function colisiones.colision_plataforma_paredes()
   local overlap, shift_plataforma_x, shift_plataforma_y
   local b = {
      x = plataforma.position_x,
      y = plataforma.position_y,
      width = plataforma.width,
      height = plataforma.height
   }
   for _, wall in pairs(paredes.nivel_actual_paredes) do
      local a = {
         x = wall.position_x,
         y = wall.position_y,
         width = wall.width,
         height = wall.height
      }
      overlap, shift_plataforma_x, shift_plataforma_y =
          colisiones.check_rectangles_overlap(a, b)
      if overlap then
         plataforma.rebote_desde_la_pared(shift_plataforma_x,
            shift_plataforma_y)
      end
   end
end

-- _____________________________________    Niveles  ___________________________________________________
local niveles = {}
niveles.nivelActual = 1
niveles.finGame = false
niveles.secuencia = {}
niveles.secuencia[1] = {
   { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
   { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
   { 1, 0, 1, 0, 1, 1, 1, 0, 1, 0 },
   { 1, 0, 1, 0, 1, 0, 0, 0, 1, 0 },
   { 1, 1, 1, 0, 1, 1, 0, 0, 0, 1 },
   { 1, 0, 1, 0, 1, 0, 0, 0, 0, 1 },
   { 1, 0, 1, 0, 1, 1, 1, 0, 0, 1 },
   { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
}

niveles.secuencia[2] = {
   { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
   { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
   { 1, 1, 0, 0, 1, 0, 1, 0, 1, 1 },
   { 1, 0, 1, 0, 1, 0, 1, 0, 1, 0 },
   { 1, 1, 1, 0, 0, 1, 0, 0, 1, 1 },
   { 1, 0, 1, 0, 0, 1, 0, 0, 1, 0 },
   { 1, 1, 1, 0, 0, 1, 0, 0, 1, 1 },
   { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
}

function niveles.cambiar_al_siguiente_nivel(ladrillos)
   if ladrillos.no_more_ladrillos then
      if niveles.nivelActual < #niveles.secuencia then
         niveles.nivelActual = niveles.nivelActual + 1
         ladrillos.construct_level(niveles.secuencia[niveles.nivelActual])
      else
         niveles.finGame = true
      end
   end
end

-- _______________________________________   LOAD  ________________________________________________
function love.load()
   local love_window_width = 800
   local love_window_height = 600
   love.window.setMode(love_window_width,
      love_window_height,
      { fullscreen = false })

   ladrillos.construct_level(niveles.secuencia[niveles.nivelActual])
   paredes.construcion_paredes()
end

-- _______________________________________   UPDATE  ________________________________________________
function love.update(dt)
   plataforma.update(dt)
   ladrillos.update(dt)
   paredes.update(dt)
   colisiones.resolver_colisiones()
   --enLinea.update()
   niveles.cambiar_al_siguiente_nivel(ladrillos)
   if love.keyboard.isDown("up") then
      print(plataforma.position_x)
      for i, brick in pairs(ladrillos.nivel_actual_ladrillos, i) do
         if ladrillos.top_left_position_x == plataforma.position_x then
            print("ladrillos.top_left_position_x")
         end
      end
   end
end

-- _______________________________________   DRAW  ________________________________________________
function love.draw()
   plataforma.draw()
   ladrillos.draw()
   paredes.draw()
   if niveles.finGame then
      love.graphics.printf("Congratulations!\n" ..
         "You have finished the game!",
         300, 250, 200, "center")
   end
end

-- _______________________________________   QUIT  ________________________________________________
function love.keyreleased(key, code)
   if key == 'escape' then
      love.event.quit()
   end
end

function love.quit()
   print("Gracias por jugar! Vuelve pronto!")
end
