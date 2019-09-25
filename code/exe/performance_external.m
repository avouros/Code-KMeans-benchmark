function [PERF_EXTER,PERF_EXTER_MORE] = performance_external(true_values, predicted_values_cell)
%PERFORMANCE_EXTERNAL executes all the external indexes

    if iscell(predicted_values_cell)
        s = length(predicted_values_cell);
    else
        predicted_values_cell = {predicted_values_cell};
        s = 1;
    end
    
    PERF_EXTER = struct('entropy',[],'purity',[],...
        'f_score',[],'accuracy',[],'recall',[],'specificity',[],'precision',[]);
    PERF_EXTER = repmat(PERF_EXTER,1,s);    
    
    PERF_EXTER_MORE = struct('CEntropy',[],'TP',[],'TN',[],'FP',[],'FN',[]);
    PERF_EXTER_MORE = repmat(PERF_EXTER_MORE,1,s);  
    
    for i = 1:s
        predicted_values = predicted_values_cell{i};
        
        [clustering_entropy, cluster_entropy] = cl_entropy(true_values, predicted_values);
        clustering_purity = cl_purity(true_values, predicted_values);
        [f_score,accuracy,recall,specificity,precision,TP,TN,FP,FN] = cl_FmeasureCL(true_values, predicted_values);
        
        PERF_EXTER(i).entropy = clustering_entropy;
        PERF_EXTER(i).purity = clustering_purity;
        PERF_EXTER(i).f_score = f_score;
        PERF_EXTER(i).accuracy = accuracy;
        PERF_EXTER(i).recall = recall;
        PERF_EXTER(i).specificity = specificity;
        PERF_EXTER(i).precision = precision;
        
        PERF_EXTER_MORE(i).CEntropy = cluster_entropy;
        PERF_EXTER_MORE(i).TP = TP;
        PERF_EXTER_MORE(i).TN = TN;
        PERF_EXTER_MORE(i).FP = FP;
        PERF_EXTER_MORE(i).FN = FN;
    end
end

