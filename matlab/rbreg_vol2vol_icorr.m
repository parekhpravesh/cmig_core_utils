function [M_v1_to_v2, min_cost, sf, lphpos] = rbreg_vol2vol_icorr(vol1, vol2, varargin)
% Multiscale Rigid body registration By Intensity Correlation
%       
% [M_reg, min_cost, sf, lphrange] = rbreg_vol2vol_icorr(vol1, vol2, [bdispiter], [bsmooth], ...
%                                         [range], [scales], [tmin], [amin], ...
%                                         [allowchanged],[ith], [baligned])
%
% Input:
%   vol1: template vol structure
%   vol2: regsitering vol structure
%   bdispiter: show ino ineach iteration
%   bsmooth: smooth input volume (default=true);
%   range: [lmin pmin hmin;lmax pmax hmax;dl dp dh]
%          default: [-70 -70 -70; 70 70 70; 2. 2. 2.]
%   scales: number of scales (default:[0 83 49 27 16 9 5 3 2 1]). Be sure
%   put 0 in the first scale to initialize algorithm
%   tmin: minimun in translation (in mm) default=0.5;
%   amin: minimum in angle (in rad) default= 0.5 degree
%   allowchanged: allowable parameter changes default=2;
%   ith: Intensity threshold for estimating center of mass
%
% Output:
%   M_v1_to_v2: Registration matrix from Vol1 to Vol2
%   min_const:  Minimization error
%   sf:         Scaling factor for Vol1/Vol2;
%   lphpos: sampling points 

%clear
%vol1=read_mgh('flash30r.mgh');
%vol2=read_mgh('flash05r.mgh');

bdispiter=false;
if nargin >= 3
  bdispiter = varargin{1};
end

bsmooth=true;
if nargin >= 4
  bsmooth = varargin{2};
end

range=[-70 -70 -70; 70 70 70; 2. 2. 2.];
if nargin >= 5
  range = varargin{3};
end

scales=[0 83 49 27 16 9 5 3 2 1];
if nargin >= 6
  scales = varargin{4};
end

tmin = 0.05;
if nargin >= 7
  tmin = varargin{5};
end

amin = (0.05)*(pi/180);
if nargin >= 8
  amin = varargin{6};
end

allowchanged=2;
if nargin >= 9
  allowchanged = varargin{7};
end

ith=20;
if nargin >= 10
  ith = varargin{8};
end

baligned = false;
if nargin >= 11
  baligned = varargin{9};
end

if bdispiter
  disp 'Calulating Center of Mass for template Volume...'
end

ln=ceil((range(2,1)-range(1,1))/range(3,1)+1);
pn=ceil((range(2,2)-range(1,2))/range(3,2)+1);
hn=ceil((range(2,3)-range(1,3))/range(3,3)+1);
tsize=ln*pn*hn;
numbins=ceil(tsize^(1/3));
lphpos=zeros(tsize,4);
count=1;

if (baligned == false)
    lphcomv1=vol_getCOM(vol1, true, ith);
    lphcomv1(3)=lphcomv1(3)+20;
    lphrange=[lphcomv1(1:3)';range];
     for i=1:ln
        for j=1:pn
            for k=1:hn
                lphpos(count,1:3)=lphcomv1(1:3)+(i-ln/2)*range(3,1)*vol1.DirCol...
                    +(j-pn/2)*range(3,2)*vol1.DirRow...
                    +(k-hn/2)*range(3,3)*vol1.DirDep;
                lphpos(count,4)=1;
                count=count+1;
            end
        end
    end
 else
     for i=1:ln
         for j=1:pn
             for k=1:hn
                 lphpos(count,1)=i*range(3,1)+range(1,1);
                 lphpos(count,2)=j*range(3,2)+range(1,2);
                 lphpos(count,3)=k*range(3,3)+range(1,3);
                 lphpos(count,4)=1;
                 count=count+1;
             end
         end
     end
end

if (bsmooth)
  if bdispiter
    disp    'Smoothing volume...'
  end
  vols1=vol_filter(vol1, 1);
  clear vol1;
  vols2=vol_filter(vol2, 1);
  clear vol2;
else
  vols1=vol1;
  clear vol1;
  vols2=vol2;
  clear vol2;

end

[vxlval1 inbound1]= vol_getvxlsval(lphpos, vols1, eye(4,4));

if bdispiter
  disp    'Registration...'
end
M_reg = eye(4,4);
M_reg_opt = M_reg;
min_cost = 1e10;
sf=1;
for scale = scales
  if scale==0
    win = 0;
  else
    win = 1;
  end
  changed = 1;
  pass = 0;
  while changed
    pass = pass+1;
    changed = 0;
    M_reg_bak = M_reg_opt;
    for txi = -win:win
    for tyi = -win:win
    for tzi = -win:win
    for axi = -win:win
    for ayi = -win:win
    for azi = -win:win
        if (sum([txi tyi tzi axi ayi azi]~=0)<=allowchanged)
            tx = txi*scale*tmin; ty = tyi*scale*tmin; tz = tzi*scale*tmin;
            ax = axi*scale*amin; ay = ayi*scale*amin; az = azi*scale*amin;
            M_reg = Mrotz(az)*Mroty(ay)*Mrotx(ax)*Mtrans(tx,ty,tz)*M_reg_bak;
            %M_reg = Mtrans(tx,ty,tz)*Mrotz(az)*Mroty(ay)*Mrotx(ax)*M_reg_bak;
            % vxlval1= vol_getvxlsval(lphpos, vols1, eye(4,4));
            [vxlval2 inbound2]= vol_getvxlsval(lphpos, vols2, M_reg);
            %tv=vxlval1-sf*vxlval2;
            %cost = tv'*tv/length(tv);
            %sf=mean(vxlval1./vxlval2);
            inbound =inbound1.*inbound2;
            ind= find(inbound>0);
            cost=-vxlval1(ind)'*vxlval2(ind)/(norm(vxlval1(ind))*norm(vxlval2(ind)));
            str = 'scale=%d (%d) [%d %d %d %d %d %d] cost=%f min_cost=%f\n';
            if (bdispiter)
                fprintf(str,scale,pass,txi,tyi,tzi,axi,ayi,azi,cost,min_cost);
            end
            if (cost<min_cost)
                [mval maxldir] = max(abs(M_reg(:,1)));
                [mval maxpdir] = max(abs(M_reg(:,2)));
                [mval maxhdir] = max(abs(M_reg(:,3)));
                if (maxldir == 1) & (maxpdir == 2) & (maxhdir == 3)
                    min_cost = cost;
                    M_reg_opt = M_reg;
                    str = '*** scale=%d (%d) [%d %d %d %d %d %d]';
                    str = [str 'cost=%f min_cost=%f\n'];
                    if (bdispiter)
                        fprintf(str,scale,pass,txi,tyi,tzi,axi,ayi,azi, cost,min_cost);
                    end
                    changed = 1;
                end
            end
        end
    end
    end
    end
    end
    end
    end
  end
end
M_v1_to_v2 = M_reg_opt;

vxlval2= vol_getvxlsval(lphpos, vols2, M_v1_to_v2);
ind=find(vxlval2>1);
sf=mean(vxlval1(ind)./ vxlval2(ind));