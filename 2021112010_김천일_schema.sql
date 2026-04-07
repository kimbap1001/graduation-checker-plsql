--데이터베이스 초기화
DROP TABLE major CASCADE CONSTRAINTS;  
DROP TABLE student CASCADE CONSTRAINTS;  
DROP TABLE grad_rqmt CASCADE CONSTRAINTS;  
DROP TABLE course CASCADE CONSTRAINTS;  
DROP TABLE enroll CASCADE CONSTRAINTS;  
DROP TABLE course_rqmt CASCADE CONSTRAINTS;  

-- 1. 학과 (MAJOR) 테이블
CREATE TABLE MAJOR (
    mid     VARCHAR2(10)    NOT NULL,
    mname   VARCHAR2(30)    NOT NULL,
    CONSTRAINT PK_MAJOR PRIMARY KEY (mid),
    CONSTRAINT UK_MAJOR_NAME UNIQUE (mname)
);

INSERT INTO MAJOR (mid, mname) VALUES ('csc', '컴퓨터공학과');


-- 2. 학생 (STUDENT) 테이블 
CREATE TABLE STUDENT (
    sid         VARCHAR2(10)    NOT NULL, 
    sname       VARCHAR2(20)    NOT NULL,
    mid         VARCHAR2(10)    NOT NULL,
    tot_credit  NUMBER          DEFAULT 0,
    maj_credit  NUMBER          DEFAULT 0,
    CONSTRAINT PK_STUDENT PRIMARY KEY (sid),
    CONSTRAINT FK_STU_MAJOR FOREIGN KEY (mid) REFERENCES MAJOR (mid)
);

INSERT INTO STUDENT (sid, sname, mid) VALUES ('2021000001', '김천일', 'csc');
INSERT INTO STUDENT (sid, sname, mid) VALUES ('2021000002', '손승현', 'csc');
INSERT INTO STUDENT (sid, sname, mid) VALUES ('2021000003', '공기훈', 'csc');
INSERT INTO STUDENT (sid, sname, mid) VALUES ('2021000004', '황윤수', 'csc');
INSERT INTO STUDENT (sid, sname, mid) VALUES ('2021000005', '이시우', 'csc');
INSERT INTO STUDENT (sid, sname, mid) VALUES ('2021000006', '정유현', 'csc');


-- 3. 졸업요건 (GRAD_RGMT) 테이블
CREATE TABLE GRAD_RGMT (
    mid          VARCHAR2(10)    NOT NULL, 
    totalCredit  NUMBER          DEFAULT 0 NOT NULL,
    majorCredit  NUMBER          DEFAULT 0 NOT NULL,
    engCourse    NUMBER          DEFAULT 0 NOT NULL,
    CONSTRAINT PK_GRAD_RGMT PRIMARY KEY (mid),
    CONSTRAINT FK_GRAD_MAJOR FOREIGN KEY (mid) REFERENCES MAJOR (mid)
);

INSERT INTO GRAD_RGMT (mid, totalCredit, majorCredit, engCourse) VALUES ('csc', 60, 40, 4);


-- 4. 과목 (COURSE) 테이블
CREATE TABLE COURSE (
    cid      VARCHAR2(10)    NOT NULL, 
    cname    VARCHAR2(30)    NOT NULL,
    credit   NUMBER          NOT NULL,
    isMajor  CHAR(1)         NOT NULL, 
    isEng    CHAR(1)         NOT NULL, 
    CONSTRAINT PK_COURSE PRIMARY KEY (cid),
    CONSTRAINT CK_CRS_CREDIT CHECK (credit > 0),
    CONSTRAINT CK_CRS_MAJOR CHECK (isMajor IN ('Y', 'N')), 
    CONSTRAINT CK_CRS_ENG CHECK (isEng IN ('Y', 'N'))
);

