%This function generates the figures used in the paper by first loading all
%the files inside the NAG_init_res folder (and subfolders) and arranging
%them accordingly

close all
clear all

% Names of the available algorithms (do not change order)
method_algos = {'algo_K-Means (Hartigan-Wong)','algo_K-Means (Lloyd)','algo_K-Medians'};
% Names of the available init methods (do not change order)
method_centers = {'Random','K-Means++','ROBIN','Kaufman','DK-Means++','D-ROBIN'};
% Names of the available sets (do not change order)
sets = {'-sets','Brodinova','gap','wgap','mixed','hdims'};

extract = 'purity'; %clustering assessment index to use for the figures
plot_stat = 'mean'; %min,max,mean,std: statistic to use for the figures
% Generate a figure comparing custom method_centers
% Add more comparisons using the same format (order: method_centers)
compare = {[3,5,6],[3,5],[3,6]}; 
 
% Load all the result files and keep the info we need
skip_create_sets = 0;
% Generate the vertical bars
skip_plot_bars = 0;
% Generate the horizontal bars used for comparisons
skip_plot_hbars = 0;
% Generate latex table (txt file)
skip_latex_table = 0;

% Put together the gap and wgap in a specific order
merge_gap_wgap = 1;
% Put together the Brodinova and hdims
merge_Brodinova_hdims = 1;

% Generate a folder and store there any mat files from this script
newFolder = 'data_for_plot';



%% Select the folder containing subfolders of the algorithms.
% The algorithms are specified as 'method_algos'. 
% All the algorithm folders must have the same data.
% Sanity check will be performed.
ppath = uigetdir(pwd,'Select the "algo_K-Means" folder or folder containing "res_data_sets.mat"');
if ppath == 0
    return
end
% Check if we have 'res_data_sets.mat' inside the selected folder
S = 1;
[tmp_folder,tmp] = fileparts(ppath);
try
    load(fullfile(tmp_folder,tmp,'res_data_sets.mat'));
    if ~exist('sets_algos','var')
        S = 0;
    end
catch
    S = 0;
end
if S == 0
    % We do not have 'res_data_sets.mat'
    rPath = fullfile(pwd,newFolder);
    if ~exist(rPath,'dir')
        mkdir(newFolder);
    end
    if contains(tmp,'NAG_init_res')
        algo_folders = dir(fullfile(ppath));
        algo_folders = algo_folders(3:end);
    else
        error('Wrong folder.');
    end
    if length(method_algos) ~= length(algo_folders)
        error('The specified folder and specified algoriths do not match.');
    end
    for i = 1:length(method_algos)
        if ~isequal(method_algos{i},algo_folders(i).name)
            error('Some algorithms are missing.');
        end
    end
    for i = 1:length(algo_folders)
        files1 = dir(fullfile(algo_folders(i).folder,algo_folders(i).name,'*.mat'));
        files1 = {files1.name};
        for j = 1:length(algo_folders)
            files2 = dir(fullfile(algo_folders(j).folder,algo_folders(j).name,'*.mat'));
            files2 = {files2.name};    
            if ~isequal(files1,files2)
                error('The algorithm folders do not contain the same data.');
            end
        end
    end
    fprintf('\nFolder accepted.\n');
    clear files1 files2
else
    % We have 'res_data_sets.mat'
    skip_create_sets = 1;
    rPath = fullfile(tmp_folder,tmp);
end


