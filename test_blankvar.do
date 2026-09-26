*! test_blankvar.do  -- assertions for blankvar 1.0.0
*!
*! Run from the repository root:
*!     do tests/test_blankvar.do
*!
*! Uses sysuse auto, so no data of your own is needed. Every check is an
*! assert: silence means it passed.

clear all
set more off

* Test the copy in this repo, not whatever is installed in PERSONAL
capture adopath ++ "`c(pwd)'"

which blankvar


* ---------------------------------------------------------------------
di as txt _n "1. string -> \"\", numeric -> ., for a subset of rows"
* ---------------------------------------------------------------------
sysuse auto, clear

blankvar make price mpg if foreign == 1

assert make  == ""           if foreign == 1
assert missing(price)        if foreign == 1
assert missing(mpg)          if foreign == 1

assert make  != ""           if foreign == 0
assert !missing(price)       if foreign == 0
assert !missing(mpg)         if foreign == 0

* variables not listed are untouched
assert !missing(weight)


* ---------------------------------------------------------------------
di as txt _n "2. the if-condition may reference a variable being blanked"
* ---------------------------------------------------------------------
sysuse auto, clear
gen str12 KEY = "uuid:A"
replace KEY = "uuid:B" if foreign == 1

quietly count if KEY == "uuid:B"
local nB = r(N)

blankvar KEY make price if KEY == "uuid:B"

* every targeted row was hit, not just the first variable in the list
quietly count if KEY == ""
assert r(N) == `nB'
assert make == ""     if foreign == 1
assert missing(price) if foreign == 1

* and nothing outside the condition moved
assert KEY  == "uuid:A" if foreign == 0
assert make != ""       if foreign == 0


* ---------------------------------------------------------------------
di as txt _n "3. stored results"
* ---------------------------------------------------------------------
sysuse auto, clear

quietly count if !missing(rep78)
local nonmiss = r(N)

blankvar rep78

assert r(N_obs)     == _N
assert r(N_vars)    == 1
assert r(N_str)     == 0
assert r(N_num)     == 1
assert r(N_changed) == `nonmiss'
assert missing(rep78)


* ---------------------------------------------------------------------
di as txt _n "4. mixed varlist, counts split by type"
* ---------------------------------------------------------------------
sysuse auto, clear
gen str5 tag = "x"

blankvar make tag price mpg weight if _n <= 10

assert r(N_vars) == 5
assert r(N_str)  == 2
assert r(N_num)  == 3
assert r(N_obs)  == 10


* ---------------------------------------------------------------------
di as txt _n "5. no if/in blanks the whole column"
* ---------------------------------------------------------------------
sysuse auto, clear

blankvar make turn

assert make == ""
assert missing(turn)
assert r(N_obs) == _N


* ---------------------------------------------------------------------
di as txt _n "6. the in qualifier"
* ---------------------------------------------------------------------
sysuse auto, clear

blankvar price in 1/5

assert missing(price)  in 1/5
assert !missing(price) in 6/l
assert r(N_obs) == 5


* ---------------------------------------------------------------------
di as txt _n "7. if and in together"
* ---------------------------------------------------------------------
sysuse auto, clear

quietly count if foreign == 1 in 1/40
local expected = r(N)

blankvar mpg if foreign == 1 in 1/40

assert r(N_obs) == `expected'
assert !missing(mpg) in 41/l


* ---------------------------------------------------------------------
di as txt _n "8. a condition matching nothing changes nothing"
* ---------------------------------------------------------------------
sysuse auto, clear

blankvar price mpg make if price > 1000000 & !missing(price)

assert r(N_obs)     == 0
assert r(N_changed) == 0
assert !missing(price)
assert !missing(mpg)
assert make != ""


* ---------------------------------------------------------------------
di as txt _n "9. storage type, variable label and value label survive"
* ---------------------------------------------------------------------
sysuse auto, clear

local type0  : type foreign
local vlab0  : variable label foreign
local vallb0 : value label foreign

blankvar foreign if rep78 == 1

local type1  : type foreign
local vlab1  : variable label foreign
local vallb1 : value label foreign

assert "`type0'"  == "`type1'"
assert "`vlab0'"  == "`vlab1'"
assert "`vallb0'" == "`vallb1'"
assert "`type1'"  == "byte"


* ---------------------------------------------------------------------
di as txt _n "10. varlist shorthand: ranges and wildcards"
* ---------------------------------------------------------------------
sysuse auto, clear

blankvar mpg-trunk if foreign == 1
assert missing(mpg) & missing(rep78) & missing(headroom) & missing(trunk) ///
    if foreign == 1

sysuse auto, clear
gen inc_a = 1
gen inc_b = 2
gen str3 inc_c = "yes"

blankvar inc_* if _n == 1

assert missing(inc_a) & missing(inc_b) & inc_c == "" in 1
assert !missing(inc_a) in 2
assert r(N_vars) == 3
assert r(N_str)  == 1
assert r(N_num)  == 2


* ---------------------------------------------------------------------
di as txt _n "11. already-blank values are not counted as changed"
* ---------------------------------------------------------------------
sysuse auto, clear
replace price = . in 1/3

blankvar price in 1/10

assert r(N_obs)     == 10
assert r(N_changed) == 7


* ---------------------------------------------------------------------
di as txt _n "12. strL is handled like any other string"
* ---------------------------------------------------------------------
sysuse auto, clear
gen strL notes = "some long free-text answer " + make

blankvar notes if foreign == 1

assert notes == "" if foreign == 1
assert notes != "" if foreign == 0


di as result _n "{hline 60}"
di as result "blankvar: all tests passed"
di as result "{hline 60}"
