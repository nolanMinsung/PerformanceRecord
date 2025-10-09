//
//  Constant.swift
//  Muyeon
//
//  Created by 김민성 on 9/28/25.
//

import Foundation

// MARK: - OPEN API 공통 코드

/**
 * 공연/예매 정보 관련 OPEN API에서 사용되는 공통 코드
 * (데이터 불변을 가정하고 구현되었음.)
 */


enum Constant {
    
    // MARK: - 공연상태 코드 (Performance Status Code)
    
    /// 공연 상태를 나타내는 코드
    enum PerformanceState: String, CaseIterable, Codable {
        /// 공연 예정 (Code: 01)
        case scheduled = "01"
        /// 공연 중 (Code: 02)
        case ongoing = "02"
        /// 공연 완료 (Code: 03)
        case completed = "03"
        /// 기타 (파싱에 실패했을 경우)
        case unknown = "00"
        
        /// 코드 설명
        var description: String {
            switch self {
            case .scheduled: return "공연예정"
            case .ongoing: return "공연중"
            case .completed: return "공연완료"
            case .unknown: return "알 수 없음"
            }
        }
        
        static func findBy(name: String) -> Self {
            switch name {
            case "공연예정": return .scheduled
            case "공연중": return .ongoing
            case "공연완료": return .completed
            default: return .unknown
            }
        }
        
    }
    
    // MARK: - 장르 코드 (Genre Code)
    
    /// 공연 장르를 나타내는 코드
    enum Genre: String, CaseIterable, Codable, Equatable {
        /// 연극 (Code: AAAA)
        case play = "AAAA"
        /// 무용(서양/한국무용) (Code: BBBC)
        case danceWesternKorean = "BBBC"
        /// 대중무용 (Code: BBBE)
        case popularDance = "BBBE"
        /// 서양음악(클래식) (Code: CCCA)
        case classicalMusic = "CCCA"
        /// 한국음악(국악) (Code: CCCC"
        case koreanTraditionalMusic = "CCCC"
        /// 대중음악 (Code: CCCD)
        case popularMusic = "CCCD"
        /// 복합 (Code: EEEA)
        case composite = "EEEA"
        /// 서커스/마술 (Code: EEEB)
        case circusMagic = "EEEB"
        /// 뮤지컬 (Code: GGGA)
        case musical = "GGGA"
        /// 기타 (파싱에 실패했을 경우)
        case unknown = "0000"
        
        /// 코드 설명 (장르명)
        var description: String {
            switch self {
            case .play: return "연극"
            case .danceWesternKorean: return "무용(서양/한국무용)"
            case .popularDance: return "대중무용"
            case .classicalMusic: return "서양음악(클래식)"
            case .koreanTraditionalMusic: return "한국음악(국악)"
            case .popularMusic: return "대중음악"
            case .composite: return "복합"
            case .circusMagic: return "서커스/마술"
            case .musical: return "뮤지컬"
            case .unknown: return "기타"
            }
        }
        
        static func findBy(name: String) -> Self {
            switch name {
            case "연극": return .play
            case "무용(서양/한국무용)": return .danceWesternKorean
            case "대중무용": return .popularDance
            case "서양음악(클래식)": return .classicalMusic
            case "한국음악(국악)": return .koreanTraditionalMusic
            case "대중음악": return .popularMusic
            case "복합": return .composite
            case "서커스/마술": return .circusMagic
            case "뮤지컬": return .musical
            default: return .unknown
            }
        }
        
    }
    
    // MARK: - 공연시설특성 코드 (Facility Characteristic Code)
    
