# EmpEconGrowthReplication

Julia replication project for:

**Cervellati, Meyerheim, and Sunde — “The Empirics of Economic Growth over Time and across Nations: A Unified Growth Perspective”**

This package reproduces the model simulations and Figures 1–5.

Replication by Nicola Foglia.

## Project structure

```text
RepEmpiricsEconomicGrowth\
├── data\                          # input data
├── output\                        # simulated model outputs
├── images\                        # replicated figures
├── EmpEconGrowthReplication\
│   ├── src\
│   │   ├── EmpEconGrowthReplication.jl
│   │   ├── simulation.jl
│   │   └── figures.jl
│   ├── test\
│   │   └── runtests.jl
│   ├── Project.toml
│   └── Manifest.toml
├── run_all.jl                     # main execution script
├── README.md
├── report.qmd
└── replication-package\           # original files
```

## How to install

From RepEmpiricsEconomicGrowth\EmpEconGrowthReplication\:

### from Julia REPL

```
using Pkg
Pkg.activate(".")
Pkg.instantiate()
```

## How to run

From RepEmpiricsEconomicGrowth\:

### Option 1 — from terminal

```
julia run_all.jl
```

### Option 2 — from Julia REPL

```
include("run_all.jl")
```

## Outputs

All simulated model outputs are saved in:

```
output\
```

All replicated figures are saved in:

```
images\
```

## How to test

From RepEmpiricsEconomicGrowth\EmpEconGrowthReplication\:

### from Julia REPL

```
using Pkg
Pkg.activate(".")
Pkg.test()
```

## How to compile the report

From RepEmpiricsEconomicGrowth\:

### from terminal

```
quarto render report.qmd
```

## Requirements

- Datasets used in the original analysis - .dta format

- No explicit hardware or time requirements specified.

---

## My Setup

- Machine: Windows laptop  
- CPU: 12th Gen Intel Core i7-1255U
- RAM: 16 GB
- OS: Windows 11  

Software used:

- Julia 1.12
- Main Packages:
  - DataFrames
  - CSV
  - ReadStatTables
  - Plots
  - Statistics
- Visual Studio Code 
- VSC Extensions:
  - Julia
  - Quarto
  - vscode-pdf

All computations run locally and complete within a few seconds.