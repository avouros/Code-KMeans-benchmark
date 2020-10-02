function [centers,time] = cluster_init_tictoc(x,k,method_centers,L,varargin)
%CLUSTER_INIT initializes cluster centroids

    switch method_centers
        case 'Random points'
            tic;
            [C,~,~] = random_init(x,k);
            time = toc;
            
        case 'First points'
            tic;
            [~,C,~] = random_init(x,k);
            time = toc;
            
        case 'K-Means++'
            tic;
            C = kmpp_init(x,k);
            time = toc;
            
        case 'Density K-Means++'
            if ~exist('L','var') || isempty(L)    
                tic;
                C = dkmpp_init(x,k);
                time = toc;
            else
                tic;
                C = dkmpp_init(x,k,L);
                time = toc;
            end
        case 'Kaufman'
            tic;
            C = kaufman_init(x,k);
            time = toc;
            
        case 'Maximin'    
            %Random reference point (original)
            tic;
            C = maximin(x,k,1);   
            time = toc;
            
        case 'Maximin-DETERMINISTIC'    
            %Random reference point (Katsavounidis)
            tic;
            C = maximin(x,k,2);      
            time = toc;
            
        case 'ROBIN-STOCHASTIC'
            %Random reference point (Brodinova)
            if ~exist('L','var') || isempty(L)   
                tic;
                C = ROBIN(x,k,10);
                time = toc;
            else
                tic;
                C = ROBIN(x,k,10,'LOF',L,'DETERMINISTIC',0);
                time = toc;
            end
            
        case 'ROBIN'
            %Origin reference point (original)
            if ~exist('L','var') || isempty(L)     
                tic;
                C = ROBIN(x,k,10,'DETERMINISTIC',1);
                time = toc;
            else
                tic;
                C = ROBIN(x,k,10,'LOF',L,'DETERMINISTIC',1);
                time = toc;
            end   
            
        case 'ROBIN-LOF'
            %Reference point with the minimum abs(1-LOF) (var1)
            if ~exist('L','var') || isempty(L)     
                tic;
                C = ROBIN(x,k,10,'DETERMINISTIC',2);
                time = toc;
            else
                tic;
                C = ROBIN(x,k,10,'LOF',L,'DETERMINISTIC',2);
                time = toc;
            end    
            
        otherwise
            error('Wrong clustering algorithm');
    end
    centers = x(C,:);
end
   