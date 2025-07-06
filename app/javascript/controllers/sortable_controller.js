import { Controller } from "@hotwired/stimulus"
import Sortable from "sortablejs"

export default class extends Controller {
  static targets = ["input"]
  static values = { 
    animation: { type: Number, default: 150 },
    handle: { type: String, default: "" }
  }

  connect() {
    const options = {
      animation: this.animationValue,
      ghostClass: "opacity-50",
      dragClass: "cursor-grabbing",
      draggable: '[data-image-id]',
      onEnd: this.updateOrder.bind(this)
    }
    
    if (this.handleValue) {
      options.handle = this.handleValue
    }
    
    this.sortable = Sortable.create(this.element, options)
  }
  
  disconnect() {
    if (this.sortable) {
      this.sortable.destroy()
    }
  }
  
  updateOrder(event) {
    // 이미지 ID 순서 수집
    const imageElements = this.element.querySelectorAll('[data-image-id]')
    const imageIds = Array.from(imageElements).map(el => el.dataset.imageId)
    
    // hidden input에 순서 저장
    if (this.hasInputTarget) {
      this.inputTarget.value = imageIds.join(',')
    } else {
      // 폴백: ID로 찾기
      const orderInput = document.getElementById('image-order') || 
                       this.element.querySelector('[name="product[image_order]"]')
      if (orderInput) {
        orderInput.value = imageIds.join(',')
      }
    }
    
    // 첫 번째 이미지에 "대표 이미지" 표시 업데이트
    imageElements.forEach((el, index) => {
      const badge = el.querySelector('.bg-blue-600')
      if (index === 0) {
        if (!badge) {
          const newBadge = document.createElement('div')
          newBadge.className = 'absolute top-2 left-2 bg-blue-600 text-white text-xs px-2 py-1 rounded'
          newBadge.textContent = '대표 이미지'
          el.appendChild(newBadge)
        }
      } else {
        if (badge) {
          badge.remove()
        }
      }
    })
    
    console.log('이미지 순서 업데이트:', imageIds)
  }
}