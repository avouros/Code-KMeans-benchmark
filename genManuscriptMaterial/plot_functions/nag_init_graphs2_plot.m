function nag_init_graphs2_plot(vals_plot,sets_p,I,i,j,method_centers,extract,plot_stat,vals_min,vals_max)
%Function that generates the figures in the paper (vertical bars).

    % User defined options
    visibility = 'off';
    maximize_figure = 0;
    overall_figure = 1;
    special_figure = 0;
    errorbars = 1;         %min, max (vals_min, vals_max)
    export = '.tif';
    export_ = 'High Quality';
    
    inGroupGap = 0.5;      %gap between each box of the same group
    outGroupGap = 1.0;     %gap between boxes of different groups
    extra_right = 0.2;     %gap before first box
    extra_left = 0.2;      %gap after last box
    width_bar = 0.25;        %width of the bar
    color_bar = 'adapt';     %color of the bar
    width_line = 0.30;       %width of the outline
    color_line = 'adapt';    %color of the outline
    yl1 = 0.4;             %y start
    yl2 = 1.15;            %y stop
    
    errorbar_color = 'black';
    errorbar_linewidth = 1.0;

    FontSize_ticks = 22;  
    FontSize_labels = 26;
    FontSize_title = 28;
    FontWeight_ticks = 'bold';
    FontWeight_labels = 'bold';
    FontWeight_title = 'bold';
    FontName = 'Arial';    
    
    add_values = 1;
    val_ndigits = 3;
    val_text_start = 1.005;
    val_font_size = 20;
    val_rotate = 90;
    
    add_hypothesis_p = 1;
    p_width_line = 0.20;
    p_step = 0.05;
    p_font_size = 26;
    p_font_size_red = 10;
    % *    = p < 0.05
    % **   = p < 0.01
    % ***  = p < 0.001
    % **** = p < 0.0001
    % #    = p >= 0.05
    
    % Other oprions
    switch I
        case 1
            str_I = 'Stochastic';
        case 2
            str_I = 'Deterministic';
        case 3
            str_I = 'Comparison';
        case 4
            str_I = 'Stochastic vs Deterministic';          
        case 5
            str_I = 'ROBIN vs D-ROBIN';             
    end
    
    switch i
        case 1
            str_i = 'Hartigan-Wong''s K-Means';
        case 2
            str_i = 'Lloyd''s K-Means';
        case 3
            str_i = 'K-Medians';
        case 4
            str_i = 'Weiszfeld';
    end
    
    eval_str = '';
    switch j
        case 1
            str_j = 'clustering';
            str_x = ['A-Set 1';'A-Set 2';'A-Set 3';...
                'S-Set 1';'S-Set 2';'S-Set 3';'S-Set 4'];
            xlab = '';
            eval_str = 'xtickangle(45)';
        case 2
            str_j = 'Brodinova';
            str_x = num2str((1:6)');
            xlab = 'models';         
        case 3
            str_j = 'gap';
            str_x = num2str((1:5)');
            xlab = 'models';
        case 4
            str_j = 'weighted gap';
            str_x = num2str((1:6)'); 
            xlab = 'models';
        case 5
            str_j = 'mixed';
            str_x = num2str((1:4)');
            xlab = 'models';
        case 6
            str_j = 'high-dims';
            str_x = num2str((1:6)');
            xlab = 'models';            
        case 7
            str_j = 'gap and weighted gap';
            str_x = {'gap2','gap3','wgap1','wgap6',...
                     'gap4','wgap5',...
                     'gap5','wgap4',...
                     'wgap2','wgap3'};
            xlab = '';
            overall_figure = 0;
            special_figure = 1;
        case 8
            str_j = 'Brodinova all models';
            str_x = num2str([(1:6),(1:6)]');
            xlab = '';
            overall_figure = 0;
            special_figure = 1;            
    end   
    
    ylab = strjoin({plot_stat,extract});
    
    % Generate output path (./graphs/'work_name')
    ppath = fullfile(pwd,'graphs',str_j);
    if ~exist(ppath,'dir')
        mkdir(ppath);
    end
    
    % Colors
    plot_colors_init = color_fullhue(length(method_centers));
    switch color_bar
        case 'adapt'
            switch I
                case 1
                    color_bar = repmat(plot_colors_init(1:3,:),length(str_x),1);
                case 2
                    color_bar = repmat(plot_colors_init(4:6,:),length(str_x),1);
                case 3
                    color_bar = repmat(plot_colors_init([3,5,6],:),length(str_x),1); 
                case 4
                    color_bar = repmat(plot_colors_init([3,5],:),length(str_x),1);   
                case 5
                    color_bar = repmat(plot_colors_init([3,6],:),length(str_x),1);                
            end
    end
    switch color_line
        case 'adapt'
            switch I
                case 1
                    color_line = repmat(plot_colors_init(1:3,:),length(str_x),1);
                case 2
                    color_line = repmat(plot_colors_init(4:6,:),length(str_x),1);
                case 3
                    color_line = repmat(plot_colors_init([3,5,6],:),length(str_x),1);
                case 4
                    color_line = repmat(plot_colors_init([3,5],:),length(str_x),1);
                case 5
                    color_line = repmat(plot_colors_init([3,6],:),length(str_x),1);
            end
    end    
    
    % Positions
    [n,m] = size(vals_plot);
    flag = 0; %indicates when we change group
    pos = 0;
    grs = zeros(1,n);   %number of groups
    for g = 1:n
        for sg = 1:m
            if flag == 0
                %Same group
                pos = [pos,pos(end)+inGroupGap];
                grs(g) = grs(g)+1;
            else
                %Other group
                pos = [pos,pos(end)+outGroupGap];
                grs(g) = grs(g)+1;
                flag = 0;
            end
        end
        flag = 1;
    end
    pos(1) = [];
    pos = pos-inGroupGap;
    pos = pos+extra_right;
        
    
    %% Plot
    % Make the figure
    if ~maximize_figure
        if ~special_figure
            if isequal(str_j,'clustering')
                NewF = figure('Visible',visibility,'tag','NewF');
            else
                NewF = figure('Visible',visibility,'tag','NewF','Units','Normalized','OuterPosition',[1.2, 0.3, 0.3, 0.3]);
            end
        else
            NewF = figure('Visible',visibility,'tag','NewF','Units','Normalized','OuterPosition',[1.2, 0.3, 0.7, 0.4]);
        end
    else
        NewF = figure('Visible',visibility,'units','normalized','outerposition',[0 0 1 1],'tag','NewF');
    end     
    faxis = axes(NewF);
    hold(faxis,'on');
    xlim(faxis,[0 pos(end)+extra_left]);   
    ylim(faxis,[yl1,yl2]);
   
    % Make the bars
    k = 1;
    for i = 1:n
        for j = 1:m
            b = bar(pos(k),vals_plot(i,j),width_bar,'parent',faxis);
            if iscell(color_bar)
                set(b,'FaceColor', color_bar{k});
            elseif ischar(color_bar)
                set(b,'FaceColor', color_bar);
            elseif isnumeric(color_bar)
                set(b,'FaceColor', color_bar(k,:));
            else
                error('Wrong color option for bar color.');
            end  
            if iscell(color_line)
                set(b,'EdgeColor', color_line{k});
            elseif ischar(color_line)
                set(b,'EdgeColor', color_line);
            elseif isnumeric(color_line)
                set(b,'EdgeColor', color_line(k,:));
            else
                error('Wrong color option for bar outline color.');
            end     
            if errorbars
                plot([pos(k),pos(k)],[vals_min(i,j),vals_max(i,j)],'Color',errorbar_color,'LineWidth',errorbar_linewidth);
                plot([pos(k)-0.05,pos(k)+0.05],[vals_min(i,j),vals_min(i,j)],'Color',errorbar_color,'LineWidth',errorbar_linewidth);
                plot([pos(k)-0.05,pos(k)+0.05],[vals_max(i,j),vals_max(i,j)],'Color',errorbar_color,'LineWidth',errorbar_linewidth);
            end
            k = k + 1;
        end
    end
    
    % Axes labels and title
    xlabel(xlab,'FontName',FontName,'FontSize',FontSize_labels,'FontWeight',FontWeight_labels);
    ylabel(ylab,'FontName',FontName,'FontSize',FontSize_labels,'FontWeight',FontWeight_labels);
    if isequal(str_j,'Brodinova all models')
        title('Brodinova','FontName',FontName,'FontSize',FontSize_title,'FontWeight',FontWeight_title);
    else
        title(str_j,'FontName',FontName,'FontSize',FontSize_title,'FontWeight',FontWeight_title);
    end       
   
    % Axis XTicks and XTickLabels
    posi1 = 1;
    p = pos(cumsum(grs));
    tickx = zeros(1,n);
    for k = 1:n
        j = find(pos==p(k));
        tickx(k) = mean(pos(posi1:j));
        posi1 = j+1;
    end    
    set(faxis,'XTick',tickx,'XTickLabel',str_x,...
        'FontSize',FontSize_ticks,'FontName',FontName,'FontWeight',FontWeight_ticks);    
    eval(eval_str); %rotate if needed
    
    % Values
    if add_values
        evals = reshape(vals_plot',1,size(vals_plot,1)*size(vals_plot,2));
        for pp = 1:length(pos)
            text(pos(pp),val_text_start,num2str(round(evals(pp),val_ndigits)),...
                'FontName',FontName,'FontSize',val_font_size,'Rotation',val_rotate,'FontWeight','bold');
        end 
    end
    
    % p-values
    if add_hypothesis_p && ~isempty(sets_p)
        s1 = 1;
        s2 = m;
        for pp = 1:n
            % For each set...
            %Collect the p-values
            posp = pos(s1:s2);
            ps = sets_p{pp};
            pv = [];
            xxyy = [];
            kk = p_step;
            for p1 = 1:size(ps,1)
                for p2 = p1+1:size(ps,2)
                    pv = [pv,ps(p1,p2)];
                    tmp = [posp(p1),posp(p2),yl2+kk,yl2+kk];
                    xxyy = [xxyy;tmp];
                    kk = kk + p_step;
                end
            end
            ylim([yl1 yl2+kk+p_step]); 
            %Preapare the symbols
            str_star = {};
            for p1 = 1:length(pv)
                if pv(p1) < 0.0001
                    ast = '****';
                elseif pv(p1) < 0.001
                    ast = '***';
                elseif pv(p1) < 0.01
                    ast = '**';
                elseif pv(p1) < 0.05
                    ast = '*';
                else
                    ast = '#';
                end
                str_star = [str_star,{ast}];
            end
            %Update the graph
            for p1 = 1:length(pv)
                plot(xxyy(p1,1:2),xxyy(p1,3:4),'LineWidth',p_width_line,'Color','black','parent',faxis);
                if isequal(str_star{p1},'#')
                    text(xxyy(p1,1),xxyy(p1,3)+0.03,str_star{p1},'FontName',FontName,'FontSize',p_font_size-p_font_size_red);
                else
                    text(xxyy(p1,1),xxyy(p1,3)+0.01,str_star{p1},'FontName',FontName,'FontSize',p_font_size);
                end
            end
            s1 = s2+1;
            s2 = s2+m;
        end
    end
    
    % Overall
    tmp = get(faxis,'YTickLabel');
    a = find(str2double(tmp) > 1);
    tmp(a) = [];
    tmp = [tmp;cell(length(a),1)];
    set(faxis,'YTick',0:0.25:1); 
    if overall_figure
        set(NewF,'Color','w','papersize',[8,8], 'paperposition',[0,0,8,5]);    
    end
    if special_figure
        set(NewF,'Color','w','papersize',[8,8], 'paperposition',[0,0,14,5]);    
    end
    if isequal(str_j,'clustering')
        set(NewF,'Color','w','papersize',[8,8], 'paperposition',[0,0,8,8]); 
    end
    box(faxis,'off');   
    hold(faxis,'off');
    
    % Export and close
    export_figure(NewF, ppath, strjoin({plot_stat,extract,str_i,str_j,str_I},'_'), export, export_);
    close(NewF);    
end

