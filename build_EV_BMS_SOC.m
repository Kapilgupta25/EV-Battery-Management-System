function build_EV_BMS_SOC
% BUILD_EV_BMS_SOC Build and save the four-cell SOC tutorial model.
% Put this file in your project folder, open it in MATLAB, and click Run.
% Requires MATLAB + Simulink; no Simscape or external parameter file needed.
% Creates EV_BMS_SOC.slx beside this file (uses a numbered name if occupied).
% Scope: SOC reference, coulomb-counting estimate, current bias and error.
% Voltage, temperature, protection and balancing are NOT implemented yet.
% Generated without a MATLAB runtime; the checks below run on your machine.

folder = fileparts(mfilename('fullpath'));
load_system('simulink');
model = 'EV_BMS_SOC';
k = 1;
while bdIsLoaded(model) || exist(fullfile(folder,[model '.slx']),'file') || ...
        exist(fullfile(folder,[model '.mdl']),'file') || ~isempty(which(model))
    model = sprintf('EV_BMS_SOC_%d',k);
    k = k+1;
end
new_system(model);
set_param(model,'SolverType','Fixed-step','Solver','ode4', ...
    'FixedStep','1','StartTime','0','StopTime','600', ...
    'ReturnWorkspaceOutputs','on');

% All parameters are embedded as block values: the SLX is self-contained.
add_block('simulink/Sources/Constant',[model '/Actual Current'], ...
    'Value','3','Position',[40 105 100 145]);
add_block('simulink/Sources/Constant',[model '/Sensor Bias'], ...
    'Value','0','Position',[40 285 100 325]);
add_block('simulink/Math Operations/Sum',[model '/Measured Current'], ...
    'Inputs','++','Position',[155 225 185 265]);

paths = {'Reference','Estimated'};
ys = [100 220];
for n = 1:2
    p = paths{n}; y = ys(n);
    add_block('simulink/Math Operations/Gain',[model '/' p ' Rate'], ...
        'Gain','-[1;1;1;1]./(3600*[3;3;3;3])', ...
        'Multiplication','Element-wise(K.*u)', ...
        'Position',[240 y 340 y+50]);
    add_block('simulink/Continuous/Integrator',[model '/' p ' SOC'], ...
        'InitialCondition','[0.80;0.78;0.76;0.74]', ...
        'Position',[400 y+5 440 y+45]);
    add_block('simulink/Math Operations/Gain',[model '/' p ' Percent'], ...
        'Gain','100','Multiplication','Element-wise(K.*u)', ...
        'Position',[500 y+5 555 y+45]);
    add_block('simulink/Sinks/Scope',[model '/' p ' Plot'], ...
        'Position',[625 y-15 665 y+15]);
    add_block('simulink/Sinks/Display',[model '/' p ' Values'], ...
        'Position',[710 y-10 820 y+65]);
    add_block('simulink/Sinks/To Workspace',[model '/' p ' Log'], ...
        'VariableName',lower([p '_soc_pct']), ...
        'SaveFormat','Timeseries','MaxDataPoints','inf', ...
        'Position',[880 y+10 1000 y+40]);
    add_line(model,[p ' Rate/1'],[p ' SOC/1'],'autorouting','on');
    add_line(model,[p ' SOC/1'],[p ' Percent/1'],'autorouting','on');
    add_line(model,[p ' Percent/1'],[p ' Plot/1'],'autorouting','on');
    add_line(model,[p ' Percent/1'],[p ' Values/1'],'autorouting','on');
    add_line(model,[p ' Percent/1'],[p ' Log/1'],'autorouting','on');
end
add_line(model,'Actual Current/1','Reference Rate/1','autorouting','on');
add_line(model,'Actual Current/1','Measured Current/1','autorouting','on');
add_line(model,'Sensor Bias/1','Measured Current/2','autorouting','on');
add_line(model,'Measured Current/1','Estimated Rate/1','autorouting','on');

add_block('simulink/Math Operations/Sum',[model '/SOC Error'], ...
    'Inputs','+-','Position',[575 390 605 430]);
add_block('simulink/Sinks/Scope',[model '/Error Plot'], ...
    'Position',[650 385 690 415]);
add_block('simulink/Sinks/Display',[model '/Error Values'], ...
    'Position',[735 385 845 460]);
