;----------------------------------------------------------------------
; dataonmap_13_640.ncl
;
; Concepts illustrated:
;   - Plotting contours of 1D data with lat/lon arrays of the same length
;   - Using the special "lat1d" / "lon1d" attributes for plotting
;   - Converting lat/lon arrays from radians to degrees
;   - Drawing raster contours for faster results
;----------------------------------------------------------------------
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
  RAD2DEG  = get_r2d("float")
  f        = addfile("MPAS.nc","r")
  sp       = f->surface_pressure(0,:)
  sp@lat1d = f->latCell * RAD2DEG
  sp@lon1d = f->lonCell * RAD2DEG

  printVarSummary(sp)         ; 163842 points

  wks = gsn_open_wks("png","dataonmap")

  res                 = True              ; Plot mods desired.

  res@gsnMaximize     = True              ; Maximize plot

  res@cnFillOn        = True              ; color plot desired
  res@cnFillMode      = "RasterFill"      ; turn raster on, faster!
  res@cnLinesOn       = False             ; turn off contour lines
  res@cnLineLabelsOn  = False             ; turn off contour labels
  res@cnLevelSpacingF = 2000              ; NCL chose 4000

  res@tiMainString    = "Surface pressure on MPAS grid (" + \
                        dimsizes(sp) + " cells)"

  plot = gsn_csm_contour_map(wks,sp,res)  
end
