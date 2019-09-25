function centers = cluster_init(x,k,method_centers,L,varargin)
%CLUSTER_INIT initializes cluster centroids

    switch method_centers
        case 'Random points'
            [C,~,~] = random_init(x,k);
            
        case 'First points'
            [~,C,~] = random_init(x,k);
            
        case 'K-Means++'
            C = kmpp_init(x,k);
            
        case 'Density K-Means++'
            if ~exist('L','var') || isempty(L)         
                C = dkmpp_init(x,k);
            else
                C = dkmpp_init(x,k,L);
            end
        case 'Kaufman'
            C = kaufman_init(x,k);
                
        case 'ROBIN'
            if ~exist('L','var') || isempty(L)     
                C = ROBIN(x,k,10);
            else
                C = ROBIN(x,k,10,'LOFCOM','lof_given',L);
            end

        case 'ROBIN-DETERM'
            if ~exist('L','var') || isempty(L)     
                C = ROBIN(x,k,10,'DETERMINISTIC');
            else
                C = ROBIN(x,k,10,'LOFCOM','lof_given',L,'DETERMINISTIC');
            end              
            
        otherwise
            error('Wrong clustering algorithm');
    end
    centers = x(C,:);
end
   