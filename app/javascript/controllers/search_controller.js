import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "suggestions"]
  
  connect() {
    this.timeout = null
    this.businessSlug = window.location.pathname.split('/')[1]
  }
  
  getSuggestions() {
    clearTimeout(this.timeout)
    const query = this.inputTarget.value.trim()
    
    if (query.length < 2) {
      this.hideSuggestions()
      return
    }
    
    this.timeout = setTimeout(() => {
      fetch(`/${this.businessSlug}/search_suggestions?q=${encodeURIComponent(query)}`)
        .then(response => response.json())
        .then(data => {
          this.showSuggestions(data)
        })
    }, 300)
  }
  
  showSuggestions(suggestions) {
    if (suggestions.length === 0) {
      this.hideSuggestions()
      return
    }
    
    const html = suggestions.map(suggestion => `
      <a href="/${this.businessSlug}/products/${suggestion.id}" 
         class="block px-4 py-3 hover:bg-zinc-800 text-white transition-colors">
        ${this.highlightMatch(suggestion.name, this.inputTarget.value)}
      </a>
    `).join('')
    
    this.suggestionsTarget.innerHTML = html
    this.suggestionsTarget.classList.remove('hidden')
    
    // 클릭 외부 감지
    document.addEventListener('click', this.handleOutsideClick.bind(this))
  }
  
  hideSuggestions() {
    this.suggestionsTarget.classList.add('hidden')
    document.removeEventListener('click', this.handleOutsideClick.bind(this))
  }
  
  handleOutsideClick(event) {
    if (!this.element.contains(event.target)) {
      this.hideSuggestions()
    }
  }
  
  highlightMatch(text, query) {
    const regex = new RegExp(`(${query})`, 'gi')
    return text.replace(regex, '<mark class="bg-yellow-500 text-black px-1 rounded">$1</mark>')
  }
}