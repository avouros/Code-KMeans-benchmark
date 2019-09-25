function colors = color_fullhue(n,test)
%COLOR_FULLHUE returns up to 340 colors with maximum saturation and value.
%In case more colors are requested then it replicates the initial colors.

% Author:
% Avgoustinos Vouros
% avouros1@sheffield.ac.uk

    limit = 340;
    colors = [(1:limit)'/360,ones(limit,1),ones(limit,1)];
    colors = hsv2rgb(colors);
    
    if n <= limit
        rows = 1:floor(limit/n):limit;
        rows = rows(1:n);
        colors = colors(rows,:);
    else
        m = 0;
        cols = [];
        while m < n
            rows = 1:1:limit;
            cols = [cols;colors(rows,:)]; 
            m = size(cols,1);
        end
        colors = cols(1:n,:);
    end
    
    % Test
    if nargin > 1
        figure;
        hold on
        for i = 1:size(colors,1)
            scatter(i,i,'MarkerEdgeColor',colors(i,:),'MarkerFaceColor',colors(i,:));
        end
    end
end