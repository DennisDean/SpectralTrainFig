function figPositionCellStr = ConvertMonitorPosToFigPos
%ConvertMonitorPosToFigPos Create cell array of figure position strings
%   Gets monitor position information and create a string suitable for a
%   popup box with in guide
% 
%  Note that functions are dependent on operating system.  Function may not
%  work on Linux or Apple machines.
%
%
% Version: 0.1.1
%
% ---------------------------------------------
% Dennis A. Dean, II, Ph.D
%
% Program for Sleep and Cardiovascular Medicine
% Brigam and Women's Hospital
% Harvard Medical School
% 221 Longwood Ave
% Boston, MA  02149
%
% File created: July 22, 2013
% Last update:  April 30, 2014 
%    
% Copyright © [2012] The Brigham and Women's Hospital, Inc. THE BRIGHAM AND 
% WOMEN'S HOSPITAL, INC. AND ITS AGENTS RETAIN ALL RIGHTS TO THIS SOFTWARE 
% AND ARE MAKING THE SOFTWARE AVAILABLE ONLY FOR SCIENTIFIC RESEARCH 
% PURPOSES. THE SOFTWARE SHALL NOT BE USED FOR ANY OTHER PURPOSES, AND IS
% BEING MADE AVAILABLE WITHOUT WARRANTY OF ANY KIND, EXPRESSED OR IMPLIED, 
% INCLUDING BUT NOT LIMITED TO IMPLIED WARRANTIES OF MERCHANTABILITY AND 
% FITNESS FOR A PARTICULAR PURPOSE. THE BRIGHAM AND WOMEN'S HOSPITAL, INC. 
% AND ITS AGENTS SHALL NOT BE LIABLE FOR ANY CLAIMS, LIABILITIES, OR LOSSES 
% RELATING TO OR ARISING FROM ANY USE OF THIS SOFTWARE.
%
    
% Define offsets
horOffset = 0;
vertOffset = 0;

% Get Monitor Position
set(0,'units','pixels') 
monitorPositions = get(0,'MonitorPositions');
numberOfMonitors = size(monitorPositions, 1);

% Rearrange monitor position information into form for figure commands
width = monitorPositions(:,3) - monitorPositions(:,1) + ...
    ones(size(monitorPositions,1),1);
height = monitorPositions(:,4)-monitorPositions(:,2) + ...
    ones(size(monitorPositions,1),1);
monitorPositions(:,1) = monitorPositions(:,1)+horOffset;
monitorPositions(:,2) = monitorPositions(:,2)-vertOffset;
monitorPositions(:,3) = width-2*+horOffset;
monitorPositions(:,4) = height-2*vertOffset;

% Create pre and post monitor position string
preStr = ones(numberOfMonitors, 1) *'[';
postStr = ones(numberOfMonitors, 1)*']';

% Create output cell array
monitorPositionsStr = strcat(preStr, num2str(monitorPositions));
monitorPositionsStr = strcat(num2str(monitorPositionsStr),postStr);
figPositionCellStr = cellstr(monitorPositionsStr);
end