%% Make object to hold the results we need
if ~skip_create_sets
    sets_algos = cell(length(sets),length(method_algos)); %sets x algorithms
    for i = 1:length(algo_folders)
        files = dir(fullfile(algo_folders(i).folder,algo_folders(i).name,'*.mat'));
        files_n = {files.name};
        for j = 1:length(sets)
            fprintf('\nWorking: %s, %s...\n',algo_folders(i).name,sets{j});
            %Find the files per specified set
            str = cellfun(@(x) contains(x,sets{j}),files_n);
            if isequal(sets{j},'gap')
                str2 = cellfun(@(x) contains(x,'wgap'),files_n);
                str = ~(str==str2);
            end        
            str = find(str==1);
            %Load these files and keep/compute the results we need 
            models_stats = {}; %init_methods x model_repetitions
            for s = 1:length(str)
                %Load and check if file is ok
                load(fullfile(files(str(s)).folder,files(str(s)).name));
                %Each variable 'resModel': 
                %cell:       1 x number_of_datasets (model repetitions), 
                %each cell:  method_centers x iterations            
                if ~exist('resModel','var')
                    error(sprintf('File does not contain the data we need: %s \n', fullfile(files(str(s)).folder,files(str(s)).name)));
                end
                %Each variable 'model_stats': models x datasets
                model_stats = cell(1,length(resModel));
                for nd = 1:length(resModel)
                    curr = resModel{nd};
                    inits_stats = nan(size(curr,1),4); %4 are the stats
                    for nm = 1:size(curr,1)
                        row = curr(nm,:);
                        % Extract all the indexes
                        if isempty(row(2).idx)
                            %Deterministic
                            vals = row.perfExternal;
                        else
                            %Stochastic
                            vals = arrayfun(@(x) x.perfExternal,row);
                        end   
                        % Get the values of the index of interest
                        fields = fieldnames(vals);
                        index = [];
                        for te = 1:length(fields)
                            if isequal(fields{te},extract)
                                eval(['index_vals=[vals.' fields{te} '];']);
                                index = [min(index_vals),max(index_vals),mean(index_vals),std(index_vals)];
                                break;
                            end
                        end      
                        %Store stats for iterations
                        inits_stats(nm,:) = index;                    
                    end
                    model_stats{1,nd} = inits_stats;
                end
                models_stats = [models_stats;model_stats];            
                clear 'resModel'
            end
            sets_algos{j,i} = models_stats;
        end
    end
    fprintf('Saving file do not pause execution...\n')
    save(fullfile(rPath,'res_data_sets.mat'),'sets_algos','-v7.3');
    fprintf('File saved.\n')
end


%% Check if we have the 'sets_algos' variable or 'res_data_sets.mat' file
if ~exist('sets_algos','var')
    try
        load(fullfile(rPath,'res_data_sets.mat'));
    catch
        error('Set skip_create_sets switch to 0');
    end
end


%% Extras
% Merge the gap and weighted gap
if merge_gap_wgap
    a = find(cellfun(@(x) isequal(x,'gap'),sets)==1);
    b = find(cellfun(@(x) isequal(x,'wgap'),sets)==1);
    tmp = cell(1,3);
    for i = 1:3
        tmp_ = [sets_algos{a,i}(2,:) ; sets_algos{a,i}(3,:) ; sets_algos{b,i}(1,:) ; sets_algos{b,i}(6,:) ; ...
                sets_algos{a,i}(4,:) ; sets_algos{b,i}(5,:) ; ...
                sets_algos{a,i}(5,:) ; sets_algos{b,i}(4,:) ; ...
                sets_algos{b,i}(2,:) ; sets_algos{b,i}(3,:)];
        tmp{i} = tmp_;
    end
    sets_algos = [sets_algos;tmp];
    sets = [sets,'gap+wgap'];
end
% Merge Brodinova and hdims
if merge_Brodinova_hdims
    a = find(cellfun(@(x) isequal(x,'Brodinova'),sets)==1);
    b = find(cellfun(@(x) isequal(x,'hdims'),sets)==1);    
    tmp = cell(1,3);
    for i = 1:3
        tmp_ = [sets_algos{a,i} ; sets_algos{b,i}];
        tmp{i} = tmp_;
    end
    sets_algos = [sets_algos;tmp];
    sets = [sets,'Brodinova+hdims'];
end


%% Statistics on the datasets over each set
[n,m] = size(sets_algos);
sets_stats = cell(n,m);
for i = 1:m
    for j = 1:n
        [nn,mm] = size(sets_algos{j,i});
        if mm == 1
            sets_stats{j,i} = sets_algos{j,i};
            continue
        else
            tmp_sets = cell(nn,1);
            for ii = 1:nn
                % For each init method
                zz = sets_algos{j,i}(ii,:);
                avg = sum(cat(3,zz{:}),3) ./ mm;
                tmp_sets{ii} = avg;
            end
            sets_stats{j,i} = tmp_sets;
        end
    end
end


%% p-values on the datasets over each set
[n,m] = size(sets_algos);
sets_p = cell(n,m);
for i = 1:m
    for j = 1:n
        [nn,mm] = size(sets_algos{j,i});
        if mm == 1
            continue
        else
            struct_p = struct('min',[],'max',[],'mean',[],'std',[]);
            struct_p = repmat(struct_p,nn,1);
            for ii = 1:nn
                zz = sets_algos{j,i}(ii,:);
                for k = 1:4
                    %For each stat
                    stat_p = nan(length(method_centers),length(method_centers));
                    for iii = 1:length(method_centers)
                        %First column
                        a = cellfun(@(x) x(iii,k),zz);
                        for jjj = iii+1:length(method_centers)
                            %Second column
                            b = cellfun(@(x) x(jjj,k),zz);
                            %Hypothesis testing
                            [p,~,~] = signrank(a',b');
                            stat_p(iii,jjj) = p;
                            stat_p(jjj,iii) = p;
                        end
                    end
                    switch k
                        case 1
                            struct_p(ii).min = stat_p;
                        case 2
                            struct_p(ii).max = stat_p;
                        case 3
                            struct_p(ii).mean = stat_p;
                        case 4
                            struct_p(ii).std = stat_p;
                    end
                end
            end
            sets_p{j,i} = struct_p;
        end
    end
