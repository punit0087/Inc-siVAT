function [m,Rp,max_distance_Rp] = MMRS(X,cp)

[n,p]=size(X);

m=ones(cp,1);
max_distance_Rp=zeros(cp,1);
d=distance2(X(ceil(rand(1)*n),:),X)';
Rp(:,1)=d;
for t=2:cp,
    d=min(d,Rp(:,t-1));
    [max_distance_Rp(t),m(t)]=max(d);
    Rp(:,t)=distance2(X(m(t),:),X)';
end;