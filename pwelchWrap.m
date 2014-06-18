function pxx = pwelchWrap(varargin)
%pelchWrap WrapperFunction for applying pwelch 30 seconds epoch
%   pwelch does not seem to work in an abstract function.  wrapper returns
%   the estimate.
%
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
% File created: December 23, 2013
% Last update:  December 23, 2013 
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

% Process input
if nargin == 5
    X = varargin{1};
    WINDOW = varargin{2};
    NOVERLAP = varargin{3};
    F = varargin{4};
    FS = varargin{5};
    freqIndex = [];
end

% Operation Flags
DEBUG = 0;

% Call function
[pxx,f,pxxc] = pwelch(X,WINDOW,NOVERLAP,F,FS);
%pxx = sqrt(pxx*2);

% Prune results if requested
if ~isempty(freqIndex)
    pxx = pxx(freqIndex);
    f = f(freqIndex);
    pxxc = pxxc(freqIndex,:);
end

% Plot data during debug
if DEBUG == 1
    % Display parameters
    map = jet(512);
    freqDisplayMax = 30;
    freqDisplayInc = 5;
    figPos = [-1919, 1, 1920, 1004];
    
    % Create Figure
    fid = figure('Position', figPos);

    % Get and plot datas
    pxxEpoch = pxx;
    fIdx = find(f<= freqDisplayMax);
    set(gca,'Ydir', 'Reverse');
    plot(f(fIdx), pxxEpoch(fIdx,:));
    colormap(map) 

    % Annotate
    title('pwelchWrap');
    xlabel('Epoch Number'); 
end
end

