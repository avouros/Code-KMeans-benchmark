function [C,FC,centers_j] = random_init(x,k)
%RANDOM_INIT generate centroids using the methods of MacQueen and Jancey

%References:
% [1] MacQueen, James. "Some methods for classification and analysis of 
%     multivariate observations." Proceedings of the fifth Berkeley 
%     symposium on mathematical statistics and probability. Vol. 1. No. 
%     14. 1967.
% [2] Jancey, R. C. "Multidimensional group analysis." Australian Journal 
%     of Botany 14.1 (1966): 127-130.


    % Random datapoints as centroids [1]
    [~,C] = datasample(x,k,'Replace',false);
    
    % The first k datapoints as centroids [1]
    FC = 1:k;
    
    % Random points in space as centroids [2]
    max_ds = max(x); % max of each dimension
    min_ds = min(x); % min of each dimension
    % Generate random centroids located between min and max
    centers_j = (max_ds - min_ds).*rand(k,1) + min_ds;
end

