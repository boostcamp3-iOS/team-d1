# Team-D1

# Project BeBrav

비 주류 사진/그림 작가들이 자신의 작품을 업로드하고 일반인들과 공유할 수 있는 플랫폼을 제공하는 앱

## Getting Started

메인뷰에서 작품사진을 CollectionView를 통해서 보여주고 페이지당 뷰 수가 가장 많은 작품은 2x2 사이즈로 나타나게된다. 이후 작품을 터치하게 되면 스크롤 뷰를 통해서 더 자세한 작품 사진을 볼 수 있고 해당 뷰에서 작가 이름을 터치하면 작가의 상세정보와 전체 작품을 감상할 수 있다. 로그인한 모든 유저는 작품 업로드 버튼을 통해서 자신의 작품을 언제든지 업로드 할 수 있으며 업로드시 가로/세로 크기, 작품의 색온도 등 알고리즘을 통해서 분류한 뒤 서버 데이터베이스에 올라가게 된다.

### Tech stack

* Firebase Rest API
* SQLite3
* Photos

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
  
 # 문서화한 데일리 스크럼
 <div align="middle">
 <img width="250" alt="1월30일" src="https://user-images.githubusercontent.com/34180216/52178326-5f010180-2810-11e9-9ca1-c8e2fac04f86.png" hspace=5>
<img width="250" alt="1월31일" src="https://user-images.githubusercontent.com/34180216/52178362-e2baee00-2810-11e9-8513-ef3d02945ea9.png" hspace=5>
<img width="250" alt="2월1일" src="https://user-images.githubusercontent.com/34180216/52178365-e6e70b80-2810-11e9-9cae-12ac23ca2462.png" hspace=5>

 </div>

# 3주차

 - 뷰 구조를 완성한다
  - 알고리즘을 구현한다
  - 테스트를 진행한다
  - 네트워크와 연결한다


 # 진행한 데일리 스크럼
 <div align="middle">
 <img width="250" alt="sign in_2" src="https://user-images.githubusercontent.com/34180216/52913533-66d99f00-3302-11e9-89cc-733abb56b607.png" hspace=5>
 
  <img width="250" alt="sign in_2" src="https://user-images.githubusercontent.com/34180216/52913534-66d99f00-3302-11e9-82df-a1488786de92.png" hspace=5>
   <img width="250" alt="sign in_2" src="https://user-images.githubusercontent.com/34180216/52913535-66d99f00-3302-11e9-85ff-66e25b514819.png" hspace=5>
    <img width="250" alt="sign in_2" src="https://user-images.githubusercontent.com/34180216/52913536-66d99f00-3302-11e9-8a27-fda347909374.png" hspace=5>
     <img width="250" alt="sign in_2" src="https://user-images.githubusercontent.com/34180216/52913537-67723580-3302-11e9-98f3-feff8e15960b.png" hspace=5>
     </div>


# 개발 완료 화면

<div align="middle">
  <img width="200" alt="sign in_1" src="https://user-images.githubusercontent.com/34180216/52908956-142cc280-32c3-11e9-9a4b-2f86c9f61f5b.png" hspace=5>
  <img width="200" alt="sign in_2" src="https://user-images.githubusercontent.com/34180216/52908957-14c55900-32c3-11e9-8257-235733b122f8.png" hspace=5>
  <img width="200" alt="sign up_1" src="https://user-images.githubusercontent.com/34180216/52908958-14c55900-32c3-11e9-9cdd-a46627cb7a0c.png" hspace=5>
  <img width="200" alt="sign up_2" src="https://user-images.githubusercontent.com/34180216/52908959-14c55900-32c3-11e9-8b14-fb88b8abc2d0.png" hspace=5>
 </div>
 
<div align="middle">
 <img width="200" alt="mainview" src="https://user-images.githubusercontent.com/34180216/52913186-d483cc00-32fe-11e9-9bd1-8eab803ca0f1.png" hspace = 5>
  <img width="200" alt="sign in_1" src="https://user-images.githubusercontent.com/34180216/52913115-06486300-32fe-11e9-82c3-d267d2709a53.png" hspace=5>
  <img width="200" alt="sign in_2" src="https://user-images.githubusercontent.com/34180216/52913116-06e0f980-32fe-11e9-8a45-93bb355be7eb.png" hspace=5>
 </div>
 
 

# 4주차

- UI 화면 전체 구성 완료
  - 통합 테스트 진행
  - 부분적 테스트 코드 작성
  - Localization / RTL 
  
# 완성된 뷰 
  - Sign In & Sign Up
  <div align="middle">
  <img width="200" alt="2019-02-25 11 28 27" src="https://user-images.githubusercontent.com/34180216/53310504-85d2c500-38f0-11e9-8c98-1dcb9e39b586.png" hspace=5>
  <img width="200" alt="login_2" src="https://user-images.githubusercontent.com/34180216/53310369-f0373580-38ef-11e9-908e-a293f0c4709e.png" hspace=5>

<img width="200" alt="signup_1" src="https://user-images.githubusercontent.com/34180216/53310377-f3cabc80-38ef-11e9-949e-1f8a5179507f.png" hspace=5>
<img width="200" alt="signup_2" src="https://user-images.githubusercontent.com/34180216/53310381-f6c5ad00-38ef-11e9-8c37-31a9a0640cbc.png" hspace=5>

</div>

  - Main View
<div align="middle">
<img width="200" alt="main_1" src="https://user-images.githubusercontent.com/34180216/53310541-ac90fb80-38f0-11e9-89e2-b8c742b26b9a.png" hspace=5>
<img width="200" alt="main_2" src="https://user-images.githubusercontent.com/34180216/53310542-ad299200-38f0-11e9-87b8-cd8fbd62a2a6.png" hspace=5>
 </div>
 
  - Detail ArtView & Detail Artist View
 <div align="middle">
 <img width="200" alt="artview" src="https://user-images.githubusercontent.com/34180216/53310808-b23b1100-38f1-11e9-8f34-fb48874cdb8e.png" hspace=5>
<img width="200" alt="artistpage" src="https://user-images.githubusercontent.com/34180216/53310809-b23b1100-38f1-11e9-9751-bdc5008e5e55.png" hspace=5>
 </div>

   - Filtering
 <div align="middle">
 <img width="200" alt="filter_1" src="https://user-images.githubusercontent.com/34180216/53310617-e95cf280-38f0-11e9-9557-cb8d615fccbd.png" hspace=5>
 <img width="200" alt="filter_2" src="https://user-images.githubusercontent.com/34180216/53310616-e8c45c00-38f0-11e9-9bca-a97798eb4b3b.png" hspace=5>
 <img width="200" alt="filter_3" src="https://user-images.githubusercontent.com/34180216/53310615-e8c45c00-38f0-11e9-9f8c-d1333acd2c5d.png" hspace=5>
 </div>

   - Uploading View
<div align="middle">
<img width="200" alt="upload_asking" src="https://user-images.githubusercontent.com/34180216/53310692-4789d580-38f1-11e9-9526-b2a7668fde9a.png" hspace=5>
<img width="200" alt="upload" src="https://user-images.githubusercontent.com/34180216/53310694-48bb0280-38f1-11e9-9298-1c8fb070a57c.png" hspace=5>
 </div>



