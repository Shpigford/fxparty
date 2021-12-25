class PagesController < ApplicationController
  def index

  end

  def search
    if params[:wallet].present?
      redirect_to wallet_path(params[:wallet])
    else
      redirect_to root_path
    end
  end
end