add_block('simulink/Sinks/To Workspace',[model '/Error Log'], ...
    'VariableName','soc_error_pp','SaveFormat','Timeseries', ...
    'MaxDataPoints','inf','Position',[890 400 1000 430]);
add_line(model,'Estimated Percent/1','SOC Error/1','autorouting','on');
add_line(model,'Reference Percent/1','SOC Error/2','autorouting','on');
add_line(model,'SOC Error/1','Error Plot/1','autorouting','on');
add_line(model,'SOC Error/1','Error Values/1','autorouting','on');
add_line(model,'SOC Error/1','Error Log/1','autorouting','on');

note = Simulink.Annotation(model,sprintf([ ...
    'FOUR-CELL SOC MODEL | 3 Ah per cell | positive current = discharge\n' ...
    'Reference = ideal charge bookkeeping; Estimated = measured-current integration.\n' ...
    'Try Sensor Bias = 0.05 A. Initial SOC and capacity are editable in the blocks.\n' ...
    'Educational baseline only: no voltage, thermal, protection or balancing yet.']));
note.Position = [40 15];
set_param(model,'SimulationCommand','update');
target = fullfile(folder,[model '.slx']);
save_system(model,target);
open_system(model);
set_param(model,'ZoomFactor','FitSystem');
fprintf('\nSaved model: %s\n',target);

% Actual Simulink checks on the user's installation, not claimed as pre-run.
% Return the live model to its baseline even if a test throws an error.
try
    expected = [80 78 76 74] - (3*600/(3600*3))*100;
    baseline = sim(model);
    ref = baseline.get('reference_soc_pct');
    err = baseline.get('soc_error_pp');
    last = reshape(ref.Data(end,:),1,[]);
    assert(numel(last)==4 && max(abs(last-expected))<1e-6, ...
        'Reference SOC did not match the analytical result.');
    assert(max(abs(err.Data(:)))<1e-6,'Baseline SOC error is not zero.');

    set_param([model '/Sensor Bias'],'Value','0.05');
    biased = sim(model);
    err = biased.get('soc_error_pp');
    assert(max(abs(err.Data(end,:)+0.277777777777778))<1e-6, ...
        'Sensor-bias result did not match the analytical result.');

    set_param([model '/Sensor Bias'],'Value','0');
    set_param([model '/Estimated SOC'],'InitialCondition', ...
        '[0.82;0.80;0.78;0.76]');
    offset = sim(model);
    err = offset.get('soc_error_pp');
    assert(max(abs(err.Data(:)-2))<1e-6, ...
        'Initial SOC offset was not retained.');

    restore_baseline(model);
    baseline = sim(model);
    save_system(model,target);
    results_file = fullfile(folder,[model '_test_results.mat']);
    save(results_file,'baseline','biased','offset');

    ref = baseline.get('reference_soc_pct');
    est = biased.get('estimated_soc_pct');
    err = biased.get('soc_error_pp');
    figure('Name','BMS SOC checks','Color','w');
    subplot(2,1,1);
    plot(ref.Time,ref.Data,'LineWidth',1.5); hold on;
    plot(est.Time,est.Data,'--','LineWidth',1);
    grid on; xlabel('Time (s)'); ylabel('SOC (%)');
    title('Solid: reference; dashed: estimate with +0.05 A bias');
    legend('Ref C1','Ref C2','Ref C3','Ref C4', ...
        'Est C1','Est C2','Est C3','Est C4','Location','best');
    subplot(2,1,2);
    plot(err.Time,err.Data,'LineWidth',1.5);
    grid on; xlabel('Time (s)'); ylabel('Error (percentage points)');
    title('Sensor-bias drift (all four cell errors overlap)');
    fprintf('PASS: ideal sensor, +0.05 A bias, and +2 pp initial offset.\n');
    fprintf('Baseline final SOC (%%): %.4f %.4f %.4f %.4f\n',expected);
    fprintf('Model restored to baseline. Test results: %s\n',results_file);
catch ME
    restore_baseline(model);
    save_system(model,target);
    warning('BMS:ValidationIncomplete', ...
        'Model saved, but automatic checks did not finish: %s',ME.message);
    fprintf('Send the warning/error text for troubleshooting.\n');
end
end

function restore_baseline(model)
set_param([model '/Sensor Bias'],'Value','0');
set_param([model '/Estimated SOC'],'InitialCondition','[0.80;0.78;0.76;0.74]');
end
