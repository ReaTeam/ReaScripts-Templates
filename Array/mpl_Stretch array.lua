  function Stretch_array(src_array, new_size) -- simply resize array
    local src_array_size = src_array.get_alloc()
    local coeff = (src_array_size - 1) / (new_size  - 1)
    local out_array = reaper.new_array(new_size)
    if new_size < src_array_size or new_size > src_array_size then
      for i = 0, new_size - 1 do 
        out_array[i+1] = src_array[math.floor(i * coeff) + 1]
      end
      return out_array
     elseif new_size == src_array_size then 
      out_array = src_array 
      return out_array
    end    
    return out_array    
  end
  
  old_t = {1,2,3,4,5,6,7,8,9,10}
  new_size = 4
  old_arr = reaper.new_array(old_t)
  new_arr = Stretch_array(old_arr, new_size)
  new_t = new_arr.table(1,new_size)


------------------------------------------------------------------

  function Stretch_array2(src_array, src_mid_point, stretched_point)   -- act as a stretch marker
  
    function Stretch_array(src_array, new_size)
      local src_array_size = src_array.get_alloc()
      local coeff = (src_array_size - 1) / (new_size  - 1)
      local out_array = reaper.new_array(new_size)
      if new_size < src_array_size or new_size > src_array_size then
        for i = 0, new_size - 1 do 
          out_array[i+1] = src_array[math.floor(i * coeff) + 1]
        end
        return out_array
       elseif new_size == src_array_size then 
        out_array = src_array 
        return out_array
      end    
      return out_array    
    end
    
    
    if src_array == nil or src_mid_point == nil or stretched_point == nil 
      then return end      
    local src_array_size = src_array.get_alloc()
    local out_arr = reaper.new_array(src_array_size)    
    local src_arr_pt1_size = src_mid_point - 1
    local src_arr_pt2_size = src_array_size-src_mid_point + 1    
    local out_arr_pt1_size = stretched_point - 1
    local out_arr_pt2_size = src_array_size-stretched_point + 1    
    local src_arr_pt1 = reaper.new_array(src_arr_pt1_size)
    local src_arr_pt2 = reaper.new_array(src_arr_pt2_size)    
    src_arr_pt1.copy(src_array,--src, 
                            1,--srcoffs, 
                            src_arr_pt1_size,--size, 
                            1)--destoffs])  
    src_arr_pt2.copy(src_array,--src, 
                            src_mid_point,--srcoffs, 
                            src_arr_pt2_size,--size, 
                            1)--destoffs])            
    local out_arr_pt1 = Stretch_array(src_arr_pt1, out_arr_pt1_size)
    local out_arr_pt2 = Stretch_array(src_arr_pt2, out_arr_pt2_size)    
    out_arr.copy(out_arr_pt1,--src, 
                 1,--srcoffs, 
                 out_arr_pt1_size,--size, 
                 1)--destoffs]) 
    out_arr.copy(out_arr_pt2,--src, 
                 1,--srcoffs, 
                 out_arr_pt2_size,--size, 
                 out_arr_pt1_size + 1)--destoffs]) 
                 
    return   out_arr               
  end  
  
  old_t = {1,2,3,4,5,6,7,8,9,10}
  old_arr = reaper.new_array(old_t)
  new_arr = Stretch_array2(old_arr, 5, 8)
  new_t = new_arr.table(1)

