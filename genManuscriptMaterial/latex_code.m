% Load the sets_algos (after nag_init_graphs2.m)
load(fullfile(pwd,'data_for_plot','res_data_sets.mat'));

% Latex code
resizebox = 1;
placement = 'h';
alignment = '\centering';

statistics = {'min','max','mean','std'}; %matlab commands
str_algorithms = {'K-Means (Hartigan-Wong)';'K-Means (Lloyd)';'K-Medians';'Weiszfeld'};
str_inits = {'Random';'K-Means++';'ROBIN';'Kaufman';'DK-Means++';'D-ROBIN'};
str_datasets = {{'A-sets 1','A-sets 2','A-sets 3',...
    'S-sets 1','S-sets 2','S-sets 3','S-sets 4'},...
    {'Brodinova (1) 1','Brodinova (1) 2','Brodinova (1) 3'},...
    {'Brodinova (1) 4','Brodinova (1) 5','Brodinova (1) 6'},...
    {'gap 1','gap 2','gap 3','gap 4','gap 5'},...
    {'wgap 1','wgap 2','wgap 3','wgap 4','wgap 5','wgap 6'},...
    {'Iris','Ionosphere','Wine','Breast Cancer','Glass','Yeast'},...
    {'mixed 1','mixed 2','mixed 3','mixed 4'},...
    {'Brodinova (2) 1','Brodinova (2) 2','Brodinova (2) 3'},...
    {'Brodinova (2) 4','Brodinova (2) 5','Brodinova (2) 6'}};


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

%table header
str_tableh = strcat('\begin{table}[',placement,']',alignment,'\caption[]{}\label{}');

%tabu header
str_tabuh = strcat('\begin{tabu}{ll|');
for i = 1:length(str_algorithms)
    tmp = repmat('c|',1,length(statistics));
    tmp2 = strcat('[3pt]',tmp);
    str_tabuh = [str_tabuh,tmp2];
end
str_tabuh = [str_tabuh,'[3pt]}'];
%tabu \tabuclines 
str_tabutabuc1 = strcat('\tabucline [3pt]{3-',num2str(length(str_algorithms)*length(statistics)+2),'}');
str_tabutabuc2 = '\\ \tabucline [3pt]{-}';
%\cline
str_cline1 = strcat('\\ \cline{3-',num2str(length(str_algorithms)*length(statistics)+2),'}');
str_cline2 = strcat('\\ \cline{2-',num2str(length(str_algorithms)*length(statistics)+2),'}');

%header 1
str_head1 = [];
for i = 1:length(str_algorithms)
    tmp = strcat('\multicolumn{',num2str(length(statistics)),'}','{c|[3pt]}{',str_algorithms{i},'} &',{' '});
    str_head1 = [str_head1,tmp{1}];
end
str_head1 = ['& & ',str_head1];
str_head1(end-2:end) = [];

%header 2
str_head2 = [];
for i = 1:length(statistics)
    tmp = strjoin(statistics,' & ');
    str_head2 = [str_head2,tmp,' & '];
end
str_head2 = ['& & ',str_head2];
str_head2(end-2:end) = [];
    
%build the tables
k = 1;
for i = 1:length(str_datasets)
    %Get the set
    dataname = str_datasets{i};
    toPrint = {};
    for j = 1:length(dataname)
        %Work with the data of the set
        multistart = strcat('\multicolumn{1}{|[3pt]l|}{\multirow{6}{*}{\rotatebox[origin=c]{90}{',dataname{j},'}}}');
        multistart2 = '\multicolumn{1}{|[3pt]l|}{}';
        for ii = 1:length(str_inits)
            assert(size(collect_all{k},1)==length(str_inits))
            %assert(size(collect_all{k},2)==4*length(str_algorithms))
            tmp = strjoin(arrayfun(@(x) num2str(x),round(collect_all{k}(ii,:),3),'UniformOutput',false),' & ');
            tmp = [' & ', str_inits{ii}, ' & ', tmp];
            if ii == 1
                thisLine = [multistart,tmp,str_cline2];
            else
                if ii == length(str_inits)
                    thisLine = [multistart2,tmp,str_tabutabuc2];
                else
                    thisLine = [multistart2,tmp,str_cline2];
                end
            end
            toPrint = [toPrint;{thisLine}];
        end
        k = k + 1;
    end
    k = 1;

    % We have finished a table, put everything together
    myLTable = {};
    if resizebox
        myLTable = [{str_tableh};{'\resizebox{\columnwidth}{!}{%'}];
    else
        myLTable = {str_tableh};
    end
    myLTable = [myLTable ; {str_tabuh} ; {str_tabutabuc1} ; {str_cline1} ;...
                {str_head1} ; {str_cline1} ; {str_head2} ; {str_tabutabuc2} ;...
                toPrint ; {'\end{tabu}'}];
    if resizebox
        myLTable = [myLTable ; {'}'}];
    end
    myLTable = [myLTable ; {'\end{table}'}];

    % Export to text (.txt) file
    fileID = fopen(fullfile(pwd,strcat('LaTeX_',str_datasets{i}{1},'.txt')),'w');
    for j = 1:size(fileID,1)
        fprintf(fileID,'%s\n',myLTable{j});
    end
    fclose(fileID); 
end

