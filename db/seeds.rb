# 관리자 계정 생성
admin = Admin.find_or_create_by!(email: 'admin@admin.com') do |a|
  a.password = '1234'
  a.password_confirmation = '1234'
end
puts "관리자 계정 생성: #{admin.email}"

# 업체 생성
businesses = [
  {
    name: '리웰 휘트니스',
    description: '강남구에 위치한 프리미엄 헬스장으로 10년간 운영되었습니다. 최신 운동기구들을 보유하고 있습니다.',
    email: 'contact@rewell.kr',
    phone: '02-1234-5678',
    address: "서울특별시 강남구 테헤란로 123\n리웰빌딩 B1-B2",
    total_debt: 850000000,
    status: 'active'
  },
  {
    name: '파워짐 신촌점',
    description: '신촌 대학가에서 15년간 사랑받던 헬스장입니다. 다양한 웨이트 기구를 보유하고 있습니다.',
    email: 'powergym@naver.com',
    phone: '02-9876-5432',
    address: "서울특별시 서대문구 신촌로 456",
    total_debt: 320000000,
    status: 'closed'
  },
  {
    name: '요가 스튜디오 선',
    description: '프리미엄 요가 전문 스튜디오입니다. 고급 요가 용품과 필라테스 기구를 판매합니다.',
    email: 'info@yogasun.co.kr',
    phone: '02-5555-7777',
    address: "서울특별시 송파구 올림픽로 789",
    total_debt: 180000000,
    status: 'active'
  }
]

created_businesses = businesses.map do |business_data|
  business = Business.find_or_create_by!(name: business_data[:name]) do |b|
    b.description = business_data[:description]
    b.email = business_data[:email]
    b.phone = business_data[:phone]
    b.address = business_data[:address]
    b.total_debt = business_data[:total_debt]
    b.status = business_data[:status]
  end
  puts "업체 생성: #{business.name}"
  business
end

# 카테고리 생성
categories_data = [
  { name: '유산소 운동기구', children: [
    { name: '런닝머신', description: '트레드밀, 워킹머신 등' },
    { name: '사이클', description: '스피닝, 실내자전거 등' },
    { name: '일립티컬', description: '크로스트레이너' },
    { name: '로잉머신', description: '조정 운동기구' }
  ]},
  { name: '웨이트 트레이닝', children: [
    { name: '프리웨이트', description: '덤벨, 바벨, 케틀벨 등' },
    { name: '머신운동기구', description: '각종 웨이트 머신' },
    { name: '파워랙/스미스', description: '복합 운동기구' },
    { name: '벤치/랙', description: '운동 보조기구' }
  ]},
  { name: '요가/필라테스', children: [
    { name: '요가용품', description: '매트, 블록, 스트랩 등' },
    { name: '필라테스기구', description: '리포머, 캐딜락 등' }
  ]},
  { name: '기타운동기구', children: [
    { name: '복합운동기구', description: '멀티짐, 홈짐 등' },
    { name: '소도구', description: '밴드, 폼롤러, 짐볼 등' },
    { name: '보조기구', description: '거울, 매트, 수납장 등' }
  ]}
]

categories_data.each_with_index do |parent_data, parent_index|
  parent = Category.find_or_create_by!(name: parent_data[:name]) do |c|
    c.position = parent_index
    c.active = true
  end
  puts "카테고리 생성: #{parent.name}"
  
  parent_data[:children].each_with_index do |child_data, child_index|
    child = Category.find_or_create_by!(name: child_data[:name], parent: parent) do |c|
      c.description = child_data[:description]
      c.position = child_index
      c.active = true
    end
    puts "  하위 카테고리 생성: #{child.name}"
  end
end

# 카테고리 매핑
category_mapping = {
  '런닝머신' => Category.find_by(name: '런닝머신'),
  '사이클' => Category.find_by(name: '사이클'),
  '웨이트기구' => Category.find_by(name: '프리웨이트'),
  '요가용품' => Category.find_by(name: '요가용품'),
  '기타운동기구' => Category.find_by(name: '복합운동기구')
}

