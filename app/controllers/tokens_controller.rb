class TokensController < ApplicationController
  def index
    if params[:sort].present?
      sort = case params[:sort]
      when 'id'
        'fxid'
      when 'name'
        'name'
      when 'artist'
        'author_name'
      when 'floor'
        'floor'
      when 'median'
        'median'
      when 'royalties'
        'royalties'
      when 'total_listing'
        'total_listing'
      when 'highest_sold'
        'highest_sold'
      when 'lowest_sold'
        'lowest_sold'
      when 'prim_total'
        'prim_total'
      when 'sec_volume_tz'
        'sec_volume_tz'
      when 'sec_volume_nb'
        'sec_volume_nb'
      when 'sec_volume_tz_24'
        'sec_volume_tz_24'
      when 'sec_volume_nb_24'
        'sec_volume_nb_24'
      when 'balance'
        'mint_progress'
      when 'created_at'
        'created_at'
      when 'avg_price_24h'
        'avg_price_24h'
      else
        params[:sort]
      end
    else
      sort = 'fxid'
    end

    if params[:dir].present?
      sort_direction = case params[:dir]
      when 'asc'
        'asc'
      else
        'desc'
      end
    else
      sort_direction = 'desc'
    end

    @link_sort = sort_direction == 'desc' ? 'asc' : 'desc'

    @tokens = Token.active.limit(250).order("#{sort} #{sort_direction} NULLS LAST")
  end
  
end
