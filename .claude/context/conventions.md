# 코딩 규칙 및 컨벤션

## Ruby/Rails 컨벤션

### 모델
- enum 사용 시 심볼과 정수 매핑
- scope는 람다 표현식으로 정의
- 검증은 모델에 집중
- 비즈니스 로직은 모델 메서드로 구현

```ruby
enum :status, { active: 0, inactive: 1, closed: 2 }
scope :available_products, -> { where(status: :available) }
validates :name, presence: true, uniqueness: true
```

### 컨트롤러
- before_action으로 공통 로직 추출
- Strong Parameters 사용
- 예외 처리는 rescue로 우아하게

```ruby
before_action :set_business
rescue ActiveRecord::RecordNotFound
  redirect_to root_path, alert: "찾을 수 없습니다."
```

### 뷰
- 부분 템플릿보다 인라인 코드 선호 (단순함 유지)
- Tailwind 유틸리티 클래스 사용
- 조건부 클래스는 인라인으로 처리

## 스타일 가이드

### CSS/Tailwind
- 다크 테마 기본
- CSS 변수로 색상 관리
- shadcn 스타일 컴포넌트 패턴

```css
:root {
  --background: #000000;
  --card: #18181b;
  --border: #27272a;
}

.card {
  background-color: var(--card);
  border: 1px solid var(--border);
  border-radius: var(--radius);
}
```

### 한글 사용
- 뷰 파일의 텍스트는 한글
- 에러 메시지도 한글
- 변수명과 메서드명은 영어

## Git 커밋 스타일
```
[FEAT] 새로운 기능 추가
[FIX] 버그 수정
[REFACTOR] 코드 리팩토링
[STYLE] 코드 스타일 변경
[DOCS] 문서 변경
[TEST] 테스트 추가/수정
[CHORE] 빌드/설정 변경
```

## 파일 명명 규칙
- 컨트롤러: 복수형 (businesses_controller.rb)
- 모델: 단수형 (business.rb)
- 뷰: 액션명.html.erb
- 관리자 영역은 admin 네임스페이스 사용

## 개발 워크플로우
1. 기능 구현 전 모델과 마이그레이션 먼저
2. 컨트롤러는 RESTful 원칙 준수
3. 뷰는 모바일 우선으로 작성
4. 커밋 전 rubocop 실행

## 테스트
- 모델 테스트 우선
- 시스템 테스트로 사용자 시나리오 검증
- fixtures 대신 factories 선호 (향후)