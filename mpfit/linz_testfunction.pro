function	linz_testfunction, fit_energy, params

	; The parameters we want to fit are heat0, flare_dur, maybe length.  Get fill to match.
	; For now, params are [heat0, fill].
	
	heat0 = params[0]
	fill  = params[1]
	flare_dur = params[2]

	; defaults
;	heat0 = 0.01          	; amplitude of (nano)flare [erg cm^-3 s^-1]
	length = 4.0e9					; loop half-length
	scale_height = 5.e9			; coronal scale height (or any desired height)
;	flare_dur = 500.				; duration of heating event [seconds]

	solar_dx_arcsec = 100.		; Diameter of solar area of interest.
													; Examples: FOXSI FWHM (5"), NuSTAR pixel (12"), AR size (~60")
	solar_dx_cm  = solar_dx_arcsec*0.725d8			; Instrument resolution, centimeters
	area = solar_dx_cm^2 * scale_height / 2 / length		; "effective" area of emitting plasma
	;;integration = 38.5			; duration of observation


	dem_cm5 = run_ebtel( time, heat0=heat0, t_heat=flare_dur, te=te, dens=dens, logtdem=logtdem, $
											 avg_dem_cm5_cor=avg_dem_cm5_cor )
	dem_cm5 *= fill[0]
	hxr = dem_hxr( logtdem, dem_cm5, area, energy )
;;	instr = 'foxsi2'
	instr = 'nustar'
	count_rate = hxr_counts( energy, hxr, instr=instr, effarea=effarea )
	counts = total( count_rate, 1 );;*integration
	obs = keep_it_real( energy, counts, coarse )
	obs[ where(obs lt 0)] = 0.

	obs = interpol( obs, coarse, fit_energy )
	
	print
	print
	print, 'DIAGNOSTICS: '
	print, '  params: ',  params
	print, '  heat0: ', heat0
	print, '  fill: ', fill
	print, '  flare_dur: ', flare_dur
	print
	print
	
	return, obs
	
end	