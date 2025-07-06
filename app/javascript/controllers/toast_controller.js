import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { 
    duration: { type: Number, default: 3000 },
    type: { type: String, default: "success" }
  }
  
  connect() {
    this.show()
  }
  
  show() {
    // Animate in
    this.element.classList.remove("scale-0", "opacity-0")
    this.element.classList.add("scale-100", "opacity-100")
    
    // Auto hide after duration
    this.hideTimeout = setTimeout(() => {
      this.hide()
    }, this.durationValue)
  }
  
  hide() {
    // Animate out
    this.element.style.animation = "toast-slide-out 0.3s ease-out forwards"
    
    // Remove from DOM after animation
    setTimeout(() => {
      this.element.remove()
    }, 300)
  }
  
  close() {
    clearTimeout(this.hideTimeout)
    this.hide()
  }
}