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
  
  old_t = {1,2,3,4,5,6,7,8,9,10}
  new_size = 4
  old_arr = reaper.new_array(old_t)
  new_arr = Stretch_array(old_arr, new_size)
  new_t = new_arr.table(1,new_size)