# 각 업체별 상품 생성
created_businesses.each do |business|
  case business.name
  when '리웰 휘트니스'
    products = [
      {
        name: 'Life Fitness 95T 런닝머신',
        description: "최고급 상업용 런닝머신\n사용기간: 2년\n상태: 매우 양호\n정기적인 유지보수 완료",
        original_price: 15000000,
        sale_price: 7500000,
        category: '런닝머신',
        stock_quantity: 3,
        specifications: "모델명: Life Fitness 95T\n크기: 211 x 89 x 158 cm\n무게: 195kg\n최대속도: 20km/h\n경사도: 0-15%\n모터: 4.0HP AC\n전원: 220V"
      },
      {
        name: 'Precor 835 사이클',
        description: "프리미엄 상업용 사이클\n사용기간: 1.5년\n상태: 우수",
        original_price: 8000000,
        sale_price: 4000000,
        category: '사이클',
        stock_quantity: 5,
        specifications: "모델명: Precor 835\n크기: 120 x 53 x 150 cm\n무게: 73kg\n저항레벨: 25단계\n프로그램: 10개"
      },
      {
        name: 'Technogym 덤벨세트 (1-50kg)',
        description: "전문가용 우레탄 덤벨 풀세트\n1kg부터 50kg까지 2kg 단위",
        original_price: 12000000,
        sale_price: 6000000,
        category: '웨이트기구',
        stock_quantity: 1,
        featured: true,
        specifications: "브랜드: Technogym\n재질: 우레탄 코팅\n구성: 1-50kg (2kg 단위)\n총 개수: 50개 (25쌍)"
      }
    ]
  when '파워짐 신촌점'
    products = [
      {
        name: '스미스머신 파워랙',
        description: "다목적 스미스머신\n사용기간: 5년\n상태: 양호\n안전바 포함",
        original_price: 6000000,
        sale_price: 2400000,
        category: '웨이트기구',
        stock_quantity: 2,
        specifications: "크기: 220 x 180 x 220 cm\n최대하중: 300kg\n바벨바 무게: 20kg\n안전장치: 포함"
      },
      {
        name: '레그프레스 머신',
        description: "45도 레그프레스\n사용기간: 4년\n최대하중 400kg",
        original_price: 4500000,
        sale_price: 1800000,
        category: '웨이트기구',
        stock_quantity: 1,
        specifications: "각도: 45도\n최대하중: 400kg\n크기: 230 x 110 x 150 cm"
      },
      {
        name: '케이블 크로스오버 머신',
        description: "양방향 케이블 머신\n다양한 운동 가능",
        original_price: 8000000,
        sale_price: 3200000,
        category: '웨이트기구',
        stock_quantity: 1,
        featured: true,
        specifications: "크기: 350 x 150 x 230 cm\n웨이트: 각 100kg\n케이블 수: 2개"
      }
    ]
  when '요가 스튜디오 선'
    products = [
      {
        name: '프리미엄 요가매트 세트 (20개)',
        description: "최고급 TPE 요가매트\n두께 6mm\n미끄럼 방지",
        original_price: 2000000,
        sale_price: 1000000,
        category: '요가용품',
        stock_quantity: 3,
        specifications: "재질: TPE\n두께: 6mm\n크기: 183 x 61 cm\n색상: 다양\n수량: 20개"
      },
      {
        name: '요가 블록 & 스트랩 세트',
        description: "요가 보조 도구 세트\n블록 40개, 스트랩 40개",
        original_price: 1200000,
        sale_price: 600000,
        category: '요가용품',
        stock_quantity: 1,
        specifications: "블록 재질: EVA\n블록 크기: 23 x 15 x 8 cm\n스트랩 길이: 183cm"
      },
      {
        name: 'Reformer 필라테스 머신',
        description: "전문가용 리포머\n사용기간: 1년\n상태: 최상",
        original_price: 12000000,
        sale_price: 7200000,
        category: '기타운동기구',
        stock_quantity: 2,
        featured: true,
        specifications: "브랜드: Balanced Body\n크기: 240 x 60 x 40 cm\n스프링: 5개\n최대하중: 150kg"
      }
    ]
  end
  
  products.each do |product_data|
    product = business.products.find_or_create_by!(name: product_data[:name]) do |p|
      p.description = product_data[:description]
      p.original_price = product_data[:original_price]
      p.sale_price = product_data[:sale_price]
      p.category = product_data[:category]  # 이전 버전 호환성
      p.category_id = category_mapping[product_data[:category]]&.id
      p.stock_quantity = product_data[:stock_quantity]
      p.specifications = product_data[:specifications]
      p.status = 'available'
      p.featured = product_data[:featured] || false
    end
    puts "  상품 생성: #{product.name}"
  end
end

# 샘플 구매 요청 생성
Product.available_products.sample(5).each do |product|
  PurchaseRequest.create!(
    product: product,
    buyer_name: Faker::Name.name,
    buyer_email: Faker::Internet.email,
    buyer_phone: "010-#{rand(1000..9999)}-#{rand(1000..9999)}",
    offered_price: product.sale_price * [0.8, 0.85, 0.9, 0.95, 1].sample,
    message: ["빠른 거래 원합니다.", "상태 확인 후 구매하고 싶습니다.", "대량 구매 시 할인 가능한가요?", nil].sample,
    status: PurchaseRequest.statuses.keys.sample
  )
end
puts "구매 요청 5개 생성 완료"

puts "\n시드 데이터 생성 완료!"
puts "관리자 로그인: admin@admin.com / 1234"
