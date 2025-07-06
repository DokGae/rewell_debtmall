# CLAUDE.md


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

## Project Overview

EndmarkDebtmall은 Rails 8.0.2로 구축된 프로젝트입니다. 현재 초기 개발 단계에 있으며, Rails 8의 최신 기능들을 활용하고 있습니다.

### Tech Stack
- **Backend**: Ruby 3.3.0, Rails 8.0.2
- **Frontend**: Hotwire (Turbo + Stimulus), Tailwind CSS
- **Database**: SQLite3 (개발/테스트), 프로덕션에서는 다중 SQLite DB 사용
- **JavaScript**: Import Maps (번들러 없음)
- **Asset Pipeline**: Propshaft
- **Web Server**: Puma
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

## Architecture & Structure

### 디렉토리 구조
- `app/` - 애플리케이션 코드
  - `assets/` - 정적 자산 (이미지, 스타일시트)
  - `controllers/` - 컨트롤러
  - `models/` - 모델
  - `views/` - 뷰 템플릿
  - `javascript/` - Stimulus 컨트롤러 및 JavaScript
  - `jobs/` - 백그라운드 작업 (Solid Queue 사용)
  - `mailers/` - 메일러
- `config/` - 설정 파일
  - `routes.rb` - 라우팅 정의
  - `database.yml` - 데이터베이스 설정
  - `importmap.rb` - JavaScript 패키지 매핑
- `db/` - 데이터베이스 관련
  - `migrate/` - 마이그레이션 파일
  - `schema.rb` - 데이터베이스 스키마
- `test/` - 테스트 파일 (Minitest 사용)

### 주요 설정
1. **다중 데이터베이스**: Rails 8의 Solid 시리즈 사용
   - Primary DB: 애플리케이션 데이터
   - Cache DB: 캐싱 (solid_cache)
   - Queue DB: 백그라운드 작업 (solid_queue)
   - Cable DB: WebSocket 연결 (solid_cable)

2. **JavaScript 관리**: Import Maps 사용
   - 번들러 없이 ES6 모듈 직접 사용
   - `config/importmap.rb`에서 패키지 관리

3. **CSS**: Tailwind CSS
   - `tailwindcss-rails` gem 사용
   - JIT 컴파일러로 최적화된 CSS 생성

### 개발 워크플로우
1. 새로운 기능 개발 시 MVC 패턴 따르기
2. Stimulus 컨트롤러로 JavaScript 동작 구현
3. Turbo로 페이지 새로고침 없는 네비게이션 구현
4. Tailwind CSS 유틸리티 클래스로 스타일링

### CI/CD
GitHub Actions를 통해 자동화:
- Ruby 보안 스캔 (Brakeman)
- JavaScript 보안 감사
- 코드 스타일 검사 (Rubocop)
- 테스트 실행

## 개발 시 주의사항

1. **Rails 8 최신 기능 활용**
   - Solid Cache/Queue/Cable 사용
   - Propshaft Asset Pipeline
   - Import Maps

2. **보안**
   - 커밋 전 `bin/brakeman` 실행으로 보안 검사
   - 민감한 정보는 credentials에 저장

3. **테스트**
   - 새로운 기능 추가 시 테스트 작성 필수
   - 시스템 테스트로 사용자 시나리오 검증

4. **코드 스타일**
   - Rubocop 규칙 준수
   - Rails 컨벤션 따르기

