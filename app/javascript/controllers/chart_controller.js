import { Controller } from "@hotwired/stimulus"
import { Chart, registerables } from 'chart.js'

Chart.register(...registerables)

export default class extends Controller {
  static values = { 
    type: String,
    data: Object,
    options: Object
  }
  
  connect() {
    const ctx = this.element.getContext('2d')
    
    // 다크 테마에 맞는 기본 옵션
    const defaultOptions = {
      responsive: true,
      maintainAspectRatio: false,
      plugins: {
        legend: {
          labels: {
            color: '#fff'
          }
        }
      },
      scales: {
        x: {
          ticks: {
            color: '#71717a'
          },
          grid: {
            color: '#27272a'
          }
        },
        y: {
          ticks: {
            color: '#71717a'
          },
          grid: {
            color: '#27272a'
          }
        }
      }
    }
    
    this.chart = new Chart(ctx, {
      type: this.typeValue,
      data: this.dataValue,
      options: { ...defaultOptions, ...this.optionsValue }
    })
  }
  
  disconnect() {
    if (this.chart) {
      this.chart.destroy()
    }
  }
}