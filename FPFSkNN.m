%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Citation:
% S. Memi?, S. Engino?lu, and U. Erkan, 2022. Fuzzy Parameterized Fuzzy 
% Soft k-Nearest Neighbor Classifier, Neurocomputing, 500, 351-378. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Abbreviation of Journal Title: Neurocomputing
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% https://doi.org/10.1016/j.neucom.2022.05.041
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% https://www.researchgate.net/profile/Samet_Memis2
% https://www.researchgate.net/profile/Serdar_Enginoglu2
% https://www.researchgate.net/profile/Ugur_Erkan
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Demo: 
% clc;
% clear all;
% DM = importdata('Wine.mat');
% [x,y]=size(DM);
% 
% data=DM(:,1:end-1);
% class=DM(:,end);
% if prod(class)==0
%     class=class+1;
% end
% k_fold=5;
% cv = cvpartition(class,'KFold',k_fold);
%     for i=1:k_fold
%         test=data(cv.test(i),:);
%         train=data(~cv.test(i),:);
%         T=class(cv.test(i),:);
%         C=class(~cv.test(i),:);
%     
%         sFPFSkNN=FPFSkNN(train,C,test,3,'Pearson');
%         accuracy(i,:)=sum(sFPFSkNN==T)/numel(T);
%     end
% mean_accuracy=mean(accuracy);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function PredictedClass=FPFSkNN(train,C,test,k,corrname)
[em,en]=size(train);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  for j=1:en
      fw(1,j)=abs(corr(train(:,j),C,'Type',corrname,'Rows','complete'));
  end
  fw(isnan(fw))=0;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[tm,n]=size(test);
data=[train;test];
for j=1:n
    data(:,j)=normalise(data(:,j));
end
train=data(1:em,:);
test=data(em+1:end,:);
UClass=unique(C);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        for r=1:numel(UClass)
            rtrain=train((C == UClass(r)),:);
            for i=1:tm
                a=[fw ; test(i,:)];
                for j=1:size(rtrain,1)
                    b=[fw ; rtrain(j,:)];
                    F(r,j,i,1)=fpfsd1(a,b);
                    F(r,j,i,2)=fpfsd2(a,b);
                    F(r,j,i,3)=fpfsd3(a,b);
                    F(r,j,i,4)=fpfsd5(a,b);
                    F(r,j,i,5)=fpfsd6(a,b,3);                
                end      
            end
            F(r,:,:,:)= sort(F(r,:,:,:),2);
            if(size(F,2)<k)
            G(r,:,:)=mean(F(r,1:size(F,2),:,:),2);
            else
            G(r,:,:)=mean(F(r,1:k,:,:),2);    
            end
            clear F;
        end

        for i=1:tm
            [~,h] =min(G(:,i,:));
            PredictedClass(i,1)=UClass(mode(h(1,1,:)));
            clear h;
        end
end

function na=normalise(a)
[m,n]=size(a);
    if max(a)~=min(a)
        na=(a-min(a))/(max(a)-min(a));
    else
        na=ones(m,n);
    end
end                                                                                                                                                                  
%Hamming pseudo metric over fpfs-matrices
function X=fpfsd1(a,b)
if size(a)==size(b)
[m,n]=size(a);
d=0;
  for i=2:m
    for j=1:n
       d=d+abs(a(1,j)*a(i,j)-b(1,j)*b(i,j));
    end
  end
  X=d;
end
end
% Chebyshev pseudo metric over fpfs-matrices
function X=fpfsd2(a,b)
if size(a)==size(b)
[m,n]=size(a);
  for i=2:m
    for j=1:n
       d(j)=abs(a(1,j)*a(i,j)-b(1,j)*b(i,j));
    end
    e(i-1)=max(d);
  end
  X=max(e);
end
end
% Euclidean pseudo metric over fpfs-matrices
function X=fpfsd3(a,b)
if size(a)==size(b)
[m,n]=size(a);
d=0;
  for i=2:m
    for j=1:n
       d=d+abs(a(1,j)*a(i,j)-b(1,j)*b(i,j))^2;
    end
  end
  X=sqrt(d);
end
end
% Hamming-Hausdorff pseudo metric over fpfs-matrices
function X=fpfsd5(a,b)
if size(a)==size(b)
[m,n]=size(a);
  for i=2:m
    for j=1:n
       d(j)=abs(a(1,j)*a(i,j)-b(1,j)*b(i,j));
    end
    e(i-1)=max(d);
  end
  X=sum(e);
end
end
% Minkowski pseudo metric over fpfs-matrices
function X=fpfsd6(a,b,p)
if size(a)==size(b)
[m,n]=size(a);
d=0;
  for i=2:m
    for j=1:n
       d=d+abs(a(1,j)*a(i,j)-b(1,j)*b(i,j))^p;
    end
  end
  X=d^(1/p);
end
end
