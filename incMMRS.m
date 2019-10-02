function [m_incsiVAT,rp_incsiVAT,max_distance_Rp_incsiVAT] = incMMRS(data_till_now,this_data,cp,m,Rp,max_distance_Rp)

    [len,wid]=size(Rp);
    [len1,~]=size(this_data); 
    
    data_till_now_new=[data_till_now;this_data]; %%X_curr = X_prev U X_ch
    
    change_in_cp_objects=0; %%ChangeMM
    
    rp_incsiVAT=zeros(len+len1,wid);
    rp_incsiVAT(1:len,1:wid)=Rp;
    
    m_incsiVAT=m;
    
    max_distance_Rp_incsiVAT=max_distance_Rp;
    
    d=distance2(data_till_now(1,:),this_data)';
    rp_incsiVAT(len+1:len+len1,1)=d;
    for t=2:cp
        d=min(d,rp_incsiVAT(len+1:len+len1,t-1));
        if(max(d)>max_distance_Rp(t))
            change_in_cp_objects=1;
            break;
        end
        rp_incsiVAT(len+1:len+len1,t)=distance2(data_till_now(m_incsiVAT(t),:),this_data)';
    end
    
    if(change_in_cp_objects)
        m_incsiVAT(t:end)=0;
        rp_incsiVAT(:,t:end)=0;
        max_distance_Rp_incsiVAT(t:end)=0;
        d=min(rp_incsiVAT(:,1:t-1),[],2);
        while t<=cp,
            d=min(d,rp_incsiVAT(:,t-1));
            [max_distance_Rp_incsiVAT(t),m_incsiVAT(t)]=max(d);
            rp_incsiVAT(:,t)=distance2(data_till_now_new(m_incsiVAT(t),:),data_till_now_new)';
            t=t+1;
        end
    end
end    
