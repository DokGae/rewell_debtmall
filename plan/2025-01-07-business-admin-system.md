# 업체별 사업주 관리 시스템 구축 계획

작성일: 2025-01-07

## 🎯 목표
메인 관리자가 업체별 로그인 정보를 관리하고, 사업주는 상품 관리만 가능한 시스템 구축

## 📋 구현 계획

### 1. **권한 구조**
- **메인 관리자 (Admin)**
  - ✅ 업체 생성/수정/삭제
  - ✅ 업체 로그인 정보(이메일/비밀번호) 설정 및 변경
  - ✅ 모든 업체의 모든 정보 관리
  - ✅ 전체 시스템 관리

- **업체 사업주 (Business)**
  - ✅ 자신의 업체 상품 등록/수정/삭제
  - ✅ 상품별 가격 제안 현황 보기 (횟수, 최고가만)
  - ❌ 업체 기본 정보 수정 불가
  - ❌ 다른 업체 접근 불가
  - ❌ 구매자 개인정보 열람 불가

### 2. **데이터베이스 변경사항**
```ruby
# 마이그레이션: AddAuthenticationToBusinesses
add_column :businesses, :encrypted_password, :string, null: false, default: ""
add_column :businesses, :reset_password_token, :string
add_column :businesses, :reset_password_sent_at, :datetime
add_column :businesses, :remember_created_at, :datetime
add_column :businesses, :sign_in_count, :integer, default: 0, null: false
add_column :businesses, :current_sign_in_at, :datetime
add_column :businesses, :last_sign_in_at, :datetime

add_index :businesses, :reset_password_token, unique: true
add_index :businesses, :email, unique: true
```

### 3. **메인 관리자 업체 관리 기능 강화**
- **업체 등록 폼** (`/admin/businesses/new`)
  - 기본 정보: 이름, 설명, 연락처, 주소 등
  - 로그인 정보: 이메일, 초기 비밀번호
  - 상태: 활성화/비활성화
  
- **업체 수정 폼** (`/admin/businesses/:id/edit`)
  - 모든 업체 정보 수정 가능
  - 비밀번호 재설정 기능
  - 로그인 차단 기능 (상태를 inactive로)

### 4. **URL 구조**
```
# 메인 관리자
/admin                      → 메인 관리자 대시보드
/admin/businesses           → 업체 관리
/admin/businesses/new       → 업체 등록 (로그인 정보 포함)
/admin/businesses/:id/edit  → 업체 수정 (비밀번호 변경 가능)

# 업체 사업주
/[slug]/admin              → 업체 로그인 페이지
/[slug]/admin/dashboard    → 업체 대시보드
/[slug]/admin/products     → 상품 관리
/[slug]/admin/products/new → 상품 등록
```

### 5. **컨트롤러 구조**

#### Admin 네임스페이스
- `Admin::BusinessesController`
  - 업체 CRUD + 비밀번호 설정/변경
  - Strong Parameters에 password 추가

#### Business 네임스페이스
- `Business::BaseController`
  - URL slug 검증
  - 로그인한 업체와 URL 업체 일치 확인
- `Business::SessionsController`
  - 커스텀 로그인 (slug 기반)
- `Business::DashboardController`
  - 상품 통계만 표시
- `Business::ProductsController`
  - 상품 CRUD (자신의 업체 상품만)

### 6. **Business 모델 수정**
```ruby
class Business < ApplicationRecord
  # Devise 모듈 (registerable 제외 - 사업주는 직접 가입 불가)
  devise :database_authenticatable, :recoverable, 
         :rememberable, :trackable, :validatable
  
  # 비밀번호 없이도 생성 가능 (관리자가 나중에 설정)
  validates :password, presence: true, on: :update
  
  # 로그인 가능 여부 체크
  def active_for_authentication?
    super && status == 'active'
  end
end
```

### 7. **메인 관리자 업체 관리 화면**
```ruby
# 업체 등록/수정 폼 필드
- 기본 정보 섹션
  - 업체명 (필수)
  - 설명
  - 이메일 (로그인용, 필수)
  - 전화번호
  - 주소
  - 총 부채
  - 마감일
  
- 로그인 정보 섹션
  - 이메일 (자동 입력)
  - 비밀번호 (등록 시 필수, 수정 시 선택)
  - 비밀번호 확인
  
- 상태 관리
  - 활성화/비활성화 (로그인 차단)
  - 마지막 로그인 시간 표시
```

### 8. **사업주 관리 페이지 기능**
- **대시보드** (`/[slug]/admin/dashboard`)
  - 등록 상품 수
  - 총 가격 제안 수
  - 상품별 제안 현황 차트
  - 최근 제안 받은 상품 목록

- **상품 관리** (`/[slug]/admin/products`)
  - 상품 목록 (페이지네이션)
  - 상품 등록/수정/삭제
  - 이미지 업로드 (드래그앤드롭)
  - 카테고리 선택
  - 재고 관리
  - 제안 현황 보기 (횟수, 최고가만)

### 9. **보안 강화**
- 비밀번호 정책: 최소 8자, 영문+숫자 조합
- 로그인 실패 시 지연 시간 추가
- 세션 타임아웃: 30분 무활동 시 자동 로그아웃
- 비활성화된 업체는 로그인 불가
- IP 기반 접속 로그 기록

### 10. **구현 순서**
1. Business 테이블에 Devise 필드 추가 (마이그레이션)
2. Business 모델에 Devise 설정
3. Admin::BusinessesController 수정 (비밀번호 관리 추가)
4. 업체별 admin 라우트 구성
5. Business::BaseController 및 인증 로직
6. 업체 로그인 페이지 구현
7. 업체 대시보드 구현
8. 상품 CRUD 구현
9. 권한 검증 및 보안 강화
10. UI 스타일링 및 한글화

### 11. **화면 예시**

#### 메인 관리자 - 업체 등록
```
업체 정보
├─ 업체명: [리웰]
├─ 이메일: [rewell@example.com]
├─ 비밀번호: [********]
├─ 비밀번호 확인: [********]
└─ 상태: [✓ 활성화]
```

#### 업체 사업주 - 로그인
```
도메인.com/리웰/admin

리웰 관리자 로그인
이메일: [___________]
비밀번호: [___________]
[로그인]
```

### 12. **주요 고려사항**
- 메인 관리자와 업체 사업주의 권한 명확히 분리
- URL 기반 업체 식별로 직관적인 접근
- 업체 사업주는 상품 관리에만 집중
- 보안 강화로 안전한 시스템 구축