*! blankvar 1.0.0  26sep2026
*! Blank out variables: string -> "", numeric -> . (system missing)
*! Md. Redoan Hossain Bhuiyan

program define blankvar, rclass
    version 14.0

    syntax varlist [if] [in]

    * ---------------------------------------------------------------------
    * Mark the observations to blank.
    *
    * "novarlist" matters here. Plain -marksample touse- would ALSO exclude
    * observations where any variable in varlist is already missing, which
    * is the opposite of what this command is for. With novarlist the marker
    * comes from the user's if/in qualifier only.
    *
    * Because the marker is built BEFORE anything is replaced, a condition
    * like  -blankvar key name if key == "abc"-  is safe: blanking key does
    * not change which rows get hit further down the varlist.
    * ---------------------------------------------------------------------
    marksample touse, novarlist

    quietly count if `touse'
    local nobs = r(N)

    if `nobs' == 0 {
        display as text "blankvar: no observations selected; nothing changed"
        return scalar N_obs     = 0
        return scalar N_vars    = 0
        return scalar N_str     = 0
        return scalar N_num     = 0
        return scalar N_changed = 0
        exit
    }

    local nvars : word count `varlist'
    local nstr    = 0
    local nnum    = 0
    local nchange = 0

    foreach var of local varlist {

        * missing() is type-aware: "" for string variables, . for numeric
        quietly count if `touse' & !missing(`var')
        local nchange = `nchange' + r(N)

        capture confirm string variable `var'
        if _rc == 0 {
            quietly replace `var' = "" if `touse'
            local ++nstr
        }
        else {
            quietly replace `var' = .  if `touse'
            local ++nnum
        }
    }

    local sobs    = trim(string(`nobs',    "%15.0fc"))
    local schange = trim(string(`nchange', "%15.0fc"))

    local sall ""
    if `"`if'`in'"' == "" local sall " (all observations)"

    display as text "blankvar: blanked " as result "`nvars'" as text          ///
        " variable(s) (`nstr' string, `nnum' numeric) in "                    ///
        as result "`sobs'" as text " observation(s)`sall'"
    display as text "          cleared " as result "`schange'" as text        ///
        " non-missing value(s)"

    return scalar N_obs     = `nobs'
    return scalar N_vars    = `nvars'
    return scalar N_str     = `nstr'
    return scalar N_num     = `nnum'
    return scalar N_changed = `nchange'
end
