function nag_init_graphs2_plot_h(v1,v2,i,I,J,II,method_centers,extract,plot_stat,sets_p)
%Function that generates the figures in the paper (horizontal bars used for 
%comparison between clustering algorithms).

    % User defined options
    visibility = 'off';
    maximize_figure = 0;
    overall_figure = 1;
    special_figure = 0;
    export = '.tif';
    export_ = 'High Quality';
    
    inGroupGap = 1.0;      %gap between each bar of the same subgroup
    subGroupGap = 1.5;     %gap between bars of different subgroups
    outGroupGap = 2.0;     %gap between bars of different groups
    extra_right = 0.2;     %gap before first box
    extra_left = 0.2;      %gap after last box
    width_bar = 0.30;        %width of the bar
    color_bar = 'adapt';     %color of the bar
    width_line = 0.30;       %width of the outline
    color_line = 'adapt';    %color of the outline
    yl1 = 0.4;             %y start
    yl2 = 1.2;             %y stop

    FontSize_ticks = 22;  
    FontSize_labels = 26;
    FontSize_title = 28;
    FontWeight_ticks = 'bold';
    FontWeight_labels = 'bold';
    FontWeight_title = 'bold';
    FontName = 'Arial';     
    
    add_values = 1;
    val_ndigits = 2;
    val_text_start = 1.005;
    val_font_size = 20;
    val_rotate = 0;
    
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
    switch II
        case 1
            str_II = 'Stochastic';
        case 2
            str_II = 'Deterministic';
        case 3
            str_II = 'Comparison';
        case 4
            str_II = 'Stochastic vs Deterministic';          
        case 5
            str_II = 'ROBIN vs D-ROBIN';                 
    end
    
    switch I
        case 1
            str_I = 'Hartigan-Wong''s K-Means';
        case 2
            str_I = 'Lloyd''s K-Means';
        case 3
            str_I = 'K-Medians';
        case 4
            str_I = 'Weiszfeld';
    end
    switch J
        case 1
            str_J = 'Hartigan-Wong''s K-Means';
        case 2
            str_J = 'Lloyd''s K-Means';
        case 3
            str_J = 'K-Medians';
        case 4
            str_J = 'Weiszfeld';
    end    
    
    eval_str = '';
    switch i
        case 1
            str_i = 'clustering';
            str_x = ['A-Set 1';'A-Set 2';'A-Set 3';...
                'S-Set 1';'S-Set 2';'S-Set 3';'S-Set 4'];
            xlab = '';
            eval_str = 'ytickangle(45)';
        case 2
            str_i = 'Brodinova';
            str_x = num2str((1:6)');
            xlab = 'models';
        case 3
            str_i = 'gap';
            str_x = num2str((1:5)');
            xlab = 'models';
        case 4
            str_i = 'weighted gap';
            str_x = num2str((1:6)'); 
            xlab = 'models';
        case 5
            str_i = 'mixed';
            str_x = num2str((1:4)'); 
            xlab = 'models';
        case 6
            str_i = 'high-dims';
            str_x = num2str((1:6)');
            xlab = 'models';            
        case 7
            str_i = 'gap and weighted gap';
            str_x = {'gap2','gap3','wgap1','wgap6',...
                     'gap4','wgap5',...
                     'gap5','wgap4',...
                     'wgap2','wgap3'};
            xlab = '';
            overall_figure = 0;
            special_figure = 1;
        case 8
            str_i = 'Brodinova all models';
            str_x = num2str([(1:6),(1:6)]');
            xlab = '';
            overall_figure = 0;
            special_figure = 1;                          
    end   
    
    ylab = strjoin({plot_stat,extract});
    
    % Generate output path (./graphs/'work_name')
    ppath = fullfile(pwd,'graphs',str_i,'hor');
    if ~exist(ppath,'dir')
        mkdir(ppath);
    end
    
    % Colors
    plot_colors_init = color_fullhue(length(method_centers));
    switch color_bar
        case 'adapt'
            switch II
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
    color_bar = color_bar(ceil((1:size(color_bar,1)*2)/2),:);
    switch color_line
        case 'adapt'
            switch II
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
    color_line = color_line(ceil((1:size(color_line,1)*2)/2),:);
    
    % Positions
    [n,m] = size(v1);
    total = 2*n*m;
    flag1 = 0; %indicates when we change subgroup
    flag2 = 0; %indicates when we change group
    pos = 0;
    grs = zeros(1,m);   %number of groups
    for g = 1:m
        for sg = 1:n
            for ssg = 1:2
                if flag1 == 0 && flag2 == 0
                    %Same sub sub group
                    pos = [pos,pos(end)+inGroupGap];
                    flag1 = 0;
                    grs(g) = grs(g)+1;
                elseif flag1 == 1 && flag2 == 0
                    %Change sub group
                    pos = [pos,pos(end)+subGroupGap];
                    flag1 = 0;
                    grs(g) = grs(g)+1;
                elseif flag1 == 0 && flag2 == 1
                    error('bug!')
                elseif flag1 == 1 && flag2 == 1
                    %Change group
                    pos = [pos,pos(end)+outGroupGap];
                    flag1 = 0;
                    flag2 = 0;
                    grs(g) = grs(g)+1;
                end
            end
            flag1 = 1; %change subgroup
        end
        flag2 = 1;
    end
    pos(1) = [];
    assert(isequal(total,length(pos)),'bug!');
    pos = pos-inGroupGap;
    pos = pos+extra_right;    

        
    
    %% Plot
    % Make the figure
    if ~maximize_figure
        if ~special_figure
            %NewF = figure('Visible',visibility,'tag','NewF');
            NewF = figure('Visible',visibility,'tag','NewF','Units','Normalized','OuterPosition',[1.2, 0.3, 0.3, 0.3]);
        else
            NewF = figure('Visible',visibility,'tag','NewF','Units','Normalized','OuterPosition',[1.2, 0.3, 0.4, 0.7]);
            %NewF = figure('Visible',visibility,'tag','NewF','Units','Normalized','OuterPosition',[1.2, 0.3, 0.65, 0.8]);
        end       
    else
        NewF = figure('Visible',visibility,'units','normalized','outerposition',[0 0 1 1],'tag','NewF');
    end     
   
    % Make the bars
    k = 1;
    for i = 1:m
        for j = 1:n
            for r = 1:2
                if r == 1
                    b = barh(pos(k),v1(j,i),width_bar);       
                    if k==1
                        faxis = findobj(NewF,'type','axes');
                        hold(faxis,'on');
                        %ylim(faxis,[0 pos(end)+extra_left]);
                        xlim(faxis,[yl1,yl2]);                        
                    end
                else
                    b = barh(pos(k),v2(j,i),width_bar,'parent',faxis);       
                end                 
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
                k = k + 1;
            end
            % Values
            if add_values
                tmp = num2str(round(v1(j,i)-v2(j,i),val_ndigits));
                if v1(j,i)-v2(j,i) < 0
                    if ~isequal(tmp(1),'-')
                        tmp = ['-',tmp];
                    end
                end
                text(val_text_start,mean(pos(k-2:k-1)),tmp,...
                    'FontName',FontName,'FontSize',val_font_size,'Rotation',val_rotate,'FontWeight','bold'); 
            end 
        end
    end
    
    % Axes labels and title
    ylabel(xlab,'FontName',FontName,'FontSize',FontSize_labels,'FontWeight',FontWeight_labels);
    xlabel(ylab,'FontName',FontName,'FontSize',FontSize_labels,'FontWeight',FontWeight_labels);
    if isequal(str_i,'Brodinova all models')
        title('Brodinova','FontName',FontName,'FontSize',FontSize_title,'FontWeight',FontWeight_title);
    else
        title(str_i,'FontName',FontName,'FontSize',FontSize_title,'FontWeight',FontWeight_title);
    end
   
    % Axis XTicks and XTickLabels
    posi1 = 1;
    p = pos(cumsum(grs));
    tickx = zeros(1,n);
    for k = 1:m
        j = find(pos==p(k));
        tickx(k) = mean(pos(posi1:j));
        posi1 = j+1;
    end    
    set(faxis,'YTick',tickx,'YTickLabel',str_x,...
        'FontSize',FontSize_ticks,'FontName',FontName,'FontWeight',FontWeight_ticks);    
    eval(eval_str); %rotate if needed
    
    % p-values
    if add_hypothesis_p && ~isempty(sets_p)
        posp = mean(reshape(pos,2,length(pos)/2));
        pv = reshape(sets_p,size(sets_p,1)*size(sets_p,2),1);
        xlim([yl1 yl2+0.15]);
        for pp = 1:length(posp)
            %Preapare the symbols
            if pv(pp) < 0.0001
                ast = '****';
            elseif pv(pp) < 0.001
                ast = '***';
            elseif pv(pp) < 0.01
                ast = '**';
            elseif pv(pp) < 0.05
                ast = '*';
            else
                ast = '#';
            end
            %Update the graph
            if isequal(ast,'#')
                text(yl2,posp(pp),ast,'FontName',FontName,'FontSize',p_font_size-p_font_size_red);
            else
                text(yl2,posp(pp)-0.8,ast,'FontName',FontName,'FontSize',p_font_size);
            end            
        end
    end
    
    % Overall
    tmp = get(faxis,'XTickLabel');
    a = find(str2double(tmp) > 1);
    tmp(a) = [];
    tmp = [tmp;cell(length(a),1)];
    set(faxis,'XTick',0:0.25:1);
    if overall_figure
        set(NewF,'Color','w','papersize',[8,8], 'paperposition',[0,0,5,8]);    
    end
    if special_figure
        set(NewF,'Color','w','papersize',[8,8], 'paperposition',[0,0,5,14]);    
    end    
    box(faxis,'off');   
    hold(faxis,'off');

    % Export
    export_figure(NewF, ppath, strjoin({'hor',plot_stat,extract,str_I,str_J,str_i,str_II},'_'), export, export_);
    close(NewF);    
end