    /// 공연 시설의 특성을 나타내는 코드
    enum FacilityCharacteristic: String, CaseIterable, Codable {
        /// 중앙정부 (Code: 1)
        case centralGovernment = "1"
        /// 문예회관 (Code: 2)
        case cultureArtCenter = "2"
        /// 기타(공공) (Code: 3)
        case otherPublic = "3"
        /// 대학로 (Code: 4)
        case daehakro = "4"
        /// 민간(대학로 외) (Code: 5)
        case privateNonDaehakro = "5"
        /// 기타(해외등) (Code: 6)
        case otherOverseasEtc = "6"
        /// 기타(비공연장) (Code: 7)
        case otherNonPerformanceVenue = "7"
        /// 기타(파싱에 실패했을 경우) (임시 Code: 0)
        case unknown = "0"
        
        /// 코드 설명
        var description: String {
            switch self {
            case .centralGovernment: return "중앙정부"
            case .cultureArtCenter: return "문예회관"
            case .otherPublic: return "기타(공공)"
            case .daehakro: return "대학로"
            case .privateNonDaehakro: return "민간(대학로 외)"
            case .otherOverseasEtc: return "기타(해외등)"
            case .otherNonPerformanceVenue: return "기타(비공연장)"
            case .unknown: return "기타"
            }
        }
        
        static func findBy(name: String) -> Self {
            switch name {
            case "중앙정부": return .centralGovernment
            case "문예회관": return .cultureArtCenter
            case "기타(공공)": return .otherPublic
            case "대학로": return .daehakro
            case "민간(대학로 외)": return .privateNonDaehakro
            case "기타(해외등)": return .otherOverseasEtc
            case "기타(비공연장)": return .otherNonPerformanceVenue
            default: return .unknown
            }
        }
    }
    
    // MARK: - 날짜 코드 (Date Code)
    
    /// 통계/조회 등에 사용되는 날짜 구분 코드
    enum DateType: String, CaseIterable, Codable {
        /// 월별 (Code: month)
        case month = "month"
        /// 주별 (Code: week)
        case week = "week"
        /// 일별 (Code: day)
        case day = "day"
        
        /// 코드 설명
        var description: String {
            switch self {
            case .month: return "월별"
            case .week: return "주별"
            case .day: return "일별"
            }
        }
    }
    
    // MARK: - 장르 구분 코드 (예매상황판용)
    
    /// 예매 상황판에서 사용되는 장르 구분 코드
    enum BoxOfficeGenre: String, CaseIterable, Codable {
        /// 연극 (Code: AAAA)
        case play = "AAAA"
        /// 뮤지컬 (Code: GGGA)
        case musical = "GGGA"
        /// 서양음악(클래식) (Code: CCCA)
        case classicalMusic = "CCCA"
        /// 한국음악(국악) (Code: CCCC)
        case koreanTraditionalMusic = "CCCC"
        /// 대중음악 (Code: CCCD)
        case popularMusic = "CCCD"
        /// 무용(서양/한국무용) (Code: BBBC)
        case danceWesternKorean = "BBBC"
        /// 대중무용 (Code: BBBR)
        case popularDance = "BBBR"
        /// 서커스/마술 (Code: EEEB)
        case circusMagic = "EEEB"
        /// 복합 (Code: EEEA)
        case composite = "EEEA"
        /// 아동 (Code: KID)
        case children = "KID"
        /// 오픈런 (Code: OPEN)
        case openRun = "OPEN"
        /// 기타 (파싱에 실패했을 경우)
        case unknown = "0000"
        
        /// 코드 설명 (장르명/구분명)
        var description: String {
            switch self {
            case .play: return "연극"
            case .musical: return "뮤지컬"
            case .classicalMusic: return "서양음악(클래식)"
            case .koreanTraditionalMusic: return "한국음악(국악)"
            case .popularMusic: return "대중음악"
            case .danceWesternKorean: return "무용(서양/한국무용)"
            case .popularDance: return "대중무용"
            case .circusMagic: return "서커스/마술"
            case .composite: return "복합"
            case .children: return "아동"
            case .openRun: return "오픈런"
            case .unknown: return "기타"
            }
        }
        
