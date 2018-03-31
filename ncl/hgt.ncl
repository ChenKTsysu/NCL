;hgt
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
begin 

   f=addfile("/mnt/e/data/hgt.sfc.nc", "r")
   hgt=short2flt(f->hgt(0,:,:))
   wks=gsn_open_wks("x11", "name")
   print(max(hgt))
   res=True
   res@cnFillOn  =True
   res@cnLinesOn =True
   res@gsnMaximize=True
   res@cnLevelSelectionMode ="ExplicitLevels"
   res@cnLevels   =(/2000/)
   res@mpMaxLonF  =140
   res@mpMinLonF  =60
   res@mpMinLatF  =10
   res@mpMaxLatF  =60
   plot=gsn_csm_contour_map(wks, hgt(:,:), res)
print("all")
   end