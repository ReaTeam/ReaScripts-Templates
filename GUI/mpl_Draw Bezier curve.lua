  
  -- mpl draw Bézier curve

  -----------------------------------
  -----------------------------------  
  
  function draw_curve(x_table, y_table)
    order = #x_table
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
    function draw_points(x,y)
      local point_side = 5
      gfx.set(0,0.8,0,0.4)
      for i = 1, #x do
        gfx.rect(x[i] -point_side/2 ,y[i] -point_side/2,point_side,point_side,1, 1)
      end
    end
    ----------------------------
    draw_points(x_table, y_table)
    for t = 0, 1, 0.001 do
      x_point = bezier_eq(order, x_table, t)+ t^order*x_table[order]
      y_point = bezier_eq(order, y_table, t)+ t^order*y_table[order] 
      gfx.x = x_point
      gfx.y = y_point
      gfx.a = 0.05
      gfx.setpixel(1,1,1)
    end    
  end


  -----------------------------------
  -----------------------------------
    
  local x_table =
                 {10,  -- x1
                  70,  -- x2
                  100,  -- x3
                  80,  -- x4
                  180,  -- x5
                  }
  local y_table =
                 {10,  -- y1
                  50,  -- y2
                  100,  -- y3
                  150,  -- y4
                  120,  -- y5
                  }                 
                   
  gfx.init('Draw Bézier curve by mpl',300, 300)                
  draw_curve(x_table, y_table)
