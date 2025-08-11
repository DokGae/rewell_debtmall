# CLAUDE.md - EndmarkDebtmall 프로젝트 가이드

## 📚 프로젝트 개요

**EndmarkDebtmall**은 부채 관련 제품을 판매하는 업체들을 위한 B2B 마켓플레이스 플랫폼입니다.
- Ruby 3.3.0 + Rails 8.0.2 기반의 풀스택 웹 애플리케이션
- Hotwire (Turbo + Stimulus)를 활용한 모던 프론트엔드
- 다중 업체(Business) 지원 및 각 업체별 독립적인 관리자 시스템
- 제품 제안 및 구매 요청 관리 기능

## 🔄 AI 세션 관리 프로토콜

### 세션 시작 시 필수 작업
1. `.claude/sessions/` 폴더에서 최근 3개 세션 파일 읽기 (LS 도구 사용)
2. `.claude/current-work.md` 파일 확인하여 진행 상황 파악
3. `.claude/context/` 폴더의 architecture.md와 conventions.md 확인
4. 이전 작업의 패턴과 결정사항을 이해한 후 작업 시작

### 작업 중 기록 규칙
중요한 변경사항이나 결정사항이 있을 때마다 메모리에 저장:
- 어떤 파일을 왜 수정했는지
- 선택한 구현 방법과 그 이유
- 사용한 라이브러리나 패턴
- 발생한 문제와 해결 방법

### 세션 종료 시 필수 작업
1. 세션 파일 생성: `.claude/sessions/YYYY-MM-DD-작업요약.md`
   - 작업 내용, 주요 결정사항, 변경된 파일 목록
   - 사용한 코드 패턴 예시
   - 다음 세션을 위한 참고사항
   
2. 현재 상태 업데이트: `.claude/current-work.md`
   - 진행 중인 작업
   - 완료된 작업
   - 대기 중인 작업

3. 아키텍처나 컨벤션 변경 시:
   - `.claude/context/architecture.md` 업데이트
   - `.claude/context/conventions.md` 업데이트

### 파일 구조
.claude/
├── sessions/                    # 각 세션별 작업 기록
│   └── YYYY-MM-DD-작업명.md   
├── context/                     # 프로젝트 전반 정보
│   ├── architecture.md         # 시스템 구조
│   └── conventions.md          # 코딩 규칙
└── current-work.md             # 현재 진행 상황
### 세션 파일 템플릿
각 세션 파일은 다음 템플릿을 따라 작성:
- 작업 내용 (무엇을 했는지)
- 주요 결정사항 (왜 그렇게 했는지)
- 변경된 파일 (어디를 수정했는지)
- 사용한 코드 패턴 (어떻게 구현했는지)
- 다음 세션 참고사항 (주의할 점)

### 중요
- 이 시스템은 AI 세션 간 연속성을 보장하기 위함
- 각 AI가 이전 AI의 작업을 완벽히 이해하고 이어받을 수 있도록 함
- 파일 생성/수정 시 Write, Edit 도구 사용
- 파일 읽기 시 Read 도구 사용



This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 🛠 기술 스택

### Backend
- **Framework**: Ruby 3.3.0, Rails 8.0.2
- **Database**: SQLite3 (다중 DB 구성)
  - Primary DB: 애플리케이션 데이터
  - Cache DB: solid_cache
  - Queue DB: solid_queue  
  - Cable DB: solid_cable
- **Authentication**: Devise (Admin, Business 다중 인증)
- **URL Management**: FriendlyId (한글 슬러그 지원)

### Frontend  
- **UI Framework**: Hotwire (Turbo + Stimulus)
- **CSS**: Tailwind CSS (JIT 컴파일)
- **JavaScript**: Import Maps (번들러 없음)
- **Asset Pipeline**: Propshaft

### Development Tools
- **Debugging**: pry-rails, pry-byebug, better_errors
- **Code Quality**: Rubocop, Brakeman
- **Performance**: Bullet (N+1 쿼리 감지)
- **Testing**: Minitest, Capybara, Selenium
- **Deployment**: Kamal (Docker 기반)

