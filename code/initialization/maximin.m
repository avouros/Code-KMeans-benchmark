function C = maximin(x,k,option)
%The maximin clustering initialisation method based on the work of [1,2].

%References:
%[1] Gonzalez, Teofilo F. "Clustering to minimize the maximum intercluster
%    distance." Theoretical Computer Science 38 (1985): 293-306.
%[2] Katsavounidis, Ioannis, C-CJ Kuo, and Zhen Zhang. "A new 
%    initialization technique for VQ codebook design." Proceedings of 1994 
%    28th Asilomar Conference on Signals, Systems and Computers. Vol. 1. 
%    IEEE, 1994.


% Input:
% - x : NxP matrix, ows are observations and columns are attributes.
% - k : number of target clusters.

% Output:
% - C : vector, indeces of x (datapoints) to be used as initial
%       centroids.

    
    if nargin < 3
        option = 1;
    end

    % Select reference point
    switch option
        case 1
            %Random [1]
            n = size(x,1);
            C = randsample(n,1);
        case 2
            %Greatest Euclidean [2]
            n = size(x,1);
            norms = zeros(n,1);
            for i = 1:n
                norms(i) = norm(x(i,:));
            end
            [~,C] = max(norms);
        otherwise
            error('Error: Wrong reference point option.');
    end
    
    % Find centroids
    while length(C) < k
        dists = pdist2(x,x(C,:));
        d = min(dists,[],2);
        [~,tmp] = sort(d,'descend');
        a = find(~ismember(tmp,C));
        if isempty(a)
            break
        else
            C = [C;tmp(a(1))];
        end
    end
end

