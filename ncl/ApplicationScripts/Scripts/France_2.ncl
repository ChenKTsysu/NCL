;----------------------------------------------------------------------
; France_2.ncl
;
; Concepts illustrated:
;   - Reading shapefiles
;   - Plotting data from shapefiles
;   - Using shapefile data to draw various boundaries for France
;   - Using special "gsSegments" resource for faster primitive draws
;----------------------------------------------------------------------
; The purpose of this script is to demonstrate the speed-up of
; attaching shapefile polylines to an existing NCL map, using NCL
; V6.2.0.
;
; This script uses gsn_add_polyline and the "gsSegments" resource.
; It will only work with NCL V6.2.0 and higher.
;----------------------------------------------------------------------
; The "FRA_adm*.shp" shapefiles were downloaded from 
; http://www.gadm.org/country/
;----------------------------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
  dir = "./"

  wks = gsn_open_wks("png","France")  ; send graphics to PNG file

  res              = True    ; Set some plot options

  res@gsnMaximize  = True     ; maximize plot in frame
  res@gsnDraw      = False
  res@gsnFrame     = False

  res@mpMinLatF    = 41
  res@mpMaxLatF    = 51.1
  res@mpMinLonF    = -5.15
  res@mpMaxLonF    = 9.6

  res@mpFillOn     = False             ; Turn off gray-filled land
  res@mpOutlineOn  = False             ; Turn off map outlines

  res@pmTickMarkDisplayMode = "Always" ; nicer tickmarks

;---Set some options for the polylines
  lnres                   = True         
  lnres@gsLineThicknessF  = 2.0          ; default is 1.0
  lnres@gsLineColor       = "NavyBlue"   ; default is black

;---Loop through each shapefile and create a separate plot.
  do i=0,5
    start_time = get_cpu_time()

    shapefile_name = dir + "FRA_adm" + i + ".shp"
    print("---> Drawing " + shapefile_name + "...")
    f = addfile(shapefile_name,"r")

;---Create the map
    res@tiMainString = shapefile_name    ; Main title
    plot = gsn_csm_map(wks,res)

;---Attach the France outlines
    lnres@gsSegments := f->segments(:,0)
    id := gsn_add_polyline(wks, plot, f->x, f->y, lnres)

;---Draw everything
    draw(plot)
    frame(wks)

    end_time = get_cpu_time()
    print("     " + (end_time-start_time) + " CPU seconds")
    print("")
  end do
end
