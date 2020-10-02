function [Silh2,Silh,Silh_cl,Si] = cl_SilhouetteIndex_par(data,indexes,varargin)
%CL_SILHOUETTEINDEX computes the Silhouette index.
% The larger the index (Silh), the better the data partition. 
% The silhouette value ranges from -1 to +1. 

% INPUT:
% - data: the dataset; rows: observations, columns: features
% - indexes: cluster of each datapoint
% - centroids: cluster centroids; rows: clusters, columns: features
% - Name-Value Pair Arguments:
%   - 'metric': any distance metric of https://bit.ly/2ztpzSz   

% OUTPUT:
% - Silh2: The Silhouette index, [-1 +1] (empirical prior).
% - Silh: The Silhouette index, [-1 +1].
% - Silh_cl: vector containing the Silhouette index of each cluster.
% - Si: vector containing the Silhouette index of each datapoint.

% Formula for Silh2 and Silh: MATLAB documentation https://goo.gl/JngbVS


    dmetric = 'squaredeuclidean';
    for i = 1:length(varargin)
        if isequal(varargin{i},'metric')
            dmetric = varargin{i+1};
        end
    end

    k = unique(indexes); %different clusters
    nk = length(k);      %number of clusters
    n = size(data,1);    %number of datapoints
    
    Silh_cl = zeros(1,length(k));
    Si = zeros(size(data,1),1);
    dinter = zeros(size(data,1),1);
    douter = inf(size(data,1),1);

    parfor i = 1:n
        % Find the cluster of the ielement
        icl = indexes(i);        
        % Average distance from the ith point to the other points in the same 
        % cluster as i.
        ineightbors = data(indexes == icl,:);
        %Compute the average distance between the ielement and the other
        %datapoints of the ielement's cluster
        di = pdist2(data(i,:),ineightbors,dmetric);
        m = size(ineightbors,1);
        dinter(i) = sum(di) / max((m-1),1);          
        % Average distance from the ith point to the other points in different 
        % clusters.
        for j = 1:nk
            if icl ~= k(j) %skip the cluster of the ielement
                %Get all the elements of the cth cluster
                others = data(indexes == k(j),:);
                %Find the average distance from the ielement to points in 
                %the cth different cluster
                do = pdist2(data(i,:),others,dmetric);
                m = size(others,1);
                do = sum(do) / m; 
                %Minimum average distance
                if do < douter(i)
                    douter(i) = do;
                end
            end
        end
    end    
    
    % Silhouette index per datapoint
    Si = (douter - dinter) ./ (max([dinter,douter],[],2));
    
    % Silhouette index per cluster
    parfor i = 1:nk
        sel = indexes == k(i);
        Silh_cl(i) = mean(Si(sel));
    end
    
    % Clustering Silhouette index (equal)
    Silh = mean(Silh_cl);
    % Clustering Silhouette index (empirical prior)
    Silh2 = mean(Si);
    % Assert final value
    if Silh2 > 1 || Silh2 < -1
        error('cl_SilhouetteIndex error: Bug found!');
    end    
end

