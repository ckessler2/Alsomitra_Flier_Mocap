clc; clear all; close all
graph_settings

csv_files = dir(fullfile("C:\Users\ck2049\Desktop\UW_mocap_1\Alsomitra MoCap Data 12-21-2025", '*.csv'));

% Plot XYZ Trajectories
w = 23; h = 23; 
fig = figure('Units','centimeters', ...
             'Position',[2 2 w h], ...
             'WindowStyle','normal', ...
             'Resize','off');
tiles = tiledlayout(4,2,'Padding','compact','TileSpacing','compact');

for i = 1:length(csv_files)
    nexttile(tiles)
    T = readtable(csv_files(i).name,'PreserveVariableNames',true);
    
    X=T.("Rigid Body_4")/1000; X = X(5:end);
    Y=T.("Rigid Body_5")/1000; Y = Y(5:end);
    Z=T.("Rigid Body_6")/1000; Z = -Z(5:end); % Flip Z
    Time = T.Type(5:end);

    X = X - X(1); Y = Y - Y(1); Z = Z - Z(1);
    
    plot(Time, Z, "LineWidth", 2,"Color", [0.51765  0.12549  0.41961]); hold on
    plot(Time(1:end-1), diff(Z)./Time(2), "LineWidth", 2, "Color", [0.89804  0.36078  0.18824]);
    ylim([-2 2]);

    xlabel("$t$ [s]"); ylabel("$z$ [m]"); 
    yyaxis right; ylabel("$v_z$ [ms$^{-1}$]");

    ax = gca;
    ax.YAxis(1).Color = "k";
    ax.YAxis(2).Color = "k";

    % if i == 1; legend("Displacement, $z$", "Velocity, $v_z$", "Location","southeast"); end

    prot = regexp(csv_files(i).name, 'prototype\d+', 'match');
    take = regexp(csv_files(i).name, 'take\d+', 'match');
    title("Prototype " + prot{1}(end) + ", Flight " + take{1}(end));

    pbaspect([3 1 1])
end

legend(ax,"Displacement, $z$", "Velocity, $v_z$", "Location",'eastoutside');

% Global font size 
set(findall(fig,'-property','FontSize'),'FontSize',10);

% Export figure as pdf
set(fig,'PaperUnits','centimeters', ...
        'PaperPosition',[0 0 w h], ...
        'PaperSize',[w h], ...
        'PaperPositionMode','manual');
print(fig,'figures/v_vs_t.pdf','-dpdf','-r1200');
exportgraphics(fig,'figures/v_vs_t.png',resolution=1200);