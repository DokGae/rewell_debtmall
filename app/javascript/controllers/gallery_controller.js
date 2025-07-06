import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["mainImage", "thumbnail"]
  
  connect() {
    // 메인 이미지 선택 시 효과
    this.highlightActiveThumbnail(0)
  }
  
  changeImage(event) {
    const index = event.currentTarget.dataset.index
    const imageUrl = event.currentTarget.dataset.largeUrl
    
    // 메인 이미지 변경
    this.mainImageTarget.src = imageUrl
    
    // 활성 썸네일 하이라이트
    this.highlightActiveThumbnail(index)
  }
  
  highlightActiveThumbnail(activeIndex) {
    this.thumbnailTargets.forEach((thumbnail, index) => {
      if (index == activeIndex) {
        thumbnail.classList.add('ring-2', 'ring-blue-500')
        thumbnail.classList.remove('ring-zinc-600')
      } else {
        thumbnail.classList.remove('ring-2', 'ring-blue-500')
        thumbnail.classList.add('ring-zinc-600')
      }
    })
  }
  
  // 터치 스와이프 지원 (모바일)
  handleTouchStart(event) {
    this.touchStartX = event.touches[0].clientX
  }
  
  handleTouchEnd(event) {
    if (!this.touchStartX) return
    
    const touchEndX = event.changedTouches[0].clientX
    const diff = this.touchStartX - touchEndX
    
    if (Math.abs(diff) > 50) {
      const currentIndex = this.getCurrentIndex()
      const totalImages = this.thumbnailTargets.length
      
      if (diff > 0 && currentIndex < totalImages - 1) {
        // 다음 이미지
        this.selectImageByIndex(currentIndex + 1)
      } else if (diff < 0 && currentIndex > 0) {
        // 이전 이미지
        this.selectImageByIndex(currentIndex - 1)
      }
    }
    
    this.touchStartX = null
  }
  
  getCurrentIndex() {
    return this.thumbnailTargets.findIndex(thumbnail => 
      thumbnail.classList.contains('ring-blue-500')
    )
  }
  
  selectImageByIndex(index) {
    const thumbnail = this.thumbnailTargets[index]
    if (thumbnail) {
      thumbnail.click()
    }
  }
}