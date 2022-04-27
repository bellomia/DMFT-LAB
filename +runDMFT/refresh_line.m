function refresh_line(EXE,doMPI,Nnew,ignList,varargin)
%% Refreshes a pre-existent calculation by Nnew loops [whole-line]
    %
    %   runDMFT.refresh_line(EXE,doMPI,Nnew,ignList,varargin)
    %
    %   EXE                 : Executable driver
    %   doMPI               : Flag to activate OpenMPI
    %   Nnew                : How much loops to add in the refresh
    %   ignList             : Flag to ignore the U_list.txt file
    %   varargin            : Set of fixed control parameters ['name',value]

    %% Open file to write/update converged U-values
    fileID_list = fopen('U_list.txt','a');

    %% Retrieve the list of the *converged* U-values
    U_converged = unique(sort(load('U_list.txt')));

    %% Build the list of all U-values or use the converged ones only
    if isempty(U_converged) || ignList == true
       [U_list, ~] = postDMFT.get_list('U');  
    else
        U_list = U_converged;
    end

    %% Phase-Line: single loop %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    for U = U_list'

        UDIR= sprintf('U=%f',U);       % Define the U-folder name.

        if isfolder(UDIR)
            cd(UDIR);                  % Enter the U-folder (if it exists)
        else
            errstr = 'U_list file appears to be inconsistent: ';
            errstr = [errstr,UDIR];
            errstr = [errstr,' folder has not been found.'];
            error(errstr);
        end

        unconverged = runDMFT.refresh_point(EXE,doMPI,Nnew,varargin{:});

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% HERE WE CATCH A FAILED (unconverged) DMFT LOOP
        if not(unconverged) && isempty(find(U_converged == U,1))
            fprintf(fileID_list,'%f\n', U);         % Update U-list, only
        end                                         % if *newly* converged
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        cd ..                           % Exit the U-folder
  
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    fclose(fileID_list);

end



