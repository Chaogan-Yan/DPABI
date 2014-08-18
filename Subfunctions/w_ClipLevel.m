function clip=w_ClipLevel(varargin)
%varargin{1}=mfac;
%varargin{2}=dataset;


%Acquire 4D Matrix
mfrac=varargin{1};
    
if ischar(varargin{2})
    [Volume4D, VoxelSize, Header]=y_ReadRPI(varargin{2});
    MeanAbsVolume=mean(abs(Volume4D) , 4);
else
    MeanAbsVolume=varargin{2};
end
    MeanAbsVolume=reshape(MeanAbsVolume , [] , 1);
    SortVolume=sort(MeanAbsVolume ,1);
    fac=max(SortVolume(:));
    
    SortVolume=SortVolume(SortVolume>0);
    [Hist , Xout] = hist(SortVolume , 10000);
    
    %qq = sum(Hist)*0.65;
    qq = length(SortVolume)*0.65;
    ii = size(Hist , 2);
    kk=0;
    while kk < qq
        kk=Hist(1 , ii) + kk;
        ii=ii-1;
    end


ncut=ii;
nold=0;
interation_count=1;

while interation_count<=66 && ncut ~= nold
    npos = sum(Hist(1,ii:end));
    nhalf= floor(npos*0.5);
    kk=0;
    while kk < nhalf && ii<=size(Hist , 2)
        kk = Hist(1,ii)+kk;
        ii=ii+1;
    end
    nold = ncut;
    ncut = floor(mfrac*ii);
    ii=ncut;
    interation_count = interation_count+1;
end

clip=Xout(ncut);