end     


%% p-values on the datasets over algorithms
[n,m] = size(sets_algos);
sets_p_algo = cell(n,m*m);
k = 1;
for i = 1:m-1
    for I = i+1:m
        for j = 1:n
            A1 = sets_algos{j,i};
            A2 = sets_algos{j,I};
            [nn,mm] = size(sets_algos{j,i});
            ps_set = cell(nn,1);
            if mm == 1
                continue
            else
                for s = 1:nn
                    A1_ = A1(s,:);
                    A2_ = A2(s,:);
                    ps = [];
                    for al = 1:length(method_centers)
                        tmp1 = [];
                        tmp2 = [];
                        for dd = 1:length(A1_)
                            tmp1 = [tmp1;A1_{dd}(al,:)];
                            tmp2 = [tmp2;A2_{dd}(al,:)];
                        end
                        z = size(tmp1,2);
                        p = nan(1,z);
                        for zz = 1:z
                            [p(zz),~,~] = signrank(tmp1(:,zz),tmp2(:,zz));
                        end
                        ps = [ps;p];
                    end
                    ps_set{s} = ps;
                end
            end
            sets_p_algo{j,k} = ps_set;
        end
        k = k + 1;
    end
end


%% Find cases where there is significant difference and indicate the best
counter_init = zeros(length(method_centers),size(sets_stats,2));
counter_perf_algo1 = zeros(length(method_centers),size(sets_stats,2));
switch plot_stat
    case 'min'
        s = 1;
    case 'max'
        s = 2;
    case 'mean'
        s = 3;
    case 'std'
        s = 4;
    otherwise
        error('Wrong plot_stat option.');
end
% Do not use the merged models
reduce = 0;
if merge_gap_wgap && merge_Brodinova_hdims
    reduce = 2;
elseif merge_gap_wgap || merge_Brodinova_hdims
    reduce = 1;
end
for i = 1:size(sets_stats,1) - reduce
    if isempty(sets_p_algo{i,1})
        % Only for models not standalone datasets
        continue
    end
    k = 1;
    for j1 = 1:size(sets_stats,2)
        v1 = sets_stats{i,j1};
        for j2 = j1+1:size(sets_stats,2)
            v2 = sets_stats{i,j2};
            ps = sets_p_algo{i,k};
            for ii = 1:length(v1)
                diff = v1{ii} - v2{ii};
                diff = diff(:,s);
                a = find(ps{ii}(:,s) < 0.05);
                for pi = 1:length(a)
                    counter_init(a(pi),k) = counter_init(a(pi),k)+1;
                    if diff(a(pi)) > 0
                        counter_perf_algo1(a(pi),k) = counter_perf_algo1(a(pi),k) + 1;
                    end
                end
            end
            k = k + 1;
        end
    end
end
counter_perf_algo2 = counter_init - counter_perf_algo1;
save(fullfile(rPath,'perf_summary.mat'),'counter_perf_algo1','counter_perf_algo2','counter_init');


