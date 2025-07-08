import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["content", "icon"]
  static values = { businessId: Number, url: String }
  
  toggle() {
    const isHidden = this.contentTarget.classList.contains("hidden")
    
    if (isHidden) {
      // 이미 로드된 컨텐츠가 있는지 확인
      if (this.contentTarget.dataset.loaded === "true") {
        // 이미 로드됨 - 단순히 표시만
        this.show()
      } else {
        // 처음 로드 - AJAX 요청
        this.loadContent()
      }
    } else {
      // 숨기기
      this.hide()
    }
  }
  
  loadContent() {
    // 로딩 상태 표시
    this.contentTarget.classList.remove("hidden")
    this.contentTarget.innerHTML = `
      <div class="p-8 text-center text-zinc-500">
        <div class="animate-pulse">
          <div class="h-4 bg-zinc-800 rounded w-1/4 mx-auto"></div>
        </div>
      </div>
    `
    
    // AJAX 요청
    fetch(this.urlValue, {
      headers: {
        'X-Requested-With': 'XMLHttpRequest',
        'Accept': 'text/html'
      }
    })
    .then(response => response.text())
    .then(html => {
      this.contentTarget.innerHTML = html
      this.contentTarget.dataset.loaded = "true"
      this.updateIcon(true)
    })
    .catch(error => {
      console.error('Error loading content:', error)
      this.contentTarget.innerHTML = '<div class="p-4 text-red-500">컨텐츠를 불러오는데 실패했습니다.</div>'
    })
  }
  
  show() {
    this.contentTarget.classList.remove("hidden")
    this.updateIcon(true)
  }
  
  hide() {
    this.contentTarget.classList.add("hidden")
    this.updateIcon(false)
  }
  
  updateIcon(isOpen) {
    if (this.hasIconTarget) {
      this.iconTarget.style.transform = isOpen ? "rotate(180deg)" : "rotate(0deg)"
    }
  }
}