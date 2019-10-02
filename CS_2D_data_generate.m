function [data_matrix] = CS_2D_data_generate(meanX,varX,meanY,varY,total_no_of_points,dimension)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
mean_c(1)=meanX; var_c(1)=varX;
mean_c(2)=meanY; var_c(2)=varY;


    data_matrix=zeros(total_no_of_points,dimension);
    l=1;
    
    while l<=size(data_matrix,1)
     for k=1:dimension
        data_matrix(l,k)=mean_c(k)+var_c(k)*randn(1);
     end
        l=l+1;
    end
end

