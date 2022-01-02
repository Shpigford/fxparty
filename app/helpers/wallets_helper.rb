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

  def heading_link(address, name, sort, type, cur_dir, cur_sort, path_type="wallet")
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
      full_icon = "fa-solid fa-arrow-down-arrow-up text-gray-500"
    else
      full_icon = "fa-duotone #{icon}"
    end

    path = case path_type
    when 'wallet'
      wallet_path(address, sort: sort, dir: sort_direction)
    when 'token'
      tokens_path(sort: sort, dir: sort_direction)
    end

    link_to "#{name} <i class='#{full_icon}'></i>".html_safe, path
  end
  
  
end
