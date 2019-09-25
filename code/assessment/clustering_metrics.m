function [centers,wcd_vec,wcd,bcd_mat,bcd,data] = clustering_metrics(x,idx,varargin)
%CLUSTERING_METRICS performes various measurements about the clustering

%INPUT: 
% - x       : matrix; every row an observation and every column a feature.
% - idx     : vector specifying the cluster assignment of each datapoint.
% - varargin: name-value pair aeguments.
%       (a) ('Weights',w) where w is of size(x,2). Weights x based on w.
%       (b) ('option_between_cluster_distance',y). 
%              y = 'bcd_centroids': Distance between two clusters is 
%                  computed based on the distance between their centroids.
%              y = 'bcd_global_center': Distance between two clusters is 
%                  computed based on the distance between the centroids and
%                  the global centroid (center of the dataset).
%              y = 'bcd_wcd': WCSSg based on the total distance between 
%                  points and global centroid minus WCSSk based on the 
%                  total distance between points and their centroid.
%       (c) ('option_within_cluster_distance',y). 
%              y = 'wcd_centroids': Dispersion of a cluster is computed
%                  based on the summed distances between the data points 
%                  belonging to the cluster and the cluster centroid.
%              y = 'wcd_centroids_average': Same as 'wcd_centroids' but the
%                  weighted summed distances are considered.
%              y = 'wcd_datapoints': Dispersion of a cluster is computed
%                  based on the pairwise distance between the data points 
%                  belonging to the cluster.
%              y = 'wcd_datapoints_average': Same as 'wcd_datapoints' but
%                  the weighted pairwise distance is considered.

%OUTPUT:
% - centers: cluster centroids, for weighted clustering x must be weighted.
% - wcd_vec: within cluster distance (Euclidean) of each cluster.
% - wcd    : overall within cluster distance (Euclidean)
% - bcd_mat: between cluster distance (Euclidean).
% - bcd    : overall between cluster distance (Euclidean).

    [n,p] = size(x);
    w = ones(1,p);
    data = x;
    labs = idx;
    dmetric = 'squaredeuclidean';
    option_within_cluster_distance = 'wcd_centroids';
    option_between_cluster_distance = 'bcd_centroids';
    
    for i = 1:length(varargin)
        if isequal(varargin{i},'Weights')
            w = varargin{i+1};
        elseif isequal(varargin{i},'option_within_cluster_distance')
            option_within_cluster_distance = varargin{i+1};            
        elseif isequal(varargin{i},'option_between_cluster_distance')
            option_between_cluster_distance = varargin{i+1};
        elseif isequal(varargin{i},'metric')
            dmetric = varargin{i+1};
        end
    end
    
    K = unique(idx);
    
    % Check if we have special indexes
    % 1. Outliers
    if ismember(0,K)
        a = find(idx==0);
        labs(a) = [];
        data(a,:) = [];
    end

    % Init clusters
    clusters = unique(labs);
    nc = length(clusters);
    centers = zeros(nc,p);
    wcd_vec = zeros(nc,1);
    
    % Weight the data
    data = repmat(w,n,1) .* data;
    
    % Compute centroids and within cluster distance
    for i = 1:nc
        a = find(labs==clusters(i));
        % Centroids
        centers(i,:) = mean(data(a,:));
        % Within cluster distance per cluster
        switch option_within_cluster_distance
            case 'wcd_centroids'
                wcd_vec(i) = sum(pdist2(data(a,:),centers(i,:),dmetric));
            case 'wcd_centroids_average'
                wcd_vec(i) = (1/length(a))*sum(pdist2(data(a,:),centers(i,:),dmetric));                
            case 'wcd_datapoints' %used in the gap statistic
                wcd_vec(i) = (1/(2*length(a)))*sum(pdist(data(a,:),dmetric));
            case 'wcd_datapoints_average' %used in the weighted gap statistic
                wcd_vec(i) = (1/(2*length(a)*(length(a)-1)))*sum(pdist(data(a,:),dmetric));
        otherwise
            error('Wrong option');                
        end
    end
    % Overall within cluster distance
    wcd = nansum(wcd_vec);
    
    % Compute the between cluster distance
    switch option_between_cluster_distance
        case 'bcd_centroids'
            % Distances between centroids
            bcd_mat = squareform(pdist(centers,dmetric));
            bcd = sum(pdist(centers,dmetric));
        case 'bcd_global_center'
            % Distances between centroids and global centroid
            cg = mean(data,1);
            bcd_vec = zeros(nc,1);
            for i = 1:nc
                bcd_vec(i) = pdist2(centers(i,:),cg,dmetric);
            end
            bcd_mat = diag(bcd_vec); %diagonal matrix
            bcd = sum(diag(bcd_mat));
        case 'bcd_wcd'
            % Distance between datapoints and global centroid
            cg = mean(data,1);
            dcg = sum(pdist2(data,cg,dmetric));
            % Distance between datapoints and their centroids
            tmp = zeros(nc,1);
            for i = 1:nc
                a = find(labs==clusters(i));
                % Centroids
                centers(i,:) = mean(data(a,:));
                % Within cluster distance per cluster
                tmp(i) = sum(pdist2(data(a,:),centers(i,:),dmetric));
            end
            bcd_mat = diag(dcg - tmp);
            bcd = dcg - sum(tmp);
        case {'single_link','complete_link','average_link'}
            %TODO
        otherwise
            error('Wrong option');
    end

end

