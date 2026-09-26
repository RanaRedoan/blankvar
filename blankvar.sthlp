{smcl}
{* *! version 1.0.0  26sep2026}{...}
{vieweralsosee "[D] replace" "help replace"}{...}
{vieweralsosee "[D] generate" "help generate"}{...}
{vieweralsosee "[U] 12.2.1 Missing values" "help missing"}{...}
{viewerjumpto "Syntax" "blankvar##syntax"}{...}
{viewerjumpto "Description" "blankvar##description"}{...}
{viewerjumpto "Remarks" "blankvar##remarks"}{...}
{viewerjumpto "Examples" "blankvar##examples"}{...}
{viewerjumpto "Stored results" "blankvar##results"}{...}
{viewerjumpto "Author" "blankvar##author"}{...}
{hline}
help for {hi:blankvar}{right:version 1.0.0}
{hline}

{title:Title}

{phang}
{bf:blankvar} {hline 2} Blank out variables, whatever their storage type


{marker syntax}{...}
{title:Syntax}

{p 8 16 2}
{cmd:blankvar} {varlist} {ifin}


{marker description}{...}
{title:Description}

{pstd}
{cmd:blankvar} clears the values of the variables in {varlist} for the
observations selected by the optional {cmd:if}/{cmd:in} qualifier. It picks
the right kind of blank for each variable by itself:

{phang2}{space 2}o{space 2}{it:string} variables (str#, strL) are set to {cmd:""}{p_end}
{phang2}{space 2}o{space 2}{it:numeric} variables (byte, int, long, float, double) are set to {cmd:.}{p_end}

{pstd}
That is the whole job. It replaces the usual routine of writing one
{helpb replace} per variable and remembering which ones need {cmd:""} and
which need {cmd:.} {hline 2} a chore that comes up constantly when cleaning
survey data, where a single bad interview has to be voided across a dozen
columns of mixed type.

{pstd}
If no {cmd:if}/{cmd:in} is given, the whole column is blanked.


{marker remarks}{...}
{title:Remarks}

{pstd}
{bf:The condition is evaluated first.} The observations to blank are marked
before anything is replaced, so it is safe for the {cmd:if} condition to
reference a variable that is itself in {varlist}:

{p 8 16 2}{cmd:. blankvar KEY name age if KEY == "uuid:abc123"}{p_end}

{pstd}
Here {cmd:KEY} is blanked along with the rest; it does not silently stop
matching partway through the list, which is what happens if you write the
{helpb replace} statements out by hand in the wrong order.

{pstd}
{bf:Storage types are unchanged.} Blanking a {cmd:byte} leaves it a
{cmd:byte}, and blanking a {cmd:str20} leaves it a {cmd:str20}. Run
{helpb compress} afterwards if you want the space back.

{pstd}
{bf:Value labels, variable labels and notes are untouched.} Only the data
values change.

{pstd}
{bf:There is no undo.} {cmd:blankvar} edits the data in memory like any
other {helpb replace}. Use {helpb preserve} first, or check the condition
with {helpb count} or {helpb list}, if you are not sure of it.


{marker examples}{...}
{title:Examples}

{pstd}Void one bad interview across several columns{p_end}
{p 8 16 2}{cmd:. blankvar name age income comments if KEY == "uuid:abc123"}{p_end}

{pstd}Blank a block of variables for everyone who was screened out{p_end}
{p 8 16 2}{cmd:. blankvar q10-q25 if eligible == 0}{p_end}

{pstd}Wildcards work, since this is an ordinary {varlist}{p_end}
{p 8 16 2}{cmd:. blankvar income_* if refused == 1}{p_end}

{pstd}Clear whole columns{p_end}
{p 8 16 2}{cmd:. blankvar enumerator_phone respondent_phone}{p_end}

{pstd}Restrict by observation number as well{p_end}
{p 8 16 2}{cmd:. blankvar q1 q2 q3 in 1/50}{p_end}


{marker results}{...}
{title:Stored results}

{pstd}{cmd:blankvar} is {cmd:rclass} and stores the following in {cmd:r()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:r(N_obs)}}observations selected by {cmd:if}/{cmd:in}{p_end}
{synopt:{cmd:r(N_vars)}}variables blanked{p_end}
{synopt:{cmd:r(N_str)}}of those, string variables{p_end}
{synopt:{cmd:r(N_num)}}of those, numeric variables{p_end}
{synopt:{cmd:r(N_changed)}}values that were non-missing before and are blank now{p_end}
{p2colreset}{...}


{marker author}{...}
{title:Author}

{pstd}
Redoan Hossain{break}
ARCED Foundation


{title:Also see}

{psee}
Manual:  {bf:[D] replace}, {bf:[D] generate}

{psee}
Online:  {helpb replace}, {helpb recode}, {helpb mvencode}, {helpb compress}
{p_end}
