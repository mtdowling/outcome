# CHANGELOG

## 0.2.2 - 2017-01-19

* Fixed `outcome.pcall`.

## 0.2.1 - 2017-01-15

* `Option:ifSome`, `Option:ifNone`, `Result:ifOk`, and `Result:ifErr` all now
  return `self`.

## 0.2.0 - 2017-01-15

* Options and Results are now created through `outcome.some`, `outcome.none`,
  `outcome.option`, `outcome.ok`, `outcome.err`.
* Added `Option:filter`.
* Performance improvements.

## 0.1.0 - 2017-01-14

* Initial release.