        static func findBy(name: String) -> Self {
            switch name {
            case "연극":
                return .play
            case "뮤지컬":
                return .musical
            case "서양음악(클래식)":
                return .classicalMusic
            case "한국음악(국악)":
                return .koreanTraditionalMusic
            case "대중음악":
                return .popularMusic
            case "무용(서양/한국무용)":
                return .danceWesternKorean
            case "대중무용":
                return .popularDance
            case "서커스/마술":
                return .circusMagic
            case "복합":
                return .composite
            case "아동":
                return .children
            case "오픈런":
                return .openRun
            default:
                return .unknown
            }
        }
    }
    
    // MARK: - 좌석 규모 코드 (예매상황판용)
    
    /// 예매 상황판에서 사용되는 좌석 규모 코드
    enum BoxOfficeSeatScale: String, CaseIterable, Codable {
        /// 0석(미상) (Code: 0)
        case unknown = "0"
        /// 1~300석 미만 (Code: 100)
        case scaleUnder300 = "100"
        /// 300~500석 미만 (Code: 300)
        case scale300To500 = "300"
        /// 500~1000석 미만 (Code: 500)
        case scale500To1000 = "500"
        /// 1000~5000석 미만 (Code: 1000)
        case scale1000To5000 = "1000"
        /// 5000~10000석 미만 (Code: 5000)
        case scale5000To10000 = "5000"
        /// 10000석 이상 (Code: 10000)
        case scaleOver10000 = "10000"
        
        /// 코드 설명
        var description: String {
            switch self {
            case .unknown: return "0석(미상)"
            case .scaleUnder300: return "1~300석 미만"
            case .scale300To500: return "300~500석 미만"
            case .scale500To1000: return "500~1000석 미만"
            case .scale1000To5000: return "1000~5000석 미만"
            case .scale5000To10000: return "5000~10000석 미만"
            case .scaleOver10000: return "10000석 이상"
            }
        }
    }
    
    // MARK: - 지역(시도) 코드 (예매상황판용)
    
    /// 예매 상황판에서 사용되는 시/도 지역 코드
    enum BoxOfficeArea: String, CaseIterable, Codable {
        /// 서울 (Code: 11)
        case seoul = "11"
        /// 인천 (Code: 28)
        case incheon = "28"
        /// 대전 (Code: 30)
        case daejeon = "30"
        /// 대구 (Code: 27)
        case daegu = "27"
        /// 광주 (Code: 29)
        case gwangju = "29"
        /// 부산 (Code: 26)
        case busan = "26"
        /// 울산 (Code: 31)
        case ulsan = "31"
        /// 세종 (Code: 36)
        case sejong = "36"
        /// 경기 (Code: 41)
        case gyeonggi = "41"
        /// 충청북도(Code: 43)
        case chungcheongbuk = "43"
        /// 충청남도(Code: 44)
        case chungcheongnam = "44"
        /// 전라북도(Code: 45)
        case jeollabuk = "45"
        /// 전라남도(Code: 46)
        case jeollanam = "46"
        /// 경상북도(Code: 47)
        case gyeongsangbuk = "47"
        /// 경상남도(Code: 48)
        case gyeongsangnam = "48"
        /// 강원 (Code: 51)
        case gangwon = "51"
        /// 제주 (Code: 50)
        case jeju = "50"
        /// 대학로 (Code: UNI)
        case daehakro = "UNI"
        /// 기타 (파싱에 실패했을 경우)
        case unknown = "기타"
        
        /// 코드 설명 (지역명)
        var description: String {
            switch self {
            case .seoul: return "서울"
            case .incheon: return "인천"
            case .daejeon: return "대전"
            case .daegu: return "대구"
            case .gwangju: return "광주"
            case .busan: return "부산"
            case .ulsan: return "울산"
            case .sejong: return "세종"
            case .gyeonggi: return "경기"
            case .chungcheongbuk: return "충북"
            case .chungcheongnam: return "충남"
            case .jeollabuk: return "전북"
            case .jeollanam: return "전남"
            case .gyeongsangbuk: return "경북"
            case .gyeongsangnam: return "경남"
            case .gangwon: return "강원"
            case .jeju: return "제주"
            case .daehakro: return "대학로"
            case .unknown: return "기타"
            }
        }
        
