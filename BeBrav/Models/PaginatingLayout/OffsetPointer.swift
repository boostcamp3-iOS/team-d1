//
//  OffsetPointer.swift
//  BeBrav
//
//  Created by bumslap on 06/02/2019.
//  Copyright © 2019 bumslap. All rights reserved.
//


///MostViewedCollectionViewLayout의 Offset을 계산하기 위해 만들어진 구조체입니다.

///Offset이란?
///컬렉션뷰의 레이아웃을 구성하기 위해서는 각 셀마다 여러가지 정보 (크기, 위치..) Attribute라는
///인스탠스를 제공해주어야합니다. 이를 위해서 CollectionViewController는 셀을 만들때 CollectionViewLayout
///인스탠스에게 이 정보를 요청하게 됩니다. 이 정보를 프로젝트에 적용하게 되면 메인 뷰를 구성하기 위해서는
///가장 뷰 수가 많은 셀의 크기가 2x2 (다른 셀이 1x1이라고 했을때) 입니다. -> 각 셀당 크기는 레이아웃내에서
///컬럼의 숫자로 화면의 width를 나눈 값이며 만약 컬럼이 3개 width가 300이라고 했을때 한 셀의 크기와 높이는
///일반셀 (100,100), 뷰수가 많은셀(200,200) 이 될것입니다.

///위 정보를 셀이 정사각형 모양이므로 (width * 1 , width * 1) , (width * 2 , width * 2) 로 바꿀 수
///있을 것이고 width는 레이아웃 클래스에서 계산한다고 했을때 (1,1) (2,2)로 정보를 축약할 수 있습니다.
///이제 크기는 계산할 수 있지만 Attribute에서는 해당 셀이 어느 위치에 올지 Frame(x,y,width,height)정보를 주어야 합니다.
///이 부분을 담당하는 것이 바로 OffsetPointer 구조체입니다.

///동작 방식:
///컬럼이 3개, 일반적인 1x1셀만 존재한다고 했을때 셀의 xOffset은 (0 * width, 1 * width, 2 * width) ->
///width 제외시에 (0,1,2) 반복되는 형태가 될 것입니다. 여기에 yOffset은 일반적으로 한 row가 끝나면 1 씩 증가하므로 0부터 시작해
///계속 증가하는 형태가 될것입니다. 이를 조합해서 3개의 컬럼을 가진 레이아웃을 구성해보면 아래와 같습니다

/*
 [(0,0),(1,0),(2,0)]
 [(0,1),(1,1),(2,1)]
 [(0,2),(1,2),(2,2)]
 [(0,3),(1,3),(2,3)]
 [(0,4),(1,4),(2,4)]
        .
        .
        .
 */

///하지만 이 프로젝트의 메인뷰는 위 처럼 구성할 수 없습니다.(위의 방식은 CollectionViewFlowLayout이 구성해 줍니다)
///컬럼이 3개, 일반적인 1x1셀, 페이지당 1개의 2x2셀이 존재하게 되면  2x2 셀이 없는 row에서는 xOffset이
///width 제외시에 (0,1,2)이 되겠지만 2x2셀이 생성되면 2개의 row에 영향을 주게됩니다. 아래의 예는 해당 셀이
///두번쨰 row의 left위치에 생성되었다고 가정합니다.

/*
 [(0,0),(1,0),(2,0)]
 [(0,1),(2,1),(2,2)] <- left 포지션에 생성, 첫번쨰 컬럼에 2x2가 차지하게 되고 두번째 컬럼에 왔어야할 셀이 3번째에 나타납니다.
 [(0,3),(1,3),(2,3)] <- yOffset역시 한칸씩 밀리게됩니다.
 [(0,4),(1,4),(2,4)]
 [(0,5),(1,5),(2,5)]
        .
        .
        .
 */

///실제 형태는 아래와 같습니다
/*
 [1x1, 1x1, 1x1]
 [2x2, 2x2, 1x1] <- 2x2셀이 자리를 차지했습니다.
 [2x2, 2x2, 1x1] <- 2x2셀이 자리를 차지했습니다.
 [1x1, 1x1, 1x1]
        .
        .
        .
 */
