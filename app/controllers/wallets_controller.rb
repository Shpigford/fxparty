class WalletsController < ApplicationController
  before_action :find_wallet, only: [:show, :download, :refresh]

  def show
    if @wallet.status == 'synced'
      if params[:sort].present?
        sort = case params[:sort]
        when 'item'
          'name'
        when 'token'
          'tokens.fxid'
        when 'floor'
          'tokens.floor'
        when 'highest_sold'
          'tokens.highest_sold'
        when 'sec_volume_tz_24'
          'tokens.sec_volume_tz_24'
        when 'sec_volume_nb_24'
          'tokens.sec_volume_nb_24'
        when 'balance'
          'tokens.mint_progress'
        when 'avg_price_24h'
          'tokens.avg_price_24h'
        when 'floor_change_24h'
          'tokens.floor_change_24h'
        when 'sec_avg_recent'
          'tokens.sec_avg_recent'
        when 'last_purchase_at'
          'last_purchase_at'
        else
          params[:sort]
        end
      else
        sort = 'last_purchase_at'
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

      @items = @wallet.items.includes(:token).order("#{sort} #{sort_direction} NULLS LAST").limit(500)

      @link_sort = sort_direction == 'desc' ? 'asc' : 'desc'

      @floor_value = @items.sum('tokens.floor')
      @cost_basis = @items.sum(:last_purchase_price_tz)
      @unrealized = @floor_value - @items.sum(:last_purchase_price_tz)
      @wallet.touch(:last_viewed_at)
    elsif @wallet.status != 'not_found'
      SyncWalletWorker.perform_async(@wallet.address)
      
      @wallet.status = 'syncing'
      @wallet.save
    end
  end

  def refresh
    @wallet.status = 'syncing'
    @wallet.save

    SyncWalletWorker.set(queue: :critical).perform_async(@wallet.address)

    redirect_to wallet_path(@wallet.address)
  end
  

  def download
    @items = @wallet.items.includes(:token).order(last_purchase_price_tz: :desc)
    render layout: nil
    respond_to do |format|
      format.html do
        headers['Content-Disposition'] = "attachment;filename=#{@wallet.address}-#{DateTime.now}.csv"
        headers['Content-Type'] ||= 'text/csv'
      end
    end
  end

  def top
    if params[:sort].present?
      sort = case params[:sort]
      when 'address'
        'address'
      when 'stat_cost_basis'
        'stat_cost_basis'
      when 'stat_floor_value'
        'stat_floor_value'
      when 'stat_unrealized_gains'
        'stat_unrealized_gains'
      when 'stat_size'
        'stat_size'
      when 'stat_sec_avg_recent'
        'stat_sec_avg_recent'
      else
        params[:sort]
      end
    else
      sort = 'stat_sec_avg_recent'
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

    @wallets = Wallet.order("#{sort} #{sort_direction} NULLS LAST").limit(250)
  end

  def feed
    @wallets = Wallet.active.tracked.pluck(:id)
    @items = Item.order('last_purchase_at desc').where(wallet_id: @wallets).where.not(last_purchase_at: nil).limit(100)
  end
  
  

private
  def find_wallet
    if params['id'] =~ /^tz([a-zA-Z0-9]{34})$/
      @wallet = Wallet.find_or_create_by(address: params[:id])
    elsif params['id'] =~ /^([A-Za-z0-9-]{1,}\.)tez$/
      domain_check = Wallet.find_by(domain: params[:id])

      if domain_check.blank?
        domain_check = HTTParty.post("https://api.tezos.domains/graphql", :body => '{"operationName":null,"variables":{},"query":"{domains(where: {name: {in: [\"'+ params[:id] +'\"]}}) {items {address name}}}"}', :headers => {'Content-Type' => 'application/json'} ).body
        domain_check_data = JSON.parse(domain_check)

        if domain_check_data['data']['domains']['items'].present?
          address = domain_check_data['data']['domains']['items'].first['address']

          @wallet = Wallet.find_or_create_by(address: address)
          @wallet.update(domain: params[:id])
        end
      else
        @wallet = domain_check
      end
    else
      render 'wallets/_invalid'
      return
    end
  end
end
