function [clustering_entropy, cluster_entropy] = cl_entropy(true_values, predicted_values)
%CL_ENTROPY computes the clustering entropy and the entropy of each cluster
% Entropy needs to be [0 , log2(Nclasses)] where 0 is obtained when the 
% clusters consist of objects of single classes. In case of binary
% clustering the maximum entropy can be log2(2) = 1.

% INPUT:
%  true_values: data labels
%  predicted_values: clustering results

% OUTPUT:
%  clustering_entropy: clustering entropy
%  cluster_entropy: vector containing the entropy per cluster
    
    if size(true_values) ~= size(predicted_values)
        error('cl_entropy error: vectors of true and predicted values needs to have the same size');
    end

    classes = unique(true_values);
    clusters = unique(predicted_values);
    
    cluster_entropy = zeros(1,length(clusters));
    
    % Entropy per cluster
    for j = 1:length(clusters)
        %elements of this cluster
        idx = find(predicted_values == clusters(j));
        %iterate through number of classes
        for t = 1:length(classes)
            %find the elements of this cluster that belong to class t
            cn = length(find(true_values(idx) == classes(t)));
            %probability
            prob = cn / length(idx);
            if prob > 0 %log2(0) is non-defined thus set to 0
                cluster_entropy(j) = cluster_entropy(j) + (prob * log2(prob));
            end
        end
    end
    
    % Entropy is defined as a positive number
    cluster_entropy = -cluster_entropy;
    
    % Clustering entropy
    clustering_entropy = 0;
    Ndata = length(true_values); %number of datapoints
    for j = 1:length(cluster_entropy)
        cn = length(find(predicted_values == clusters(j))); %number of elements of this cluster
        clustering_entropy = clustering_entropy + ( cluster_entropy(j) * (cn/Ndata) );
    end
    
    % Assert final value
    if clustering_entropy < 0
        error('cl_entropy error: Entropy < 0');
    end
    if clustering_entropy > log2(length(classes))
        assert(length(classes) ~= length(clusters) , 'cl_entropy error: Entropy > log2(Nclasses)');
    end
end