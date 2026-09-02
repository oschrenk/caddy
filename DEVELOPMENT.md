# Development

## Layout

One Swift package, `Woodwork`, with a shared library and one executable target per project:

```text
Sources/
  Woodwork/     library — Gear/, Hardware/, Output/ (reusable across projects)
  Caddy/        executable — Structure/, Nesting.swift, main.swift
```

`Woodwork` holds anything a second project would want: the gear models used for scale and fit-checking, hardware (casters, screws), and the cutlist / screw-list / SVG-nesting output helpers.
Project targets hold their own geometry and their own `main.swift`.

Because `Woodwork` is a separate module, anything it exposes has to be `public`.
Unlike within a module, public structs do not pick up `Sendable` automatically.
Plain data types (`CutPart`, `ScrewHole`, `NestLabel`, `NestingPlan`) declare it explicitly.

## Building the Model

```sh
task caddy    # swift run caddy → writes Build/Caddy/caddy.3mf
              #   (+ caddy.stl, Nesting.svg, Screws.md, Docs/Caddy/Cutlist.md)
```

The build **requires the decrypted `Assets/models/*.stl` files**.
The model loads `Tower.stl`, `Headphones.stl`, and `Raspberry Pi 4 Model B.stl` at generate time.
A fresh clone leaves them encrypted, so run `task decrypt` first (see [Decrypting](#decrypting)).
If you skip it, the build fails with:

```text
🛑 [ERROR] ... The file "Tower.stl" doesn't exist.
```

Other targets: `task build` (compile only, no model), `task clean` (wipe `.build` + every project's generated files), `task caddy:clean` (just the caddy).

## Adding a Project

1. `Sources/<Name>/` with a `main.swift` that `import Woodwork`.
2. In `Package.swift`, add an `.executableTarget(name: "<Name>", dependencies: ["Woodwork", "Cadova", "Helical"], swiftSettings: [.interoperabilityMode(.Cxx)])` plus a lowercase `.executable` product so it runs as `swift run <name>`.
   Every target that touches Cadova needs the Cxx setting.
   Cadova wraps the C++ Manifold kernel, and the setting does not propagate across modules.
3. Write output to `Build/<Name>/` and docs to `Docs/<Name>/`.
4. Add `<name>` and `<name>:clean` tasks to `taskfile.yml`.

## Encrypted Assets

[cottage](https://github.com/sayanarijit/cottage) stores the third-party STLs in `Assets/models/` as age-encrypted blobs:

- `*.cott.age`: encrypted binary, tracked via git LFS
- `*.cott.toml`: plain-text metadata (checksums, recipients)
- Plaintext `*.stl`: gitignored, never committed

## Prerequisites

```sh
# cottage
cargo binstall --locked cottage   # or: pip install cottage

# git LFS (if not already installed)
brew install git-lfs
git lfs install
```

You also need an **age identity** whose public key appears in `.cottage/recipients/`.
This repo's recipient `oliver` is the age public key `age1lwq90ew3eu7qh504gdh9e6vdrk8yxx32e87t6kxz9ff3gvsmyclq0dprfs`.
Decryption needs the matching private key (`AGE-SECRET-KEY-1...`).

### Getting the Identity Onto a Machine

The private key is not in the repo (only the public recipient is).
Recover it from:

- **1Password** holds the backup (look for an item containing `AGE-SECRET-KEY-`).
  This is the source of truth.
- Another machine that already has `~/.config/cottage/identity`.

Place it at the global path so all repos can use it:

```sh
mkdir -p ~/.config/cottage
# paste the AGE-SECRET-KEY line into the file
chmod 400 ~/.config/cottage/identity
```

Verify it matches this repo's recipient before trusting it:

```sh
age-keygen -y ~/.config/cottage/identity
# must print: age1lwq90ew3eu7qh504gdh9e6vdrk8yxx32e87t6kxz9ff3gvsmyclq0dprfs
```

> **Gotcha:** `ctg` only auto-discovers `.cottage/identity` (repo-local) or `~/.ssh`.
> It does not auto-discover `~/.config/cottage/identity`.
> `task decrypt` handles this for you by exporting `COTTAGE_IDENTITY` when the global identity exists.
> If you run `ctg` directly, point it there yourself: `ctg decrypt -i ~/.config/cottage/identity Assets/models/*.cott.age`.

## Decrypting

```sh
task decrypt
```

Runs `git lfs pull` (the `*.cott.age` files are LFS-tracked, so a plain clone only has pointer stubs) then `ctg decrypt Assets/models/*.cott.age`, leaving plaintext STLs in `Assets/models/`.
It auto-uses `~/.config/cottage/identity` if present.

For one-shot use with no plaintext left on disk:

```sh
ctg run -- swift run caddy   # decrypts, runs, cleans up
```

## Adding a New Machine / Recipient

On the **new** machine, generate a key and add the public side to the repo:

```sh
ctg init                                            # creates .cottage/identity + .cottage/recipients/<name>
mv .cottage/identity ~/.config/cottage/identity     # optional: make it global
```

On a machine that **can already decrypt**, re-encrypt for the new recipient:

```sh
git pull
ctg sync           # re-encrypts everything for the updated recipient list
git add .cottage/recipients Assets/models/*.cott.age Assets/models/*.cott.toml
git commit -m "Add recipient"
git push
```

The new machine can now `git pull && ctg decrypt Assets/models/*.cott.age`.

## Reference

| Command | Purpose |
|---|---|
| `ctg status` | Show which secrets are out of sync (timestamp-based) |
| `ctg diff` | Show actual diff between encrypted and decrypted |
| `ctg sync` | Decrypt + re-encrypt (reconcile both sides) |
| `ctg clean` | Delete all plaintext secrets from working tree |
| `ctg verify` | Verify checksums match metadata (use in CI) |

## Troubleshooting

| Symptom | Cause | Fix |
|---|---|---|
| `The file "Tower.stl" doesn't exist` on `task caddy` | Assets still encrypted | `task decrypt` |
| `*.cott.age` files are ~130 bytes | LFS blobs not pulled (only pointer stubs) | `git lfs pull` (or `task decrypt`) |
| `ctg decrypt`: no identity / decryption fails | `ctg` did not find your key | Ensure `~/.config/cottage/identity` exists, or pass `-i <path>` / set `COTTAGE_IDENTITY` |
| `ctg`: recipient mismatch | Your key is not an authorized recipient | Have a recipient machine run `ctg sync` to re-encrypt for you (see [Adding a new machine](#adding-a-new-machine--recipient)) |
