import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="column-filter"
export default class extends Controller {
  static targets = ["options", "filters"]

  connect() {
    this.processColumns()
  }

  processColumns() {
    const type = this.data.get("type")

    if (type === 'wallet' && localStorage.getItem("wallet_columns") === null) {
      localStorage.setItem('wallet_columns', 'token,artist,balance,last_purchase_price_tz,last_purchase_at,royalties,floor,floor_change_24,sec_avg_recent,highest_sold,avg_price_24h,sec_volume_nb_24')
    } else if (type === 'token' && localStorage.getItem("token_columns") === null) {
      localStorage.setItem('token_columns', 'name,artist,balance,created_at,royalties,floor,floor_change_24h,sec_avg_recent,median,total_listing,highest_sold,lowest_sold,prim_total,sec_volume_tz,sec_volume_nb,avg_price_24h,sec_volume_tz_24,sec_volume_nb_24')
    }

    document.querySelectorAll("[data-column]").forEach((col) => {
      col.classList.add('hidden')
    });

    var columns = localStorage.getItem(type + '_columns').split(',');
    columns.forEach((c) => {
      document.querySelectorAll("[data-column='" + c + "']").forEach((col) => {
        col.classList.remove('hidden')
      });

      document.querySelectorAll("input[value='" + c + "']").forEach((col) => {
        col.checked = true
      });
    })
  }

  show(event) {
    this.optionsTarget.classList.toggle('hidden');

    event.preventDefault();
  }

  filter(event) {
    const type = this.data.get("type")
    const columns = []

    this.filtersTargets.forEach((t) => {
      localStorage.setItem(type + '_columns', columns)
      if (t.checked == true) {
        columns.push(t.value)
      }
    });

    localStorage.setItem(type + '_columns', columns)

    this.processColumns()
  }


}
