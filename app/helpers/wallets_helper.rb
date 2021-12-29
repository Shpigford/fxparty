module WalletsHelper
  def sort_icon(type='text', current_direction)
    type = case type
    when 'text'
      'a-z'
    when 'number'
      '1-9'
    end

    direction = current_direction == 'asc' ? 'down' : 'up'

    "fa-arrow-#{direction}-#{type}"
  end

  def heading_link(address, name, sort, type, cur_dir, cur_sort)
    type = case type
    when 'text'
      'a-z'
    when 'number'
      '1-9'
    end
    direction = cur_dir == 'asc' ? 'down' : 'up'
    icon = "fa-arrow-#{direction}-#{type}"

    sort_direction = case cur_dir
    when 'asc'
      'desc'
    else
      'asc'
    end

    if cur_sort != sort
      full_icon = "fa-solid fa-arrow-down-arrow-up text-gray-300"
    else
      full_icon = "fa-duotone #{icon}"
    end

    link_to "#{name} <i class='#{full_icon}'></i>".html_safe, wallet_path(address, sort: sort, dir: sort_direction)
  end
  
  
end
