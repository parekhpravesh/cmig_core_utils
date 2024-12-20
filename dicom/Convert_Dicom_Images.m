function [vol,M] = Convert_Dicom_Images(dcminfo);

maxlen = max([dcminfo(:).filenamelen]);
nim = length(dcminfo);
flist = char(zeros(nim,maxlen));
for imnum = 1:nim
  tmpstr = dcminfo(imnum).filename;
  flist(imnum,1:length(tmpstr)) = tmpstr;
end
[vol, M] = load_dicom_fl2(flist,dcminfo);
