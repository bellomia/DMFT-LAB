function autostep_line(EXE,doMPI,Uold,Ustart,Ustop,varargin)
%% Runs a U-line with feedback-controlled steps: 
%  if dmft does not converge the point is discarded and Ustep is reduced.
%
%   runDMFT.autostep_line(EXE,doMPI,Uold,Ustart,Ustop,varargin)
%
%   EXE                 : Executable driver
%   doMPI               : Flag to activate OpenMPI
%   Uold                : Restart point [NaN or empty -> no restart]
%   Ustart,Ustop        : Input Hubbard interaction [Ustart<U<Ustop or Ustart>U>Ustop]
%   varargin            : Set of fixed control parameters ['name',value]

Ulist = fopen('U_list.txt','a');
Uconv = fopen('U_conv.txt','a');

%% Phase-Line: single loop %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Ustep = [.5,.25,.1,.05,.01];       % Let's keep them hard-coded... for now.
NUstep = length(Ustep);

% Autodetermine span direction
if Ustart > Ustop
   Ustep = -Ustep;
end

nonconvFLG = false;                % Convergence-fail *flag*
nonconvCNT = 0;                    % Convergence-fail *counter*
nonconvMAX = NUstep-1;             % Maximum #{times} we accept DMFT to fail

U = Ustart; 
while abs(U-Ustep-Ustop) > min(abs(Ustep)/2)
%                  ≥ 0 would sometimes give precision problems

    unconverged = runDMFT.single_point(EXE,doMPI,U,Uold,varargin{:});

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% HERE WE CATCH A FAILED (unconverged) DMFT LOOP
    if (unconverged) 
        nonconvFLG = true;
        nonconvCNT = nonconvCNT + 1;
        errorfile = [sprintf('U=%f',U),'/ERROR.README'];
        movefile(errorfile,sprintf('ERROR_U=%f',U));
        fprintf(Ulist,'%f\n', NaN);             % Write on U-list
    else
        fprintf(Ulist,'%f\n', U);	            % Write on U-list
        fprintf(Uconv,'%f\n', U);	            % Write on U-conv
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    if nonconvCNT > nonconvMAX
        error('Not converged: phase-span stops now!');         
    end 

    if nonconvFLG == true
        U = Uold; 			        % if nonconverged we don't want to update 
        nonconvFLG = false;	        % > but we want to reset the flag(!)
    else
        Uold = U; 			        % else we update Uold and proceed to...         
    end

    U = U + Ustep(nonconvCNT+1);    % ...Hubbard update  

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fclose(Ulist); fclose(Uconv);

end