INSERT INTO COURSE (cid, cname, credit, isMajor, isEng) VALUES ('csc001', '기초프로그래밍', 3, 'Y', 'N');
INSERT INTO COURSE (cid, cname, credit, isMajor, isEng) VALUES ('csc002', '알고리즘', 3, 'Y', 'N');
INSERT INTO COURSE (cid, cname, credit, isMajor, isEng) VALUES ('csc003', '자료구조', 3, 'Y', 'N');
INSERT INTO COURSE (cid, cname, credit, isMajor, isEng) VALUES ('csc004', '이산구조', 3, 'Y', 'N');
INSERT INTO COURSE (cid, cname, credit, isMajor, isEng) VALUES ('csc005', '데이터베이스', 3, 'Y', 'N');
INSERT INTO COURSE (cid, cname, credit, isMajor, isEng) VALUES ('csc006', '운영체제', 3, 'Y', 'Y');
INSERT INTO COURSE (cid, cname, credit, isMajor, isEng) VALUES ('csc007', '소프트웨어공학', 3, 'Y', 'N');
INSERT INTO COURSE (cid, cname, credit, isMajor, isEng) VALUES ('csc008', '컴퓨터구성', 3, 'Y', 'N');
INSERT INTO COURSE (cid, cname, credit, isMajor, isEng) VALUES ('csc009', '컴퓨터구조', 3, 'Y', 'N');
INSERT INTO COURSE (cid, cname, credit, isMajor, isEng) VALUES ('csc010', '객체지향프로그래밍', 3, 'Y', 'N');
INSERT INTO COURSE (cid, cname, credit, isMajor, isEng) VALUES ('csc011', '시스템소프트웨어', 3, 'Y', 'N');
INSERT INTO COURSE (cid, cname, credit, isMajor, isEng) VALUES ('csc012', '임베디드', 3, 'Y', 'N');
INSERT INTO COURSE (cid, cname, credit, isMajor, isEng) VALUES ('csc013', '인공지능', 3, 'Y', 'N');
INSERT INTO COURSE (cid, cname, credit, isMajor, isEng) VALUES ('csc014', '네트워크', 3, 'Y', 'Y');
INSERT INTO COURSE (cid, cname, credit, isMajor, isEng) VALUES ('csc015', '종합설계1', 3, 'Y', 'Y');
INSERT INTO COURSE (cid, cname, credit, isMajor, isEng) VALUES ('csc016', '종합설계2', 3, 'Y', 'Y');
INSERT INTO COURSE (cid, cname, credit, isMajor, isEng) VALUES ('pri001', '미적분학1', 3, 'N', 'N');
INSERT INTO COURSE (cid, cname, credit, isMajor, isEng) VALUES ('pri002', '미적분학2', 3, 'N', 'N');
INSERT INTO COURSE (cid, cname, credit, isMajor, isEng) VALUES ('pri003', '생물학개론', 3, 'N', 'N');
INSERT INTO COURSE (cid, cname, credit, isMajor, isEng) VALUES ('pri004', '지구환경과학', 3, 'N', 'N');
INSERT INTO COURSE (cid, cname, credit, isMajor, isEng) VALUES ('pri005', '공학윤리', 3, 'N', 'N');
INSERT INTO COURSE (cid, cname, credit, isMajor, isEng) VALUES ('pri006', '공학경제', 3, 'N', 'N');


-- 5. 수강 (ENROLL) 테이블
CREATE TABLE ENROLL (
    sid     VARCHAR2(10)    NOT NULL, 
    cid     VARCHAR2(10)    NOT NULL, 
    grade   CHAR(1)         NOT NULL,
    CONSTRAINT PK_ENROLL PRIMARY KEY (sid, cid),
    CONSTRAINT FK_ENR_STU FOREIGN KEY (sid) REFERENCES STUDENT (sid),
    CONSTRAINT FK_ENR_CRS FOREIGN KEY (cid) REFERENCES COURSE (cid),
    CONSTRAINT CK_ENR_GRADE CHECK (grade IN ('A', 'B', 'C', 'D', 'F'))
);

--수강을 등록할 때 학생 인스턴스의 총학점과 전공학점을 갱신하는 트리거
CREATE OR REPLACE TRIGGER TRG_ENROLL_INSERT
AFTER INSERT ON ENROLL
FOR EACH ROW
DECLARE
    v_credit  COURSE.credit%TYPE;
    v_isMajor COURSE.isMajor%TYPE;
BEGIN
    -- 1. F 학점이 아닐 경우에만 학점 계산 수행
    IF :new.grade <> 'F' THEN
        
        -- 2. 현재 등록하려는 과목의 학점과 전공 여부 조회
        SELECT credit, isMajor
        INTO   v_credit, v_isMajor
        FROM   COURSE
        WHERE  cid = :new.cid;

        -- 3. 학생 테이블 업데이트 (총 이수 학점, 전공 이수 학점)
        UPDATE STUDENT
        SET tot_credit = tot_credit + v_credit,
            -- 전공(Y)이면 학점을 더하고, 아니면 0을 더함
            maj_credit = maj_credit + (CASE WHEN v_isMajor = 'Y' THEN v_credit ELSE 0 END)
        WHERE sid = :new.sid;
        
    END IF;
END;
/

