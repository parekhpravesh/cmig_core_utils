function volf=vol_filter(voli, filter_type, varargin)
% Image Volume filtering
%
%   volf=vol_filter(vol, filter_type, [params])
%
%   vol:    Input Image volume
%   volf:   Output volume
%
%   filter_type and params:
%       0: Gradient Magnitude by sobel oprators
%       1: Gaussian filter, default size(3), sigma(0,5)
%           ex. volf=vol_filter(vol, 1, size, signma)
%       2: Laplacian filter, defualt alpha=0.2
%           ex. volf=vol_filter(vol, 2, alpha)
%       3: Laplacian of Gaussian filter, defulat size=5, sigma=0.5;
%           ex. volf=vol_filter(vol, 3, size, signma)
%       4: Sobel Operation in Row direction, no params.
%       5: Sobel Operation in Column direction, no params.
%       6: Sobel operation in Slice direction, no params
%
%

if filter_type <0 || filter_type>6
    disp 'Wrong filter tyep....';
end

params=[0;0];

%Sobel in Row
SobelR=zeros(3,3,3);
SobelR(1,1,1)=-2.;
SobelR(1,2,1)=0.;
SobelR(1,3,1)=2.;
SobelR(2,1,1)=-3.;
SobelR(2,2,1)=0.;
SobelR(2,3,1)=3.;
SobelR(3,1,1)=-2.;
SobelR(3,2,1)=0.;
SobelR(3,3,1)=2.;

SobelR(1,1,2)=-3.;
SobelR(1,2,2)=0.;
SobelR(1,3,2)=3.;
SobelR(2,1,2)=-6.;
SobelR(2,2,2)=0.;
SobelR(2,3,2)=6.;
SobelR(3,1,2)=-3.;
SobelR(3,2,2)=0.;
SobelR(3,3,2)=3.;

SobelR(1,1,3)=-2.;
SobelR(1,2,3)=0.;
SobelR(1,3,3)=2.;
SobelR(2,1,3)=-3.;
SobelR(2,2,3)=0.;
SobelR(2,3,3)=3.;
SobelR(3,1,3)=-2.;
SobelR(3,2,3)=0.;
SobelR(3,3,3)=2.;

SobelR=SobelR/52;

%Sobel in Column
SobelC=zeros(3,3,3);
SobelC(1,1,1)=-2.;
SobelC(1,2,1)=-3;
SobelC(1,3,1)=-2.;
SobelC(2,1,1)=0.;
SobelC(2,2,1)=0.;
SobelC(2,3,1)=0.;
SobelC(3,1,1)=2.;
SobelC(3,2,1)=3.;
SobelC(3,3,1)=2.;

SobelC(1,1,2)=-3.;
SobelC(1,2,2)=-6.;
SobelC(1,3,2)=-3.;
SobelC(2,1,2)=0.;
SobelC(2,2,2)=0.;
SobelC(2,3,2)=0.;
SobelC(3,1,2)=3.;
SobelC(3,2,2)=6.;
SobelC(3,3,2)=3.;

SobelC(1,1,3)=-2.;
SobelC(1,2,3)=-3.;
SobelC(1,3,3)=-2.;
SobelC(2,1,3)=0.;
SobelC(2,2,3)=0.;
SobelC(2,3,3)=0.;
SobelC(3,1,3)=2.;
SobelC(3,2,3)=3.;
SobelC(3,3,3)=2.;

SobelC=SobelC/52;

%Sobel in Slice
SobelD=zeros(3,3,3);
SobelD(1,1,1)=-2.;
SobelD(1,2,1)=-3;
SobelD(1,3,1)=-2.;
SobelD(2,1,1)=-3.;
SobelD(2,2,1)=-6.;
SobelD(2,3,1)=-3.;
SobelD(3,1,1)=-2.;
SobelD(3,2,1)=-3.;
SobelD(3,3,1)=-2.;

SobelD(1,1,2)=0.;
SobelD(1,2,2)=0.;
SobelD(1,3,2)=0.;
SobelD(2,1,2)=0.;
SobelD(2,2,2)=0.;
SobelD(2,3,2)=0.;
SobelD(3,1,2)=0.;
SobelD(3,2,2)=0.;
SobelD(3,3,2)=0.;

SobelD(1,1,3)=2.;
SobelD(1,2,3)=3.;
SobelD(1,3,3)=2.;
SobelD(2,1,3)=3.;
SobelD(2,2,3)=6.;
SobelD(2,3,3)=3.;
SobelD(3,1,3)=2.;
SobelD(3,2,3)=3.;
SobelD(3,3,3)=2.;

SobelD=SobelD/52;

