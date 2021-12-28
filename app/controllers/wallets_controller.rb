class WalletsController < ApplicationController
  before_action :find_wallet

  def show
    if @wallet.status == 'synced'
      @items = @wallet.items.includes(:token).order(last_purchase_price_tz: :desc)
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
