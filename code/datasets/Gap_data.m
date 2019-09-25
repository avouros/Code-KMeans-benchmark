function [x,x_labs] = Gap_data(model,visualize)
%GAP_DATA This function generates the synthetic datasets used in the work
%of Tibshirani et al [1]

% References:
% [1] Tibshirani, Robert, Guenther Walther, and Trevor Hastie. "Estimating 
%     the number of clusters in a data set via the gap statistic." Journal 
%     of the Royal Statistical Society: Series B (Statistical Methodology) 
%     63.2 (2001): 411-423.

    switch model
        case 1 %1 cl, 10 dim
            n = 200;
            x = rand(200,10);
            x_labs = ones(n,1);
        case 2 %3 cl, 2 dim
            s = 1;
            n1 = 25;
            m1 = [0,0];
            n2 = 25;
            m2 = [0,5];   
            n3 = 50;
            m3 = [5,-3];   
            r1 = [s.*randn(n1,1) + m1(1) , s.*randn(n1,1) + m1(2)];
            r2 = [s.*randn(n2,1) + m2(1) , s.*randn(n2,1) + m2(2)];
            r3 = [s.*randn(n3,1) + m3(1) , s.*randn(n3,1) + m3(2)];            
            x = [r1;r2;r3];
            x_labs = [ones(n1,1);2*ones(n2,1);3*ones(n3,1)];   
        case 3 %4 cl, 3 dim
            ns = [25,50];            
            m = 0; %centers mean
            s = 5; %centers sigma
            sd = 1;%data sigma
            while (1)
                nl = length(ns);
                n = ns(randi(nl));
                c1 = s.*randn(1,3) + m;
                r1 = sd.*randn(n,3) + repmat(c1,n,1);
                l1 = ones(n,1);
                c2 = s.*randn(1,3) + m;
                r2 = sd.*randn(n,3) + repmat(c2,n,1);
                l2 = 2*ones(n,1);
                c3 = s.*randn(1,3) + m;
                r3 = sd.*randn(n,3) + repmat(c3,n,1);
                l3 = 3*ones(n,1);
                c4 = s.*randn(1,3) + m;
                r4 = sd.*randn(n,3) + repmat(c4,n,1);
                l4 = 4*ones(n,1);
                x = [r1;r2;r3;r4];
                x_labs = [l1;l2;l3;l4]; 
                % Check if the minimum distance between two points of
                % different clusters is more than 1
                flag = 0;
                for i = 1:4
                    for j = i+1:4
                        dists = pdist2(x(x_labs==i,:),x(x_labs==j,:),'euclidean');
                        a = min(min(dists));
                        if a <= 1
                            flag = 1;
                            break
                        end
                    end
                    if flag
                        break
                    end
                end
                if ~flag
                    break
                end
            end             
        case 4 %4 cl, 10 dim
            ns = [25,50];            
            m = 0; %centers mean
            s = 1.9; %centers sigma
            sd = 1;%data sigma
            while (1)
                nl = length(ns);
                n = ns(randi(nl));
                c1 = s.*randn(1,10) + m;
                r1 = sd.*randn(n,10) + repmat(c1,n,1);
                l1 = ones(n,1);
                c2 = s.*randn(1,10) + m;
                r2 = sd.*randn(n,10) + repmat(c2,n,1);
                l2 = 2*ones(n,1);
                c3 = s.*randn(1,10) + m;
                r3 = sd.*randn(n,10) + repmat(c3,n,1);
                l3 = 3*ones(n,1);
                c4 = s.*randn(1,10) + m;
                r4 = sd.*randn(n,10) + repmat(c4,n,1);
                l4 = 4*ones(n,1);
                x = [r1;r2;r3;r4];
                x_labs = [l1;l2;l3;l4]; 
                % Check if the minimum distance between two points of
                % different clusters is more than 1
                flag = 0;
                for i = 1:4
                    for j = i+1:4
                        dists = pdist2(x(x_labs==i,:),x(x_labs==j,:),'euclidean');
                        a = min(min(dists));
                        if a <= 1
                            flag = 1;
                            break
                        end
                    end
                    if flag
                        break
                    end
                end
                if ~flag
                    break
                end
            end          
        case 5 %2 cl, 3 dim
            n = 100;
            s = 0.1;
            r1 = (repmat(linspace(-0.5,0.5,n),3,1))' + s.*randn(n,3)+0;
            r2 = (repmat(linspace(-0.5,0.5,n),3,1))' + s.*randn(n,3)+0 + 10;
            x = [r1;r2];
            x_labs = [ones(n,1);2*ones(n,1)];             
        otherwise
            error('Wrong model number')
    end
    
    
    if visualize
        f = figure;
        ax = axes(f);
        hold(ax,'on');
        [~,p] = size(x);
        un = length(unique(x_labs));
        switch p 
            case 1 %1D

            case 2 %2D
                if visualize > 1
                    % Colors
                    for i = 1:un
                        scatter(x(x_labs==i,1),x(x_labs==i,2),20,'filled');
                    end
                else
                    scatter(x(:,1),x(:,2),20,'filled','MarkerFaceColor','black');
                end
            case 3 %3D
                if visualize > 1
                    % Colors
                    for i = 1:un
                        scatter3(x(x_labs==i,1),x(x_labs==i,2),x(x_labs==i,3),20,'filled');
                    end
                else
                    scatter3(x(:,1),x(:,2),x(:,3),20,'filled','MarkerFaceColor','black');
                end
                zlabel('x_3');
        end
        xlabel('x_1');
        ylabel('x_2');
        set(ax,'FontSize',12,'FontWeight','bold');    
        axis equal;
        grid on;
    end

end