if (filter_type==0)
    mag=zeros(size(voli.imgs));
    sr=imfilter(voli.imgs,SobelR);
    mag=sr.^2;
    clear sr;
    sc=imfilter(voli.imgs,SobelC);
    mag=mag+sc.^2;
    clear sc;
    sd=imfilter(voli.imgs,SobelD);
    mag=mag+sd.^2;
    clear sd;
    volf=voli;
    volf.imgs=sqrt(mag);
end

if (filter_type==4)
    volf=voli;
    volf.imgs=imfilter(voli.imgs,SobelR);
end

if (filter_type==5)
    volf=voli;
    volf.imgs=imfilter(voli.imgs,SobelC);
end

if (filter_type==6)
    volf=voli;
    volf.imgs=imfilter(voli.imgs,SobelD);
end

        
if filter_type==1
    params=[3;0.5];
    if nargin >= 3
       params(1) = varargin{1};
    end
    if nargin >= 4
       params(2) = varargin{2};
    end
    hsize=2*params(1)+1;
    H=zeros(hsize, hsize, hsize);
    mind=params(1)+1;
    var=params(2)^2;
    sumt=0.;
    for k=1:hsize
    for i=1:hsize
    for j=1:hsize
        st=  (i-mind)*(i-mind)+(j-mind)*(j-mind)+(k-mind)*(k-mind);
        H(i,j,k)=exp(-st/(2*var));
        sumt=sumt+ H(i,j,k);
    end
    end
    end
    
    H=H./sumt;
    volf=voli;
    volf.imgs=imfilter(voli.imgs,H);
  
    
end

if filter_type==2
    params=[0;0.2];
    if nargin >= 3
       params(2) = varargin{1};
    end
    alpha=params(2);
    H=zeros(3,3,3);
    H(1,1,1)=alpha/20.;
    H(1,2,1)=alpha/20.;
    H(1,3,1)=alpha/20.;
    H(2,1,1)=alpha/20.;
    H(2,2,1)=(1-alpha)/6.;
    H(2,3,1)=alpha/20.;
    H(3,1,1)=alpha/20.;
    H(3,2,1)=alpha/20.;
    H(3,3,1)=alpha/20.;

	H(1,1,2)=alpha/20.;
	H(1,2,2)=(1-alpha)/6.;
	H(1,3,2)=alpha/20.;
	H(2,1,2)=(1-alpha)/6.;
	H(2,2,2)=-1;
	H(2,3,2)=(1-alpha)/6.;
	H(3,1,2)=alpha/20.;
	H(3,2,2)=(1-alpha)/6.;
	H(3,3,2)=alpha/20.;
	
	H(1,1,3)=alpha/20.;
	H(1,2,3)=alpha/20.;
	H(1,3,3)=alpha/20.;
	H(2,1,3)=alpha/20.;
	H(2,2,3)=(1-alpha)/6.;
	H(2,3,3)=alpha/20.;
	H(3,1,3)=alpha/20.;
	H(3,2,3)=alpha/20.;
	H(3,3,3)=alpha/20.;
    volf=voli;
    volf.imgs=imfilter(voli.imgs,H);

end

if filter_type==3
    params=[5;0.5];
    if nargin >= 3
       params(1) = varargin{1};
    end
    if nargin >= 4
       params(2) = varargin{2};
    end
    hsize=2*params(1)+1;
    H=zeros(hsize, hsize, hsize);
    mind=params(1)+1;
    var=params(2)^2;
    sumt=0.;
    for k=1:hsize
    for i=1:hsize
    for j=1:hsize
        st=  (i-mind)*(i-mind)+(j-mind)*(j-mind)+(k-mind)*(k-mind);
        wt=(st-2*var)/(2*pi*var^3);
        tmp=exp(-st/(2*var));
        sumt=sumt+ tmp;
        H(i,j,k)=tmp/wt;
    end
    end
    end
    
    H=H./sumt;
    volf=voli;
    volf.imgs=imfilter(voli.imgs,H);

end


% volf=voli;
% info_i=zeros(4,6);
% info_i(1,1)=voli.dimr;
% info_i(2,1)=voli.dimc;
% info_i(3,1)=voli.dimd;
% info_i(1,2)=voli.vx;
% info_i(2,2)=voli.vy;
% info_i(3,2)=voli.vz;
% info_i(4,2)=voli.slicegap;
% info_i(1:3,3)=voli.DirRow;
% info_i(1:3,4)=voli.DirCol;
% info_i(1:3,5)=voli.DirDep;
% info_i(1:3,6)=voli.lphcent;
% info_i(4,6)=1;
% %params
% imgsvec=volfilterMEX(info_i, voli.imgs, filter_type, params);
% 
% volf.imgs=reshape(imgsvec, volf.dimr, volf.dimc, volf.dimd);
% volf.maxI=max(volf.imgs(:));
% volf.minI=min(volf.imgs(:));
