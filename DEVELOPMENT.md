# Development

## Encrypted assets

Files in `Assets/` (third-party STLs) are stored as age-encrypted blobs via [cottage](https://github.com/sayanarijit/cottage):

- `*.cott.age` — encrypted binary, tracked via git LFS
- `*.cott.toml` — plain-text metadata (checksums, recipients)
- Plaintext `*.stl` — gitignored, never committed

## Prerequisites

```sh
# cottage
cargo binstall --locked cottage   # or: pip install cottage

# git LFS (if not already installed)
brew install git-lfs
git lfs install
```

You also need an identity that's listed in `.cottage/recipients/`. On the original machine the private key lives at `~/.config/cottage/identity`.

## Decrypting

```sh
task decrypt
```

Runs `git lfs pull` then `ctg decrypt Assets/*.cott.age`, leaving plaintext STLs in `Assets/`.

For one-shot use with no plaintext left on disk:

```sh
ctg run -- swift run caddy   # decrypts, runs, cleans up
```

## Adding a new machine / recipient

On the **new** machine, generate a key and add the public side to the repo:

```sh
ctg init                                            # creates .cottage/identity + .cottage/recipients/<name>
mv .cottage/identity ~/.config/cottage/identity     # optional: make it global
```

On a machine that **can already decrypt**, re-encrypt for the new recipient:

```sh
git pull
ctg sync           # re-encrypts everything for the updated recipient list
git add .cottage/recipients Assets/*.cott.age Assets/*.cott.toml
git commit -m "Add recipient"
git push
```

The new machine can now `git pull && ctg decrypt Assets/*.cott.age`.

## Dependencies

Cadova is pinned to its `dev` branch (see `Package.swift`). SwiftPM does **not** automatically pick up new commits on a branch — `Package.resolved` locks the specific revision. To advance to the latest commit on `dev`:

```sh
task update     # swift package update
```

## Reference

| Command | Purpose |
|---|---|
| `ctg status` | Show which secrets are out of sync (timestamp-based) |
| `ctg diff` | Show actual diff between encrypted and decrypted |
| `ctg sync` | Decrypt + re-encrypt (reconcile both sides) |
| `ctg clean` | Delete all plaintext secrets from working tree |
| `ctg verify` | Verify checksums match metadata (use in CI) |
