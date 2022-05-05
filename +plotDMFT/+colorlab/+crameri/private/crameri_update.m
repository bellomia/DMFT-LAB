%% Code to collect latest CRAMERI data into a single .mat file: 

% • Unzip the latest release from http://doi.org/10.5281/zenodo.1243862 (†)
% • Navigate to the resulting dìrectory: …/ScientificColourMaps*/ (* = version)
% • Run the following:

 clear()

 stru = dir('*/*.mat');
 fold = {stru(:).folder}; 

 new = {stru(:).name};
 new = erase(new,'.mat');

 old = {'acton','bam','bamO','bamako','batlow','batlowK','batlowW','berlin','bilbao','broc','brocO',...
        'buda','bukavu','cork','corkO','davos','devon','fes','grayC','hawaii','imola','lajolla','lapaz',...
        'lisbon','nuuk','oleron','oslo','roma','romaO','tofino','tokyo','turku','vanimo','vik','vikO'}; 

 for k = 1:length(new)
      if ~ismember(old,new{k})
         fprintf("'%s' is a new colormap!\n",new{k})
      end
      load([fold{k},'/',new{k},'.mat']);
 end
 
 clear('stru','fold','new','old','k') 

 save('CrameriColourMaps.mat') % Move the .mat archive to the original path [Automate?]

 % (†) TODO: automate this task? With websave() should be easy, but how to select the url?
 %           the global, static, doi does not do the work and I don't understand how to 
 %           automatically get the latest release, I don't want to use the version-specific
 %           doi everytime...