        static func findBy(name: String) -> Self {
            switch name {
            case "서울": return .seoul
            case "인천": return .incheon
            case "대전": return .daejeon
            case "대구": return .daegu
            case "광주": return .gwangju
            case "부산": return .busan
            case "울산": return .ulsan
            case "세종": return .sejong
            case "경기": return .gyeonggi
            case "충북": return .chungcheongbuk
            case "충남": return .chungcheongnam
            case "전북": return .jeollabuk
            case "전남": return .jeollanam
            case "경북": return .gyeongsangbuk
            case "경남": return .gyeongsangnam
            case "강원": return .gangwon
            case "제주": return .jeju
            case "대학로": return .daehakro
            default: return .unknown
            }
        }
    }
    
    // MARK: - 지역(시도) 코드 (행정표준코드 앞 2자리)
    
    /// 행정 표준 코드 앞 2자리를 사용하는 시/도 지역 코드
    enum AdminAreaCode: String, CaseIterable, Codable {
        case seoul = "11" // 서울특별시
        case busan = "26" // 부산광역시
        case daegu = "27" // 대구광역시
        case incheon = "28" // 인천광역시
        case gwangju = "29" // 광주광역시
        case daejeon = "30" // 대전광역시
        case ulsan = "31" // 울산광역시
        case sejong = "36" // 세종특별자치시
        case gyeonggi = "41" // 경기도
        case gangwonSpecialSelfGoverning = "51" // 강원특별자치도
        case chungcheongbuk = "43" // 충청북도
        case chungcheongnam = "44" // 충청남도
        case jeollabuk = "45" // 전라북도
        case jeollanam = "46" // 전라남도
        case gyeongsangbuk = "47" // 경상북도
        case gyeongsangnam = "48" // 경상남도
        case jejuSpecialSelfGoverning = "50" // 제주특별자치도
        case unknown = "00" // 기타 (파싱에 실패했을 경우)
        
        /// 코드 설명 (시/도명)
        var description: String {
            switch self {
            case .seoul: return "서울특별시"
            case .busan: return "부산광역시"
            case .daegu: return "대구광역시"
            case .incheon: return "인천광역시"
            case .gwangju: return "광주광역시"
            case .daejeon: return "대전광역시"
            case .ulsan: return "울산광역시"
            case .sejong: return "세종특별자치시"
            case .gyeonggi: return "경기도"
            case .gangwonSpecialSelfGoverning: return "강원특별자치도"
            case .chungcheongbuk: return "충청북도"
            case .chungcheongnam: return "충청남도"
            case .jeollabuk: return "전라북도"
            case .jeollanam: return "전라남도"
            case .gyeongsangbuk: return "경상북도"
            case .gyeongsangnam: return "경상남도"
            case .jejuSpecialSelfGoverning: return "제주특별자치도"
            case .unknown: return "기타"
            }
        }
        
        static func findBy(name: String) -> Self {
            switch name {
            case "서울특별시": return .seoul
            case "부산광역시": return .busan
            case "대구광역시": return .daegu
            case "인천광역시": return .incheon
            case "광주광역시": return .gwangju
            case "대전광역시": return .daejeon
            case "울산광역시": return .ulsan
            case "세종특별자치시": return .sejong
            case "경기도": return .gyeonggi
            case "강원특별자치도": return .gangwonSpecialSelfGoverning
            case "충청북도": return .chungcheongbuk
            case "충청남도": return .chungcheongnam
            case "전라북도": return .jeollabuk
            case "전라남도": return .jeollanam
            case "경상북도": return .gyeongsangbuk
            case "경상남도": return .gyeongsangnam
            case "제주특별자치도": return .jejuSpecialSelfGoverning
            default: return .unknown
            }
        }
    }
    
    
    // MARK: - 지역(구군) 코드 (행정표준코드 앞 2자리)
    
