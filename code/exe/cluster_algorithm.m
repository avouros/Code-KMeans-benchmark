function [idx,centroids,w,iterations] = cluster_algorithm(x,k,s,centers,method_clustering)
%CLUSTER_EXECUTE executes the selected clustering algorithm

    if k > 1
        switch method_clustering
            case 'K-Means (Lloyd)'
                [idx,centroids,iterations,ifault] = kmeans_lloyd(x,k,centers,10000);
                w = ones(1,size(centroids,2));
                if ifault ~= 0
                    disp(ifault);
                end
                if ifault == 1
                    idx = NaN(size(x,1));
                    centroids = NaN(size(centers));
                    w = nan(1,size(centroids,2));
                end
            case 'K-Means (Hartigan-Wong)'
                try
                    %Nag library
                    isx = ones([size(x,2),1],'int64');
                    [centroids,idx] = g03ef(x,isx,centers,'maxit', int64(10000));
                    idx = double(idx);
                    iterations = NaN;         
                    w = ones(1,size(centroids,2));
                catch
                    idx = NaN(size(x,1));
                    centroids = NaN(size(centers));
                    w = nan(1,size(centroids,2));
                    warning('The NAG Toolbox for MATLAB is required to run this algorithm. The toolbox is available at https://www.nag.co.uk/nag-toolbox-matlab');
                    %error('The NAG Toolbox for MATLAB is required to run this algorithm. The toolbox is available at https://www.nag.co.uk/nag-toolbox-matlab');
                end
            case 'K-Medians'
                [idx,centroids,iterations,ifault] = kmedians(x,k,centers,10000);
                w = ones(1,size(centroids,2));
                if ifault ~= 0
                    disp(ifault);
                end
                if ifault == 1
                    idx = NaN(size(x,1));
                    centroids = NaN(size(centers));
                    w = nan(1,size(centroids,2));
                end
            case 'None'
                % Clusters based on initial centroids
                [idx,w,iterations] = noclustering(x,centers);
                centroids = centers;
            otherwise
                error('Wrong clustering algorithm');
        end  
    else
        % If we have only 1 cluster
        idx = ones(size(x,1),1);
        centroids = centers;
        w = ones(1,size(x,2));
        iterations = 1; 
    end
   
end
