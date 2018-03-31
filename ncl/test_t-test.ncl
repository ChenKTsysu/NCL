load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
begin

    
    f1=addfile("/mnt/f/data/ERA-interim/monthly/precip.mon.mean.nc", "r")
    fed=addfile("/mnt/f/data/ERA-interim/monthly/precip.DJF.mean.nc", "r")
    fu1=addfile("/mnt/f/data/ERA-interim/monthly/uwnd.mon.mean.nc", "r")
    fv1=addfile("/mnt/f/data/ERA-interim/monthly/vwnd.mon.mean.nc", "r")
    fh=addfile("/mnt/f/data/NCEP/hgt.sfc.nc", "r")

    pe=f1->r(48:383,:,:)
    pe_DJF=fed->r(:,:,:)
    ue=short2flt(fu1->u(48:383,{850},:,:))
    ve=short2flt(fv1->v(48:383,{850},:,:))
    hgt=short2flt(fh->hgt(0,:,:))

    f2=addfile("/mnt/f/data/CFSV2_output/pre/pre.em24.out.nc", "r")
    fcd=addfile("/mnt/f/data/CFSV2_output/pre/pre.em24.DJF.out.nc", "r")
    fu2=addfile("/mnt/f/data/CFSV2_output/u850/u850.em24.out.nc", "r")
    fv2=addfile("/mnt/f/data/CFSV2_output/v850/v850.em24.out.nc", "r")

wks=gsn_open_wks("x11", "/mnt/f/pdf/850_prc_differ")
;gsn_define_colormap(wks, "MPL_gist_yarg")
;plot=new(4,graphic)
print("--------------------------10%-------------------------")
    do i=0,9,30
        p=f2->pre(:,i,:,:)
        u2=fu2->ugrd(:,i,:,:)
        v2=fv2->vgrd(:,i,:,:)
        p_DJF=fcd->pre(:,i,:,:)
        pc=g2fsh_Wrap(p, (/121,240/));将从高斯网格标量数量插值到固定网格（保留元数据）
        pc_DJF=g2fsh_Wrap(p_DJF, (/121,240/))

        pe_JJA=month_to_season(pe, "JJA")
        pc_JJA=month_to_season(pc, "JJA")
        ue_JJA=month_to_season(ue, "JJA")
        ve_JJA=month_to_season(ve, "JJA")
        uc_JJA=month_to_season(u2, "JJA")
        vc_JJA=month_to_season(v2, "JJA")

        pe_JJA_avg=dim_avg_n_Wrap(pe_JJA, 0)
        pe_DJF_avg=dim_avg_n_Wrap(pe_DJF, 0)
        pc_JJA_avg=86400*dim_avg_n_Wrap(pc_JJA, 0)
        pc_DJF_avg=86400*dim_avg_n_Wrap(pc_DJF, 0)

        pe_JJA_var=dim_variance_n_Wrap(pe_JJA, 0)
        pe_DJF_var=dim_variance_n_Wrap(pe_DJF, 0)
        pc_JJA_var=dim_variance_n_Wrap(86400*pc_JJA, 0)
        pc_DJF_var=dim_variance_n_Wrap(86400*pc_DJF, 0)

        copy_VarCoords(pe_JJA_var, pc_JJA_var)
        copy_VarCoords(pe_JJA_var, pc_DJF_var)

        copy_VarCoords(pe_JJA_avg, pc_JJA_avg)
        copy_VarCoords(pe_JJA_avg, pc_DJF_avg)
print("---------------------40%---------------------")
        p_dif_JJA=dim_avg_n_Wrap(pe_JJA, 0)-86400*dim_avg_n_Wrap(pc_JJA, 0)
        p_dif_DJF=dim_avg_n_Wrap(pe_DJF, 0)-86400*dim_avg_n_Wrap(pe_JJA, 0)

        pt=dim_avg_n_Wrap(pe_JJA, 0)
        copy_VarCoords(pt, p_dif_JJA)
        copy_VarCoords(pt, p_dif_DJF)

        dimce=dimsizes(pe_JJA)
        ntim=dimce(0)
        nlat=dimce(1)
        mlon=dimce(2)

        pe_tmp_JJA=pe_JJA(lat|:,lon|:,time|:)
        pe_tmp_DJF=pe_DJF(lat|:,lon|:,time|:)
        pc_tmp_JJA=pc_JJA(lat|:,lon|:,time|:)
        pc_tmp_DJF=pc_DJF(lat|:,lon|:,time|:)

        sigr=0.05

        pe_JJA_eqv=equiv_sample_size(pe_tmp_JJA, sigr, 0)
        pe_DJF_eqv=equiv_sample_size(pe_tmp_DJF, sigr, 0)
        pc_JJA_eqv=equiv_sample_size(pc_tmp_JJA, sigr, 0)
        pc_DJF_eqv=equiv_sample_size(pc_tmp_DJF, sigr, 0)

        pe_JJA_N=wgt_areaave(pe_JJA_eqv, 1., 1., 0)
        pe_DJF_N=wgt_areaave(pe_DJF_eqv, 1., 1., 0)
        pc_JJA_N=wgt_areaave(pc_JJA_eqv, 1., 1., 0)
        pc_DJF_N=wgt_areaave(pc_DJF_eqv, 1., 1., 0)

        iflag=False
print("----------------------80%----------------------------")
        prob_JJA=ttest(pe_JJA_avg, pe_JJA_var, pe_JJA_N, pc_JJA_avg, pc_JJA_var, pc_JJA_N, iflag, False)
        prob_DJF=ttest(pe_DJF_avg, pe_DJF_var, pe_DJF_N, pc_DJF_avg, pc_DJF_var, pc_DJF_N, iflag, False)
        
copy_VarCoords(pe_JJA_avg, prob_JJA)
copy_VarCoords(pe_JJA_avg, prob_DJF)

        printVarSummary(prob_JJA)
        printVarSummary(prob_DJF)
        ;print((prob_JJA))
        print(min(prob_JJA))
        ;print((prob_DJF))
        print(min(prob_DJF))
    end do

    res=True
    res@cnFillOn=True
    res@cnLinesOn=True
    res@mpMaxLatF=60
    res@mpMinLatF=0
    res@mpMaxLonF=140
    res@mpMinLonF=40
    res@cnLevels=(/0.95/)

plot=gsn_csm_contour_map(wks, prob_JJA, res)
plot2=gsn_csm_contour_map(wks, prob_DJF, res)

end
        


