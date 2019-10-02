%%Please cite the following paper when using our code or its subrotines.

%%For inc-siVAT, inc-MMRS please cite following paper.
%Rathore, P., Kumar, D., Bezdek, J. C., Rajasegarar, S., Palaniswami, M.(2019). Visual Structure Assessment and Anomaly Detection for High-Velocity Data Streams, under review in IEEE Transactions on Cybernetics.

%%If using inc-VAT/dec-iVAT and inc-iVAT/dec-iVAT, please cite following paper.
%% Kumar, D., Bezdek, J. C., Rajasegarar, S., Palaniswami, M., Leckie, C., Chan, J., & Gubbi, J. (2016) Adaptive cluster tendency visualization and anomaly detection for streaming data. ACM Transactions on Knowledge Discovery from Data (TKDD), 11(2), 24.

%% If using VAT and iVAT please cite following papers.

%VAT - Bezdek, J. C., & Hathaway, R. J. (2002, May). VAT: A tool for visual assessment of (cluster) tendency. In Proceedings of the 2002 International Joint Conference on Neural Networks. IJCNN'02 (Cat. No. 02CH37290) (Vol. 3, pp. 2225-2230). IEEE.
%iVAT - Havens, T. C., & Bezdek, J. C. (2011). An efficient formulation of the improved visual assessment of cluster tendency (iVAT) algorithm. IEEE Transactions on Knowledge and Data Engineering, 24(5), 813-822.

clc
close all
clear all

%%%%%%:Load Input (simulated) data stream%%%%%%%%%%%%%%%%%55
%We generate synthetic data and simulate its data stream
dimension=2;

[data_matrix] = CS_2D_data_generate(-15,1,-8,1,12000,dimension);
data_matrix_with_lables=[data_matrix zeros(12000,1)+1];

[data_matrix] = CS_2D_data_generate(-15,1,8,1,12000,dimension);
data_matrix=[data_matrix zeros(12000,1)+2];
data_matrix_with_lables=[data_matrix_with_lables;data_matrix];

[data_matrix] = CS_2D_data_generate(15,1,8,1,12000,dimension);
data_matrix=[data_matrix zeros(12000,1)+3];
data_matrix_with_lables=[data_matrix_with_lables;data_matrix];

[data_matrix] = CS_2D_data_generate(15,1,-8,1,12000,dimension);
data_matrix=[data_matrix zeros(12000,1)+4];
data_matrix_with_lables=[data_matrix_with_lables;data_matrix];


[data_matrix] = CS_2D_data_generate(0,1,0,1,2000,dimension);
data_matrix=[data_matrix zeros(2000,1)+5];
data_matrix_with_lables=[data_matrix_with_lables;data_matrix];


[data_matrix] = CS_2D_data_generate(-15,1,0,3,25000,dimension);
data_matrix=[data_matrix zeros(25000,1)+6];
data_matrix_with_lables=[data_matrix_with_lables;data_matrix];

[data_matrix] = CS_2D_data_generate(15,1,0,3,25000,dimension);
data_matrix=[data_matrix zeros(25000,1)+7];
data_matrix_with_lables=[data_matrix_with_lables;data_matrix];


data_matrix_without_lables=data_matrix_with_lables(:,1:end-1);
Labels=data_matrix_with_lables(:,end);

% INDX=randperm(total_no_of_points);
% data_matrix_with_lables=data_matrix_with_lables(INDX,:);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%parameters
total_no_of_points=size(data_matrix_without_lables,1); %%N
dimension = size(data_matrix_without_lables,2); %%data dimension
cp=30; %%k'
ns=200; %%n
inc_sivat_window_size=500;  %%N_ch = InitN = 500
no_of_iterations=floor(total_no_of_points/inc_sivat_window_size);


time_incsiVAT_incMMRS=[];
time_incsiVAT_smp=[];
time_incsiVAT_vat=[];
data_till_now=data_matrix_without_lables(1:inc_sivat_window_size,:); %%X_curr



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Steps 1 and 2, Apply siVAT (MMRS and iVAT) to the first or initial chunk
[ RiV,rv,C,I,ri,cut,smp,m,Rp,nt_all,cp_nn_index,max_distance_Rp ] = siVAT(data_till_now, cp, ns );



cut=cut'; %%d - cut magnitudes
cut(1)=[];

rp_incsiVAT=Rp; %%R - distance matrix
m_incsiVAT=m; %%M - Maximin points
max_distance_Rp_incsiVAT=max_distance_Rp; %%Dmax

