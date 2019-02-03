# Team-D1

# Project BeBrav

비 주류 사진/그림 작가들이 자신의 작품을 업로드하고 일반인들과 공유할 수 있는 플랫폼을 제공하는 앱

## Getting Started

메인뷰에서 작품사진을 CollectionView를 통해서 보여주고 페이지당 뷰 수가 가장 많은 작품은 2x2 사이즈로 나타나게된다. 이후 작품을 터치하게 되면 스크롤 뷰를 통해서 더 자세한 작품 사진을 볼 수 있고 해당 뷰에서 작가 이름을 터치하면 작가의 상세정보와 전체 작품을 감상할 수 있다. 로그인한 모든 유저는 작품 업로드 버튼을 통해서 자신의 작품을 언제든지 업로드 할 수 있으며 업로드시 가로/세로 크기, 작품의 색온도 등 알고리즘을 통해서 분류한 뒤 서버 데이터베이스에 올라가게 된다.

### Tech stack

* Firebase Rest API
* SQLite3

## Deployment

2019.02.21 예정


## Versioning

version 1.0

## Contributor
  *Mentor*  - [Chope](https://github.com/yoonhg84)

  *team D1*  - [SangbumGoh](https://github.com/bumsgoh)</n>
             - [SeonghunKim](https://github.com/Seonghun23)</n>
             - [JiwonGong](https://github.com/jyeoni0919)</n>
           
           
## License

MIT License


# 1주차
  - 팀내 코딩 규칙을 정한다
  - 개발계획을 세부적으로 정한다
  - 와이어 프레임을 작성한다
  - 기본적인 UI를 구현한다

# 코딩 컨벤션 참고 사이트
https://github.com/StyleShare/swift-style-guide

https://github.com/raywenderlich/swift-style-guide


1. 코드를 주로 이용하되 스토리보드에 반영할 수 있도록 한다

2. guard let return 시 return 할 것이 있으면 엔터 없으면 { return }로 한다

3. 변수 초기화 var array: [Int] = [] 사용한다

4. self, types 추론 가능한것 쓰지않는다

5. self 옵셔널 되면 guard let 으로 뺀다

6. 상속을 줄이고 프로토콜로 대체, MVC패턴 사용한다

7. UI객체들 내용 + 해당 객체 이름으로 정한다. ex ) label 은 내용 + Label을 붙인다

8. 함수의 경우 구체적은 동작을 정의한다 loginButtonDidTap

9. delegate / dataSource extension으로 나누어 구현한다

10. return .init() 사용한다

11. 변수 접근자끼리 먼저 묶고 let var 로 나눈다

# 프로젝트 계획표
<div align="middle">
<img width="1630" alt="2019-01-28 11 57 00" src="https://user-images.githubusercontent.com/34180216/51812209-ef60b300-22f3-11e9-98c8-295bd0c29f82.png">
 </div>

# 와이어프레임
<img width="1262" alt="2019-01-22 2 38 37" src="https://user-images.githubusercontent.com/34180216/51735628-40da2980-20cb-11e9-8941-15e215eef968.png">

# UI 프로토타입
<div align="middle">
<img width="300" alt="2019-01-25 6 04 49" src="https://user-images.githubusercontent.com/34180216/51736110-9a8f2380-20cc-11e9-9b76-01b9ec963ddf.png">
<img width="300" alt="2019-01-22 2 38 37" src="https://user-images.githubusercontent.com/34180216/51736019-64ea3a80-20cc-11e9-9033-3df97f47daaf.jpg">
</div>
<div align="middle">
<img width="300" alt="2019-01-22 2 38 37" src="https://user-images.githubusercontent.com/34180216/51736021-674c9480-20cc-11e9-9527-7b4f3fe46318.png">
<img width="300" alt="2019-01-22 2 38 37" src="https://user-images.githubusercontent.com/34180216/51736023-674c9480-20cc-11e9-913e-76b5a60657ba.png"></div>



# 2주차

  - 네트워크 레이어를 구성한다
  - 내부 로컬 데이터베이스 구성한다(sqlite)
  - 작품 데이터 구분 알고리즘 구현한다
  - 기본적인 UI를 구현한다
  - 데일리 스크럼을 문서화한다
  
# 로컬 데이터베이스 테이블
<div align="middle">
  <img width="399" alt="screen shot 2019-02-01 at 10 24 51 am" src="https://user-images.githubusercontent.com/34180216/52178271-a76bef80-280f-11e9-8dbf-e0e010db38c1.png">
 </div>
 
 
 
 
 # 네트워크 JSON 구조의 데이터베이스
 <div align="middle">
<img width="752" alt="2019-02-03 11 54 46" src="https://user-images.githubusercontent.com/34180216/52178272-ad61d080-280f-11e9-889f-56af0eb5a1b5.png">
  </div>

 
