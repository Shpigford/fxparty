import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="nav"
export default class extends Controller {
  static targets = ["modal"];

  launchModal(event) {
    this.modalTarget.classList.remove('hidden');
  }

  closeModal(event) {
    this.modalTarget.classList.add('hidden');
  }
}
