function C = kmpp_init(x,k,varargin)
%KMPP_INIT implements the K-Means++ initialisation method [1].
%Based on the implementation of:
%James McCaffrey, Test Run - K-Means++ Data Clustering, MSDN Magazine Blog,
%August 2015, https://bit.ly/2K7ihXV

%References:
% [1] Arthur, David, and Sergei Vassilvitskii. "k-means++: The advantages
%     of careful seeding." Proceedings of the eighteenth annual ACM-SIAM 
%     symposium on Discrete algorithms. Society for Industrial and 
%     Applied Mathematics, 2007.

% Author: Avgoustinos Vouros, avouros1@sheffield.ac.uk

%%

% Input:
% - x : a matrix where rows are observations and columns are attributes.
% - k : number of target clusters.
% - varargin: if one more variable is given the algorithm uses init seed
%             (becomes deterministic).

% Output:
% - C : vector, indeces of x (datapoints) to be used as initial
%       centroids. 

    % Make the algorithm deterministic
    if ~isempty(varargin)
        s = RandStream('mt19937ar','Seed',0);
        RandStream.setGlobalStream(s);
    end

    [n,~] = size(x);
    
    % Distance matrix
    min_distances = inf(n,1);

    % Pick the first seed at random
    r = randi([1 n],1,1);
    C = r;

    while length(C) < k
        % Fitness selection (Roulette Wheel Selection):
        % Take the distances of every item from the nearest centroid
        d = Euclidean2(x,x(C(end),:));
        % Take the minimum distance of points to nearest clusters
        min_distances = min(min_distances,d);
        prob = min_distances ./ sum(min_distances);
        %Cumulative probabilities
        cumprob = cumsum(prob);   
        %Random number between (0,1)
        r = rand;
        %Select the first cumprob > r as the next centroid
        sel = find(cumprob > r);
        C = union(C,sel(1),'Stable'); %ensure we do not have duplicates 
    end
    
    % Squared Euclidean distances between every datapoint and a point
    function dist = Euclidean2(datapoins,point)
        dist = zeros(size(datapoins,1),1);
        for ii = 1:size(datapoins,1)
            dist(ii) = sum( (datapoins(ii,:) - point) .^ 2 );
        end
    end
end