///OffsetPointer구조체를 생성하게 되면 init 인자로 컬럼수와 만들어 내야하는 yOffset의 위치를 주어야 합니다.

///제공된 컬럼 수를 이용하여 먼저 설정한 것은 referenceColumn 이라는 배열입니다. 이는 xOffset을
///만들어내는 간단한 배열이지만 전체적으로 이 배열을 참고해서 offset들을 구성하게 됩니다. 확장성을 위해 기본적으로
///컬럼 수에 따라서 xOffset배열을 만들도록 초기화 할 수 있습니다. (3개 컬럼 [0, 1, 2] / 4개 [0, 1, 2, 3]..)
///yOffset인자는 다음 batchSize의 데이터를 받아왔을때 이전 yOffset의 다음 위치에 offset을 생성하기 위해서 만들어진
///값 입니다.

///위와 같은 방식으로 OffsetPointer를 인스탠스화 하게되면 getOffsets(count: Int,freezeAt number: Int) -> [(CGFloat, CGFloat)] 메서드를 사용할 수 있게됩니다. count는 batchSize(몇개의 아이템이 있는지 확인)입니다.
///freeze는 2x2 offset을 만들어내라는 신호와 같으므로 freezeAt은 해당하는 index의 셀을 2x2 로 만들겠다는 의미와
///같습니다. 내부에서는 calculateOffsets (count: Int, freezeAt: Int) 메서드를 호출하게 되고 이 메서드는
///받아온 인자로 정상적인(1x1 셀을 만드는) 방식으로 연산하다가 freezeAt에 해당하는 수가 나오게 되면 freeze() 메서드를 실행합니다
///freeze() 메서드는 단순히 isNextRowFreezed 프로퍼티를 true로 만들고 바로 뒤에오는 offset의 값을 -1(block)으로 만들게 됩니다
///이후 isNextRowFreezed 상태를 검사하여 position에 따라서 연산을 실행하는데 이는 다음 row에서 offset생성을 막는 역할을(block)
///담당합니다. 이 연산이 모두 진행되면 restore() 메서드를 호출하여 원래의 일반적인 셀(1x1)을 만들어 내게 됩니다.
///이에따라서 block이 포함된 xOffset그리고 정상적으로 크기가 1씩 증가한 yOffset이 생성되고 이는 zip연산을 통하여 합쳐지는
///동시에 filter를 거쳐 block이 포함된 offset은 뛰어넘게되고 마지막으로 나온 x,yOffset이 튜플 형태로 그리고 zippedBucket
///에 담겨서 전부 return되게 됩니다.


import UIKit

struct OffsetPointer {
    
    ///offset을 생성할 때 참조하는 xOffset을 담아놓은 배열입니다.
    private var referenceColumn: [Int]
    
    ///zip연산을 하기전에 x,yOffset를 담아놓는 배열입니다.
    private var xOffsetBucket: [[Int]] = []
    private var yOffsetBucket: [[Int]] = []
    
    ///2x2 셀이 들어왔을 경우 다음 row에서는 xOffset을 한번 건너뛰어야 하므로 이를 판별하는 Bool 프로퍼티입니다.
    private var isNextRowFreezed = false
    
    ///생성시 현재 x,yOffset를 가르키는 포인터입니다.
    private var xOffsetPointer = 0
    private var yOffsetPointer = 0
    
    ///레이아웃은 기본적으로 2x2셀이 왼쪽에 오는 경우와 오른쪽에 오는 경우로 나뉘게 됩니다.
    ///이에따라 offset을 다르게 생성해야 하므로 이를 구분해주는 프로퍼티가 position이며 Position
    ///타입은 left, right 케이스가 있는 enum타입입니다.
    private var position: Position = .left
    
    ///2x2 셀이 생성시에 바로 뒤에오는 xOffset은 생성이 안되게끔 막아줘야합니다. 이를 위해서 만든것이
    ///block 프로퍼티입니다.
    private let block = -1
    
