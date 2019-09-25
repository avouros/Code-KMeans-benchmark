function clustering_purity = cl_purity(true_values, predicted_values)
%CL_PURITY computes the clustering purity.
% Purity needs to be between [0,1], where 1 is obtained when the 
% clusters consist of objects of single classes. 

% INPUT:
%  true_values: data labels
%  predicted_values: clustering results

% OUTPUT:
%  clustering_purity: clustering purity

% Formula obtained from: https://goo.gl/MS42ME

    if size(true_values) ~= size(predicted_values)
        error('cl_entropy error: vectors of true and predicted values needs to have the same size');
    end

    conf_mat = confusionmat(true_values,predicted_values);
    clustering_purity = sum(max(conf_mat',[],2)) / length(true_values);

    % Assert final value
    if clustering_purity > 1 || clustering_purity < 0
        error('cl_entropy error: Bug found!');
    end
end

