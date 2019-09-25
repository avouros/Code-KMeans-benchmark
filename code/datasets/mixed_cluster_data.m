function [x,x_labs] = mixed_cluster_data(model,visualize)
%MIXED_CLUSTER_DATA contains dataset generation models with various
%properties.

    switch model
        case 1 %elogated and normal
            % Cluster normal
            n1 = 80;            %number of points
            m1 = [0,0,0];       %means
            s1 = [0.1,0.1,0.1]; %stds
            % Cluster elongated 1
            n2 = 100;
            s2 = [0.30,0.30,0.30];
            lims2 = [-1.0,1.0]; %elogation limits
            dist2 = 2;          %distance from normal cluster mean
            % Cluster elongated 2
            n3 = 100;
            s3 = [0.30,0.30,0.30];
            lims3 = [-1.0,1.0]; %elogation limits
            dist3 = 2;          %distance from normal cluster mean
            % Make the normal cluster
            center = [s1(1).*randn(n1,1) + m1(1) ,...
                      s1(2).*randn(n1,1) + m1(2) ,...
                      s1(3).*randn(n1,1) + m1(3)];
            % Make the elongated cluster 1
            elo1 = ( repmat(linspace(lims2(1),lims2(2),n2),3,1) )' + s2.*randn(n2,3); 
            elo1(:,2) = elo1(:,2) + dist2; 
            % Make the elongated cluster 2
            elo2 = ( repmat(linspace(lims3(1),lims3(2),n3),3,1) )' + s3.*randn(n3,3); 
            elo2(:,2) = elo2(:,2) - dist3; 
            elo2(:,1) = - elo2(:,1);
            % Store the data
            x = [center;elo1;elo2];
            x_labs = [ones(n1,1);2*ones(n2,1);3*ones(n3,1)];
            
        case 2 %non-gaussian and normal
            % Non-gaussian
            n1 = 80;
            pd = makedist('Exponential','mu',1);
            pd = truncate(pd,-1,1); %bound the distribution between limits
            c1 = random(pd,n1,3);
            n2 = 100;
            pd = makedist('Exponential','mu',1);
            pd = truncate(pd,2,3); %bound the distribution between limits
            c2 = random(pd,n2,3);  
            % Gaussian
            n3 = 80;            %number of points
            m1 = [0.5,2.5,2.5]; %means
            s1 = [0.1,0.1,0.1]; %stds
            c3 = [s1(1).*randn(n3,1) + m1(1) ,...
                  s1(2).*randn(n3,1) + m1(2) ,...
                  s1(3).*randn(n3,1) + m1(3)];    
            n4 = 100;           %number of points
            m1 = [2.5,0.5,0.5]; %means
            s1 = [0.2,0.2,0.2]; %stds
            c4 = [s1(1).*randn(n4,1) + m1(1) ,...
                  s1(2).*randn(n4,1) + m1(2) ,...
                  s1(3).*randn(n4,1) + m1(3)];  
            % Make
            x = [c1;c2;c3;c4];
            x_labs = [ones(n1,1);2*ones(n2,1);3*ones(n3,1);4*ones(n4,1)]; 
           
        case 3 %gaussians with difference std (same over dims)
            n1 = 80;            %number of points
            m1 = [0.0,0.0,0.0]; %means
            s1 = [0.1,0.1,0.1]; %stds
            c1 = [s1(1).*randn(n1,1) + m1(1) ,...
                  s1(2).*randn(n1,1) + m1(2) ,...
                  s1(3).*randn(n1,1) + m1(3)];    
            n2 = 100;           %number of points
            m2 = [2.0,0.0,0.0]; %means
            s2 = [0.2,0.2,0.2]; %stds
            c2 = [s2(1).*randn(n2,1) + m2(1) ,...
                  s2(2).*randn(n2,1) + m2(2) ,...
                  s2(3).*randn(n2,1) + m2(3)];  
            n3 = 120;           %number of points
            m3 = [0.0,2.0,0.0]; %means
            s3 = [0.3,0.3,0.3]; %stds
            c3 = [s3(1).*randn(n3,1) + m3(1) ,...
                  s3(2).*randn(n3,1) + m3(2) ,...
                  s3(3).*randn(n3,1) + m3(3)];   
            n4 = 140;           %number of points
            m4 = [0.0,0.0,2.0]; %means
            s4 = [0.4,0.4,0.4]; %stds
            c4 = [s4(1).*randn(n4,1) + m4(1) ,...
                  s4(2).*randn(n4,1) + m4(2) ,...
                  s4(3).*randn(n4,1) + m4(3)];               
            % Make
            x = [c1;c2;c3;c4];
            x_labs = [ones(n1,1);2*ones(n2,1);3*ones(n3,1);4*ones(n4,1)];   
            
        case 4 %mixed gaussians
            n1 = 80;            %number of points
            m1 = [0.0,0.0,0.0]; %means
            s1 = [0.1,0.1,0.2]; %stds
            c1 = [s1(1).*randn(n1,1) + m1(1) ,...
                  s1(2).*randn(n1,1) + m1(2) ,...
                  s1(3).*randn(n1,1) + m1(3)];    
            n2 = 100;           %number of points
            m2 = [2.0,0.0,0.0]; %means
            s2 = [0.1,0.2,0.3]; %stds
            c2 = [s2(1).*randn(n2,1) + m2(1) ,...
                  s2(2).*randn(n2,1) + m2(2) ,...
                  s2(3).*randn(n2,1) + m2(3)];  
            n3 = 120;           %number of points
            m3 = [0.0,2.0,0.0]; %means
            s3 = [0.2,0.4,0.6]; %stds
            c3 = [s3(1).*randn(n3,1) + m3(1) ,...
                  s3(2).*randn(n3,1) + m3(2) ,...
                  s3(3).*randn(n3,1) + m3(3)];   
            n4 = 140;           %number of points
            m4 = [0.0,0.0,2.0]; %means
            s4 = [1.0,0.1,0.1]; %stds
            c4 = [s4(1).*randn(n4,1) + m4(1) ,...
                  s4(2).*randn(n4,1) + m4(2) ,...
                  s4(3).*randn(n4,1) + m4(3)];               
            % Make
            x = [c1;c2;c3;c4];
            x_labs = [ones(n1,1);2*ones(n2,1);3*ones(n3,1);4*ones(n4,1)];   
            
        otherwise
            error('Wrong model number')
    end
            

    %% Visualize dataset
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