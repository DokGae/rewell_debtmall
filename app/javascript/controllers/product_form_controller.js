import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["discountRate", "submitButton", "container", "originalPrice", "salePrice"]

  connect() {
    this.calculateDiscount()
  }

  formatPrice(event) {
    const input = event.target
    let value = input.value.replace(/[^\d]/g, '') // 숫자만 남김
    
    // 숫자가 있으면 천 단위 콤마 추가
    if (value) {
      const formattedValue = parseInt(value).toLocaleString('ko-KR')
      input.value = formattedValue
    }
  }

  calculateDiscount(event) {
    const originalPriceInput = this.hasOriginalPriceTarget ? this.originalPriceTarget : this.element.querySelector('input[name="product[original_price]"]')
    const salePriceInput = this.hasSalePriceTarget ? this.salePriceTarget : this.element.querySelector('input[name="product[sale_price]"]')
    
    // 콤마 제거하고 숫자로 변환
    const originalPrice = parseInt(originalPriceInput.value.replace(/[^\d]/g, '')) || 0
    const salePrice = parseInt(salePriceInput.value.replace(/[^\d]/g, '')) || 0
    
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
    // 가격 필드에서 콤마 제거
    if (this.hasOriginalPriceTarget) {
      const cleanValue = this.originalPriceTarget.value.replace(/[^\d]/g, '')
      this.originalPriceTarget.value = cleanValue
    }
    if (this.hasSalePriceTarget) {
      const cleanValue = this.salePriceTarget.value.replace(/[^\d]/g, '')
      this.salePriceTarget.value = cleanValue
    }

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