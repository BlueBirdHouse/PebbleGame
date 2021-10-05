%clear java;
%clear classes;
disp('A MATLAB Toolbox for Two-Dimensional Rigidity Percolation: The Pebble Game');
disp('   ');
disp('We sincerely hope our toolbox facilitates your researching and teaching.');
disp('Any suggestions, corrections and improvements are welcome.');
disp('Please Email: bluebirdhouse@me.com');
disp('   ');
disp('Sincerely');
disp('Zhang Lin');

example_path = fileparts(mfilename('fullpath'));
example_path = strcat(example_path,'/Examples');
addpath(example_path);

%root_path = fullfile(fileparts(mfilename('fullpath')), '../');
%addpath(genpath(root_path));
%root_path

