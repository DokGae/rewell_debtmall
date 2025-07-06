import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["discountRate", "submitButton", "container"]

  connect() {
    this.calculateDiscount()
  }

  calculateDiscount(event) {
    const originalPriceInput = this.element.querySelector('input[name="product[original_price]"]')
    const salePriceInput = this.element.querySelector('input[name="product[sale_price]"]')
    
    const originalPrice = parseFloat(originalPriceInput.value) || 0
    const salePrice = parseFloat(salePriceInput.value) || 0
    
    if (originalPrice > 0 && salePrice > 0) {
      const discount = Math.round(((originalPrice - salePrice) / originalPrice) * 100)
      this.discountRateTarget.value = `${discount}%`
      
      // 할인율에 따라 색상 변경
      if (discount >= 30) {
        this.discountRateTarget.classList.add('text-red-600', 'font-semibold')
      } else {
        this.discountRateTarget.classList.remove('text-red-600', 'font-semibold')
      }
    } else {
      this.discountRateTarget.value = "0%"
    }
  }

  validateField(event) {
    const field = event.target
    const value = field.value.trim()
    
    // 기본 검증
    if (field.hasAttribute('required') && !value) {
      this.showFieldError(field, '필수 입력 항목입니다')
    } else {
      this.clearFieldError(field)
    }
    
    // 숫자 필드 검증
    if (field.type === 'number' && value) {
      const num = parseFloat(value)
      if (isNaN(num) || num < 0) {
        this.showFieldError(field, '0 이상의 숫자를 입력해주세요')
      }
    }
  }

  showFieldError(field, message) {
    // 기존 에러 메시지 제거
    this.clearFieldError(field)
    
    // 새 에러 메시지 추가
    const error = document.createElement('p')
    error.className = 'text-red-500 text-sm mt-1 field-error'
    error.textContent = message
    field.parentElement.appendChild(error)
    
    // 필드 스타일 변경
    field.classList.add('border-red-300', 'focus:border-red-500', 'focus:ring-red-500')
  }

  clearFieldError(field) {
    const error = field.parentElement.querySelector('.field-error')
    if (error) {
      error.remove()
    }
    field.classList.remove('border-red-300', 'focus:border-red-500', 'focus:ring-red-500')
  }

  // 폼 제출 전 전체 검증
  validateForm(event) {
    const requiredFields = this.element.querySelectorAll('[required]')
    let hasError = false
    
    requiredFields.forEach(field => {
      if (!field.value.trim()) {
        this.showFieldError(field, '필수 입력 항목입니다')
        hasError = true
      }
    })
    
    if (hasError) {
      event.preventDefault()
      // 첫 번째 에러 필드로 스크롤
      const firstError = this.element.querySelector('.field-error')
      if (firstError) {
        firstError.parentElement.scrollIntoView({ behavior: 'smooth', block: 'center' })
      }
    }
  }
}