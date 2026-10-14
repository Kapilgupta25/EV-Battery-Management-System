# EV Battery Management System — Simulation

A four-cell battery SOC estimation project built in MATLAB/Simulink.

## Current features
- Reference SOC calculation for four series-connected cells
- Coulomb-counting SOC estimation
- Current-sensor bias testing
- Initial SOC error testing
- SOC comparison and error plots

## Requirements
- MATLAB
- Simulink

## How to run
1. Open build_EV_BMS_SOC.m in MATLAB.
2. Click Run to generate and open the Simulink model.
3. Inspect the plots and automatic test results.

Alternatively, open the generated EV_BMS_SOC.slx model directly.

## Planned features
- Cell voltage and temperature models
- Overvoltage and undervoltage protection
- Overcurrent and overtemperature protection
- Passive cell balancing

## Scope
Educational simulation with illustrative parameters.
Not validated for use with a physical EV battery pack.