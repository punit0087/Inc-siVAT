function [RV,C,I,RI,d,new_point_location] = incVAT(RV,C,I,RI,d,distance_previous_points)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here %%     distance previous points means V 
    I_old=I; %%Reordered Indices Old  (Pn+1=I) , initilly Pn=Iold
    C_old=C;  %% Connection Indices Old
    new_point_index=length(I)+1;   %% i for insertPosition algorithm Dheeraj paper  (i=n+1)
    new_point_location=length(I)+1; 
    for j=1:length(I)-1  %% t (here t= j)  varies from 1 to n-1 InsertPosition Dheeraj
        [value,index]=min(distance_previous_points(1:j)); %%% min({Y1,Y2...Yj}
        %d(j)
        if(value<d(j))  %%if  min({Y1,Y2...Yj} < d(j)
            new_point_location=j+1; %% new point position  (i= j+1)
            break;
        else
            [~,index]=min(distance_previous_points); %% (in Dheeraj code j=argmin(V)=index
        end
    end
    %new_point_location
    %C
    remaining_points=I(new_point_location:end); %% remaining_points = A = I \ Pn  (points in Pn which are not in Pn+1)
    remaining_points_old_points_method=remaining_points;
    remaining_points_location_in_RV=new_point_location:length(RV);  %%(new point location to end)
    remaining_points_old_points_method_location_in_RV=remaining_points_location_in_RV;
    included_old_points=[];
    included_old_points_location_in_RV=[];
    pointer_last_point=new_point_location-1; %%pointer from new location -1 so that G1,G2 (i), G3 can be formed
    d_remaining=d(new_point_location-1:end); %% d remaining (d for remanining points)
    C_remaining=C(new_point_location:end);    %%C  remaining (C for remanining points)
    
    I=[I(1:new_point_location-1) new_point_index];  %%Pn+1={Pn1,Pn2,..new_point_index} (as in paper)
    d=[d(1:new_point_location-2) min(distance_previous_points(1:new_point_location-1))];  %%dn+1={dn1,dn2....min(Y1,Y2..Yt)}
    RV_reordering=1:new_point_location-1; %%RV_reordering=G
    C=[C(1:new_point_location-1) index];%%Fn+1={Fn1,Fn2....index(here j)}
    
    
    
    
    
    method=[];
    for k=1:length(remaining_points)
        %start_point=1
        min_dist_old_points=d_remaining(1); %%min_dist_old_points= z1=dn(Pos(B1)-1)
        closest_old_points=remaining_points_old_points_method(1); %%closest_old_points=w1 =P(ns+1) B1
        closest_old_points_location_RV=remaining_points_location_in_RV(1); %%Pos(w1)
        [~,closest_point_C_remaining_old_points]=ismember(I_old(C_remaining(1)),I); %%closest_old_points_location_RV=v1=arg (Pn(H1)=Pn+1)

        dist_new_point=distance_previous_points(remaining_points_location_in_RV); %Y_A
        [min_dist_new_point,index]=min(dist_new_point); %% min_dist_new_point=z2=min(Y_A)
        closest_new_point_location_RV=remaining_points_location_in_RV(index); 
        %closest_new_point=remaining_points(closest_new_point_location_RV-new_point_location+2);
        closest_new_point=remaining_points(index);%%closest_new_point=w2=A(argmin(YA))
        closest_point_C_remaining_new_point=new_point_location; %%closest_point_C_remaining_new_point=v2=i=new point location

        included_old_points;
        included_old_points_location_in_RV;
        remaining_points;
        remaining_points_location_in_RV; %%E ?
        dist_included_old_points=RV(included_old_points_location_in_RV,remaining_points_location_in_RV); %%Dn*(Pos(A),Pos(E))
        if(length(included_old_points_location_in_RV)==1)
            [value1,index1]=min(dist_included_old_points);
            %closest_point_C_included_old_points=included_old_points_location_in_RV;
            [~,closest_point_C_included_old_points]=ismember(included_old_points,I);
        else
            [value,index]=min(dist_included_old_points);
            [value1,index1]=min(value); %% z3=min(Dn*(Pos(A),Pos(E)))
            %closest_point_C_included_old_points=remaining_points_location_in_RV(index(index1));
            [~,closest_point_C_included_old_points]=ismember(included_old_points(index(index1)),I);   %%closest_point_C_included_old_points=v3=arg(E(index1)=Pn+1)
        end
        min_dist_included_old_points=value1;  %%z3
        closest_included_old_points_location_RV=remaining_points_location_in_RV(index1);
        closest_included_old_points=remaining_points(index1); %%w3=Aj=A(index1)
        %[~,closest_point_C_included_old_points]=ismember(I_old(C_remaining(1)),I);

        if(isempty(min_dist_included_old_points))
            [min_dist_all,min_dist_method]=min([min_dist_old_points min_dist_new_point]);
        else %%z=min(z1,z2,z3)
        [min_dist_all,min_dist_method]=min([min_dist_old_points min_dist_new_point min_dist_included_old_points]);
        end

        switch min_dist_method
            case(1)  %%% Procedude M1 in Dheeraj Paper
                method=[method 1];
                I=[I closest_old_points]; %%Pn+1= {Pn+1,w1)
                d=[d min_dist_old_points]; %%dn+1= {dn+1,z1)
                C=[C closest_point_C_remaining_old_points];  %%Fn+1= {Fn+1,w1)
                %included_old_points=[included_old_points closest_old_points]
                %included_old_points_location_in_RV=[included_old_points_location_in_RV closest_old_points_location_RV]
                RV_reordering=[RV_reordering closest_old_points_location_RV];  %%G= {G,Pos(w1))
                remaining_points(remaining_points==closest_old_points)=[]; %% delete w1 from A
                remaining_points_old_points_method(remaining_points_old_points_method==closest_old_points)=[];
                remaining_points_old_points_method_location_in_RV(remaining_points_old_points_method_location_in_RV==closest_old_points_location_RV)=[];
                remaining_points_location_in_RV(remaining_points_location_in_RV==closest_old_points_location_RV)=[];
                pointer_last_point=pointer_last_point+1;
                d_remaining(1)=[];
                C_remaining(1)=[];
                if(length(remaining_points_old_points_method)>0)
                    while(ismember(remaining_points_old_points_method(1),I)) %% Delete H1 till length(H1)>length(B1)
                        pointer_last_point=pointer_last_point+1;
                        d_remaining(1)=[];
                        C_remaining(1)=[];
                        remaining_points_old_points_method(1)=[];
                        remaining_points_old_points_method_location_in_RV(1)=[];

                        %included_old_points(included_old_points==closest_old_points)=[];
                        %included_old_points_location_in_RV(included_old_points_location_in_RV==closest_old_points_location_RV)=[];
                        if(length(remaining_points_old_points_method)==0)
                            break;
                        end
                    end
                end
            case(2)%%% Procedude M2 in Dheeraj Paper
                method=[method 2];
                I=[I closest_new_point];
                d=[d min_dist_new_point];
                C=[C closest_point_C_remaining_new_point];
                if(closest_new_point==remaining_points(1)) %%if w2=A1
                    if(length(remaining_points_old_points_method)>0)
                        while(ismember(remaining_points_old_points_method(1),I))
                            pointer_last_point=pointer_last_point+1;
                            d_remaining(1)=[];
                            C_remaining(1)=[];
                            
                            included_old_points(included_old_points==remaining_points_old_points_method(1))=[];
                            included_old_points_location_in_RV(included_old_points_location_in_RV==remaining_points_old_points_method_location_in_RV(1))=[];

                            remaining_points_old_points_method(1)=[];
                            remaining_points_old_points_method_location_in_RV(1)=[];
                            if(length(remaining_points_old_points_method)==0)
                                break;
                            end
                        end
                    end
                else
                    included_old_points=[included_old_points closest_new_point];%%E={E,w2}
                    included_old_points_location_in_RV=[included_old_points_location_in_RV closest_new_point_location_RV];
                    %remaining_points_old_points_method(remaining_points_old_points_method==closest_new_point)=[]
                    %remaining_points_location_in_RV(remaining_points_location_in_RV==closest_new_point_location_RV)=[]
                end
                RV_reordering=[RV_reordering closest_new_point_location_RV];%G={G,Pos(w2)}
                remaining_points(remaining_points==closest_new_point)=[];
                remaining_points_location_in_RV(remaining_points_location_in_RV==closest_new_point_location_RV)=[];
            case(3) %%% Procedude M3 in Dheeraj Paper
                method=[method 3];
                I=[I closest_included_old_points];
                d=[d min_dist_included_old_points];
                C=[C closest_point_C_included_old_points];
                if(closest_included_old_points==remaining_points(1))
                    if(length(remaining_points_old_points_method)>0)
                        while(ismember(remaining_points_old_points_method(1),I))
                            pointer_last_point=pointer_last_point+1;
                            d_remaining(1)=[];
                            C_remaining(1)=[];

                            included_old_points(included_old_points==remaining_points_old_points_method(1))=[];
                            included_old_points_location_in_RV(included_old_points_location_in_RV==remaining_points_old_points_method_location_in_RV(1))=[];

                            remaining_points_old_points_method(1)=[];
                            remaining_points_old_points_method_location_in_RV(1)=[];

                            if(length(remaining_points_old_points_method)==0)
                                break;
                            end
                        end
                    end
                else
                    included_old_points=[included_old_points closest_included_old_points];
                    included_old_points_location_in_RV=[included_old_points_location_in_RV closest_included_old_points_location_RV];
                    %remaining_points_old_points_method(remaining_points_old_points_method==closest_included_old_points)=[]
                    %remaining_points_location_in_RV(remaining_points_location_in_RV==closest_included_old_points_location_RV)=[]
                end
                RV_reordering=[RV_reordering closest_included_old_points_location_RV];
                remaining_points(remaining_points==closest_included_old_points)=[];
                remaining_points_location_in_RV(remaining_points_location_in_RV==closest_included_old_points_location_RV)=[];
        end
%         if(~isequal(remaining_points,remaining_points_old_points_method))
%             remaining_points
%             remaining_points_old_points_method
%         end

    end

    %d=[d(1:new_point_location-2) min(distance_previous_points) d(new_point_location-1:end)]
    
   
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Update VAT reordered Dissimilarity Matrix%%%%%%%%%%%%%%%%%%%%%%%%%%%
    RV_old=RV;
    RV=RV(RV_reordering,RV_reordering);
    %row_to_insert=[distance_previous_points(1:new_point_location-1) 0 distance_previous_points(new_point_location:end)]
    row_to_insert=distance_previous_points(RV_reordering); %% Y*
    row_to_insert=[row_to_insert(1:new_point_location-1) 0 row_to_insert(new_point_location:end)];
    RV=[RV(1:new_point_location-1,1:new_point_location-1) (row_to_insert(1:new_point_location-1))' RV(1:new_point_location-1,new_point_location:end);row_to_insert;RV(new_point_location:end,1:new_point_location-1) (row_to_insert(new_point_location+1:end))' RV(new_point_location:end,new_point_location:end)];
    [~,RI]=sort(I);
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
end

