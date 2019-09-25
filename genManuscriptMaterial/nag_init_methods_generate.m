%This functions first generates all the required datasets and then runs all 
%the 'method_centers' and 'method_clustering' on them. Each method is applied
%to the same datasets.

NREP = 40;  %repeat dataset
NITER = 25; %repeat solution if non-deterministic
datasets = {'gap','wgap','Brodinova','mixed','hdims','S-sets','A-sets'};
unique_datasets = {'S-sets','A-sets'};
method_centers = {'Random points','K-Means++','ROBIN','Kaufman','Density K-Means++','ROBIN-DETERM'};
method_clustering = {'K-Means (Lloyd)','K-Means (Hartigan-Wong)','K-Medians'};

VOCAL = 0;


%% Initialize
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



%% Generate all the required datasets
if ~exist(fullfile(ff,'data.mat'),'file')
    dataDataset = cell(ndm,1);
    for dm = 1:ndm %for each dataset
        switch datasets{dm}
            case 'gap' 
                M = 5; 
            case 'wgap'
                M = 6; 
            case 'Brodinova'
                models = {[40,3,20,0,0,0,0,0],...
                          [40,10,20,0,0,0,0,0],...
                          [40,3,15,5,0,0,0,0],...     
                          [40,10,15,5,0,0,0,0],...
                          [40,3,10,10,0,0,0,0],...     
                          [40,10,10,10,0,0,0,0]};   
                M = length(models);
			case 'mixed'
				M = 4; 
			case 'hdims'
				unbalanced_sets_begin = 5;
				models = {[40,3,1000,0,0,0,0,0],...   
						  [40,10,1000,0,0,0,0,0],...
						  [40,10,1500,0,0,0,0,0],...  
						  [25,50,1500,0,0,0,0,0],... 
						  [100,3,1000,0,0,0,0,0],... 
						  [100,10,1000,0,0,0,0,0]};	
				M = length(models);					
			case 'S-sets'
                M = 4;
            case 'A-sets'
                M = 3;
            otherwise
                error('Wrong dataset')
        end

        dataModel = cell(M,NREP);
        for nm = 1:M %for each model
            for nr = 1:NREP %for each repetition
                switch datasets{dm}
                    case 'gap' 
                        [x,x_labs] = Gap_data(nm,0);
						
                    case 'wgap'
                        [x,x_labs] = YanYe_data(nm,0);
						
                    case 'Brodinova'
                        group_sizes = models{nm}(1)*ones(1,models{nm}(2));
                        [x,x_labs] = dataSynth('dataset',group_sizes,'p_info',models{nm}(3),'p_noise',models{nm}(4),...
                             'pn_info',models{nm}(5),'pp_info',models{nm}(6),'pn_noise',models{nm}(7),...
                             'pp_noise',models{nm}(8),'MINDIST',3);
							 
                    case 'mixed' 
                        [x,x_labs] = mixed_cluster_data(nm,0);
						
                    case 'hdims' 
                        if nm < unbalanced_sets_begin
                            %Balanced sets
                            group_sizes = models{nm}(1)*ones(1,models{nm}(2));
                        else
                            %Unbalanced sets, datapoints random [size/2 size]
                            group_sizes = randi([fix(models{nm}(1)/2),models{nm}(1)],1,models{nm}(2));
                        end
                        [x,x_labs] = dataSynth('dataset',group_sizes,'p_info',models{nm}(3),'p_noise',models{nm}(4),...
                             'pn_info',models{nm}(5),'pp_info',models{nm}(6),'pn_noise',models{nm}(7),...
                             'pp_noise',models{nm}(8),'MINDIST',3);  

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
				
                dataModel{nm,nr} = {x,x_labs};
				flag = 0;
				%Check if unique dataset
				for tt = 1:length(unique_datasets)
					if isequal(datasets{dm},unique_datasets{i});
						flag = 1;
						dataModel(:,2:end) = [];
					end
				end
				if flag
					break;
				end				
            end
        end
        dataDataset{dm} = dataModel;
    end
    save(fullfile(ff,'data.mat'),'dataDataset','datasets','unique_datasets');
else
    load(fullfile(ff,'data.mat'));
end



%% Run all the clustering algorithms and init methods
for A = 1:nmc %for each clustering algorithm
    for dm = 1:ndm %for each dataset
        cdata = dataDataset{dm};
        for nm = 1:size(cdata,1) %for each model
            resModel = cell(1,NREP);
            for nr = 1:NREP  %for each repetition
                x = cdata{nm,nr}{1};
                x_labs = cdata{nm,nr}{2};
                k = length(unique(x_labs));
                
                tmpres = struct('centers',[],'idx',[],'centroids',[],'weights',[],'iterations',[],'perfExternal',[],'perfExternalMore',[],'totalExes',[]);
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
                    if VOCAL
                        fprintf('counter = %d',counter);
                    end
                end
                % Models x Repetitions
                resModel{1,nr} = res;
            end
            P = fullfile(ff, sprintf('algo_%s',method_clustering{A}));
            if ~exist(P,'dir')
                mkdir(P);
            end            
            save(fullfile(P,sprintf('%s_model_%d.mat',datasets{dm},nm)),'resModel','method_centers');
        end
    end
end
