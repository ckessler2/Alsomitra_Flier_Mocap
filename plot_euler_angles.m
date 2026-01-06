clc; clear; close all;
graph_settings

% If you have your own style function like in your example:
% graph_settings

%% === Global Constants (match Python) ===
G_PROMINENCE = 0.05;
G_DISTANCE   = 100;
G_AXIS       = "Roll";
G_VIEW       = 1000;
FPS          = 240;

% Data start override (Python: data_start=None)
data_start = [];   % e.g., data_start = 84;  % [] means auto-detect

% Y-axis displacements
roll_disp  = 0;
pitch_disp = 0;
yaw_disp   = 0;

% Cutoff seconds from end
cutoff = 1.5;

% URL
csv_files = dir(fullfile("C:\Users\ck2049\Desktop\UW_mocap_1\Alsomitra MoCap Data 12-21-2025", '*.csv'));


%% === Plot (3 stacked axes, like Python subplots) ===
w = 23; h = 23; 
fig = figure('Units','centimeters','Position',[2 2 w h], 'WindowStyle','normal', 'Resize','off');
tiles = tiledlayout(7,3,"TileSpacing","compact","Padding","compact");

for i = 1:length(csv_files)
    ax1 = nexttile(tiles);
    T = readtable(csv_files(i).name,'PreserveVariableNames',true);
    
    % These must match your CSV headers exactly:
    qx = T.("Rigid Body"); qx = qx(5:end);
    qy = T.("Rigid Body_1"); qy = qy(5:end);
    qz = T.("Rigid Body_2"); qz = qz(5:end);
    qw = T.("Rigid Body_3"); qw = qw(5:end);
    
    %% === Process Euler angles (Python: process_euler) ===
    eulerTbl = process_euler_matlab(qx, qy, qz, qw, ...
        G_AXIS, G_DISTANCE, G_PROMINENCE, G_VIEW, data_start);
    
    % (Optional) trim_by_degree_change equivalent (Python default is NOT using it)
    % eulerTbl = trim_by_degree_change_matlab(eulerTbl, 10);
    
    %% === Unwrap + smooth yaw (Python) ===
    yaw_deg = eulerTbl.Yaw;
    yaw_unwrapped = rad2deg(unwrap(deg2rad(yaw_deg)));
    % yaw_unwrapped = smooth_signal_matlab(yaw_unwrapped, 25, 3);
    eulerTbl.Yaw = yaw_unwrapped;
    
    %% === Recalibrate so first point is 0 ===
    eulerTbl.Roll  = eulerTbl.Roll  - eulerTbl.Roll(1);
    eulerTbl.Pitch = eulerTbl.Pitch - eulerTbl.Pitch(1);
    eulerTbl.Yaw   = eulerTbl.Yaw   - eulerTbl.Yaw(1);
    
    %% === Time axis + cutoff ===
    N = height(eulerTbl);
    t = linspace(0, N/FPS, N)';  % matches numpy.linspace(0, len/FPS, len)
    mask = (t <= cutoff);

    if i == 4
        mask = (t <= 4); 
    end
    
    t_chopped = t(mask);
    euler_chopped = eulerTbl(mask, :);
    
    plot(ax1, t_chopped, rad2deg(euler_chopped.Roll + roll_disp), "LineWidth", 2,"Color", [0.51765  0.12549  0.41961]);
    grid(ax1,"on");
    ylabel(ax1, "Roll [°]"); xlabel(ax1, "Time [s]");
    % ylim(20*[floor(min(rad2deg(euler_chopped.Roll + roll_disp))/20) ceil(max(rad2deg(euler_chopped.Roll + roll_disp))/20)])
    % yticks(ax1, -20:20:100); 
    pbaspect([3 1 1])
    
    ax2 = nexttile(tiles);
    plot(ax2, t_chopped, rad2deg(euler_chopped.Pitch + pitch_disp), "LineWidth", 2, "Color", [0.89804  0.36078  0.18824]);
    grid(ax2,"on");
    ylabel(ax2, "Pitch [°]"); xlabel(ax2, "Time [s]");
    % ylim(20*[floor(min(rad2deg(euler_chopped.Pitch + pitch_disp))/20) ceil(max(rad2deg(euler_chopped.Pitch + pitch_disp))/20)])
    % yticks(ax2, -60:20:20); 
    pbaspect([3 1 1])
    prot = regexp(csv_files(i).name, 'prototype\d+', 'match');
    take = regexp(csv_files(i).name, 'take\d+', 'match');
    title("Prototype " + prot{1}(end) + ", Flight " + take{1}(end));
    
    ax3 = nexttile(tiles);
    plot(ax3, t_chopped, rad2deg(euler_chopped.Yaw + yaw_disp), "LineWidth", 2, "Color", [0.96471  0.84314  0.27451]);
    grid(ax3,"on");
    ylabel(ax3, "Yaw [°]"); xlabel(ax3, "$t$ [s]");
    % ylim(100*[floor(min(rad2deg(euler_chopped.Yaw + yaw_disp))/100) ceil(max(rad2deg(euler_chopped.Yaw + yaw_disp))/100)])
    % yticks(ax3, -200:100:600); 
    pbaspect([3 1 1])
end

function outTbl = process_euler_matlab(qx, qy, qz, qw, G_AXIS, G_DISTANCE, G_PROMINENCE, G_VIEW, custom_start)

    % Quaternion -> Euler (Roll, Pitch, Yaw) in degrees.
    % Python used euler_from_quaternion(x,y,z,w) returning:
    %   roll = -roll_deg, pitch=+pitch_deg, yaw=+yaw_deg, order ZYX (yaw-pitch-roll).
    angles = quat2eul([qx, qy, qz, qw]);
    rollDeg = angles(:,1); pitchDeg = angles(:,2); yawDeg = angles(:,3); 

    % Smooth Roll and Pitch only (match Python: for axis in ['Roll','Pitch'])
    % rollDeg  = smooth_signal_matlab(rollDeg, 25, 3);
    % pitchDeg = smooth_signal_matlab(pitchDeg, 25, 3);
    rollDeg = unwrap(rollDeg);
    pitchDeg = unwrap(pitchDeg);
    yawDeg = unwrap(yawDeg);

    outTbl = table(rollDeg, pitchDeg, yawDeg, 'VariableNames', {'Roll','Pitch','Yaw'});

    
end

function outTbl = trim_by_degree_change_matlab(eulerTbl, threshold)
    roll = eulerTbl.Roll;
    cutIdx = 1;
    for i = 2:numel(roll)
        if abs(roll(i) - roll(i-1)) < threshold
            cutIdx = i;
            break;
        end
    end
    outTbl = eulerTbl(cutIdx:end, :);
end

% Global font size 
set(findall(fig,'-property','FontSize'),'FontSize',10);

% Export figure as pdf
set(fig,'PaperUnits','centimeters', ...
        'PaperPosition',[0 0 w h], ...
        'PaperSize',[w h], ...
        'PaperPositionMode','manual');
print(fig,'figures/euler_angles.pdf','-dpdf','-r1200');
exportgraphics(fig,'figures/euler_angles.png',resolution=1200);
