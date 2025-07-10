# Mixed Binary Possibilistic Optimization for CSP-TES Systems under Uncertainty

This repository contains the full MATLAB implementation for the simulation and analysis conducted in the research paper:

**Mixed Binary Possibilistic Programming for Economic Optimization of Solar Power Plants with Thermal Energy Storage under Uncertainty: A Case Study**

## Overview

The code framework integrates **Mixed-Binary Linear Programming (MBLP)** with **Possibilistic Optimization** to support robust investment and operation planning for **Concentrated Solar Power (CSP)** plants coupled with **Thermal Energy Storage (TES)**. Uncertainty in solar radiation, electricity demand, and interest rates is handled using fuzzy logic with possibility and necessity measures.
The case study is based on the IEEE 39-Bus system.

---

##  Repository Contents

###  Main Simulation
- `main.m`  
  Executes multiple scenarios under varying levels of possibility and necessity. Loads variables, defines the model, solves the optimization problem, displays and saves results.

### Model Components
- `Variable.m`  
  Loads input data, defines system parameters, fuzzy distributions, and uncertainty modeling.

- `Problem_formulation_all_0318.m`  
  Defines the MBLP optimization problem with all constraints, variables, and the objective function.

- `Solver_Options.m`  
  Specifies solver settings (CPLEX via YALMIP).

- `Result_all.m`  
  Displays optimization results and key variables such as energy generation, storage status, and CSP output.

- `Save_Results_all.m`  
  Saves the results of each scenario into `.mat` files for later analysis.

---

## Post-Processing and Visualization

### Scenario Result Visualization
- `check_result.m`  
  Loads saved `.mat` result files and visualizes power flows, storage usage, switching logic, and grid graph.

 ### Economic & Financial Evaluation 
- `econo_analysis.m` loads saved .mat scenario results
 Computes net profit, revenue, maintenance cost, investment cost, and return percentage, producing a clean financial table for all scenarios; this tool supports investor-level profitability analysis under varying uncertainty attitudes.
 
---

## Scenarios Simulated

Scenarios are defined based on the type of uncertainty handling:

| Scenario | Type  | Level (ρ) |
|----------|-------|------------|
| 1        | Possibility | 0.25 |
| 2        | Possibility | 0.5  |
| 3        | Possibility | 0.75 |
| 4        | Necessity   | 0.0  |
| 5        | Necessity   | 0.25 |
| 6        | Necessity   | 0.5  |
| 7        | Necessity   | 0.75 |

Each scenario adjusts solar radiation, demand, and financial parameters accordingly.

---

## Output

For each scenario, a `.mat` file is generated containing:

- Generator dispatch
- Load served
- TES charge/discharge levels
- Storage state
- CSP generation and thermal input
- Final objective value
- Scenario runtime

These are stored in the `Res` structure for analysis.

---

## Reproducibility

This codebase was used to generate all results, tables, and figures in the associated journal manuscript. The `main.m` script can be executed to replicate simulations for all uncertainty scenarios.

---


