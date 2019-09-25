function [x,x_labs] = YanYe_data(model,visualize)
%YANYE_DATA This function generates the synthetic datasets used in the work
%of Yan and Ye [1]

% References:
% [1] Yan, Mingjin, and Keying Ye. "Determining the number of clusters 
%     using the weighted gap statistic." Biometrics 63.4 (2007): 1031-1037.

    switch model
        case 1
            s = 1;
            n = randi([25 50],1,1);
            m1 = [10,0];
            m2 = [6,0];
            m3 = [0,0];
            m4 = [-5,0];
            m5 = [5,5];
            m6 = [0,-6];
            r1 = [s.*randn(n,1) + m1(1) , s.*randn(n,1) + m1(2)];
            r2 = [s.*randn(n,1) + m2(1) , s.*randn(n,1) + m2(2)];
            r3 = [s.*randn(n,1) + m3(1) , s.*randn(n,1) + m3(2)];
            r4 = [s.*randn(n,1) + m4(1) , s.*randn(n,1) + m4(2)];
            r5 = [s.*randn(n,1) + m5(1) , s.*randn(n,1) + m5(2)];
            r6 = [s.*randn(n,1) + m6(1) , s.*randn(n,1) + m6(2)];   
            x = [r1;r2;r3;r4;r5;r6];
            x_labs = [ones(n,1);2*ones(n,1);3*ones(n,1);4*ones(n,1);5*ones(n,1);6*ones(n,1)];
        case 2
            n1 = 100;
            m1 = [0,0];
            s1 = [1,1];
            n2 = 15;
            m2 = [5,0];   
            s2 = [0.1,0.1];
            r1 = [s1(1).*randn(n1,1) + m1(1) , s1(2).*randn(n1,1) + m1(2)];
            r2 = [s2(1).*randn(n2,1) + m2(1) , s2(2).*randn(n2,1) + m2(2)];
            x = [r1;r2];
            x_labs = [ones(n1,1);2*ones(n2,1)];   
        case 3 %non-normally distributed clusters
            n = 50;
            pd = makedist('Exponential','mu',1);
            t = truncate(pd,-1,1);
            c1 = random(t,n,2);
            c2 = random(t,n,2);
            c3 = random(t,n,2);
            c4 = random(t,n,2);
            m1 = [0,0];
            m2 = [0,-2.5];
            m3 = [-2.5,-2.5];
            m4 = [-2.5,0];   
            r1 = [c1(:,1)+repmat(m1(1),n,1),c1(:,2)+repmat(m1(2),n,1)];
            r2 = [c2(:,1)+repmat(m2(1),n,1),c2(:,2)+repmat(m2(2),n,1)];
            r3 = [c3(:,1)+repmat(m3(1),n,1),c3(:,2)+repmat(m3(2),n,1)];
            r4 = [c4(:,1)+repmat(m4(1),n,1),c4(:,2)+repmat(m4(2),n,1)];
            x = [r1;r2;r3;r4];
            x_labs = [ones(n,1);2*ones(n,1);3*ones(n,1);4*ones(n,1)];  
        case 4 %elongated clusters
            s = 0.01;
            t1 = -0.5:0.01:0.5;
            t2 = -0.5:0.01:0.5;
            r1 = [t1'+(sqrt(s)*randn(size(t1',1),1)),t2'+(sqrt(s)*randn(size(t2',1),1))];
            t1 = -0.5:0.01:0.5;
            t2 = -0.5:0.01:0.5;
            r2 = [t1'+(sqrt(s)*randn(size(t1',1),1))-1,t2'+(sqrt(s)*randn(size(t2',1),1))];    
            x = [r1;r2];
            n = size(t1',1);
            x_labs = [ones(n,1);2*ones(n,1)];    
        case 5        
            n = repmat(randi([25 50],1,1),1,4);
            p = 10; %dimensions
            k = 4;     
            minDistCents = 5;
            minDistPoints = 1;
            % Generate the centroids
            while 1          
                m1 = zeros(1,p);
                s1 = 3.6.*diag(ones(1,p));
                c = mvnrnd(m1,s1,k);
                if min(pdist(c,'euclidean')) >= minDistCents
                    break
                end
            end
            % Generate the data
            while 1
                flag = 1;
                x = [];
                x_labs = [];                 
                for i = 1:k
                    r = randn(n(i),p) + repmat(c(i,:),n(i),1);  
                    x = [x;r];
                    x_labs = [x_labs;i*ones(n(i),1)];                  
                end
                % Terminate only if the distance between any pair of points
                % in two different clusters is less than 'minDistPoints'       
                for k1 = 1:k
                    for k2 = k1+1:k
                        dists = pdist2(x(x_labs==k1,:),x(x_labs==k2,:),'euclidean');
                        a = min(min(dists));
                        if a < minDistPoints
                            flag = 0;
                        end
                    end
                end     
                if flag
                    break
                end
            end
        case 6
            s = 1;
            n = 50;
            m1 = [0,0];
            m2 = [-1,5];
            m3 = [10,-10];
            m4 = [15,-10];
            m5 = [10,-15];
            m6 = [25,25];
            r1 = [s.*randn(n,1) + m1(1) , s.*randn(n,1) + m1(2)];
            r2 = [s.*randn(n,1) + m2(1) , s.*randn(n,1) + m2(2)];
            r3 = [s.*randn(n,1) + m3(1) , s.*randn(n,1) + m3(2)];
            r4 = [s.*randn(n,1) + m4(1) , s.*randn(n,1) + m4(2)];
            r5 = [s.*randn(n,1) + m5(1) , s.*randn(n,1) + m5(2)];
            r6 = [s.*randn(n,1) + m6(1) , s.*randn(n,1) + m6(2)];   
            x = [r1;r2;r3;r4;r5;r6];
            x_labs = [ones(n,1);2*ones(n,1);3*ones(n,1);4*ones(n,1);5*ones(n,1);6*ones(n,1)];            
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

