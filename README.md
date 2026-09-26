# blankvar

A small Stata command that blanks out variables without making you think about
their storage type. String variables become `""`, numeric variables become `.`,
and one command does the lot.

Cleaning survey data usually means voiding a record across a whole block of
columns at once — a duplicate submission, a test interview, a respondent who
withdrew. Done by hand that is a run of `replace` statements where you have to
keep track of which columns take `""` and which take `.`:

```stata
replace name       = "" if KEY == "uuid:abc123"
replace comments   = "" if KEY == "uuid:abc123"
replace age        = .  if KEY == "uuid:abc123"
replace income     = .  if KEY == "uuid:abc123"
replace hh_size    = .  if KEY == "uuid:abc123"
```

With `blankvar` that becomes one line:

```stata
blankvar name comments age income hh_size if KEY == "uuid:abc123"
```

## Syntax

```
blankvar varlist [if] [in]
```

No options. If you leave off `if`/`in`, the whole column is blanked.

## Examples

```stata
* void one bad interview across several columns
blankvar name age income comments if KEY == "uuid:abc123"

* blank a block of questions for everyone screened out
blankvar q10-q25 if eligible == 0

* wildcards work — it is an ordinary varlist
blankvar income_* if refused == 1

* clear whole columns before sharing the data
blankvar enumerator_phone respondent_phone

* restrict by observation number
blankvar q1 q2 q3 in 1/50
```

## Why not just use `replace`?

Three reasons, beyond the typing.

**It picks the blank for you.** `replace age = ""` is an error and
`replace name = .` is an error; `blankvar` checks each variable's type and
does the right thing. That matters most on wide SurveyCTO/ODK exports where
you rarely remember offhand whether `q17_other` came back as a string.

**The condition is evaluated before anything changes.** This is safe:

```stata
blankvar KEY name age if KEY == "uuid:abc123"
```

`KEY` is blanked along with the rest, but it does not stop matching partway
through the list. Written out by hand in the wrong order, the same thing
silently blanks only the first variable.

**It tells you what it did.** The command reports how many variables and
observations it touched and how many previously non-missing values were
cleared, which is worth having in a cleaning log:

```
blankvar: blanked 5 variable(s) (2 string, 3 numeric) in 1 observation(s)
          cleared 4 non-missing value(s)
```

The same counts are stored in `r()` — `r(N_obs)`, `r(N_vars)`, `r(N_str)`,
`r(N_num)`, `r(N_changed)` — if you want to assert on them in a do-file.

## Installation

### Straight from GitHub

```stata
net install blankvar, from("https://raw.githubusercontent.com/RanaRedoan/blankvar/main/") replace
```

If your default branch is `master` rather than `main`, change it in the URL.

### With the `github` command

```stata
net install github, from("https://haghish.github.io/github/")
github install RanaRedoan/blankvar
```

### By hand

Download `blankvar.ado` and `blankvar.sthlp` and drop them in your PERSONAL
ado directory — run `adopath` in Stata if you are not sure where that is.

### Check it worked

```stata
which blankvar
help blankvar
```

## Notes and caveats

- **There is no undo.** `blankvar` edits the data in memory like any other
  `replace`. `preserve` first, or check the condition with `count`, if you are
  not certain of it.
- **Storage types are unchanged.** A blanked `byte` stays a `byte`, a blanked
  `str20` stays a `str20`. Run `compress` afterwards to reclaim the space.
- **Labels and notes survive.** Only the data values change.
- Requires Stata 14 or later.

## Repository layout

```
blankvar.ado          the command
blankvar.sthlp        help file  (help blankvar)
blankvar.pkg          package manifest for net install
stata.toc             package index for net install
tests/test_blankvar.do   assertions — run it after any change
LICENSE               MIT
```

## Tests

Open Stata, `cd` to the repo, and run:

```stata
do tests/test_blankvar.do
```

It uses `sysuse auto` so it needs no data of your own. Every check is an
`assert`, so silence means everything passed.

## License

MIT — see [LICENSE](LICENSE).