    init(numberOfColums: Int, yOffset: Int) {
        self.yOffsetPointer = yOffset
        self.referenceColumn = Array(repeating: 0, count: numberOfColums)
        for index in 0..<numberOfColums {
            self.referenceColumn[index] = index
        }
    }
    
    
    /// 구조체 내부 메서드를 이용하여 offset을 구하고 유효한 offset(block이 없는) 만을 zip연산, filter연산
    /// 을거쳐서 리턴합니다. x,yOffset을 합칠 때 block 여부를 filter로 확인하고 block된 것이 있다면 그 좌표는 append하지
    /// 않습니다.
    ///
    /// - Parameters:
    ///   - count: 한번에 만들어낼 offset의 갯수입니다. batchSize와 동일합니다.
    ///   - freezeAt: 2x2셀을 만들어낼 offset의 index입니다.
    /// - Returns: 유효한 offset(block이 없는)을 연산을 거쳐서 배열에 담아 return합니다.
    mutating func getOffsets(count: Int, freezeAt number: Int) -> [(CGFloat, CGFloat)]{
        calculateOffsets(count: count, freezeAt: number)
        var zippedBucket: [(CGFloat, CGFloat)] = []
        for index in 0..<xOffsetBucket.count - 1 {
            Array(zip(xOffsetBucket[index],yOffsetBucket[index]))
                .filter{
                    $0.0 != block
                }
                .forEach {
                    let transformedTuple = (CGFloat($0.0), CGFloat($0.1))
                    zippedBucket.append(transformedTuple)
            }
        }
        return zippedBucket
    }
    
    
    /// isNextRowFreezed 상태인 프로퍼티를 false로 돌리고 referenceColumn을 정상상태로 돌려놓습니다.
    private mutating func restore() {
        isNextRowFreezed = false
        for index in 0..<referenceColumn.count {
            self.referenceColumn[index] = index
        }
    }
    
    
    /// 현재 컬럼을 가르키는 xOffsetPointer를 이용하여 referenceColumn의 값을 block(-1)로
    /// 바꾸어 이를 통해 연산하는 offset이 반영되지 않도록 합니다. 또한 다음 row에 영향을 주기 위해
    /// isNextRowFreezed의 값을 true 로 변경합니다.
    private mutating func freeze() {
        referenceColumn[xOffsetPointer] = block
        isNextRowFreezed = true
    }
    
    
    /// freeze해야하는 index가 left인지 right인지 확인한 후 인자로 받은 계산할 아이템의 갯수만큼
    /// 루프를 돌며 row가 바뀔때마다 referenceColumn과 yOffset값들을 배열에 추가하고 이후 yOffset
    /// 값을 1 올립니다. 또한 isNextRowFreezed 상태일때 left, right값에 따라서 특정 offset을
    /// block 합니다. 이후 restore() 메서드를 이용하여 다시 원래대로 돌려줍니다.
    ///
    /// - Parameters:
    ///   - count: 한번에 만들어낼 offset의 갯수입니다. batchSize와 동일합니다.
    ///   - freezeAt: 2x2셀을 만들어낼 offset의 index입니다.
    /// - Returns:
    private mutating func calculateOffsets(count: Int, freezeAt: Int) {
        if freezeAt % 3 == 0 { position = .left } else {
            position = .right
        }
        for number in 0..<count {
            
            if (referenceColumn.count - 1) == xOffsetPointer {
                xOffsetBucket.append(referenceColumn)
                yOffsetBucket.append(Array(repeating: yOffsetPointer, count: 3))
                yOffsetPointer = yOffsetPointer + 1
                
            }
            
            if (referenceColumn.count - 1) == xOffsetPointer && isNextRowFreezed {
                
                switch position {
                case .left:
                    referenceColumn[0] = block
                    xOffsetBucket.append(referenceColumn)
                    restore()
                case .right:
                    referenceColumn[xOffsetPointer] = block
                    referenceColumn[xOffsetPointer - 1] = block
                    xOffsetBucket.append(referenceColumn)
                    restore()
                }
            }
            
            xOffsetPointer = xOffsetPointer < (referenceColumn.count - 1) ?
                (xOffsetPointer + 1) : 0
            
            if number == freezeAt {
                freeze()
            }
        }
    }
}
