# 야시장 가격표 / 제작 노트

- 방향: 보랏빛 밤하늘, 주홍색 좌판, 호박색 종이등. 손으로 그린 평면 벡터 삽화를 메인 배너에 사용하고, 장부와 상품 카드를 하나의 색 체계로 연결한다.
- 시각 자산: `assets/market.svg`를 이 프로젝트에서 직접 제작. UI의 별과 점은 폰트에 실제 존재하는 기호만 사용.
- 소리: `generate_audio.py`로 만든 0.105초 단음 `assets/tick.wav`. 버튼 입력 확인용. 직접 합성한 소리.
- 폰트: Noto Sans KR (SIL Open Font License 1.1). `assets/NotoSansKR.ttf`를 동봉하고 라이선스 원문은 `assets/OFL-NotoSansKR.txt`에 보관. 실행 시 Godot Theme에 직접 지정해 Web에서도 한글 렌더링. `tests/test_campaign.gd`에서 주요 한글·기호의 글리프를 검사.
- 게임 방식: 매일 가격 1~5냥, 준비량 0~8개를 선택한다. 한 개 준비 원가 2냥, 당일 미판매분 전량 폐기. 사건 효과와 가격 탄력성을 더해 수요가 결정되며 시드는 재현 가능. 최종 순이익 75냥 이상, 폐기 15개 이하가 승리 조건이다.
- 조작: 클릭/터치로 버튼, Tab/Enter로 키보드 버튼 선택, Enter로 다음 단계, Esc로 첫 화면, 장사 준비 중 숫자 1~3은 해당 상품 가격 +1, 4~6은 재고 +1.
- 저장: `user://night_market.cfg`에 준비 화면/당일 결과, 가격과 재고, 시드와 누적 장부를 기록. 브라우저 저장 공간에 의존한다. 종료 뒤 결과 화면은 이어하기 대상이 아니다.
- 실행: Godot 4.7.2에서 프로젝트 폴더를 열거나 `godot --path .`; Web은 `web/index.html`을 HTTP 서버에서 서빙한다 (`python3 -m http.server 8768 --directory web`). `file://`로 직접 열면 WebAssembly가 막힐 수 있다.
- 검증: `godot --headless --path . --script res://tests/test_model.gd`, `godot --headless --path . --script res://tests/test_campaign.gd`, `godot --headless --path . --script res://tests/test_scene.gd`, `godot --headless --path . --export-release Web web/index.html`. 390×844 브라우저 화면은 `evidence/mobile-pricing.png`에 기록.
