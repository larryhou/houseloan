forvalues yr = 40/80 {
	clear
	set obs 1200
	generate n = _n
	capture scalar drop r
	scalar r = `yr' / 1000 / 12

	generate f1 = ((1+r)*((1+r)^n-1)/r - r*(1+r)^n/((1+r)^n-1) * ((1+r)*((1+r)^n-1)/r^2-n/r)) * r
	generate f2 = r*(n+1)/2
	generate p = (f1 - f2) / f2

	label variable f1 "等额本息利息"
	label variable f2 "等额本金利息"
	format f1 %4.2f
	format f2 %4.2f
	format  p %5.3f
	
	local yrstr=strofreal(r*12*100, "%3.1f")

	#delimit ;
	line f1 f2 n in 1/360, xsize(16) ysize(9)
	xtitle("")
	xlabel(,grid)
	ylabel(,grid format(%4.2f))
	xmtick(##10, grid glw(*.5))
	ymtick(##5 , grid glw(*.5))
	legend(ring(0) pos(5) region(c(none)) symx(*.5))
	lc(red black) lw(*1.5)
	title("年化利率(`yrstr'%)", ring(0))
	;
	#delimit cr
	graph export "loan_yr`yr'.pdf", replace
}

forvalues yn = 1/30 {
	clear
	set obs 1000
	generate yr = _n/100/100
	generate pr = yr * 100
	generate r = yr / 12
	capture scalar drop n
	scalar n = `yn'*12
	generate f1 = ((1+r)*((1+r)^n-1)/r - r*(1+r)^n/((1+r)^n-1) * ((1+r)*((1+r)^n-1)/r^2-n/r)) * r
	generate f2 = r*(n+1)/2
	label variable f1 "等额本息利息"
	label variable f2 "等额本金利息"
	format f1 %5.3f
	format f2 %5.3f
	#delimit ;
	line f1 f2 pr, xsize(16) ysize(9)
	xmtick(##10, grid glw(*.5))
	ymtick(##5 , grid glw(*.5)) ylabel(,format(%4.2f))
	legend(ring(0) pos(5) region(c(none)) symx(*.5)) xlabel(,grid)
	lc(red black) lw(*1.5)
	title("贷款周期(`yn'年)", ring(0))
	xtitle("")
	;
	#delimit cr
	graph export "loan_yn`yn'.pdf", replace
}

forvalues s = 1/10 {
	clear
	set obs 1000
	generate r = 0.1/_n
	generate pr = r * 100
	generate nr = 100 * r * ln(1+`s'/10)/ln(1+r)
	#delimit ;
	line nr pr, xsize(16) ysize(9)
	xlabel(,format(%4.1f) grid)
	ylabel(,format(%4.1f) grid)
	ymtick(##5 , grid glw(*.5))
	xmtick(##10, grid glw(*.5))
	xtitle("收益率/pct")
	ytitle("倍积(periods×rate/pct)")
	title("贷款周期(`yn'年)", ring(0))
	title("收益速算图(`=`s'*10'%)", ring(0))
	lc(black) lw(*1.5)
	;
	#delimit cr
	graph export rapidcal_p`=`s'*10'.pdf, replace
}







