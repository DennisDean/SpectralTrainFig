function fid = imageColorMap( colorMap, clim, data, position)
%imageColorMap Create image with custom scaling of color bar
%   Rescales image value to color map range and rescales color bar to
%   values
%
% Version: 0.1.01
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
% File created: December 29, 2013
% Last update:  December 29, 2013 
%    
% Copyright © [2013] The Brigham and Women's Hospital, Inc. THE BRIGHAM AND 
% WOMEN'S HOSPITAL, INC. AND ITS AGENTS RETAIN ALL RIGHTS TO THIS SOFTWARE 
% AND ARE MAKING THE SOFTWARE AVAILABLE ONLY FOR SCIENTIFIC RESEARCH 
% PURPOSES. THE SOFTWARE SHALL NOT BE USED FOR ANY OTHER PURPOSES, AND IS
% BEING MADE AVAILABLE WITHOUT WARRANTY OF ANY KIND, EXPRESSED OR IMPLIED, 
% INCLUDING BUT NOT LIMITED TO IMPLIED WARRANTIES OF MERCHANTABILITY AND 
% FITNESS FOR A PARTICULAR PURPOSE. THE BRIGHAM AND WOMEN'S HOSPITAL, INC. 
% AND ITS AGENTS SHALL NOT BE LIABLE FOR ANY CLAIMS, LIABILITIES, OR LOSSES 
% RELATING TO OR ARISING FROM ANY USE OF THIS SOFTWARE.
%

% Calculate Parameters
numColorBarTicks = 8;
numColors = size(colorMap,1);

% Rescale image 
gt2Index = find(data>=clim(2));
data(gt2Index)=clim(2);
lt0Index = find(data<=clim(1));
data(lt0Index)=clim(1);
data = floor(data/2*(numColors-1))+1;

% Determine axis values
colorMapVal = [[1:numColors/numColorBarTicks:numColors] numColors]';
colorMapStr = num2str([clim(1):(clim(2)-clim(1))/numColorBarTicks:clim(2)]');

% Plot Spectrum
fid = figure('InvertHardcopy','off','Color',[1 1 1]);
set(fid, 'Position', position)
colormap(colorMap);
image(flipud(data));
colorbar('YTick', colorMapVal,'YTickLabel', colorMapStr);
hold on;

end

