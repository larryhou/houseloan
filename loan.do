capture scalar drop rate
scalar rate=3.3

clear
set obs 360
gen n = _n-1
gen s = .

disp rate

// 0: 等额本息
// 1: 等额本金

quietly forvalues x = -2(1)2 {
	local rr = rate + 0.5 * `x'
	local r = `rr' / 100 / 12
	forvalues y = 10(5)30 {
		local N = `y' * 12
		local c = `r'*(1+`r')^`N'/((1+`r')^`N'-1)
		
		replace s = ((1+`r')^n[_n] - 1)/`r' if _n <= `N' + 1
		
		local t = strofreal(`y', "%2.0f") + "_" + strofreal(`rr'*10, "%02.0f")
		
		// 剩余本金
		generate P0_`t'= (1+`r')^n[_n] - `c' * s[_n]
		replace P0_`t' = . if _n > `N'
		label variable P0_`t' "本金(0)`t'"
		
		generate P1_`t' = (`N'-n[_n])/`N'
		replace P1_`t' = . if _n > `N'
		label variable P1_`t' "本金(1)`t'"
		
		// 月供
		generate R0_`t' = `c'
		replace R0_`t' = . if _n > `N' + 1
		label variable R0_`t' "月付(0)`t'"
		
		generate R1_`t' = P1_`t'[_n-1] * `r' + 1/`N'
		replace R1_`t' = . if _n > `N' + 1
		label variable R1_`t' "月付(1)`t'"
		
		generate T`t' = R1_`t'/R0_`t'
		label variable T`t' "月付对比(`t')"
		
		// 累计利息
		generate I0_`t'= (1-(1+`r')^n[_n]+n[_n]*`r'*(1+`r')^`N')/((1+`r')^`N'-1)
		replace I0_`t' = . if _n > `N' + 1
		label variable I0_`t' "利息(0)`t'"
		
		// 累计利息
		generate I1_`t' = n[_n]*`r'*(2*`N'-n[_n]+1)/(2*`N')
		replace I1_`t' = . if _n > `N' + 1
		label variable I1_`t' "利息(1)`t'"
	}
}

set scheme morden

forvalues x = -2(1)2 {
	local r = rate + 0.5 * `x'
	local t = strofreal(`r'*10, "%2.0f")
	line P0*_`t' P1*_`t' n, lw(*.5 ...)            ///
		xlabel(0(60)360) xmtick(##5,grid glw(*.5)) ///
		ylabel(0(0.1)1.) ymtick(##5,grid glw(*.5)) ///
		title("(`r')剩余本金对比", ring(0)) xtitle("")
	graph export principal_`t'.pdf, replace
		
	line I0*_`t' I1*_`t' n, lw(*.5 ...)             ///
		xlabel(0(60)360) xmtick(##5,grid glw(*.5))  ///
		ylabel(0(0.1).7) ymtick(##5,grid glw(*.5))  ///
		title("(`r')贷款年限对利息的影响", ring(0)) xtitle("")
	graph export interest_`t'.pdf, replace
	
	line T*_`t' n, lw(*.5 ...)                   ///
	xlabel(0(60)360) xmtick(##6,grid glw(*.5))   ///
	ymtick(##5,grid glw(*.5))  ///
	title("(`r')等本息/等本金月付(首月)比率", ring(0)) xtitle("")
	graph export diff_`t'.pdf, replace
}


clear
set obs 360
gen n = _n

quietly forvalues x = -2(1)2 {
	local rr = rate + `x' * 0.5
	local r = `rr' / 100 / 12
	local t = strofreal(`rr'*10, "%2.0f")
	generate p0_`t' = `r'*(1+`r')^n/((1+`r')^n-1)
	label variable p0_`t' "月付(0)`t'"
	generate p1_`t' = `r' + 1/n
	label variable p1_`t' "月付(1)`t'"
}

line p0_* n if _n > 120, lw(*.5 ...) ///
	ylabel(0.004(0.001)0.01) ymtick(##5,grid glw(*.5))     ///
	xlabel(120(60)360) xmtick(##5, grid glw(*.5)) ///
	title("(等本息)还款期数对月付的影响", ring(0)) xtitle("")
graph export payment_`=rate'_0.pdf, replace as(pdf)
	
line p1_* n if _n > 120, lw(*.5 ...) ///
	ylabel(0.005(0.001)0.012) ymtick(##5,grid glw(*.5))     ///
	xlabel(120(60)360) xmtick(##5, grid glw(*.5)) ///
	title("(等本金)(首月)还款期数对月付的影响", ring(0)) xtitle("")
graph export payment_`=rate'_1.pdf, replace as(pdf)

