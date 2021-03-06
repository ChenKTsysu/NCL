
;   Example script to produce plots for a WRF real-data run,
;   with the ARW coordinate dynamics option.
;   Plot data on a cross section
;   This script will plot data from a a given point A to point B
;   Vertical coordinate is height

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$VAPOR_HOME/share/vapor-1.5.0/examples/NCL/wrf2geotiff.ncl"

begin
;
; The WRF ARW input files.  

wrffiles = systemfunc("ls wrfout_d02_2008-09-28*") + ".nc"   ; the ".nc" is required
numFiles = dimsizes(wrffiles)
inpFiles = addfiles(wrffiles,"r")

; We generate plots, but what kind do we prefer?
;  type = "x11"
; type = "pdf"
 type = "ps"
; type = "ncgm"

  wks = gsn_open_wks(type,"plt_CrossSection2")
  wrf2gtiff = wrf2geotiff_open(wks)
;  Since this is a vertical plot, turn off georeferencing:
  wrf2geotiff_disableGeoTags(wrf2gtiff)


; Set some basic resources
  res = True
  res@MainTitle = "REAL-TIME WRF"

  pltres = True 

  ; Control the frame advance manually:
  pltres@gsnFrame = False


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  FirstTime = True
  do ifile = 0, numFiles-1
  a = inpFiles[ifile]
  times  = wrf_user_list_times(a)  ; get times in the file
  ntimes = dimsizes(times)         ; number of times in the file

  mdims = getfilevardimsizes(a,"P") ; get some dimension sizes for the file
  nd = dimsizes(mdims)

;---------------------------------------------------------------

  do it = 0,ntimes-1             ; TIME LOOP

    print("Working on time: " + times(it) )
    res@TimeLabel = times(it)   ; Set Valid time to use on plots

    tc  = wrf_user_getvar(a,"tc",it)     ; T in C
    rh = wrf_user_getvar(a,"rh",it)      ; relative humidity
    z   = wrf_user_getvar(a, "z",it)     ; grid point height

    if ( FirstTime ) then                ; get height info for labels
      zmin = 0.
      zmax = max(z)/1000.
      nz   = floattoint(zmax/2 + 1)
      FirstTime = False
    end if

;---------------------------------------------------------------

ip = 1   	;  Just do the one (constant y coord) plot
        opts = True            ; setting start and end times
        plane = new(4,float)

        if(ip .eq. 1) then
          plane = (/  0,84,  200,84  /) ; start x;y & end x;y point
;  The jangmi data is on a grid from 0 to 200
        end if
        if(ip .eq. 2) then
          plane = (/  130,1, 130,162  /) ; start x;y & end x;y point
        end if
        if(ip .eq. 3) then
          plane = (/   49,1, 210,162  /) ; start x;y & end x;y point
        end if


        rh_plane = wrf_user_intrp3d(rh,z,"v",plane,0.,opts)
        tc_plane = wrf_user_intrp3d(tc,z,"v",plane,0.,opts)

        dim = dimsizes(rh_plane)                      ; Find the data span - for use in labels
        zspan = dim(0)


      ; Options for XY Plots
        opts_xy                         = res
        opts_xy@tiYAxisString           = "Height (km)"
        opts_xy@AspectRatio             = 0.75
        opts_xy@cnMissingValPerimOn     = True
        opts_xy@cnMissingValFillColor   = 0
        opts_xy@cnMissingValFillPattern = 11
        opts_xy@tmYLMode                = "Explicit"
        opts_xy@tmYLValues              = fspan(0,zspan,nz)                    ; Create tick marks
        opts_xy@tmYLLabels              = sprintf("%.1f",fspan(zmin,zmax,nz))  ; Create labels
        opts_xy@tiXAxisFontHeightF      = 0.020
        opts_xy@tiYAxisFontHeightF      = 0.020
        opts_xy@tmXBMajorLengthF        = 0.02
        opts_xy@tmYLMajorLengthF        = 0.02
        opts_xy@tmYLLabelFontHeightF    = 0.015
        opts_xy@PlotOrientation         = tc_plane@Orientation


      ; Plotting options for RH
        opts_rh = opts_xy
        opts_rh@pmLabelBarOrthogonalPosF = -0.07
        opts_rh@ContourParameters       = (/ 10., 90., 10. /)
        opts_rh@cnFillOn                = True
        opts_rh@cnFillColors            = (/"White","White","White", \
                                            "White","Chartreuse","Green", \
                                            "Green3","Green4", \
                                            "ForestGreen","PaleGreen4"/)

      ; Plotting options for Temperature
        opts_tc = opts_xy
        opts_tc@cnInfoLabelOrthogonalPosF = 0.00
        opts_tc@ContourParameters  = (/ 5. /)


      ; Get the contour info for the rh and temp
        contour_tc = wrf_contour(a,wks,tc_plane,opts_tc)
        contour_rh = wrf_contour(a,wks,rh_plane,opts_rh)

      ; MAKE PLOTS         
        plot = wrf_overlays(a,wks,(/contour_rh,contour_tc/),pltres)
        
      ; save the date for the geotiff, and end the frame:
        wrf2geotiff_write(wrf2gtiff, a, times(it), wks, plot, True)
	frame(wks)


      ; Delete options and fields, so we don't have carry over
        delete(opts_tc)
        delete(opts_rh)
        delete(tc_plane)
        delete(rh_plane)

;    end do  ; make next cross section (loop over ip was removed) 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  end do        ; END OF TIME LOOP
 
  end do	; END OF FILE LOOP

  wrf2geotiff_close(wrf2gtiff,wks)

end
