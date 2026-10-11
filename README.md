# Macroeconomics of Climate Change (ENF7010)

**English** | [한국어](README.ko.md)

Lecture notes and hands-on code for a graduate course on climate and the macroeconomy, taught by Seong-Hoon Kim at Yonsei University (2025). The notes are in Korean; the code comments are mostly in Korean.

## What the course covers

The course starts from how economists connect the economy and the climate, moves to the facts of long-run growth, and then works through a full empirical replication. Students learn to read a published paper, rebuild its results in Stata, and handle climate data in R.

The replication target is

> Colacito, Riccardo, Bridget Hoffmann, and Toan Phan. 2019. "Temperature and Growth: A Panel Analysis of the United States." *Journal of Money, Credit and Banking* 51 (2–3): 313–368. [doi:10.1111/jmcb.12574](https://doi.org/10.1111/jmcb.12574)

which finds that hot summers lower U.S. state output growth while temperatures in other seasons matter less.

## Lecture notes (`notes/`)

| File | Topic |
|---|---|
| `lecture01.pdf` | Daily life and the planet's climate: general equilibrium, the three modules of an integrated assessment model (carbon cycle, energy balance, damages), externalities and the carbon tax |
| `lecture02.pdf` | Facts about long-run growth: Kaldor facts, Hassler and Krusell (2018), the Kaya identity |
| `lecture03.pdf` | Reading the replication paper: research question, data (NOAA, BEA, BLS), and empirical design of Colacito, Hoffmann and Phan (2019) |
| `lecture04.pdf` | Stata basics: do-files and datasets, core commands, growth rates as log differences |
| `lecture05.pdf` | Designing empirical research: constructs vs. operational definitions, question, method, expected results |

## Stata replication (`stata/`)

| File | Content |
|---|---|
| `lecture.do` | Step-by-step class version: Table 1 (U.S. and state-level regressions of growth on seasonal temperature), Table 2 (cumulative lagged effects), Figure 3 (rolling regressions), Table 3 (labor productivity vs. employment) |
| `replication.do` | Fuller version: Tables 1–3 with two-way clustered errors, Figure 3, and Table 4 (industry-level effects of summer temperature) |

Run either file with the working directory set to `stata/`. Results are written to `stata/results/`.

Required packages (from SSC):

```stata
ssc install estout
ssc install parmest
ssc install coefplot
ssc install ivreg2
ssc install ranktest
ssc install xtivreg2
```

**Data (`stata/data/`):** U.S. and state temperature and output growth from the replication files of Colacito, Hoffmann and Phan (2019); private-sector employment from the BLS; state output by industry from the BEA.

## Climate data in R (`r/`)

| File | Content |
|---|---|
| `nasapower.R` | Download daily NASA POWER weather data (1981–2025) for Seoul and Busan and build a two-city panel. Writes `data/seoul_re.xlsx`, `data/busan_re.xlsx`, `data/Korea_re.xlsx` (included). |
| `nasapower_panel.do` | Load the NASA POWER panel into Stata and declare it as panel data. |
| `spei.R` | Read the SPEI drought index (NetCDF), map one month, and crop it to South Africa. |
| `shapefile.R` | Overlay the SPEI map with administrative boundaries from GADM shapefiles. |

Run the R scripts with the working directory set to `r/`. Packages: `nasapower`, `openxlsx`, `dplyr`, `tidyr`, `terra`, `sf`, `ncdf4`, `ggplot2`, `tidyterra`, `scales`.

The SPEI and shapefile scripts need inputs that are not included. Download them into `r/data/`:

- `spei01_africa.nc`: 1-month SPEI for Africa from the [SPEI Global Drought Monitor](https://spei.csic.es/)
- `gadm41_ZAF_shp/`: South Africa shapefiles from [GADM](https://gadm.org/)

Documentation for the `nasapower` package: <https://docs.ropensci.org/nasapower/>