    /// 행정 표준 코드 앞 4자리를 사용하는 지역(구군) 코드
    /// 우선순위는 아니므로 일단 일부만 표시
    enum AdminDistrictCode: String, CaseIterable, Codable {
        // 서울특별시
        case jongnoGu = "1111" // 서울특별시 종로구
        case jungGuSeoul = "1114" // 서울특별시 중구
        case yongsanGu = "1117" // 서울특별시 용산구
        // ... (나머지 서울시 구군 생략)
        case gangdongGu = "1174" // 서울특별시 강동구
        
        // 부산광역시
        case busanMetropolitanCity = "2600" // 부산광역시
        case jungGuBusan = "2611" // 부산광역시 중구
        // ... (나머지 부산시 구군 생략)
        case gijangGun = "2671" // 부산광역시 기장군
        
        // 대구광역시
        case daeguMetropolitanCity = "2700" // 대구광역시
        case jungGuDaegu = "2711" // 대구광역시 중구
        // ... (나머지 대구시 구군 생략)
        case dalseongGun = "2771" // 대구광역시 달성군
        
        // 인천광역시
        case incheonMetropolitanCity = "2800" // 인천광역시
        case jungGuIncheon = "2811" // 인천광역시 중구
        // ... (나머지 인천시 구군 생략)
        case ongjinGun = "2872" // 인천광역시 옹진군
        
        // 광주광역시
        case gwangjuMetropolitanCity = "2900" // 광주광역시
        case dongGuGwangju = "2911" // 광주광역시 동구
        // ... (나머지 광주시 구군 생략)
        case gwangsanGu = "2920" // 광주광역시 광산구
        
        // 대전광역시
        case daejeonMetropolitanCity = "3000" // 대전광역시
        case dongGuDaejeon = "3011" // 대전광역시 동구
        // ... (나머지 대전시 구군 생략)
        case daedeokGu = "3023" // 대전광역시 대덕구
        
        // 울산광역시
        case ulsanMetropolitanCity = "3100" // 울산광역시
        case jungGuUlsan = "3111" // 울산광역시 중구
        // ... (나머지 울산시 구군 생략)
        case uljuGun = "3171" // 울산광역시 울주군
        
        // 세종특별자치시
        case sejongSpecialSelfGoverningCity = "3600" // 세종특별자치시
        case sejongCity = "3611" // 세종특별자치시
        
        // 경기도
        case gyeonggiProvince = "4100" // 경기도
        case suwonCityGyeonggi = "4111" // 경기도 수원시
        // ... (나머지 경기도 시군 생략)
        case yangpyeongGun = "4183" // 경기도 양평군
        
        // 강원특별자치도
        case gangwonSpecialSelfGoverningProvince = "5100" // 강원특별자치도
        case chuncheonCity = "5111" // 강원특별자치도 춘천시
        // ... (나머지 강원특별자치도 시군 생략)
        case yangyangGun = "5183" // 강원특별자치도 양양군
        
        // 충청북도
        case chungcheongbukProvince = "4300" // 충청북도
        case cheongjuCity = "4311" // 충청북도 청주시
        // ... (나머지 충청북도 시군 생략)
        case danyangGun = "4380" // 충청북도 단양군
        
        // 충청남도
        case chungcheongnamProvince = "4400" // 충청남도
        case cheonanCity = "4413" // 충청남도 천안시
        // ... (나머지 충청남도 시군 생략)
        case taeanGun = "4482" // 충청남도 태안군
        
        // 전라북도
        case jeollabukProvince = "4500" // 전라북도
        case jeonjuCity = "4511" // 전라북도 전주시
        // ... (나머지 전라북도 시군 생략)
        case buanGun = "4580" // 전라북도 부안군
        
        // 전라남도
        case jeollanamProvince = "4600" // 전라남도
        case mokpoCity = "4611" // 전라남도 목포시
        // ... (나머지 전라남도 시군 생략)
        case sinanGun = "4691" // 전라남도 신안군
        
