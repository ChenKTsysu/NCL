;*************************************************
; axes_1.ncl           
;************************************************
; Concepts illustrated:
;   - Generating dummy data using "generate_2d_array"
;   - Linearizing the Y axis
;   - Drawing filled contours
;   - Keeping labelbar labels from overlapping
;   - Using the new color model
;************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
;
; Generate some dummy data.
;
  level = (/1000, 850, 700, 500, 400, 300, 250, 200, 150, 100/)
  lat   = fspan(-90,90,20)

  nlat  = dimsizes(lat)
  nlev  = dimsizes(level)
  data     = generate_2d_array(10, 12, -20., 17., 0, (/ nlev,nlat/))

  data!0   = "lev"     ; Name the dimensions and
  data!1   = "lat"     ; attach coordinate arrays
  data&lev = level     ; This coordinate array is irregularly-spaced
  data&lat = lat

  wks = gsn_open_wks("png","axes")      ; send graphics to PNG file

; Set up resources.
  res                     = True
  res@gsnMaximize         = True        ; Maximize plot in frame

  res@cnFillOn            = True        ; Turn on contour fill
  res@cnFillPalette       = "rainbow"   ; set color map
  res@cnLinesOn           = False       ; Turn off contour lines

  res@tiYAxisString       = "Irregularly-spaced values"
  plot = gsn_csm_contour(wks,data,res)  ; Create filled contours

  res@tiYAxisString       = "Y axis linearized"
  res@gsnYAxisIrregular2Linear = True
  plot = gsn_csm_contour(wks,data,res)  ; Create filled contours
end
