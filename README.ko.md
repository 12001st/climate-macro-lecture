# 기후변화의 거시경제학 (ENF7010)

[English](README.md) | **한국어**

연세대학교 대학원 강의(2025, 김성훈)의 강의노트와 실습 코드입니다. 강의노트와 코드 주석은 대부분 한국어입니다.

## 강의 내용

경제학이 경제와 기후를 어떻게 연결하는지에서 출발해 장기 성장의 사실들을 살펴본 뒤, 하나의 실증 논문을 처음부터 끝까지 재현합니다. 학생들은 출판된 논문을 읽고, Stata로 결과를 다시 만들고, R로 기후 자료를 다루는 법을 배웁니다.

재현 대상 논문은 다음과 같습니다.

> Colacito, Riccardo, Bridget Hoffmann, and Toan Phan. 2019. "Temperature and Growth: A Panel Analysis of the United States." *Journal of Money, Credit and Banking* 51 (2–3): 313–368. [doi:10.1111/jmcb.12574](https://doi.org/10.1111/jmcb.12574)

이 논문은 여름 기온이 높을수록 미국 주(州)의 산출 성장률이 낮아지고, 다른 계절의 기온은 덜 중요하다는 것을 보였습니다.

## 강의노트 (`notes/`)

| 파일 | 주제 |
|---|---|
| `lecture01.pdf` | 나의 일상과 지구의 기후: 일반균형, 통합평가모형의 세 모듈(탄소순환, 에너지 균형, 피해함수), 외부효과와 탄소세 |
| `lecture02.pdf` | 장기 성장에 관한 사실들: 칼도어의 정형화된 사실, Hassler and Krusell (2018), 카야 항등식 |
| `lecture03.pdf` | 재현 논문 읽기: Colacito, Hoffmann and Phan (2019)의 연구 질문, 자료(NOAA, BEA, BLS), 실증 설계 |
| `lecture04.pdf` | Stata 기초: do 파일과 데이터셋, 핵심 명령어, 로그 차분으로 본 성장률 |
| `lecture05.pdf` | 실증연구 설계: 구성개념과 조작적 정의, 연구 질문, 방법, 예상 결과 |

## Stata 재현 (`stata/`)

| 파일 | 내용 |
|---|---|
| `lecture.do` | 수업용 단계별 버전: 표 1(미국 전체·주 단위 성장률의 계절 기온 회귀), 표 2(시차 누적 효과), 그림 3(이동 회귀), 표 3(노동생산성 대 고용) |
| `replication.do` | 확장 버전: 이원 군집 표준오차를 쓴 표 1–3, 그림 3, 표 4(여름 기온의 산업별 효과) |

작업 폴더를 `stata/`로 지정한 뒤 실행하세요. 결과는 `stata/results/`에 저장됩니다.

필요한 패키지(SSC):

```stata
ssc install estout
ssc install parmest
ssc install coefplot
ssc install ivreg2
ssc install ranktest
ssc install xtivreg2
```

**자료 (`stata/data/`):** 미국 및 주별 기온과 산출 성장률은 Colacito, Hoffmann and Phan (2019)의 재현 자료, 민간 고용은 BLS, 주별 산업 산출은 BEA 자료입니다.

## R로 기후 자료 다루기 (`r/`)

| 파일 | 내용 |
|---|---|
| `nasapower.R` | 서울과 부산의 NASA POWER 일별 기상 자료(1981–2025)를 내려받아 두 도시 패널을 만듭니다. `data/seoul_re.xlsx`, `data/busan_re.xlsx`, `data/Korea_re.xlsx`를 저장합니다(포함됨). |
| `nasapower_panel.do` | NASA POWER 패널을 Stata로 불러와 패널 자료로 선언합니다. |
| `spei.R` | 가뭄지수 SPEI(NetCDF)를 읽어 한 달을 지도로 그리고 남아프리카공화국 영역을 잘라냅니다. |
| `shapefile.R` | GADM 행정경계 shapefile을 SPEI 지도 위에 겹쳐 그립니다. |

작업 폴더를 `r/`로 지정한 뒤 실행하세요. 패키지: `nasapower`, `openxlsx`, `dplyr`, `tidyr`, `terra`, `sf`, `ncdf4`, `ggplot2`, `tidyterra`, `scales`.

SPEI와 shapefile 스크립트에 필요한 입력 자료는 포함되어 있지 않습니다. 다음을 `r/data/`에 내려받으세요.

- `spei01_africa.nc`: [SPEI Global Drought Monitor](https://spei.csic.es/)의 아프리카 1개월 SPEI
- `gadm41_ZAF_shp/`: [GADM](https://gadm.org/)의 남아프리카공화국 shapefile

`nasapower` 패키지 문서: <https://docs.ropensci.org/nasapower/>
