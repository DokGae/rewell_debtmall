# 시스템 아키텍처

## 기술 스택
- **Backend**: Ruby 3.3.0, Rails 8.0.2
- **Frontend**: Hotwire (Turbo + Stimulus), Tailwind CSS
- **Database**: SQLite3 (개발), 다중 SQLite DB (프로덕션)
- **Asset Pipeline**: Propshaft
- **JavaScript**: Import Maps
- **Image Processing**: Active Storage + image_processing (WebP 변환)

## 디렉토리 구조
```
app/
├── controllers/
│   ├── admin/
│   │   ├── base_controller.rb         # 관리자 기본 컨트롤러
│   │   ├── businesses_controller.rb   # 업체 관리
│   │   ├── products_controller.rb     # 상품 관리
│   │   └── purchase_requests_controller.rb # 구매요청 관리
│   ├── businesses_controller.rb       # 업체 페이지
│   ├── products_controller.rb         # 상품 상세
│   ├── purchase_requests_controller.rb # 구매 문의
│   └── home_controller.rb             # 홈페이지
├── models/
│   ├── business.rb                    # 업체 (FriendlyId)
│   ├── product.rb                     # 상품 (다중 이미지)
│   ├── purchase_request.rb            # 구매요청
│   └── admin.rb                       # 관리자 (Devise)
├── views/
│   ├── layouts/
│   │   ├── application.html.erb       # 공개 레이아웃
│   │   └── admin.html.erb             # 관리자 레이아웃
│   ├── admin/                         # 관리자 뷰
│   ├── businesses/                    # 업체 뷰
│   ├── products/                      # 상품 뷰
│   └── home/                          # 홈 뷰
└── assets/
    └── tailwind/
        └── application.css            # 다크 테마 스타일
```

## 데이터베이스 구조

### businesses
- id, name, slug (unique), description, email, phone
- address, total_debt, status (enum), timestamps
- has_one_attached :logo
- has_many :products

### products  
- id, business_id, name, description
- original_price, sale_price, category, status (enum)
- featured, stock_quantity, specifications, timestamps
- has_many_attached :images
- has_many :purchase_requests

### purchase_requests
- id, product_id, buyer_name, buyer_email, buyer_phone
- offered_price, message, status (enum), timestamps
- belongs_to :product

### admins (Devise)
- id, email, encrypted_password, devise fields, timestamps

## 라우팅 구조
```ruby
# 공개 라우트
root "home#index"
get "/:business_slug" => "businesses#show"
get "/:business_slug/products/:id" => "products#show"
post "/:business_slug/products/:id/purchase_requests" => "purchase_requests#create"

# 관리자 라우트
namespace :admin do
  resources :businesses do
    resources :products
  end
  resources :purchase_requests, only: [:index, :show, :update]
  root "businesses#index"
end
```

## 이미지 처리
- Active Storage variants로 자동 WebP 변환
- 세 가지 크기: thumb (300x300), medium (600x600), large (1200x1200)
- 업체 로고와 상품 이미지 지원

## 보안
- Devise로 관리자 인증
- CSRF 보호
- Strong Parameters
- Friendly URL로 ID 노출 방지