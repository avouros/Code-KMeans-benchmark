function [idx,dims,cls] = load_clustering_basic_dataset(fn,set,number)
%LOAD_DATASET loads a 2D Gaussian dataset from:
% @misc{ClusteringDatasets,
%     author = {Pasi Fr\"anti and Sami Sieranoja},
%     title = {K-means properties on six clustering benchmark datasets},
%     year = {2018},
%     volume  = {48},
%     number  = {12},
%     pages   = {4743--4759},
%     url = {http://cs.uef.fi/sipu/datasets/},
% }


% fn = 'D:\DATA\Practice Datasets\Clustering basic benchmark'
%[idx,data,cls] = load_dataset(fn,'A-sets',1)
   
    assert(exist(fn,'dir')==7,'Wrong path');
    fn = fullfile(fn,set);
    assert(exist(fn,'dir')==7,'Wrong set');
    
    switch set
        case 'A-sets'
            fn = fullfile(fn,'Asets.csv');
            s = 1:3;
            if sum(ismember(s,number)) ~= 1
                error('Wrong number');
            end            
        case 'S-sets'
            fn = fullfile(fn,'Ssets.csv');
            s = 1:4;
            if sum(ismember(s,number)) ~= 1
                error('Wrong number');
            end    
    end
    
    assert(exist(fn,'file')==2,'Set non found');

    %% Read the file
    fid=fopen(fn,'r');
    cont=fscanf(fid,'%c');
    cont=regexprep(cont,'\t',',');
    fclose(fid);

    MM = {};
    
    M = textscan(cont,'%s','delimiter', '\n');
    M = M{1};
    for i=1:length(M)
        temp=textscan(M{i},'%s','delimiter', {'\t',','});
        temp=temp{1};
        if length(temp) < size(MM,2)
            a = size(MM,2) - length(temp);
            temp = [temp;cell(1,a)];
        end
        MM = [MM;temp'];
    end
    
    %% Parse the dataset
    values = MM(2:end,:);
    switch number
        case 1
            idx = values(:,1);
            a = find(cellfun(@isempty,idx)==1);
            idx(a) = [];
            idx = cellfun(@str2num,idx,'UniformOutput', true);
            dims = values(:,2:3);
            a = find(cellfun(@isempty,dims(:,1))==1);
            dims(a,:) = [];            
            dims = cellfun(@str2num,dims,'UniformOutput', true);
            cls = values(:,4:5);
            a = find(cellfun(@isempty,cls(:,1))==1);
            cls(a,:) = [];            
            cls = cellfun(@str2num,cls,'UniformOutput', true);
        case 2
            idx = values(:,6);
            a = find(cellfun(@isempty,idx)==1);
            idx(a) = [];
            idx = cellfun(@str2num,idx,'UniformOutput', true);
            dims = values(:,7:8);
            a = find(cellfun(@isempty,dims(:,1))==1);
            dims(a,:) = [];            
            dims = cellfun(@str2num,dims,'UniformOutput', true);
            cls = values(:,9:10);
            a = find(cellfun(@isempty,cls(:,1))==1);
            cls(a,:) = [];            
            cls = cellfun(@str2num,cls,'UniformOutput', true);            
        case 3
            idx = values(:,11);
            a = find(cellfun(@isempty,idx)==1);
            idx(a) = [];
            idx = cellfun(@str2num,idx,'UniformOutput', true);
            dims = values(:,12:13);
            a = find(cellfun(@isempty,dims(:,1))==1);
            dims(a,:) = [];            
            dims = cellfun(@str2num,dims,'UniformOutput', true);
            cls = values(:,14:15);
            a = find(cellfun(@isempty,cls(:,1))==1);
            cls(a,:) = [];            
            cls = cellfun(@str2num,cls,'UniformOutput', true);                 
        case 4
            idx = values(:,16);
            a = find(cellfun(@isempty,idx)==1);
            idx(a) = [];
            idx = cellfun(@str2num,idx,'UniformOutput', true);
            dims = values(:,17:18);
            a = find(cellfun(@isempty,dims(:,1))==1);
            dims(a,:) = [];            
            dims = cellfun(@str2num,dims,'UniformOutput', true);
            cls = values(:,19:20);
            a = find(cellfun(@isempty,cls(:,1))==1);
            cls(a,:) = [];            
            cls = cellfun(@str2num,cls,'UniformOutput', true);                 
    end

end

