function [ RiV,rv,C,I,ri,cut,smp,m,rp,nt_all,i,max_distance_Rp ] = siVAT( x, cp, ns )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

[n,p]=size(x);

nt_all=zeros(cp,1);

[m,rp,max_distance_Rp]=MMRS(x,cp);

[~,i]=min(rp,[],2); 

smp=[];
for t=1:cp,
    s = find(i==t);
    nt = ceil(ns*length(s)/n);
    nt_all(t)=nt;
    ind=randperm(length(s));
    ind = ind(1:nt);
    smp=[smp; s(ind)];
end;
rs = distance2(x(smp,:),x(smp,:));
[rv,C,I,ri,cut]=VAT(rs);

[RiV,~,~]=iVAT(rv,1);

end

