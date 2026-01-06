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
    Z=T.("Rigid Body_6")/1000; Z = Z(5:end);

    X = X - X(1); Y = Y - Y(1); Z = Z - Z(1);
    
    FPS=240; 
    t=(0:numel(X)-1)'/FPS; 
    on=t<2; off=~on; 
    Z0=Z(find(on,1));
    tcol = max(t)-t;  % <-- key line: fixes "time looks backwards"
   
    scatter3(X(on),Y(on), Z(on)-Z0,16,tcol(on),'o','filled')
    
    caxis([min(tcol) max(tcol)]);
    A=[0.001462 0.000466 0.013866;0.046915 0.030324 0.150164;0.142378 0.046242 0.308553;0.258234 0.038571 0.406485;0.366529 0.071579 0.431994;0.472328 0.110547 0.428334;0.578304 0.148039 0.404411;0.682656 0.189501 0.360757;0.780517 0.243327 0.299523;0.865006 0.316822 0.226055;0.929644 0.411479 0.145367;0.970919 0.522853 0.058367;0.987622 0.645320 0.039886;0.978806 0.774545 0.176037;0.950018 0.903409 0.380271;0.988362 0.998364 0.644924]; 
    colormap(interp1(linspace(0,1,size(A,1)),A,linspace(0,1,256),'pchip'));

    cb=colorbar; cb.Label.String="$t$ [s]"; cb.Label.Interpreter="Latex";
    view(15,18); xlabel("$x$ [m]"); ylabel("$y$ [m]"); zlabel("$z$ [m]");

    prot = regexp(csv_files(i).name, 'prototype\d+', 'match');
    take = regexp(csv_files(i).name, 'take\d+', 'match');
    title("Prototype " + prot{1}(end) + ", Flight " + take{1}(end));

    daspect([1 1 1])
end

% Global font size 
set(findall(fig,'-property','FontSize'),'FontSize',10);

% Export figure as pdf
set(fig,'PaperUnits','centimeters', ...
        'PaperPosition',[0 0 w h], ...
        'PaperSize',[w h], ...
        'PaperPositionMode','manual');
print(fig,'figures/xyz_trajectories.pdf','-dpdf','-r1200');
exportgraphics(fig,'figures/xyz_trajectories.png',resolution=1200);