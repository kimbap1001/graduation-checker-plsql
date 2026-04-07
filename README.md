# graduation-checker-plsql

A graduation eligibility checker implemented in **Oracle PL/SQL**, developed
as a Database Design course project. The system evaluates whether a student
meets all graduation requirements and provides detailed feedback on unmet
conditions.

---

## Overview

This project models a university academic administration system at the
**database level**, implementing complex graduation evaluation logic using
Oracle Stored Procedures, Functions, and Triggers.

Key design goals:
- **Data-driven architecture** — graduation requirements stored in DB tables,
  not hardcoded, allowing rule changes without modifying source code
- **Modular logic** — each requirement validated by a dedicated function,
  aggregated by a main procedure
- **Performance optimization** — denormalization applied to the STUDENT table
  with trigger-based synchronization for frequent credit queries
- **Comprehensive feedback** — all unmet requirements reported at once,
  not just the first failure

---

## Graduation Requirements

| Requirement | Threshold |
|-------------|-----------|
| Total Credits | 60+ credits |
| Major Credits | 40+ credits |
| English-taught Courses | 4+ courses (F grade excluded) |
| Required Subjects | All designated mandatory courses passed |

---

## Database Design

Designed through full normalization (1NF → 2NF → 3NF), then selectively
denormalized for performance.

**Tables:**
- `STUDENT` — student info + denormalized credit totals (`tot_credit`, `maj_credit`)
- `MAJOR` — department info (separated to eliminate transitive dependency)
- `COURSE` — course catalog with major/English flags
- `ENROLL` — enrollment records with grades (M:N bridge table)
- `GRAD_RGMT` — per-department graduation thresholds
- `COURSE_RQMT` — required course list per department (1NF: extracted from repeating group)

**Trigger:** `TRG_ENROLL_INSERT` — automatically updates `tot_credit` and
`maj_credit` on every INSERT to ENROLL, excluding F-grade courses.

---

## Implementation

- `Show_Enroll_History(p_sid)` — displays full enrollment history with
  major/English/required course flags using multi-table JOIN + CURSOR
- `Func_Check_Total(p_sid)` — validates total credit requirement
- `Func_Check_Major(p_sid)` — validates major credit requirement
- `Func_Check_Eng(p_sid)` — counts English courses (F excluded) vs. requirement
- `Func_Check_Must(p_sid)` — identifies missing required courses using `MINUS`
  set operation
- `Check_Graduation(p_sid)` — main procedure: aggregates all 4 function results,
  raises custom exception on any failure, outputs full feedback

---

## Test Cases

6 student scenarios were designed to cover edge cases:

| Student | Scenario |
|---------|----------|
| 2021000001 | All requirements met → **PASS** |
| 2021000002 | Total credits insufficient |
| 2021000003 | Total credits + major credits + English courses insufficient |
| 2021000004 | English courses insufficient only |
| 2021000005 | Required subject not completed |
| 2021000006 | All courses taken but F grades → credits not counted → **FAIL** |

---

## Sample Output

**Pass:**
```
[졸업 판정 결과] : 합격
김천일 학생님, 졸업 요건을 모두 충족하셨습니다.
```
**Fail (multiple conditions):**
```
[졸업 판정 결과] : 불합격 (반려)
공기훈 학생님은 아래 요건이 미달되었습니다.

총 학점 부족 (현재: 54 / 필수: 60)
전공 학점 부족 (현재: 36 / 필수: 40)
영어 강의 부족 (현재: 3과목 / 필수: 4과목)
```





---

## Files

- `schema.sql` — table definitions, sample data, and trigger
- `plsql.sql` — stored procedures and functions

---

## Environment

- Oracle Database
- PL/SQL (Stored Procedure, Function, Trigger)
