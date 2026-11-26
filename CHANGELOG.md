# Changelog

## Unreleased

### Changed

- **Breaking**: `xrsa` and `xrsb` are removed; use `getdata(GOES.XRS[id = 16]["xrsb_flux"], t0, t1)`.

### Changed

- GOES instruments are `SpaceDataModel.Registry` objects. Select datasets with `XRS[id = 16]`
  and materialize them with `getdata(dataset, t0, t1)`.
- GOES archive versions are resolved from remote listings instead of being hard-coded.

## [0.2.0] - 2026-01-11

### Changed

- **Breaking**: Replace `goesr_xrs` with `GEOS.XRS`