        // 경상북도
        case gyeongsangbukProvince = "4700" // 경상북도
        case pohangCity = "4711" // 경상북도 포항시
        // ... (나머지 경상북도 시군 생략)
        case ulleungGun = "4794" // 경상북도 울릉군
        
        // 경상남도
        case gyeongsangnamProvince = "4800" // 경상남도
        case changwonCity = "4812" // 경상남도 창원시
        // ... (나머지 경상남도 시군 생략)
        case hapcheonGun = "4889" // 경상남도 합천군
        
        // 제주특별자치도
        case jejuSpecialSelfGoverningProvince = "5000" // 제주특별자치도
        case jejuCity = "5011" // 제주특별자치도 제주시
        case seogwipoCity = "5013" // 제주특별자치도 서귀포시
        
        /// 코드 설명 (지역명/구군명)
        var description: String {
            switch self {
            case .jongnoGu: return "서울특별시종로구"
            case .jungGuSeoul: return "서울특별시중구"
            case .yongsanGu: return "서울특별시용산구"
                // ... (모든 case에 대한 description 구현 필요)
            case .gangdongGu: return "서울특별시강동구"
            case .busanMetropolitanCity: return "부산광역시"
            case .jungGuBusan: return "부산광역시중구"
            case .gijangGun: return "부산광역시기장군"
            case .daeguMetropolitanCity: return "대구광역시"
            case .jungGuDaegu: return "대구광역시중구"
            case .dalseongGun: return "대구광역시달성군"
            case .incheonMetropolitanCity: return "인천광역시"
            case .jungGuIncheon: return "인천광역시중구"
            case .ongjinGun: return "인천광역시옹진군"
            case .gwangjuMetropolitanCity: return "광주광역시"
            case .dongGuGwangju: return "광주광역시동구"
            case .gwangsanGu: return "광주광역시광산구"
            case .daejeonMetropolitanCity: return "대전광역시"
            case .dongGuDaejeon: return "대전광역시동구"
            case .daedeokGu: return "대전광역시대덕구"
            case .ulsanMetropolitanCity: return "울산광역시"
            case .jungGuUlsan: return "울산광역시중구"
            case .uljuGun: return "울산광역시울주군"
            case .sejongSpecialSelfGoverningCity: return "세종특별자치시"
            case .sejongCity: return "세종특별자치시"
            case .gyeonggiProvince: return "경기도"
            case .suwonCityGyeonggi: return "경기도수원시"
            case .yangpyeongGun: return "경기도양평군"
            case .gangwonSpecialSelfGoverningProvince: return "강원특별자치도"
            case .chuncheonCity: return "강원특별자치도춘천시"
            case .yangyangGun: return "강원특별자치도양양군"
            case .chungcheongbukProvince: return "충청북도"
            case .cheongjuCity: return "충청북도청주시"
            case .danyangGun: return "충청북도단양군"
            case .chungcheongnamProvince: return "충청남도"
            case .cheonanCity: return "충청남도천안시"
            case .taeanGun: return "충청남도태안군"
            case .jeollabukProvince: return "전라북도"
            case .jeonjuCity: return "전라북도전주시"
            case .buanGun: return "전라북도부안군"
            case .jeollanamProvince: return "전라남도"
            case .mokpoCity: return "전라남도목포시"
            case .sinanGun: return "전라남도신안군"
            case .gyeongsangbukProvince: return "경상북도"
            case .pohangCity: return "경상북도포항시"
            case .ulleungGun: return "경상북도울릉군"
            case .gyeongsangnamProvince: return "경상남도"
            case .changwonCity: return "경상남도창원시"
            case .hapcheonGun: return "경상남도합천군"
            case .jejuSpecialSelfGoverningProvince: return "제주특별자치도"
            case .jejuCity: return "제주특별자치도제주시"
            case .seogwipoCity: return "제주특별자치도서귀포시"
            // default: return "알 수 없는 지역"
            }
        }
        
    }
    
}
