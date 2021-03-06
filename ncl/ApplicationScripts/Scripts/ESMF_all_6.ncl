;======================================================================
; ESMF_all_6.ncl
;
; Concepts illustrated:
;   - Interpolating from one grid to another using ESMF software
;   - Interpolating data from a CMIP5 grid to a 1X1 degree rectilinear grid
;======================================================================
; This example is identical to ESMF_regrid_6.ncl, except it does the
; regridding in separate steps.  See ESMF_wgts_6.ncl for a faster 
; example of regridding using an existing weights file.
;======================================================================
; This example uses the ESMF application "ESMF_RegridWeightGen" to 
; generate the weights.
;
; For more information about ESMF:
;
;        http://www.earthsystemmodeling.org/
;
; This script uses built-in functions that are only available in 
; NCL V6.1.0 and later.
;======================================================================
; This script regrids a CMIP5 grid to a 1.0 degree world grid and
; plots sea water potential temperature on the new grid.
;
; It uses SCRIP for both the CMIP5 and 1.0 degree world grid.
;======================================================================
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;
; This file still has to be loaded manually
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

begin
;---Interpolation methods
    methods      = (/"bilinear","patch","conserve"/)

;---Input file
    srcFileName  = "thetao_Omon_MPI-ESM-LR_piControl_r1i1p1_280001-284912.nc"

;---Output (and input) files
    srcGridName  = "CMIP5_SCRIP.nc"
    dstGridName  = "World1deg_SCRIP.nc"
    wgtFile      = "CMIP5_2_World_" + methods + ".nc"

;---Get data and lat/lon grid from CMIP5 Grid
    sfile       = addfile(srcFileName,"r")
    thetao      = sfile->thetao(0,0,:,:)
    cmip5_lat2d = sfile->lat
    cmip5_lon2d = sfile->lon
    latlon_dims = dimsizes(cmip5_lon2d)

;---Set to True if you want to skip any of these steps
    SKIP_CMIP5_SCRIP_GEN = False
    SKIP_WORLD_SCRIP_GEN = False
    SKIP_WGT_GEN         = False
    
;----------------------------------------------------------------------
; Convert CMIP5 to SCRIP file.
;----------------------------------------------------------------------
    if(.not.SKIP_CMIP5_SCRIP_GEN) then
      Opt                = True
      Opt@Mask2D         = where(.not.ismissing(thetao),1,0)
      Opt@GridCornerLat  = sfile->lat_vertices
      Opt@GridCornerLon  = sfile->lon_vertices
      Opt@PrintTimings   = True
      Opt@ForceOverwrite = True
      Opt@Debug          = True

      curvilinear_to_SCRIP(srcGridName,cmip5_lat2d,cmip5_lon2d,Opt)

;---Clean up
      delete(Opt)
    end if

;----------------------------------------------------------------------
; Convert 1 degree world grid to SCRIP file
;----------------------------------------------------------------------
    if(.not.SKIP_WORLD_SCRIP_GEN)
      Opt                = True
      Opt@ForceOverwrite = True
      Opt@LLCorner       = (/-89.75d,   0.00d /)
      Opt@URCorner       = (/ 89.75d, 359.75d /) 
      Opt@Title          = "World Grid 1-degree Resolution"
      Opt@PrintTimings   = True
      Opt@Debug          = True

      latlon_to_SCRIP(dstGridName,"1x1",Opt)

;---Clean up
      delete(Opt)
    end if

;----------------------------------------------------------------------
; Setup for graphics
;----------------------------------------------------------------------
    wks = gsn_open_wks("png","ESMF_all")        ; send graphics to PNG file

;---Resources to share between both plots
    res                     = True              ; Plot modes desired.

    res@gsnDraw             = False             ; Will panel later
    res@gsnFrame            = False             ; Will panel later

    res@gsnMaximize         = True              ; Maximize plot

    res@cnFillOn            = True              ; color plot desired
    res@cnFillPalette       = "rainbow"         ; set color map
    res@cnLinesOn           = False             ; turn off contour lines
    res@cnLineLabelsOn      = False             ; turn off contour labels
    res@cnFillMode          = "RasterFill"      ; turn raster on      
  
    res@cnLevelSelectionMode = "ExplicitLevels"
    res@cnLevels             = ispan(270,300,2)
  
    res@mpFillOn            = False

    res@trGridType         = "TriangularMesh"  ; allow missing coordinates
    res@gsnAddCyclic       = False

    res@pmLabelBarWidthF   = 0.7
    res@lbLabelBarOn       = False   ; Will do this in panel

    res@gsnAddCyclic       = False

;---Resources for paneling
    pres                  = True
    pres@gsnMaximize      = True
    pres@gsnPanelLabelBar = True
    pres@lbLabelFontHeightF = 0.01

;----------------------------------------------------------------------
; Loop across each method and generate interpolation weights for 
; CMIP5 Grid to World Grid    
;----------------------------------------------------------------------
    plot_regrid = new(dimsizes(methods),graphic)

    do i=0,dimsizes(methods)-1
      if(.not.SKIP_WGT_GEN) then
        Opt                      = True
        Opt@ForceOverwrite       = True
        Opt@SrcESMF              = False
        Opt@DstESMF              = False
        Opt@InterpMethod         = methods(i)
        Opt@PrintTimings         = True

        print("Generating interpolation weights from CMIP5 to")
        print("World 1 degree grid using the " + methods(i) + " method.")

        ESMF_regrid_gen_weights(srcGridName, dstGridName, wgtFile(i), Opt)

;---Clean up
        delete(Opt)
      end if

;----------------------------------------------------------------------
; Interpolate data from CMIP5 to World 1-degree grid.
;----------------------------------------------------------------------
      Opt                = True
      Opt@PrintTimings   = True
      Opt@Debug          = True

      thetao_regrid = ESMF_regrid_with_weights(thetao,wgtFile(i),Opt)

      printVarSummary(thetao_regrid)
;----------------------------------------------------------------------
; Plotting section
;----------------------------------------------------------------------

;---Resources for plotting original data
      res@sfXArray = cmip5_lon2d
      res@sfYArray = cmip5_lat2d
      res@tiMainString = "Data on original CMIP5 grid (" + \
                         str_join(tostring(dimsizes(thetao))," x ") + ")"

      plot_orig   = gsn_csm_contour_map(wks,thetao,res)

;---Clean up
      delete(res@sfXArray)
      delete(res@sfYArray)

;---Resources for plotting regridded data
      res@tiMainString = "CMIP5 to 1x1-degree grid (" + \
                         methods(i) + ") (" + \
                         str_join(tostring(dimsizes(thetao_regrid))," x ") + ")"

      plot_regrid(i) = gsn_csm_contour_map(wks,thetao_regrid,res)

;---Panel two plots
      gsn_panel(wks,(/plot_orig,plot_regrid(i)/),(/2,1/),pres)

;---Clean up before next time in loop.
      delete(Opt)
      delete(thetao_regrid)
    end do
end
