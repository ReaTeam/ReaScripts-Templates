  
  -- mpl draw Bézier curve

  -----------------------------------
  -----------------------------------  
  
  function draw_curve(order, xy_t)
    ----------------------------
    function fact(n) if n == 0 then return 1 else return n * fact(n-1) end end
    ----------------------------
    function bezier_eq(n, tab_xy, dt)
      local B = 0
      for i = 0, n-1 do
        B = B + 
          ( fact(n) / ( fact(i) * fact(n-i) ) ) 
          *  (1-dt)^(n-i)  
          * dt ^ i
          * tab_xy[i+1]
      end 
      return B
    end  
    ----------------------------
    function gen_points(xy_t)
      local x = {}
      local y = {}
      for i = 1, #xy_t/2 do
        x[i] = xy_t[i*2+1]
        y[i] = xy_t[i*2+2]
      end 
      return x,y
    end 
    ----------------------------
    function draw_points(xy_t)
      local x,y = gen_points(xy_t)
      local point_side = 5
      gfx.set(0,0.8,0,0.4)
      for i = 1, #xy_t/2 -1 do
        gfx.rect(x[i] -point_side/2 ,y[i] -point_side/2,point_side,point_side,1, 1)
      end
    end
    ----------------------------
    x,y = gen_points(xy_t)
    draw_points(xy_t)
    for t = 0, 1, 0.001 do
      x_point = bezier_eq(order, x, t)+ t^order*x[order]
      y_point = bezier_eq(order, y, t)+ t^order*y[order]      
      -- draw point 
        gfx.x = x_point
        gfx.y = y_point
        gfx.a = 0.2 
        gfx.setpixel(1,1,1)
    end    
  end


  -----------------------------------
  -----------------------------------
    
  local xy_table =
                 {20,  -- x1
                  150, -- y1, 
                  
                  50,   -- x2, 
                  100,  -- y2
                  
                  100, -- x3
                  60,  -- y3
                  
                  150,  -- x4
                  150,  -- y4
                  
                  210,  --x5
                  180,  --y5
                  
                  250,  --x6
                  10    --x6
                  }
                   
  gfx.init('Draw Bézier curve by mpl',300, 300)                
  draw_curve(#xy_table/2 - 1, xy_table)