## Common Development Commands

### 개발 서버 실행
```bash
bin/dev  # Foreman을 사용해 Rails 서버와 Tailwind CSS 감시 모드를 함께 실행
```

### 테스트 실행
```bash
bin/rails test                # 모든 테스트 실행
bin/rails test test/models    # 모델 테스트만 실행
bin/rails test:system         # 시스템 테스트 실행
```

### 코드 스타일 검사
```bash
bin/rubocop              # Ruby 코드 스타일 검사
bin/rubocop -a           # 자동 수정 가능한 문제 수정
bin/rubocop -A           # 더 공격적인 자동 수정
```

### 보안 검사
```bash
bin/brakeman             # 보안 취약점 스캔
bin/importmap audit      # JavaScript 패키지 보안 감사
```

### 데이터베이스 관리
```bash
bin/rails db:create      # 데이터베이스 생성
bin/rails db:migrate     # 마이그레이션 실행
bin/rails db:seed        # 시드 데이터 생성
bin/rails db:reset       # DB 리셋 (drop, create, migrate, seed)
```

### 콘솔
```bash
bin/rails console        # Rails 콘솔 실행
bin/rails c              # 축약형
```

### Asset 관련
```bash
bin/rails assets:precompile    # 프로덕션용 에셋 컴파일
bin/rails tailwindcss:build    # Tailwind CSS 빌드
bin/rails tailwindcss:watch    # Tailwind CSS 감시 모드
```

## 🏗 아키텍처 & 구조

### 주요 모델
- **Admin**: 시스템 전체 관리자
- **Business**: 업체 (다중 업체 지원, 독립적인 관리자 계정)
  - slug/domain 기반 URL 라우팅
  - deadline 기반 시간 제한 기능
  - status 관리 (active/inactive/closed)
- **Product**: 제품 (업체별 제품 관리)
  - 카테고리 분류
  - 이미지 첨부 (Active Storage)
  - 제안 통계 추적
- **PurchaseRequest**: 구매 요청/제안
  - 제품별 가격 제안
  - 상태 관리 (pending/accepted/rejected)
- **Category**: 제품 카테고리
- **Company**: 회사 정보

### 라우팅 구조
```ruby
# 관리자 영역
/admin/*                    # 시스템 관리자
/business/*                 # 업체 관리자 (인증 후)

# 공개 영역  
/:business_slug/            # 업체별 페이지
/:business_slug/products/:id # 업체 제품 상세
/:business_slug/admin       # 업체 관리자 로그인
```

### 디렉토리 구조
```
app/
├── controllers/
│   ├── admin/          # 시스템 관리자 컨트롤러
│   ├── business/       # 업체 관리자 컨트롤러
│   └── (public)        # 공개 컨트롤러
├── models/             # 데이터 모델
├── views/
│   ├── admin/          # 관리자 뷰
│   ├── business/       # 업체 관리자 뷰
│   └── layouts/        # 레이아웃 (admin, business, application)
├── javascript/
│   └── controllers/    # Stimulus 컨트롤러
└── assets/
    └── stylesheets/    # CSS (Tailwind 기반)
```

### 개발 워크플로우
1. **MVC 패턴 준수**: Model-View-Controller 구조 엄격히 따르기
2. **Hotwire 우선**: JavaScript는 Stimulus 컨트롤러로, 네비게이션은 Turbo로
3. **서버 렌더링 우선**: 클라이언트 사이드 렌더링 최소화
4. **Tailwind 유틸리티**: 커스텀 CSS 대신 Tailwind 클래스 활용
5. **I18n 적용**: 모든 텍스트는 locale 파일 사용 (ko.yml, en.yml)

### CI/CD
GitHub Actions를 통해 자동화:
- Ruby 보안 스캔 (Brakeman)
- JavaScript 보안 감사
- 코드 스타일 검사 (Rubocop)
- 테스트 실행

## ⚠️ 개발 시 주의사항

