class PagesController < ApplicationController
  def index
    render layout: "landing"
  end

  def shutdown
    render layout: "landing"
  end

  def search
    if params[:wallet].present?
      redirect_to wallet_path(params[:wallet])
    else
      redirect_to root_path
    end
  end

  def wallpaper
    
  end
  
end
