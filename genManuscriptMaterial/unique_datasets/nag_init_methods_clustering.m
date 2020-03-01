%This functions runs all the 'method_centers' and 'method_clustering' on 
%the clustering datasets.

NREP = 1;   %repeat dataset
NITER = 25; %repeat solution if non-deterministic
datasets = {'S-sets','A-sets'};
method_centers = {'Random points','K-Means++','ROBIN','Kaufman','Density K-Means++','ROBIN-DETERM'};
method_clustering = {'K-Means (Lloyd)','K-Means (Hartigan-Wong)','K-Medians','Weiszfeld'};

ndm = length(datasets);
nmi = length(method_centers);
nmc = length(method_clustering);

selpath = uigetdir(pwd,'Select output folder. A subfolder NAG_init_res will be created.');
if isequal(selpath,0)
    return
end

ff = fullfile(selpath,'NAG_init_res');
if ~exist(ff,'dir')
    mkdir(ff);
end

for A = 1:nmc %for each clustering algorithm
    for dm = 1:ndm %for each dataset
        switch datasets{dm}
            case 'S-sets'
                M = 4;
            case 'A-sets'
                M = 3;
            otherwise
                error('Wrong dataset')
        end

        for nm = 1:M %for each model
            resModel = cell(1,NREP);
            for nr = 1:NREP 
                %% For each repetition
                switch datasets{dm}
                    case 'S-sets' %Iris, Ionosphere, Wine    
                        ft = fullfile(pwd,'datasets','Clustering basic benchmark');
                        switch nm
                            case 1 
                                [x_labs,x,~] = load_clustering_basic_dataset(ft,'S-sets',1);
                            case 2
                                [x_labs,x,~] = load_clustering_basic_dataset(ft,'S-sets',2);
                            case 3 
                                [x_labs,x,~] = load_clustering_basic_dataset(ft,'S-sets',3);
                            case 4     
                                [x_labs,x,~] = load_clustering_basic_dataset(ft,'S-sets',4);
                        end
                    case 'A-sets'
                        ft = fullfile(pwd,'datasets','Clustering basic benchmark');
                        switch nm
                            case 1 
                                [x_labs,x,~] = load_clustering_basic_dataset(ft,'A-sets',1);
                            case 2
                                [x_labs,x,~] = load_clustering_basic_dataset(ft,'A-sets',2);
                            case 3 
                                [x_labs,x,~] = load_clustering_basic_dataset(ft,'A-sets',3);
                        end
                    otherwise
                        error('Wrong dataset')
                end            
                %%
                k = length(unique(x_labs));
                tmpres = struct('data',[],'centers',[],'idx',[],'centroids',[],'weights',[],'iterations',[],'perfExternal',[],'perfExternalMore',[],'totalExes',[]);
                res = repmat(tmpres,nmi,NITER);
                for mi = 1:nmi %for each init method
                    iwcd = inf;
                    I = 1;
                    counter = 0;
                    while I <= NITER
                        % Execute clustering solution NITER times and keep the best
                        centers = cluster_init(x,k,method_centers{mi}); 
                        try
                            [idx,centroids,w,iterations] = cluster_algorithm(x,k,0,centers,method_clustering{A});
                            if any(isnan(idx)) || ~isempty((find(any(isnan(centroids)))))
                                counter = counter + 1;
                                continue;
                            end
                        catch
                            counter = counter + 1;
                            continue;
                        end
                        [~,~,wcd,~,~,~] = clustering_metrics(x,idx);
                        [PERF_EXTER,PERF_EXTER_MORE] = performance_external(x_labs,idx);
                        res(mi,I).data = x;
                        res(mi,I).labels = x_labs;
                        res(mi,I).centers = centers;
                        res(mi,I).idx = idx;
                        res(mi,I).centroids = centroids;
                        res(mi,I).weights = w;
                        res(mi,I).iterations = iterations;
                        res(mi,I).perfExternal = PERF_EXTER;
                        res(mi,I).perfExternalMore = PERF_EXTER_MORE;
                        res(mi,I).totalExes = counter;
                        iwcd = wcd;
                        I = I + 1;
                        counter = counter + 1;
                        % Check if the method is deterministic
                        if isequal(method_centers{mi},'Kaufman') || isequal(method_centers{mi},'Density K-Means++') || isequal(method_centers{mi},'ROBIN-DETERM')
                            break;
                        end
                    end
                end
                % Models x Repetitions
                resModel{1,nr} = res;
            end
            P = fullfile(ff, sprintf('algo_%s',method_clustering{A}));
            if ~exist(P,'dir')
                mkdir(P);
            end            
            save(fullfile(P,sprintf('%s_model_%d.mat',datasets{dm},nm)),'resModel');
        end
    end
end
    



