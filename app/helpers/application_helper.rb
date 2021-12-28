module ApplicationHelper
  def number_to_tez(number)
    number / 1000000
  end

  def display_tez(number)
    "#{number_with_delimiter(number_to_tez(number).round(1).to_s.sub(/\.?0+$/, ''))} tez"
  end
end
