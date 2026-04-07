--PL/SQL

--수강 내역 조회 
CREATE OR REPLACE PROCEDURE Show_Enroll_History(p_sid IN VARCHAR2) IS
    v_sname    STUDENT.sname%TYPE;
    v_mname    MAJOR.mname%TYPE;
    v_tot      STUDENT.tot_credit%TYPE;
    v_maj      STUDENT.maj_credit%TYPE;
    
    CURSOR cur_history IS
        SELECT c.cid, c.cname, c.credit, c.isMajor, c.isEng, e.grade,
               -- 필수과목 테이블에 해당 학과(s.mid)와 과목(c.cid)으로 매칭되는지 확인
               -- 매칭되면(NOT NULL) 'Y', 아니면 'N'
               NVL2(cr.cid, 'Y', 'N') AS isMust
        FROM   ENROLL e
        JOIN   COURSE c ON e.cid = c.cid
        JOIN   STUDENT s ON e.sid = s.sid -- 학생의 학과를 알기 위해 조인
        -- 필수과목 테이블과 LEFT JOIN (없을 수도 있으니까)
        LEFT JOIN COURSE_RQMT cr ON c.cid = cr.cid AND s.mid = cr.mid
        WHERE  e.sid = p_sid
        ORDER BY c.cid;

BEGIN
    -- 기본 정보 조회
    SELECT s.sname, m.mname, s.tot_credit, s.maj_credit
    INTO   v_sname, v_mname, v_tot, v_maj
    FROM   STUDENT s, MAJOR m
    WHERE  s.mid = m.mid
    AND    s.sid = p_sid;

    -- 헤더 출력 
    DBMS_OUTPUT.PUT_LINE('==========================================================================');
    DBMS_OUTPUT.PUT_LINE(' 학번: ' || p_sid || ' | 이름: ' || v_sname || ' | 학과: ' || v_mname);
    DBMS_OUTPUT.PUT_LINE(' 총 이수: ' || v_tot || '학점 | 전공 이수: ' || v_maj || '학점');
    DBMS_OUTPUT.PUT_LINE('==========================================================================');
    DBMS_OUTPUT.PUT_LINE(RPAD('과목코드', 10, ' ') || RPAD('과목명', 20, ' ') || 
                         RPAD('학점', 6, ' ') || RPAD('구분', 6, ' ') || 
                         RPAD('영어', 6, ' ') || RPAD('필수', 6, ' ') || '성적');
    DBMS_OUTPUT.PUT_LINE('--------------------------------------------------------------------------');

    -- 커서 루프
    FOR rec IN cur_history LOOP
        DBMS_OUTPUT.PUT_LINE(
            RPAD(rec.cid, 10, ' ') || 
            RPAD(rec.cname, 20, ' ') || 
            RPAD(TO_CHAR(rec.credit), 6, ' ') || 
            RPAD(CASE WHEN rec.isMajor='Y' THEN '전공' ELSE '교양' END, 6, ' ') ||
            RPAD(CASE WHEN rec.isEng='Y' THEN 'O' ELSE ' ' END, 6, ' ') ||
            RPAD(CASE WHEN rec.isMust='Y' THEN 'O' ELSE ' ' END, 6, ' ') ||
            rec.grade
        );
    END LOOP;
    
    DBMS_OUTPUT.PUT_LINE('==========================================================================');

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('>> 존재하지 않는 학생입니다.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('>> 에러 발생: ' || SQLERRM);
END;
/

SET SERVEROUTPUT ON;
-- 모든 요건을 충족한 김천일 학생 (성적 A)
EXEC Show_Enroll_History('2021000001');
-- F학점이 많았던 정유현 학생 (성적 F 확인)
EXEC Show_Enroll_History('2021000006');
-- 없는 학번 테스트
EXEC Show_Enroll_History('9999999999');



-- 졸업 가능 여부 확인

-- 총 이수 학점 확인 함수
CREATE OR REPLACE FUNCTION Func_Check_Total(p_sid IN VARCHAR2) RETURN VARCHAR2 IS
    v_current  NUMBER;
    v_req      NUMBER;
    v_mid      VARCHAR2(10);
BEGIN
    -- 1. 학생의 현재 학점과 학과의 요구 학점 조회
    SELECT s.tot_credit, g.totalCredit, s.mid
    INTO   v_current, v_req, v_mid
    FROM   STUDENT s, GRAD_RGMT g
    WHERE  s.mid = g.mid
    AND    s.sid = p_sid;

    -- 2. 비교 및 결과 리턴
    IF v_current < v_req THEN
        RETURN '- 총 학점 부족 (현재: ' || v_current || ' / 필수: ' || v_req || ')' || CHR(10);
    ELSE
        RETURN NULL; -- 통과 시 빈 값 리턴
    END IF;
END;
/
-- 전공 이수 학점 확인 함수
CREATE OR REPLACE FUNCTION Func_Check_Major(p_sid IN VARCHAR2) RETURN VARCHAR2 IS
    v_current  NUMBER;
    v_req      NUMBER;
BEGIN
    -- 1. 학생의 전공 학점과 학과의 요구 전공 학점 조회
    SELECT s.maj_credit, g.majorCredit
    INTO   v_current, v_req
    FROM   STUDENT s, GRAD_RGMT g
    WHERE  s.mid = g.mid
    AND    s.sid = p_sid;

    -- 2. 비교
    IF v_current < v_req THEN
        RETURN '- 전공 학점 부족 (현재: ' || v_current || ' / 필수: ' || v_req || ')' || CHR(10);
    ELSE
        RETURN NULL;
    END IF;
END;
/
-- 영어 강의 수강 확인 함수
CREATE OR REPLACE FUNCTION Func_Check_Eng(p_sid IN VARCHAR2) RETURN VARCHAR2 IS
    v_current  NUMBER;
    v_req      NUMBER;
BEGIN
    -- 1. 학생의 영어 강의 수강 개수 직접 카운트 (F학점 제외)
    SELECT COUNT(*)
    INTO   v_current
    FROM   ENROLL e, COURSE c
    WHERE  e.cid = c.cid
    AND    e.sid = p_sid
    AND    c.isEng = 'Y'
    AND    e.grade <> 'F';

    -- 2. 학과 요구량 조회
    SELECT g.engCourse
    INTO   v_req
    FROM   GRAD_RGMT g, STUDENT s
    WHERE  g.mid = s.mid
    AND    s.sid = p_sid;

    -- 3. 비교
    IF v_current < v_req THEN
        RETURN '- 영어 강의 부족 (현재: ' || v_current || '과목 / 필수: ' || v_req || '과목)' || CHR(10);
    ELSE
        RETURN NULL;
    END IF;
END;
/
--필수 과목 이수 확인 함수
CREATE OR REPLACE FUNCTION Func_Check_Must(p_sid IN VARCHAR2) RETURN VARCHAR2 IS
    v_missing_list VARCHAR2(1000) := ''; -- 미이수 과목명들을 담을 변수
    v_mid          VARCHAR2(10);
    
    -- 미이수 필수 과목을 찾아내는 커서
    CURSOR cur_missing IS
        SELECT c.cname
        FROM   COURSE_RQMT cr, COURSE c
        WHERE  cr.cid = c.cid
        AND    cr.mid = (SELECT mid FROM STUDENT WHERE sid = p_sid) -- 학생의 학과 기준
        MINUS
        SELECT c.cname
        FROM   ENROLL e, COURSE c
        WHERE  e.cid = c.cid
        AND    e.sid = p_sid
        AND    e.grade <> 'F'; -- F학점은 이수 안 한 걸로 간주

BEGIN
    -- 커서를 돌면서 미이수 과목이 있으면 문자열에 추가
    FOR rec IN cur_missing LOOP
        v_missing_list := v_missing_list || rec.cname || ', ';
    END LOOP;

    -- 결과 리턴
    IF v_missing_list IS NOT NULL THEN
        -- 끝에 붙은 쉼표 제거 후 리턴
        v_missing_list := RTRIM(v_missing_list, ', ');
        RETURN '- 필수 과목 미이수: [' || v_missing_list || ']' || CHR(10);
    ELSE
        RETURN NULL;
    END IF;
END;
/

-- 메인 프로시저
CREATE OR REPLACE PROCEDURE Check_Graduation(p_sid IN VARCHAR2) IS
    -- 변수 선언
    v_sname    STUDENT.sname%TYPE;
    v_msg      VARCHAR2(4000) := ''; -- 전체 피드백 메시지
    
    -- 예외 선언
    e_grad_fail EXCEPTION;

BEGIN
    -- 1. 학생 이름 조회 (겸사겸사 학생 존재 확인)
    SELECT sname INTO v_sname FROM STUDENT WHERE sid = p_sid;

    -- 2. 4가지 함수 호출 및 결과 누적 (결과가 없으면 NULL이므로 아무것도 안 더해짐)
    v_msg := v_msg || Func_Check_Total(p_sid);
    v_msg := v_msg || Func_Check_Major(p_sid);
    v_msg := v_msg || Func_Check_Eng(p_sid);
    v_msg := v_msg || Func_Check_Must(p_sid);

    -- 3. 최종 판정
    IF v_msg IS NOT NULL THEN
        -- 메시지가 비어있지 않다면(뭔가 걸렸다면) 예외 발생
        RAISE e_grad_fail;
    ELSE
        -- 메시지가 비어있다면 졸업 성공
        DBMS_OUTPUT.PUT_LINE('**************************************************');
        DBMS_OUTPUT.PUT_LINE(' [졸업 판정 결과] : 합격');
        DBMS_OUTPUT.PUT_LINE(' ' || v_sname || ' 학생님, 졸업 요건을 모두 충족하셨습니다.');
        DBMS_OUTPUT.PUT_LINE(' 졸업을 진심으로 축하합니다!');
        DBMS_OUTPUT.PUT_LINE('**************************************************');
    END IF;

EXCEPTION
    WHEN e_grad_fail THEN
        DBMS_OUTPUT.PUT_LINE('**************************************************');
        DBMS_OUTPUT.PUT_LINE(' [졸업 판정 결과] : 불합격 (반려)');
        DBMS_OUTPUT.PUT_LINE(' ' || v_sname || ' 학생님은 아래 요건이 미달되었습니다.');
        DBMS_OUTPUT.PUT_LINE('--------------------------------------------------');
        DBMS_OUTPUT.PUT_LINE(v_msg); -- 누적된 에러 메시지 한 번에 출력
        DBMS_OUTPUT.PUT_LINE('**************************************************');

    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('>> 존재하지 않는 학생입니다.');
        
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('>> 시스템 에러: ' || SQLERRM);
END;
/

---- 1. 김천일 (졸업 가능)
EXEC Check_Graduation('2021000001');
-- 2. 손승현 (총 학점 부족 - 전공은 채웠음)
EXEC Check_Graduation('2021000002');
-- 3. 공기훈 (전공 부족 + 총 학점 부족 + 영어 부족)
EXEC Check_Graduation('2021000003');
-- 4. 황윤수 (영어 부족)
EXEC Check_Graduation('2021000004');
-- 5. 이시우 (필수 미이수 - 알고리즘)
EXEC Check_Graduation('2021000005');
-- 6. 정유현 (F학점으로 인해 총학점/전공학점 부족, 필수 미이수 등 복합 에러)
EXEC Check_Graduation('2021000006');
