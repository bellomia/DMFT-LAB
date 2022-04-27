function dry_line(EXE,doMPI,Uold,Ustart,Ustep,Ustop,varargin)
%% Runs a U-line with no other convergence control than building a U_list.txt file
    %
    %   runDMFT.dry_line(EXE,doMPI,Uold,Ustart,Ustep,Ustop,varargin)
    %
    %   EXE                 : Executable driver
    %   doMPI               : Flag to activate OpenMPI
    %   Uold                : Restart point [NaN -> no restart]
    %   Ustart,Ustep,Ustop  : Input Hubbard interaction [Ustart:Ustep:Ustop]
    %   varargin            : Set of fixed control parameters ['name',value]

    if sign(Ustop-Ustart) ~= sign(Ustep)
       Ustep = -Ustep;
       warning('Changed sign to Ustep to avoid infinite loops!');
    end

    Ulist = fopen('U_list.txt','a');

    %% Phase-Line: single loop %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    U = Ustart; 
    while abs(U-Ustep-Ustop) > abs(Ustep)/2
    %                  ≥ 0 would sometimes give precision problems

        unconverged = runDMFT.single_point(EXE,doMPI,U,Uold,varargin{:});

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% HERE WE CATCH A FAILED (unconverged) DMFT LOOP
        if not(unconverged)
           fprintf(Ulist,'%f\n', U);   % Update U-list (only if converged)
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        Uold = U;
        U = U + Ustep;                  % Hubbard update  

    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    fclose(Ulist);

end


