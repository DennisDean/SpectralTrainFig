function CloseChildrenFigures
%CloseChildrenFigures Close children figures, leave GUIs open
%   An alternative to close all, which may close GUIs for some versions of
%   MATLAV

% Identify figure handles not assoicated with a figure
hands     = get (0,'Children');   % locate fall open figure handles
hands     = sort(hands);          % sort figure handles
numfigs   = size(hands,1);        % number of open figures
indexes   = find(hands-round(hands)==0);

close(hands(indexes));
end

