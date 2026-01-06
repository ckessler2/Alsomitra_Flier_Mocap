function [ ] = graph_settings
% The following changes the default matlab setting for the current matlab
% session. If you logout and in again they reset to defaults.
% I would reccommend downloading the export_fig function and saving your
% plots directly with the command:
% export_fig -transparent -nocrop path/filname.pdf for the best results.
 
% Set the colours, line porperties & font size of multi-line plots
% colour RGB values (7 colours)

nn = 8; % fontsize

H=[ 0         0.4470    0.7410
    0.8500    0.3250    0.0980
    0         0.5       0
    0.4940    0.1840    0.5560
    0.4660    0.6740    0.1880
    0.3010    0.7450    0.9330
    0.6350    0.0780    0.1840]; % color codes

set(groot, 'DefaultAxesColorOrder', H,... % colors for multi axis plot
           'DefaultLineLineWidth', 1.5,... % line width is higher since most often plots are scaled down in papers
           'DefaultAxesFontSize', nn,...
           'DefaultTextFontSize', nn,...
           'DefaultLegendFontSize', nn, 'DefaultLegendFontSizeMode', 'manual',...
           'DefaultLegendBox', 'on',...
           'DefaultFigureColor', [1 1 1]); % set frame to white
       
style = {'s';'o';'x';'p';'*';'v';'d';'^';'h';'+';'>';'<';'.'}; % easy call for markers
 
% Allows you to use latex formatting on figures 
set(groot, 'DefaultAxesTickLabelInterpreter', 'latex',...
           'DefaultLegendInterpreter', 'latex',...
           'DefaultTextInterpreter', 'latex');

set(groot, 'DefaultAxesPosition', [0.12 0.12 0.80 0.80],... % controls size of inner plot box, see note
           'DefaultFigurePosition', [100, 100, 900, 800]); % controls size of outer plot, inc whitespace, see note
%       Note: *Position is [xcord ycord xlength ylength]
%       DefaultAxesPosition xcord is 0.17*500 as the plot window is 550 wide.
%       Plot window set to be larger than normal to allow for equations on
%       axis labels. When you save figures they are alligned to the inner
%       plot box, not outer plot window.

set(groot, 'DefaultAxesXGrid', 'on',...
           'DefaultAxesYGrid', 'on',...
           'DefaultAxesZGrid', 'on',... % turn grid on
           'DefaultAxesBox', 'off'); % turn box on

end