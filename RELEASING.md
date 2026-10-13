# Releasing Tubecrate

Releases are automated by [`.github/workflows/release.yml`](.github/workflows/release.yml).

## Cut a release

```bash
# bump nothing by hand — just tag and push
git tag v1.1
git push origin v1.1
```

On a `v*` tag push, the workflow (macOS runner) will:

1. Build `Tubecrate.app` via `Scripts/build-app.sh` (ad-hoc signed)
2. Zip it to `Tubecrate-<version>.zip` and compute its `sha256`
3. Create a GitHub Release with the zip attached + install notes

The version is derived from the tag (`v1.1` → `1.1`).

## Notarization (optional, removes the Gatekeeper warning)

The released app is **ad-hoc signed**, so users must right-click → Open (or strip
quarantine) on first launch. To remove that friction you need an Apple Developer
Program membership and a Developer ID certificate; then build locally with
`Scripts/notarize.sh` and `Scripts/make-dmg.sh` (see the comments in those scripts).