%% Plot: Vertical bars
if ~skip_plot_bars
    % Plots comparing init methods separately per algorithm
    switch plot_stat
        case 'min'
            s = 1;
        case 'max'
            s = 2;
        case 'mean'
            s = 3;
        case 'std'
            s = 4;
        otherwise
            error('Wrong plot stat option.');
    end

    [ns,na] = size(sets_stats);
    for I = 1:length(compare)+2 % stochastic, deterministic and comparisons
        for i = 1:na
            % For each algorithm
            for j = 1:ns
                % For each set
                vals = sets_stats{j,i};
                % Collect the values for plotting
                vals_plot = [];
                vals_ps = {};
                vals_min = [];
                vals_max = [];
                for ii = 1:length(vals)
                    %Each row is a bar group
                    switch I
                        case 1
                            %1:3 are the stochastic methods
                            vals_plot = [vals_plot ; (vals{ii}(1:3,s))'];
                            vals_min = [vals_min ; (vals{ii}(1:3,1))'];
                            vals_max = [vals_max ; (vals{ii}(1:3,2))'];
                            tmp = sets_p{j,i};
                            if ~isempty(tmp)
                                eval(['tmp = tmp(',num2str(ii),').',plot_stat,';']);
                                vals_ps = [vals_ps,{tmp(1:3,1:3)}];
                            end
                        case 2
                            %4:6 are the deterministic methods
                            vals_plot = [vals_plot ; (vals{ii}(4:6,s))'];
                            vals_min = [vals_min ; (vals{ii}(4:6,1))'];
                            vals_max = [vals_max ; (vals{ii}(4:6,2))'];
                            tmp = sets_p{j,i};
                            if ~isempty(tmp)
                                eval(['tmp = tmp(',num2str(ii),').',plot_stat,';']);
                                vals_ps = [vals_ps,{tmp(4:6,4:6)}];
                            end
                        otherwise
                            %compare selected methods
                            vals_plot = [vals_plot ; (vals{ii}(compare{I-2},s))'];
                            vals_min = [vals_min ; (vals{ii}(compare{I-2},1))'];
                            vals_max = [vals_max ; (vals{ii}(compare{I-2},2))'];
                            tmp = sets_p{j,i};
                            if ~isempty(tmp)
                                eval(['tmp = tmp(',num2str(ii),').',plot_stat,';']);
                                vals_ps = [vals_ps,{tmp(compare{I-2},compare{I-2})}];
                            end          
                    end
                end
                % Generate the plot
                nag_init_graphs2_plot(vals_plot,vals_ps,I,i,j,method_centers,extract,plot_stat,vals_min,vals_max);
            end
        end
    end
end


%% Plot: Horizontal bars
if ~skip_plot_hbars
    % Plots comparing init methods per two algorithms
    switch plot_stat
        case 'min'
            s = 1;
        case 'max'
            s = 2;
        case 'mean'
            s = 3;
        case 'std'
            s = 4;
        otherwise
            error('Wrong plot_stat option.');
    end

    [ns,na] = size(sets_stats);
    vals_plot_collect = cell(ns,na);
    for II = 1:length(compare)+2 % stochastic, deterministic and comparisons
        for i = 1:ns
            % For each set    
            for I = 1:na 
                % For each algorithm 
                valsA = sets_stats{i,I}; 
                vals_plot = [];
                for j = 1:length(valsA)
                    % For each model
                    switch II
                        case 1
                            vals_plot = [vals_plot,valsA{j}(1:3,s)];
                        case 2
                            vals_plot = [vals_plot,valsA{j}(4:6,s)];
                        otherwise
                            %compare selected methods
                            vals_plot = [vals_plot,valsA{j}(compare{II-2},s)];
                    end
                end
                vals_plot_collect{i,I} = vals_plot; % studies x algorithms
            end
        end
        
        for i = 1:ns %set 
            for I = 1:na %algorithm 1
                v1 = vals_plot_collect{i,I};
                [n,m] = size(v1);
                for J = I+1:na %algorithm 2
                    if I == 1 && J == 2
                        ps = sets_p_algo{i,1};
                    elseif I == 1 && J == 3
                        ps = sets_p_algo{i,2};
                    elseif I == 2 && J == 3
                        ps = sets_p_algo{i,3};
                    else
                        error('Fix p-values');
                    end
                    send_ps = [];
                    for zz = 1:length(ps)
                        ps_ = ps{zz}(:,s);
                        switch II
                            case 1
                                ps_ = ps_(1:3);
                            case 2
                                ps_ = ps_(4:6);
                            otherwise
                                %compare selected methods
                                ps_ = ps_(compare{II-2});                            
                        end   
                        send_ps = [send_ps;ps_'];
                    end
                    v2 = vals_plot_collect{i,J};
                    send_ps = send_ps';
                    nag_init_graphs2_plot_h(v1,v2,i,I,J,II,method_centers,extract,plot_stat,send_ps);
                end
            end
        end
    end
end


%% Generate latex table
if ~skip_latex_table
    % Collect the stats in table format
    collect_all = cell(sum(cellfun(@(x) size(x,1),sets_algos(:,1))),1);
    k = 1;
    for i = 1:size(sets_algos,1)
        c = sets_algos(i,:);
        tmps_algo = [];
        for j = 1:size(c,2)
            tmp = c{j}; %j-th algorithm
            tmps = [];
            for ii = 1:size(tmp,1)
                %Compute the stats
                mi = [];
                ma = [];
                me = [];
                st = [];
                for jj = 1:size(tmp,2)
                    mi = [mi,tmp{ii,jj}(:,1)];
                    ma = [ma,tmp{ii,jj}(:,2)];
                    me = [me,tmp{ii,jj}(:,3)];
                    st = [st,tmp{ii,jj}(:,4)];
                end
                %arr = [min(mi,[],2) , max(ma,[],2) , mean(me,2) , std(st,[],2)];
                arr = [mean(mi,2) , mean(ma,2) ,mean(me,2) , mean(st,2)];
                tmps = [tmps;{arr}];
            end
            tmps_algo = [tmps_algo,tmps];
        end
        for j = 1:size(tmps_algo,1)
            collect_all{k} = cell2mat(tmps_algo(j,:));
            k = k + 1;
        end   
    end
    
    % Latex code
    statistics = {'min','max','mean','std'}; %matlab commands
    str_algorithms = {'K-Means (Hartigan-Wong)';'K-Means (Lloyd)';'K-Medians'};
    str_datasets = {'A-sets 1','A-sets 2','A-sets 3',...
        'S-sets 1','S-sets 2','S-sets 3','S-sets 4',...
        'Brodinova (1) 1','Brodinova (1) 2','Brodinova (1) 3',...
        'Brodinova (1) 4','Brodinova (1) 5','Brodinova (1) 6',...
        'gap 1','gap 2','gap 3','gap 4','gap 5',...
        'wgap 1','wgap 2','wgap 3','wgap 4','wgap 5','wgap 6',...
        'mixed 1','mixed 2','mixed 3','mixed 4',...
        'Brodinova (2) 1','Brodinova (2) 2','Brodinova (2) 3',...
        'Brodinova (2) 4','Brodinova (2) 5','Brodinova (2) 6'};
    nalgos = length(str_algorithms);
    cols_per_algo = length(statistics);
    cols_for_algos = nalgos * cols_per_algo;
    total_cols = cols_for_algos + 2; %data name and init names
    rows_inits = length(method_centers);
    rows_total = rows_inits + 2; %algo names and stats names   
    %Header
    str = [' & \multicolumn{',num2str(cols_per_algo),'}{c|}'];
    header = cell(length(str_algorithms),1);
    for i = 1:nalgos
        header{i} = [str,'{',num2str(str_algorithms{i}),'}'];
    end
    header = [header;'\\ \cline{3-',num2str(total_cols),'}'];
    header = strjoin(header,''); 
    %Subheader
    subheader = ['& & ',strjoin( (repmat({strjoin(statistics,' & ')},3,1))' ,' & ') , ' \\ \hline'];
    %Rows type 1
    init_rows_1 = cell(length(str_datasets),1);
    for i = 1:length(str_datasets)
        tmp = char(strjoin(string(round(collect_all{i}(1,:),3)),{' & '}));
        tmp = strjoin([{' & '},{tmp},{' \\ \cline{2-',num2str(total_cols),'}'}],'');
        init_rows_1{i} = ['\multicolumn{1}{|l|}{\multirow{',num2str(rows_inits),'}{*}{\rotatebox[origin=c]{90}{',str_datasets{i},'}}} '...
            '& ',method_centers{1},tmp];
    end    
    %Rows body
    part_body = {};
    for ii = 1:length(str_datasets)
        part_body = [part_body;init_rows_1{ii}];
        for i = 1:rows_inits-1
            if i == rows_inits-1
                tmp = char(strjoin(string(round(collect_all{ii}(i+1,:),3)),{' & '}));
                tmp = strjoin([{' & '},{tmp},{' \\ \hline'}],'');            
                part_body = [part_body ; ['\multicolumn{1}{|l|}{} & ',method_centers{i+1},tmp] ];
            else
                tmp = char(strjoin(string(round(collect_all{ii}(i+1,:),3)),{' & '}));
                tmp = strjoin([{' & '},{tmp},{' \\ \cline{2-',num2str(total_cols),'}'}],'');            
                part_body = [part_body ; ['\multicolumn{1}{|l|}{} & ',method_centers{i+1},tmp] ];
            end
        end
    end   
    %LaTeX parts
    part_h = {'\begin{table}[h]';...
                 ['\begin{tabular}{ll',repmat('|c',1,cols_for_algos),'|}'];...
                 ['\cline{3-',num2str(total_cols),'}'];...
                 ['&',header,];...
                 subheader;...
             };
    part_e = {'\end{tabular}';'\end{table}'};
    %LaTeX table to text file
    fileID = fopen(fullfile(rPath,'myLatexTable.txt'),'w');
    for i = 1:length(part_h)
        fprintf(fileID,'%s\n',part_h{i});
    end
    for i = 1:length(part_body)
        fprintf(fileID,'%s\n',part_body{i});
    end
    for i = 1:length(part_e)
        fprintf(fileID,'%s\n',part_e{i});
    end
    fclose(fileID);    
end