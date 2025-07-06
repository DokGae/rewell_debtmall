import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "preview", "dropZone", "progress", "progressBar"]
  static values = { 
    maxSize: Number,
    accept: String 
  }

  connect() {
    this.setupDropZone()
    this.existingImagesCount = this.previewTarget.querySelectorAll('[data-image-id]').length
  }

  setupDropZone() {
    const dropZone = this.dropZoneTarget
    
    // 클릭으로 파일 선택
    dropZone.addEventListener('click', (e) => {
      if (e.target !== this.inputTarget) {
        this.inputTarget.click()
      }
    })
    
    // 드래그 앤 드롭 이벤트
    dropZone.addEventListener('dragover', (e) => {
      e.preventDefault()
      dropZone.classList.add('border-zinc-600', 'bg-zinc-50')
    })
    
    dropZone.addEventListener('dragleave', (e) => {
      e.preventDefault()
      dropZone.classList.remove('border-zinc-600', 'bg-zinc-50')
    })
    
    dropZone.addEventListener('drop', (e) => {
      e.preventDefault()
      dropZone.classList.remove('border-zinc-600', 'bg-zinc-50')
      
      const files = Array.from(e.dataTransfer.files)
      this.handleFiles({ target: { files } })
    })
  }

  handleFiles(event) {
    const files = Array.from(event.target.files)
    const validFiles = []
    
    // 파일 검증
    files.forEach(file => {
      if (!file.type.startsWith('image/')) {
        this.showNotification('이미지 파일만 업로드 가능합니다', 'error')
        return
      }
      
      const maxSizeInBytes = this.maxSizeValue * 1024 * 1024
      if (file.size > maxSizeInBytes) {
        this.showNotification(`${file.name}은(는) ${this.maxSizeValue}MB를 초과합니다`, 'error')
        return
      }
      
      validFiles.push(file)
    })
    
    // 최대 10장 제한
    const totalImages = this.existingImagesCount + this.previewTarget.querySelectorAll('.new-image').length + validFiles.length
    if (totalImages > 10) {
      this.showNotification('최대 10장까지만 업로드 가능합니다', 'error')
      return
    }
    
    // 프리뷰 표시
    validFiles.forEach(file => {
      this.createPreview(file)
    })
  }

  createPreview(file) {
    const reader = new FileReader()
    
    reader.onload = (e) => {
      const previewItem = document.createElement('div')
      previewItem.className = 'relative group new-image'
      previewItem.innerHTML = `
        <div class="aspect-square bg-zinc-100 rounded-lg overflow-hidden">
          <img src="${e.target.result}" class="w-full h-full object-cover" alt="${file.name}">
        </div>
        <div class="absolute inset-0 bg-black bg-opacity-50 opacity-0 group-hover:opacity-100 transition-opacity rounded-lg flex items-center justify-center gap-2">
          <button type="button"
                  class="text-white p-2 hover:bg-white hover:bg-opacity-20 rounded"
                  data-action="click->image-upload#removeNewImage"
                  title="이미지 제거">
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"></path>
            </svg>
          </button>
        </div>
        <div class="absolute bottom-2 left-2 bg-green-600 text-white text-xs px-2 py-1 rounded">
          새 이미지
        </div>
      `
      
      this.previewTarget.appendChild(previewItem)
    }
    
    reader.readAsDataURL(file)
  }

  removeNewImage(event) {
    event.currentTarget.closest('.new-image').remove()
    
    // 새 이미지 제거 시에만 카운트 감소
    const newImagesCount = this.previewTarget.querySelectorAll('.new-image').length
    if (newImagesCount === 0) {
      // 모든 새 이미지가 제거되었을 때만 파일 입력 리셋
      this.inputTarget.value = ''
    }
  }

  removeExistingImage(event) {
    event.preventDefault()
    const index = event.currentTarget.dataset.imageIndex
    const removeInput = document.getElementById(`remove_image_${index}`)
    const imageContainer = event.currentTarget.closest('[data-image-id]')
    
    if (removeInput && imageContainer) {
      // Hidden input 값을 1로 설정
      removeInput.value = "1"
      
      // 시각적으로 삭제됨을 표시
      imageContainer.style.opacity = '0.3'
      imageContainer.classList.add('grayscale')
      
      // 휴지통 버튼을 복원 버튼으로 변경
      const deleteButton = event.currentTarget
      deleteButton.innerHTML = `
        <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 10h10a8 8 0 018 8v2M3 10l6 6m-6-6l6-6"></path>
        </svg>
      `
      deleteButton.setAttribute('data-action', 'click->image-upload#restoreExistingImage')
      deleteButton.setAttribute('title', '이미지 복원')
      
      // 삭제 표시 추가
      const badge = imageContainer.querySelector('.bg-blue-600') || imageContainer.querySelector('.absolute.top-2.left-2')
      if (badge) {
        badge.classList.remove('bg-blue-600')
        badge.classList.add('bg-red-600')
        badge.textContent = '삭제 예정'
      }
      
      this.showNotification('이미지가 삭제 예정입니다. 저장 시 적용됩니다.', 'info')
    }
  }
  
  restoreExistingImage(event) {
    event.preventDefault()
    const index = event.currentTarget.dataset.imageIndex
    const removeInput = document.getElementById(`remove_image_${index}`)
    const imageContainer = event.currentTarget.closest('[data-image-id]')
    
    if (removeInput && imageContainer) {
      // Hidden input 값을 0으로 복원
      removeInput.value = "0"
      
      // 시각적 효과 제거
      imageContainer.style.opacity = '1'
      imageContainer.classList.remove('grayscale')
      
      // 버튼을 다시 휴지통으로 변경
      const restoreButton = event.currentTarget
      restoreButton.innerHTML = `
        <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"></path>
        </svg>
      `
      restoreButton.setAttribute('data-action', 'click->image-upload#removeExistingImage')
      restoreButton.setAttribute('title', '이미지 삭제')
      
      // 삭제 표시 제거
      const badge = imageContainer.querySelector('.bg-red-600')
      if (badge) {
        badge.classList.remove('bg-red-600')
        badge.classList.add('bg-blue-600')
        badge.textContent = imageContainer.querySelector('[data-image-index="0"]') ? '대표 이미지' : ''
      }
      
      this.showNotification('이미지가 복원되었습니다.', 'info')
    }
  }

  showNotification(message, type = 'info') {
    // 간단한 알림 표시 (실제로는 더 나은 UI 필요)
    const notification = document.createElement('div')
    notification.className = `fixed top-4 right-4 p-4 rounded-lg text-white z-50 ${
      type === 'error' ? 'bg-red-600' : 'bg-blue-600'
    }`
    notification.textContent = message
    
    document.body.appendChild(notification)
    
    setTimeout(() => {
      notification.remove()
    }, 3000)
  }

  // 업로드 진행 상태 표시 (향후 AJAX 업로드 시 사용)
  showProgress(percent) {
    this.progressTarget.classList.remove('hidden')
    this.progressBarTarget.style.width = `${percent}%`
  }

  hideProgress() {
    setTimeout(() => {
      this.progressTarget.classList.add('hidden')
      this.progressBarTarget.style.width = '0%'
    }, 500)
  }
}