-- ==========================================================
-- 김천일 (2021000001) : 졸업 가능 (완벽한 케이스)
-- ==========================================================
-- 전략: 필수과목 12개(36학점) + 영어(네트워크) + 일반전공 2개 + 교양 5개 = 총 60학점
-- 영어강의: 운영체제, 종합1, 종합2, 네트워크 (4개 충족)

-- 필수 과목 (12개)
INSERT INTO ENROLL VALUES ('2021000001', 'csc001', 'A');
INSERT INTO ENROLL VALUES ('2021000001', 'csc002', 'A');
INSERT INTO ENROLL VALUES ('2021000001', 'csc003', 'A');
INSERT INTO ENROLL VALUES ('2021000001', 'csc004', 'A');
INSERT INTO ENROLL VALUES ('2021000001', 'csc005', 'A');
INSERT INTO ENROLL VALUES ('2021000001', 'csc006', 'A');
INSERT INTO ENROLL VALUES ('2021000001', 'csc007', 'A');
INSERT INTO ENROLL VALUES ('2021000001', 'csc008', 'A');
INSERT INTO ENROLL VALUES ('2021000001', 'csc010', 'A');
INSERT INTO ENROLL VALUES ('2021000001', 'csc011', 'A');
INSERT INTO ENROLL VALUES ('2021000001', 'csc015', 'A');
INSERT INTO ENROLL VALUES ('2021000001', 'csc016', 'A');

-- 추가 전공 (네트워크 포함)
INSERT INTO ENROLL VALUES ('2021000001', 'csc014', 'A');
INSERT INTO ENROLL VALUES ('2021000001', 'csc009', 'A');
INSERT INTO ENROLL VALUES ('2021000001', 'csc012', 'A');

-- 교양 (5개, 15학점)
INSERT INTO ENROLL VALUES ('2021000001', 'pri001', 'B');
INSERT INTO ENROLL VALUES ('2021000001', 'pri002', 'B');
INSERT INTO ENROLL VALUES ('2021000001', 'pri003', 'B');
INSERT INTO ENROLL VALUES ('2021000001', 'pri004', 'B');
INSERT INTO ENROLL VALUES ('2021000001', 'pri005', 'B');


-- ==========================================================
-- 손승현 (2021000002) : 총 학점 부족 (39학점)
-- ==========================================================
-- 전략: 필수과목 12개 + 네트워크(영어채움) + 컴퓨터구조 수강함.
-- 결과: 전공 42학점, 영어 4개, 필수는 충족했으나 총 학점(42) 미달

INSERT INTO ENROLL VALUES ('2021000002', 'csc001', 'B');
INSERT INTO ENROLL VALUES ('2021000002', 'csc002', 'B');
INSERT INTO ENROLL VALUES ('2021000002', 'csc003', 'B');
INSERT INTO ENROLL VALUES ('2021000002', 'csc004', 'B');
INSERT INTO ENROLL VALUES ('2021000002', 'csc005', 'B');
INSERT INTO ENROLL VALUES ('2021000002', 'csc006', 'B');
INSERT INTO ENROLL VALUES ('2021000002', 'csc007', 'B');
INSERT INTO ENROLL VALUES ('2021000002', 'csc008', 'B');
INSERT INTO ENROLL VALUES ('2021000002', 'csc009', 'A'); 
INSERT INTO ENROLL VALUES ('2021000002', 'csc010', 'B');
INSERT INTO ENROLL VALUES ('2021000002', 'csc011', 'B');
INSERT INTO ENROLL VALUES ('2021000002', 'csc015', 'B');
INSERT INTO ENROLL VALUES ('2021000002', 'csc016', 'B');
INSERT INTO ENROLL VALUES ('2021000002', 'csc014', 'B');


-- ==========================================================
-- 공기훈 (2021000003) : 전공 학점 부족 (36학점)
-- ==========================================================
-- 전략: 필수과목(36학점)만 딱 듣고 나머지는 전부 교양으로 채움.
-- 결과: 총학점 54(미달)이지만 특히 '전공 40학점' 기준 미달이 핵심

-- 필수 12개 (전공 36학점)
INSERT INTO ENROLL VALUES ('2021000003', 'csc001', 'C');
INSERT INTO ENROLL VALUES ('2021000003', 'csc002', 'C');
INSERT INTO ENROLL VALUES ('2021000003', 'csc003', 'C');
INSERT INTO ENROLL VALUES ('2021000003', 'csc004', 'C');
INSERT INTO ENROLL VALUES ('2021000003', 'csc005', 'C');
INSERT INTO ENROLL VALUES ('2021000003', 'csc006', 'C');
INSERT INTO ENROLL VALUES ('2021000003', 'csc007', 'C');
INSERT INTO ENROLL VALUES ('2021000003', 'csc008', 'C');
INSERT INTO ENROLL VALUES ('2021000003', 'csc010', 'C');
INSERT INTO ENROLL VALUES ('2021000003', 'csc011', 'C');
INSERT INTO ENROLL VALUES ('2021000003', 'csc015', 'C');
INSERT INTO ENROLL VALUES ('2021000003', 'csc016', 'C');

