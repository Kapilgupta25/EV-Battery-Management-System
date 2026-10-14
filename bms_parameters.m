% Parameters for the first BMS SOC model.
% Educational assumptions; not a validated commercial battery model.

% Four cells connected in series
N_cells = 4;

% True cell capacities in Ah
Q_true_Ah = [3; 3; 3; 3];

% Capacities assumed by the SOC estimator
Q_est_Ah = [3; 3; 3; 3];

% Initial reference SOC: fractions, not percentages
SOC0_true = [0.80; 0.78; 0.76; 0.74];

% Initial SOC supplied to the estimator
SOC0_est = SOC0_true;

% Current convention:
% Positive = discharge
% Negative = charge
I_discharge_A = 3;

% Sensor offset, in amperes
current_bias_A = 0;

% Simulation duration, in seconds
simulation_time_s = 600;