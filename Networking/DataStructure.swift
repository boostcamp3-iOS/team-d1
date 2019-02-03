//
//  DataStructure.swift
//  BeBrav
//
//  Created by bumslap on 03/02/2019.
//  Copyright © 2019 bumslap. All rights reserved.
//

import Foundation
/*
 root - users - UID - uid
                    - nickName
                    - email
                    - userProfile_url
                    - artworks          - artwork_uid - artwork_uid
                                                      - artwork_url
                                                      - title
                                                      - timestamp
                                                      - views
              - UID - uid
                    - nickName
                    - email
                    - userProfile_url
                    - artworks          - artwork_uid - artwork_uid
                                                      - artwork_url
                                                      - title
                                                      - timestamp
                                                      - views
 
 
 유저 회원가입시 -> 성공시에 UID를 리턴 받아서 그 UID를 Key로 하고 이하 children 까지 해서 patch
 한다.
 
 아트웍 업로드시 -> 먼저 post 로 전체 데이터를 업로드하면 uid를 얻을수 있고 성공시에 uid 
 
 
 
 */