### Rails 8 최신 기능 활용
- **Solid 시리즈**: solid_cache, solid_queue, solid_cable 적극 활용
- **Propshaft**: Sprockets 대신 Propshaft 사용
- **Import Maps**: 번들러 없이 JavaScript 모듈 관리
- **Turbo 8**: Morphing, Streams 등 최신 기능 활용

### 보안 체크리스트
- [ ] 커밋 전 `bin/brakeman` 실행
- [ ] Strong Parameters 확인
- [ ] CSRF 토큰 검증
- [ ] SQL Injection 방지 (ActiveRecord 사용)
- [ ] XSS 방지 (html_safe 신중히 사용)
- [ ] 민감 정보는 `rails credentials:edit` 사용

### 성능 최적화
- [ ] N+1 쿼리 방지 (Bullet gem 활용)
- [ ] 적절한 인덱스 추가
- [ ] 이미지 최적화 (variant 사용)
- [ ] Turbo Frame/Stream으로 부분 업데이트
- [ ] 캐싱 전략 (Russian Doll Caching)

### 코드 품질
- [ ] Rubocop 검사 통과 (`bin/rubocop -a`)
- [ ] 테스트 커버리지 유지
- [ ] RESTful 라우팅 준수
- [ ] Fat Model, Skinny Controller 원칙
- [ ] DRY (Don't Repeat Yourself) 원칙

## 🔑 핵심 기능

### 1. 다중 업체 시스템
- 각 업체별 독립적인 관리자 계정 (Devise)
- 업체별 고유 도메인/슬러그 URL
- 업체 상태 관리 (active/inactive/closed)
- 마감 기한(deadline) 카운트다운

### 2. 제품 관리
- 업체별 제품 등록/수정/삭제
- 카테고리 분류 시스템
- 다중 이미지 업로드 (Active Storage)
- 제안 통계 자동 집계

### 3. 구매 요청/제안 시스템  
- 제품별 가격 제안 접수
- 제안 상태 관리 (pending/accepted/rejected)
- 업체별 제안 현황 대시보드
- 실시간 알림 (Turbo Streams 예정)

### 4. 관리자 시스템
- **시스템 관리자**: 전체 업체/카테고리/제품 관리
- **업체 관리자**: 자사 제품/제안 관리
- 역할 기반 접근 제어 (RBAC)

## 📋 계획서 관리 기능

### 계획서 저장
사용자가 "계획 저장해" 또는 "계획서 저장"이라고 요청하면:

1. **계획서 저장 위치**: `/plan/` 폴더
2. **파일명 규칙**: `YYYY-MM-DD-기능명.md`
3. **저장 내용**:
   - 작성한 전체 계획서 내용
   - 목표, 구현 계획, 기술 스택, 주의사항 등
   - 마크다운 형식으로 저장

4. **README 업데이트**: `/plan/README.md` 파일에 새 계획서 링크 추가

### 계획서 실행
사용자가 "계획 실행해" 또는 "계획서 실행"이라고 요청하면:

1. **최근 계획서 찾기**: 
   - `/plan/` 폴더에서 가장 최근 날짜의 계획서 파일 찾기
   - 파일명의 날짜(YYYY-MM-DD)를 기준으로 정렬

2. **계획서 읽기**:
   - 선택된 계획서 파일을 Read 도구로 읽기
   - 구현 순서와 상세 내용 파악

3. **TodoWrite로 작업 목록 생성**:
   - 계획서의 "구현 순서" 섹션을 기반으로 todo 항목 생성
   - 각 단계를 개별 todo로 등록

4. **구현 시작**:
   - 첫 번째 todo를 in_progress로 변경
   - 계획서에 따라 순차적으로 구현 진행

### 계획서 템플릿
```markdown
# [기능명] 구축 계획

작성일: YYYY-MM-DD

## 🎯 목표
[목표 설명]

## 📋 구현 계획
[상세 구현 계획]

## 🛠 기술 스택
[사용할 기술들]

## ⚠️ 주의사항
[구현 시 주의할 점]

## 📝 구현 순서
1. [첫 번째 작업]
2. [두 번째 작업]
...
```

이 기능을 통해 AI 세션이 바뀌어도 이전 계획을 참고하고 실행할 수 있습니다.