-- 교양 6개 (18학점)
INSERT INTO ENROLL VALUES ('2021000003', 'pri001', 'A');
INSERT INTO ENROLL VALUES ('2021000003', 'pri002', 'A');
INSERT INTO ENROLL VALUES ('2021000003', 'pri003', 'A');
INSERT INTO ENROLL VALUES ('2021000003', 'pri004', 'A');
INSERT INTO ENROLL VALUES ('2021000003', 'pri005', 'A');
INSERT INTO ENROLL VALUES ('2021000003', 'pri006', 'A');


-- ==========================================================
-- 황윤수 (2021000004) : 영어 강의 부족 (3개)
-- ==========================================================
-- 전략: 총학점, 전공, 필수는 다 채웠는데 '네트워크'를 안 듣고 일반 전공을 들음.
-- 영어강의: OS, 종합1, 종합2 (3개)

-- 필수 12개 (이 중 3개가 영어)
INSERT INTO ENROLL VALUES ('2021000004', 'csc001', 'B');
INSERT INTO ENROLL VALUES ('2021000004', 'csc002', 'B');
INSERT INTO ENROLL VALUES ('2021000004', 'csc003', 'B');
INSERT INTO ENROLL VALUES ('2021000004', 'csc004', 'B');
INSERT INTO ENROLL VALUES ('2021000004', 'csc005', 'B');
INSERT INTO ENROLL VALUES ('2021000004', 'csc006', 'B');
INSERT INTO ENROLL VALUES ('2021000004', 'csc007', 'B');
INSERT INTO ENROLL VALUES ('2021000004', 'csc008', 'B');
INSERT INTO ENROLL VALUES ('2021000004', 'csc010', 'B');
INSERT INTO ENROLL VALUES ('2021000004', 'csc011', 'B');
INSERT INTO ENROLL VALUES ('2021000004', 'csc015', 'B');
INSERT INTO ENROLL VALUES ('2021000004', 'csc016', 'B');

-- 일반 전공 추가 (영어 아님)
INSERT INTO ENROLL VALUES ('2021000004', 'csc009', 'A');
INSERT INTO ENROLL VALUES ('2021000004', 'csc012', 'A');

-- 교양 6개
INSERT INTO ENROLL VALUES ('2021000004', 'pri001', 'A');
INSERT INTO ENROLL VALUES ('2021000004', 'pri002', 'A');
INSERT INTO ENROLL VALUES ('2021000004', 'pri003', 'A');
INSERT INTO ENROLL VALUES ('2021000004', 'pri004', 'A');
INSERT INTO ENROLL VALUES ('2021000004', 'pri005', 'A');
INSERT INTO ENROLL VALUES ('2021000004', 'pri006', 'A');


-- ==========================================================
-- 이시우 (2021000005) : 필수 과목 미이수
-- ==========================================================
-- 전략: '알고리즘(csc002)'을 안 들음. 대신 네트워크(Eng)는 들어서 영어 조건은 맞춤.

-- 알고리즘(csc002) 제외한 필수 11개
INSERT INTO ENROLL VALUES ('2021000005', 'csc001', 'A');
INSERT INTO ENROLL VALUES ('2021000005', 'csc003', 'A');
INSERT INTO ENROLL VALUES ('2021000005', 'csc004', 'A');
INSERT INTO ENROLL VALUES ('2021000005', 'csc005', 'A');
INSERT INTO ENROLL VALUES ('2021000005', 'csc006', 'A');
INSERT INTO ENROLL VALUES ('2021000005', 'csc007', 'A');
INSERT INTO ENROLL VALUES ('2021000005', 'csc008', 'A');
INSERT INTO ENROLL VALUES ('2021000005', 'csc010', 'A');
INSERT INTO ENROLL VALUES ('2021000005', 'csc011', 'A');
INSERT INTO ENROLL VALUES ('2021000005', 'csc015', 'A');
INSERT INTO ENROLL VALUES ('2021000005', 'csc016', 'A');

