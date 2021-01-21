% Add paths
if isdeployed
    addpath(genpath(ctfroot));
else
    addpath(genpath(pwd));
end


nag_init_methods_generate;
nag_init_methods_timing;