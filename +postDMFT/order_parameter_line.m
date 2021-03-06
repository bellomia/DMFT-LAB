function [ids,ordpms,U_list] = order_parameter_line(U_LIST)
%% Getting a list of order parameter values, from directories.
%
%       [ids,ordpms,U_list] = postDMFT.order_parameter_line(U_LIST)
%
%  ids: a cell of strings, the names of the order parameters 
%  ordpms: a cell of arrays, corresponding to the names above, for all U
%  U_LIST: an optional array of values of Hubbard interaction: where to search
%  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    if ~exist('U_LIST','var') || isempty(U_LIST)
    [U_LIST, ~] = postDMFT.get_list('U'); 
    else
    U_LIST = sort(U_LIST);
    end
    % Then we can proceed spanning all the U-values
    Nu = length(U_LIST);
    cellordpms = cell(Nu,1);
    for iU = 1:length(U_LIST)
        U = U_LIST(iU);
        UDIR= sprintf('U=%f',U);
        if ~isfolder(UDIR)
           errstr = 'U_list appears to be inconsistent: ';
           errstr = [errstr,UDIR];
           errstr = [errstr,' folder has not been found.'];
           error(errstr);
        end
        cd(UDIR); 
        [ids, cellordpms{iU}] = postDMFT.get_order_parameters();
        cd('..');
    end
    % We need some proper reshaping
    Nordpms = length(ids);
    ordpms = cell(1,Nordpms);
    for jORDPMS = 1:Nordpms
        ordpms{jORDPMS} = zeros(Nu,1);
        for iU = 1:Nu
           ordpms{jORDPMS}(iU) = cellordpms{iU}(jORDPMS);
        end
        filename = [ids{jORDPMS},'.txt'];
        postDMFT.writematrix(ordpms{jORDPMS},filename,'Delimiter','tab');
    end
    U_list = U_LIST;
end


