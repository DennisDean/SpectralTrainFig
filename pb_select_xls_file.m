function [xls_fn xls_pn xls_file_is_selected ] = ...
                                       pb_select_xls_file(current_xls_path)
%pb_select_xls_file Select xls file
%   File created to facilitate building GUI's from command line routines
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
% File created: June 7, 2014
% Last update:  June 7, 2014 
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
    
% Program Constant
DEBUG = 1;


% Select file to open. 
[xls_fn, xls_pn, filterindex] = uigetfile( ...
{  '*.xls','XLS Files (*.xls)'; ...
   '*.xlsx','XLS Files (*.xlsx)'; ...
   '*.XLS','XLS Files (*.XLS)'; ...
   '*.XLSX','XLS Files (*.XLSX)'; ...
   '*.*',  'All Files (*.*)'}, ...
   'Select XLS files', ...
   current_xls_path,...
   'MultiSelect', 'off');

% Check output
if isequal(xls_fn,0)
   xls_file_is_selected = 0;
else
   xls_file_is_selected = 1;
end

end

