import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="account"
export default class extends Controller {
  static targets = ["wallet"]

  connect() {
    if (localStorage.getItem("wallet") !== null) {
      document.querySelector('.wallet-link').innerHTML = "My Wallet"
      document.querySelector('.wallet-link').href = "/wallets/" + localStorage.getItem("wallet")
    }
  }

  pin(event) {
    const wallet = this.data.get("wallet")

    localStorage.setItem('wallet', wallet)

    document.querySelector('.wallet-link').innerHTML = "My Wallet"
    document.querySelector('.wallet-link').href = "/wallets/" + localStorage.getItem("wallet")

    event.preventDefault();
  }
}
