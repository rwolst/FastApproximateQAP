n = 279;
num_runs = 100;
num_algs = 6;

rootDir='~/Research/projects/primary/FastApproximateQAP';
load([rootDir, '/data/results/elegans_connectomes2.mat']); % load FAQ results
savestuff=0;

%% compute errors for chemical connectome

err_chem = zeros(num_runs,num_algs);

for idx = 1:num_runs
    
    % Achem(the_perm,the_perm) == Achem(p_PATH,p_PATH);
    
    the_perm = dlmread(sprintf([rootDir, '/data/elegans/txt_files/perm/perm_%d.txt'],idx));
    the_perm = the_perm(:);
    
    iv = 1:n;
    rp = zeros(n,1);
    rp(the_perm) = iv;
    
    graphm_perms = dlmread(sprintf([rootDir, '/data/elegans/output/exp_out_file_%d'],idx),' ',5,0);
    graphm_perms = graphm_perms(:,[1 5 3 2 4 6]);
    
    %     p_I = graphm_perms(:,1);
    %     p_rand = graphm_perms(:,5);
    %     p_RANK = graphm_perms(:,3);
    %     p_U = graphm_perms(:,2);
    %     p_QCV = graphm_perms(:,4);
    %     p_PATH = graphm_perms(:,num_algs);
    
    for ii = 1:num_algs
        err_chem(idx,ii) = sum( rp == graphm_perms(:,ii) ) / n;
        p = graphm_perms(:,ii);
        err_chem(idx,ii) = nnz( rp == p ) / n;
    end
    
end

percentiles=[.05, .25, .5 .75, .95];
chemErrors=[1-err_chem(:,4:end), chem.errors/n];


%% compute errors for electrical connectome

err_gap = zeros(num_runs,num_algs);

for idx = 1:num_runs
    
    % Agap(the_perm,the_perm) == Agap(p_PATH,p_PATH);
    
    the_perm = dlmread(sprintf([rootDir, '/data/elegans/txt_files/perm/perm_%d.txt'],idx));
    the_perm = the_perm(:);
    
    iv = 1:n;
    rp = zeros(n,1);
    rp(the_perm) = iv;
    
    graphm_perms = dlmread(sprintf([rootDir, '/data/elegans/output/exp_out_file_gap_%d'],idx),' ',5,0);
    graphm_perms = graphm_perms(:,[1 5 3 2 4 6]);
    
    %     p_I = graphm_perms(:,1);
    %     p_rand = graphm_perms(:,5);
    %     p_RANK = graphm_perms(:,3);
    %     p_U = graphm_perms(:,2);
    %     p_QCV = graphm_perms(:,4);
    %     p_PATH = graphm_perms(:,6);
    
    for ii = 1:num_algs
        p = graphm_perms(:,ii);
        err_gap(idx,ii) = nnz( rp == p ) / n;
    end
    
end

gapErrors=[1-err_gap(:,4:end), gap.errors/n];

%% boxplot results
clc

left=0.1;
bottom1=0.55;
bottom2=0.1;
width=0.80;
height=0.3;


figure(1); clf
subplot('Position',[left bottom1 width height]);
boxplot(chemErrors,...
    'labels',{'','','',''},...
    'color','k','symbol','k+','plotstyle','compact'...
    ,'positions',linspace(0,.1,4));
title('Chemical')
ylabel('error (%)')
set(gca,'YTick',[0:.5:1])
ylim([0 1])

subplot('Position',[left bottom2 width height]);
boxplot(gapErrors...
    ,'labels',{'U',' QCV','PATH','FAQ'}...
    ,'labelorientation','horizontal'...
    ,'color','k','symbol','k+','plotstyle','compact');
ylim([0 1])
set(gca,'YTick',[0:.5:1])
title('Electrical')
ylabel('error (%)')

if savestuff==1
    wh=[3 1.3]*2;
    figName=[rootDir, 'figs/connectomes'];
    set(gcf,'PaperSize',wh,'PaperPosition',[0 0 wh],'Color','w');
    print('-dpdf',figName)
    print('-dpng',figName)
    saveas(gcf,figName)
end

%% get stats

chemPercentiles=quantile(chemErrors,percentiles);
gapPercentiles=quantile(gapErrors,percentiles);
% chemIQR=chemPercentiles(4



%
%
% figure(2), clf, hold all
% % subplot(2,1,1);
% errorbar([1:4],gapPercentiles(3,:),gapPercentiles(2,:)-gapPercentiles(3,:),gapPercentiles(4,:)-gapPercentiles(3,:),'x','linewidth',2,'color',[.75, .75, .75])
% errorbar([1:4]+0.05,chemPercentiles(3,:),chemPercentiles(2,:)-chemPercentiles(3,:),chemPercentiles(4,:)-chemPercentiles(3,:),'xk','linewidth',2)