-- 네트워크(Eng) 추가 -> 영어 4개 충족
INSERT INTO ENROLL VALUES ('2021000005', 'csc014', 'A'); 

-- 학점 채우기용 전공/교양
INSERT INTO ENROLL VALUES ('2021000005', 'csc009', 'A');
INSERT INTO ENROLL VALUES ('2021000005', 'pri001', 'A');
INSERT INTO ENROLL VALUES ('2021000005', 'pri002', 'A');
INSERT INTO ENROLL VALUES ('2021000005', 'pri003', 'A');
INSERT INTO ENROLL VALUES ('2021000005', 'pri004', 'A');
INSERT INTO ENROLL VALUES ('2021000005', 'pri005', 'A');


-- ==========================================================
-- 정유현 (2021000006) : F 학점으로 인한 졸업 불가
-- ==========================================================
-- 전략: 1번 김천일과 똑같이 수강신청을 했으나, 핵심 과목들에 'F'를 받음.
-- 결과: 역정규화된 학점 계산 시 F가 빠져서 학점 부족 발생 예정

-- 필수 과목 중 일부 F 처리
INSERT INTO ENROLL VALUES ('2021000006', 'csc001', 'F');
INSERT INTO ENROLL VALUES ('2021000006', 'csc002', 'F');
INSERT INTO ENROLL VALUES ('2021000006', 'csc003', 'F');
INSERT INTO ENROLL VALUES ('2021000006', 'csc004', 'A');
INSERT INTO ENROLL VALUES ('2021000006', 'csc005', 'A');
INSERT INTO ENROLL VALUES ('2021000006', 'csc006', 'A');
INSERT INTO ENROLL VALUES ('2021000006', 'csc007', 'A');
INSERT INTO ENROLL VALUES ('2021000006', 'csc008', 'A');
INSERT INTO ENROLL VALUES ('2021000006', 'csc010', 'A');
INSERT INTO ENROLL VALUES ('2021000006', 'csc011', 'A');
INSERT INTO ENROLL VALUES ('2021000006', 'csc015', 'A');
INSERT INTO ENROLL VALUES ('2021000006', 'csc016', 'A');

-- 나머지
INSERT INTO ENROLL VALUES ('2021000006', 'csc014', 'A');
INSERT INTO ENROLL VALUES ('2021000006', 'csc009', 'F');
INSERT INTO ENROLL VALUES ('2021000006', 'csc012', 'A');
INSERT INTO ENROLL VALUES ('2021000006', 'pri001', 'B');
INSERT INTO ENROLL VALUES ('2021000006', 'pri002', 'F');
INSERT INTO ENROLL VALUES ('2021000006', 'pri003', 'B');
INSERT INTO ENROLL VALUES ('2021000006', 'pri004', 'B');
INSERT INTO ENROLL VALUES ('2021000006', 'pri005', 'B');


-- 6. 졸업필수과목 (COURSE_RQMT) 테이블
CREATE TABLE COURSE_RQMT (
    cid     VARCHAR2(10)    NOT NULL, 
    mid     VARCHAR2(10)    NOT NULL,
    CONSTRAINT PK_COURSE_RQMT PRIMARY KEY (cid, mid),
    CONSTRAINT FK_RQMT_CRS FOREIGN KEY (cid) REFERENCES COURSE (cid),
    CONSTRAINT FK_RQMT_GRAD FOREIGN KEY (mid) REFERENCES GRAD_RGMT (mid)
);

INSERT INTO COURSE_RQMT (cid, mid) VALUES ('csc001', 'csc');
INSERT INTO COURSE_RQMT (cid, mid) VALUES ('csc002', 'csc');
INSERT INTO COURSE_RQMT (cid, mid) VALUES ('csc003', 'csc');
INSERT INTO COURSE_RQMT (cid, mid) VALUES ('csc004', 'csc');
INSERT INTO COURSE_RQMT (cid, mid) VALUES ('csc005', 'csc');
INSERT INTO COURSE_RQMT (cid, mid) VALUES ('csc006', 'csc');
INSERT INTO COURSE_RQMT (cid, mid) VALUES ('csc007', 'csc');
INSERT INTO COURSE_RQMT (cid, mid) VALUES ('csc008', 'csc');
INSERT INTO COURSE_RQMT (cid, mid) VALUES ('csc010', 'csc');
INSERT INTO COURSE_RQMT (cid, mid) VALUES ('csc011', 'csc');
INSERT INTO COURSE_RQMT (cid, mid) VALUES ('csc015', 'csc');
INSERT INTO COURSE_RQMT (cid, mid) VALUES ('csc016', 'csc');

COMMIT;


