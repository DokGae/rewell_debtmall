import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { deadline: String }
  static targets = ["days", "hours", "minutes", "seconds", "container"]
  
  connect() {
    if (!this.deadlineValue) return
    
    this.deadline = new Date(this.deadlineValue)
    this.updateCountdown()
    this.timer = setInterval(() => {
      this.updateCountdown()
    }, 1000)
  }
  
  disconnect() {
    if (this.timer) {
      clearInterval(this.timer)
    }
  }
  
  updateCountdown() {
    const now = new Date()
    const timeRemaining = this.deadline - now
    
    if (timeRemaining <= 0) {
      this.showExpired()
      if (this.timer) {
        clearInterval(this.timer)
      }
      return
    }
    
    const days = Math.floor(timeRemaining / (1000 * 60 * 60 * 24))
    const hours = Math.floor((timeRemaining % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60))
    const minutes = Math.floor((timeRemaining % (1000 * 60 * 60)) / (1000 * 60))
    const seconds = Math.floor((timeRemaining % (1000 * 60)) / 1000)
    
    if (this.hasDaysTarget) this.daysTarget.textContent = String(days).padStart(2, '0')
    if (this.hasHoursTarget) this.hoursTarget.textContent = String(hours).padStart(2, '0')
    if (this.hasMinutesTarget) this.minutesTarget.textContent = String(minutes).padStart(2, '0')
    if (this.hasSecondsTarget) this.secondsTarget.textContent = String(seconds).padStart(2, '0')
  }
  
  showExpired() {
    if (this.hasContainerTarget) {
      this.containerTarget.innerHTML = `
        <div class="text-red-500 font-semibold">
          마감되었습니다
        </div>
      `
    }
  }
}