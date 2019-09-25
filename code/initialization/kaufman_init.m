function C = kaufman_init(x,k)
%KAUFMAN_INIT implements the Kaufman initialisation method [1].
%Based on the pseudo-code of [2].

%References:
% [1] Kaufman, L., and P. J. Rousseeuw. "Finding Groups in Data: An 
%     Introduction to Cluster Analysis Wiley New York Google Scholar." 
%     (1990).
% [2] Pena, José M., Jose Antonio Lozano, and Pedro Larranaga. "An 
%     empirical comparison of four initialization methods for the k-means 
%     algorithm." Pattern recognition letters 20.10 (1999): 1027-1040.

% Author: Avgoustinos Vouros, avouros1@sheffield.ac.uk

    n = size(x,1);

    % Find the center of the dataset
    center = mean(x);
    
    % Find the datapoint closest to the center of the dataset
    [~,a] = min(pdist2(x,center));
    C(1) = a;

    SC = zeros(n,1);
    while length(C) < k
        s = 0;
        si = 0;
        for i = 1:n
            if ismember(i,C)
                continue
            end
            for j = i+1:n
                if ismember(j,C)
                    continue
                end       
                d = pdist2(x(i,:),x(j,:));
                tmp = find(~isnan(C));
                D = min( pdist2(x(j,:),x(C(tmp),:)) );
                val = max(D-d,0);
                SC(i) = SC(i) + val;
            end
            if max(SC) > s
                [s,si] = max(SC);
            end
        end
        C = union(C,si);
    end
end