RiV_incsiVAT=RiV;
rv_incsiVAT=rv;
C_incsiVAT=C; %%F = Connection Indices in MST
I_incsiVAT=I; %% P - VAR Reordering
ri_incsiVAT=ri; %%
cut_incsiVAT=cut;  %d - MST cut magnitudes
smp_incsiVAT=smp; %%MMRS sample \tilde{S}

%%%%%%%%%%%%%%%%%%plots%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if dimension == 2
    g=subplot(2,1,2);
    plot(data_till_now(:,1),data_till_now(:,2),'.','color','b'); hold on;
end

g=subplot(2,1,1);
p = get(g,'position');
p(2) = p(3)*0.6; % Add 10 percent to height
set(g, 'position', p);
imagesc(RiV);colormap gray; axis equal; axis off;

set(gcf,'NextPlot','add');
axes;
s1 = strcat('Number of data points =', num2str(size(data_till_now,1)),', New points added in iVAT image=', num2str(length(0)));
s2=  strcat('Old points deleted from iVAT image=', num2str(1));
s3=  strcat('Computation Time = ',num2str(0),' seconds');


h = title({s1,s2,s3});
set(gca,'Visible','off');
set(h,'Visible','on');




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
PerChunk_incsiVATTime=[];
ElemstoRemove=[];
ElemstoAdd=[];

for i=2:no_of_iterations
    i
    
    %%Step 3
    this_data=data_matrix_without_lables((i-1)*inc_sivat_window_size+1:i*inc_sivat_window_size,:);
    data_till_now_new=[data_till_now;this_data];
    
    %%%%%%%%%%%%%%%%%% Following code plots only for 2D data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    refresh;
    if dimension == 2
        g= subplot(2,1,2);
        plot(this_data(:,1),this_data(:,2),'.','color','b'); hold on;
    end
    %%%%%%%%%%%%%%%%%%plots%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    [n,~]=size(data_till_now_new); %%N_curr
    nt_all_incsiVAT=zeros(1,cp); %%\mathcal{N}
    
    
    %%% Step 4
    tic
    [m_incsiVAT,rp_incsiVAT,max_distance_Rp_incsiVAT] = incMMRS(data_till_now,this_data,cp,m_incsiVAT,rp_incsiVAT,max_distance_Rp_incsiVAT);
    [~,cp_nn_index_siVAT]=min(rp_incsiVAT,[],2); %% find  nearest neighbour to new cp points
    time_incsiVAT_incMMRS=[time_incsiVAT_incMMRS toc];
    
    
    
    %%% Step 5
    elemnts_to_remove=[];
    elements_to_add=[];
    
    tic
    for t=1:cp,
        s = find(cp_nn_index_siVAT==t);
        nt = ceil(ns*length(s)/n);
        nt_all_incsiVAT(t)=nt;
        
        [tf, ~] = ismember(smp_incsiVAT, s);
        already_in_smp=smp_incsiVAT(tf);
        
        if(length(already_in_smp)>nt)
            ind=randperm(length(already_in_smp));
            
            elemnts_to_remove=[elemnts_to_remove;already_in_smp(ind(1:length(already_in_smp)-nt))];
        else
            if(length(already_in_smp)<nt)
                [tf1, ~] = ismember(s,smp_incsiVAT);
                not_in_smp=s(~tf1);
                ind=randperm(length(not_in_smp));
                
                elements_to_add=[elements_to_add;not_in_smp(ind(1:nt-length(already_in_smp)))];
            end
        end
    end
    time_incsiVAT_smp=[time_incsiVAT_smp toc];
    
    %%% Step 6
    
    tic
    for j=1:length(elemnts_to_remove)
        point_to_remove=find(smp_incsiVAT==elemnts_to_remove(j));
        iVAT_point_to_remove_index=find(I_incsiVAT==point_to_remove);
        [rv_incsiVAT,C_incsiVAT,I_incsiVAT,ri_incsiVAT,cut_incsiVAT] = decVAT(rv_incsiVAT,C_incsiVAT,I_incsiVAT,ri_incsiVAT,cut_incsiVAT,point_to_remove);
        [RiV_incsiVAT] = deciVAT(rv_incsiVAT,RiV_incsiVAT,iVAT_point_to_remove_index);
        
        smp_incsiVAT_1=smp_incsiVAT;
        smp_incsiVAT_1(point_to_remove)=[];
        I_mapped=zeros(1,length(I_incsiVAT));
        for k=1:length(I_mapped)
            idx=find(smp_incsiVAT_1==smp_incsiVAT(I_incsiVAT(k)));
            I_mapped(k)=idx;
        end
        smp_incsiVAT=smp_incsiVAT_1;
        I_incsiVAT=I_mapped;
    end
    
    %%% Step 7
    
    for j=1:length(elements_to_add)
        distance_previous_points=distance2(data_till_now_new(elements_to_add(j),:),data_till_now_new(smp_incsiVAT(I_incsiVAT),:));
        [rv_incsiVAT,C_incsiVAT,I_incsiVAT,ri_incsiVAT,cut_incsiVAT,new_point_location] = incVAT(rv_incsiVAT,C_incsiVAT,I_incsiVAT,ri_incsiVAT,cut_incsiVAT,distance_previous_points);
        [RiV_incsiVAT] = inciVAT(rv_incsiVAT,RiV_incsiVAT,new_point_location);
        smp_incsiVAT=[smp_incsiVAT;elements_to_add(j)];
    end
    time_incsiVAT_vat=[time_incsiVAT_vat toc];
    
    PerChunk_incsiVATTime= [PerChunk_incsiVATTime time_incsiVAT_incMMRS(end)+time_incsiVAT_smp(end)+time_incsiVAT_vat(end)];
    TotalIncsiVATTime=cumsum(PerChunk_incsiVATTime); %%Cumulative
    ElemstoRemove= [ElemstoRemove length(elemnts_to_remove)];
    ElemstoAdd= [ElemstoAdd length(elements_to_add)];
    
    
    %%%%%%%%%%%%%%%%%%plots%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    refresh;
    g=subplot(2,1,1);
    p = get(g,'position');
    p(2) = p(3)*0.6; % Add 10 percent to height
    set(g, 'position', p);
    imagesc(RiV_incsiVAT);colormap gray; axis equal; axis off;
    
    set(gcf,'NextPlot','add');
    axes;
    s1 = strcat('Number of data points =', num2str(size(data_till_now_new,1)),', New points added in iVAT image=', num2str(length(elements_to_add)));
    s2=  strcat('Old points deleted from iVAT image=', num2str(length(elemnts_to_remove)));
    s3=  strcat('Computation Time = ',num2str(TotalIncsiVATTime(end)),' seconds');
    
    
    h = title({s1,s2,s3});
    set(gca,'Visible','off');
    set(h,'Visible','on');
    
    drawnow;
    refreshdata;
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Step 8
    data_till_now=data_till_now_new;
     
