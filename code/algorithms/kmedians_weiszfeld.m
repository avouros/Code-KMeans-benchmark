function [idx,centroids,iterations,ifault] = kmedians_weiszfeld(x,k,init_centroids,ITER,varargin)
%KMEDIAN_WEISZFELD uses the Weiszfeld's algorithm to compute the geometric 
%median.

%INPUT:
% x: datapoins; rows = observations, columns = attributes
% k: number of target clusters
% init_centroids: initial centroids positions; if empty then random positions
% iterations: number of iterations

%OUTPUT
% idx: vector; the cluster of each datapoint.
% centroids: final centroids locations.
% iterations: number of iterations before converged.
% ifault: 2 = no converged, 1 = empty cluster(s), 0 = converged

    % Assert initial centroids
    s = size(init_centroids);
    assert(s(1)==k);
    assert(s(2)==size(x,2));  
    
    dmetric = 'squaredeuclidean';
    for i = 1:length(varargin)
        if isequal(varargin,'metric')
            dmetric = varargin{i+1};
        end
    end
    
    % Initialise
    ifault = 0;
    ndata = size(x,1);
    ndim = size(x,2);
    idx = zeros(ndata,1);
    iterations = 1;
    
    % Create initial clusters
    % Assign datapoints to the nearest centroids
    dist = pdist2(x,init_centroids,dmetric);
    [~,idx] = min(dist,[],2);
    
    % Compute initial clusters
    centroids = nan(k,ndim);
    for ii = 1:k
        elements = find(idx == ii);
        if length(elements) > 1
            med = mean(x(elements,:),1); %Start with median = mean
            for j = 1:ndim
                num = 0;
                den = 0;
                for iii = 1:length(elements)
                    dist = pdist2(x(elements(iii),:),med,dmetric);
                    num = num + ( x(elements(iii),j) / dist );
                    den = den + (1 / dist);
                end
                centroids(ii,j) = num / den;
            end
        elseif length(elements) == 1 %if only 1 element
            centroids(ii,:) = x(elements,:);             
        elseif isempty(elements) %if no elements
            centroids(ii,:) = centroids(ii,:); 
        end                
    end     
    if length(unique(idx)) ~= k
        ifault = 1;
        return
    end        

    
    % Lloyd's main loop
    old_centroids = centroids;
    
    for T = 1:ITER + 1
        % Assign datapoints to clusters
        dist = pdist2(x,centroids,dmetric);
        [~,idx] = min(dist,[],2);        
        
        % Recompute the centroids
        for ii = 1:k
            elements = find(idx == ii);
            if length(elements) > 1
                med = mean(x(elements,:),1); %Start with median = mean
                for j = 1:ndim
                    num = 0;
                    den = 0;
                    for iii = 1:length(elements)
                        dist = pdist2(x(elements(iii),:),med,dmetric);
                        num = num + ( x(elements(iii),j) / dist );
                        den = den + (1 / dist);
                    end
                    centroids(ii,j) = num / den;
                end
            elseif length(elements) == 1 %if only 1 element
                centroids(ii,:) = x(elements,:);             
            elseif isempty(elements) %if no elements
                centroids(ii,:) = centroids(ii,:); 
            end                
        end       
        if length(unique(idx)) ~= k 
            ifault = 1;
            return
        end         
        
        % Number of iterations
        iterations = iterations + 1;
        
        % Check for convergence in centroids
        if isequal(old_centroids,centroids)
            return
        else
            old_centroids = centroids;
        end
        
        % Check for convergence in iterations
        if T == ITER+1
            ifault = 2;
            iterations = iterations-1;
        end       
    end
end