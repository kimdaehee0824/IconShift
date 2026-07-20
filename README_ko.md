<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="docs/images/banner-dark.jpg">
    <img src="docs/images/banner-light.jpg" alt="IconShift" width="100%">
  </picture>
</p>

<p align="center"><a href="README.md">English</a> · 한국어 · <a href="README_jp.md">日本語</a> · <a href="https://github.com/kimdaehee0824/IconShift/releases/latest/download/IconShift.dmg"><picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/download-dark.svg"><img src="docs/images/download-light.svg" height="14" alt=""></picture> <b>macOS용 다운로드</b></a></p>

다크 모드를 켜면 Mac의 모든 것이 어두워집니다. 딱 그 아이콘 하나만 빼고요. **IconShift**는 바로 그 아이콘을 위한 작은 메뉴 막대 앱입니다. 앱마다 라이트·다크 아이콘을 하나씩 지정해 두면, 시스템 외형이 바뀔 때마다 Finder와 Dock의 아이콘도 알맞게 바뀝니다.

범인은 대개 Safari나 Chrome으로 만든 웹 앱입니다. 한쪽 배경만 생각하고 그려진 아이콘이라, 반대 모드에서는 혼자 붕 떠 보입니다.

- **자동 전환**: 시스템 외형이 바뀌는 순간 라이트 또는 다크 아이콘을 적용
- **앱별 설정**: 시스템을 따르거나, 항상 라이트·항상 다크로 고정
- **간단한 지정**: PNG나 ICNS 파일을 아이콘 칸에 끌어다 놓거나 파일로 선택
- **로그인 시 실행**: 로그인 후 조용히 시작해 아이콘을 계속 맞춰 둠
- **메뉴 막대 아이콘 숨김**: 아이콘을 숨겨도 백그라운드에서 계속 동작
- **자동 복구**: 브라우저 업데이트가 이따금 아이콘을 되돌려 놓아도, 시작할 때마다 다시 적용

## 동작 환경

| 항목  | 요구 사항                        |
| ----- | -------------------------------- |
| macOS | 14 이상                          |
| Mac   | Apple Silicon과 Intel (Universal) |

IconShift를 사용하는 데 Xcode나 개발자 도구는 필요하지 않습니다.

## 설치

1. [GitHub Releases](https://github.com/kimdaehee0824/IconShift/releases)에서 최신 `IconShift-<버전>.dmg`를 내려받습니다.
2. DMG를 열고 `IconShift.app`을 응용 프로그램 폴더로 드래그합니다.
3. IconShift를 한 번 실행합니다. 아직 공증(노터라이즈)되지 않은 릴리스라 macOS가 첫 실행을 막을 수 있습니다. 이때는 **시스템 설정 > 개인정보 보호 및 보안**을 열고 **보안** 영역에서 **그래도 열기**를 누른 뒤 **열기**로 확인합니다.
4. IconShift가 처음 앱 아이콘을 바꿀 때 macOS가 **앱 관리** 접근 허용을 묻습니다. **허용**을 누르세요. 알림을 놓쳤다면 **시스템 설정 > 개인정보 보호 및 보안 > 앱 관리**에서 IconShift를 켜면 됩니다.

공증된 릴리스를 제공하기 전까지는 IconShift를 업데이트한 뒤 이 승인 과정을 다시 거쳐야 할 수 있습니다.

## 사용법

1. IconShift를 열고 사이드바에서 **앱 추가**를 누릅니다.
2. 설치된 앱을 고른 뒤 **라이트 아이콘**과 **다크 아이콘** 칸에 이미지를 끌어다 놓습니다.
3. 자동 전환을 쓰려면 **시스템 외형 따르기**를 켜 둡니다. 끄면 **항상 라이트**나 **항상 다크**로 고정할 수 있습니다.
4. 바꾼 아이콘을 바로 적용하고 싶을 때는 **지금 적용**을 누릅니다.

**설정 > 일반**에서 **로그인 시 실행**과 **메뉴 막대 아이콘 표시**를 바꿀 수 있습니다. 메뉴 막대 아이콘을 숨긴 상태에서 창을 다시 열려면 IconShift를 한 번 더 실행하면 됩니다. **설정 > 정보**에서는 버전과 라이선스를 확인할 수 있습니다.

Finder의 아이콘은 곧바로 바뀝니다. 이미 실행 중인 앱은 종료했다가 다시 열기 전까지 Dock에 이전 아이콘이 남는데, 이는 macOS Dock의 정상 동작입니다. IconShift는 시작할 때마다 설정된 아이콘을 다시 적용하므로, Safari나 Chrome 업데이트로 초기화된 웹 앱 아이콘도 자연스럽게 복구됩니다.

아이콘 파일이 더 필요하다면 [macOSicons](https://macosicons.com)에서 PNG 또는 ICNS 아이콘을 다운로드한 뒤 IconShift로 끌어다 놓거나 **선택…**으로 지정할 수 있습니다. IconShift는 macOSicons와 제휴 관계가 없으며 API를 사용하지 않습니다. 아이콘 제공 여부와 라이선스는 macOSicons 및 각 제작자의 정책을 따릅니다.

## 기여하기

개발 환경 구성과 기여 방법은 [CONTRIBUTING.md](CONTRIBUTING.md)에 정리되어 있습니다.

## 라이선스

IconShift는 [MIT License](LICENSE)로 배포됩니다.
