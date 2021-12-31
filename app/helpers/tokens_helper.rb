module TokensHelper
  def cell_color_sort(cur_sort, cur_column, header = false)
    if header == true and cur_sort == cur_column
      'bg-yellow-100'
    elsif cur_sort == cur_column
      'bg-yellow-50'
    else
      ''
    end
  end
  
end