end

%%%Step 9: Optional %%%%%%%%%Find cut threshold for clustering%%%%
%%Incomplete..
sort_cut=sort(cut_incsiVAT);
Q1=[1 sort_cut(1)];
Q2=[length(smp_incsiVAT) sort_cut(end)];

d=zeros(length(smp_incsiVAT),1);
for i=1:length(smp_incsiVAT)-1
    i;
    P=[i sort_cut(i)];
    d(i) = abs(det([Q2-Q1;P-Q1]))/norm(Q2-Q1);
end
[d_max_val,d_max_idx]=max(d);

alpha=((sort_cut(d_max_idx)+sort_cut(d_max_idx+1))/2)/mean(cut_incsiVAT)
cut_threshold=alpha*mean(cut_incsiVAT)
ind_cut_incsiVAT=find(cut_incsiVAT>=cut_threshold);
NoofK=length(ind_cut_incsiVAT)+1;
% [cuts,ind_incsiVAT]=sort(cut_incsiVAT,'descend');
% ind_incsiVAT=sort(ind_incsiVAT(1:NoofK-1));
Pi=zeros(length(ind_cut_incsiVAT),1);
Pi(I_incsiVAT(1:ind_cut_incsiVAT(1)-1))=1;
Pi(I_incsiVAT(ind_cut_incsiVAT(end):end))=NoofK;
for k=2:NoofK-1,
    Pi(I_incsiVAT(ind_cut_incsiVAT(k-1):ind_cut_incsiVAT(k)-1))=k;
end;
[a,b]=hist(Pi,[1:NoofK]);
figure, plot(sort_cut,':k'); hold on;
plot(repmat(cut_threshold,1,length(sort_cut)),'-r');


%%%%%%%%%%%%%%%%%%%Plot Elements Added/Deleted for Change Detection%%%%%%%%%%
figure, plot(1:length(ElemstoRemove),(ElemstoAdd+ElemstoRemove),'');
ylabel('Number of points added/deleted')


