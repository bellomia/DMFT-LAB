function interactive_line(EXE,doMPI,Uold,Ustart,Ustep,Ustop,varargin)
%% Runs an interactive U-line 
%  if dmft does not converge the point is reiterated: time to change the inputfile!
%
%   runDMFT.interactive_line(EXE,doMPI,Uold,Ustart,Ustep,Ustop,varargin)
%
%   EXE                 : Executable driver
%   doMPI               : Flag to activate OpenMPI
%   Uold                : Restart point [NaN or empty -> no restart]
%   Ustart,Ustep,Ustop  : Input Hubbard interaction [Ustart:Ustep:Ustop]
%   varargin            : Set of fixed control parameters ['name',value]

if sign(Ustop-Ustart) ~= sign(Ustep)
   Ustep = -Ustep;
   warning('Changed sign to Ustep to avoid infinite loops!');
end

Ulist = fopen('U_list.txt','a');
Uconv = fopen('U_conv.txt','a');

%% Phase-Line: single loop %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

nonconvCNT = 0;     % Convergence-fail *counter*
nonconvMAX = 5;     % Maximum #{times} we accept DMFT to fail [hard-coded...]
                    % --> Available time to modify the inputfile on the flight

U = Ustart;
doUpdate = true;
while abs(U-Ustep-Ustop) > abs(Ustep)/2
%                  ≥ 0 would sometimes give precision problems

    unconverged = runDMFT.single_point(EXE,doMPI,U,Uold,varargin{:});

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% HERE WE CATCH A FAILED (unconverged) DMFT LOOP
    if (unconverged)
        nonconvCNT = nonconvCNT + 1;
        errorfile = [sprintf('U=%f',U),'/ERROR.README'];
        movefile(errorfile,'ERROR.README');
        fprintf(Ulist,'%f\n', NaN);             % Write on U-list
    else
        fprintf(Ulist,'%f\n', U);	            % Write on U-list
        fprintf(Uconv,'%f\n', U);	            % Write on U-conv
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    if nonconvCNT > nonconvMAX
        error('Not converged: phase-span stops now!');         
    elseif 0 < nonconvCNT && nonconvCNT < nonconvMAX
        % You manage the workflow manually, by modifying on-the-flight the
        % **external** input-file at runtime. Very effective when feasible.
        doUpdate = false; % ---------------> So you don't want to update...
    end

    if doUpdate
        Uold = U;
        U = U + Ustep;          % Hubbard update  
    else
        U = Uold + Ustep; 		% old-Hubbard update (if nonconverged!)
    end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fclose(Ulist); fclose(Uconv);

end

