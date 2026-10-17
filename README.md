# infrastructure

Single entry point for deploying the nowak-reisen and speisehof machines and services. This repo owns the inventory, the Ansible config, the dependency list, the vault, and every playbook for the Nowak businesses.

It is the sibling of `uhlig-it/infrastructure`: that repo covers the uhlig-it fleet; this one covers nowak-reisen (Taxi und Busreisen Nowak) and speisehof (Speisehof Nowak). The application repos stay code-only.

## Layout

- `inventory/hosts.yml` — the hosts this repo manages.
- `inventory/group_vars/`, `inventory/host_vars/` — variables, including the one vault.
- `playbooks/machines/` — host provisioning, one file per host.
- `playbooks/services/` — application deployments, one file per service.
- `playbooks/site.yml` — runs the baseline and the static sites.
- `roles/` — host-specific roles that are not shared library.

## Hosts

| Host | What it is |
| --- | --- |
| `neon` | The nowak-reisen server (Hetzner). This repo provisions it and deploys caterbill, speisehof.de and nowak-reisen.de to it. It also serves a few uhlig-it services, which `uhlig-it/infrastructure` deploys. |
| `opus` | A uhlig-it home server, listed only as the target for the caterbill backup verification (`sqlite-vault-verify`). Not provisioned here. |

## Usage

```command
$ ansible-galaxy collection install -r requirements.yml
$ ansible-galaxy role install -r requirements.yml
$ ansible-playbook playbooks/site.yml --check

$ ansible-playbook playbooks/services/caterbill.yml -e stage=prod
$ ansible-playbook playbooks/services/sqlite-vault-verify.yml -e stage=prod --ask-vault-pass
$ ansible-playbook playbooks/services/speisehof.yml
$ ansible-playbook playbooks/services/nowak-reisen.yml
```

The services that build from source read the app checkout from a variable (`caterbill_source`, `sqlite_vault_source`, `speisehof_source`, `nowak_reisen_source`). The defaults point at the sibling clones in a workspace layout; override them with `-e` when the checkouts live elsewhere.

## Secrets

One vaulted file, `inventory/group_vars/all/secrets.yml`, holds every secret. It carries the `caterbill.<stage>` and `sqlite_vault_verify.<stage>` maps over from the retired `speisehof/caterbill-deployment`. The vault password is read from the file named by `$ANSIBLE_VAULT_PASSWORD_FILE`.

## Commits And Identity

Commits to this repo are made as **Aishe Drechsler** (aishe.drechsler@speisehof.de), signed with the SSH key `~/.ssh/identities/aidrex/id_ed25519`.

`~/.gitconfig.local` maps `github.com/nowak-reisen/**` and `github.com/speisehof/**` to `~/git/github.com/nowak-reisen/.gitconfig` (name, email, `core.sshCommand`, `commit.gpgsign`), but that `includeIf` matches the main clone's `.git` directory only — it does not match a wtg worktree's gitdir. Inside a workspace worktree, set the identity explicitly:

```command
$ git config user.name "Aishe Drechsler"
$ git config user.email "aishe.drechsler@speisehof.de"
$ git config core.sshCommand "ssh -o IdentitiesOnly=yes -i ~/.ssh/identities/aidrex/id_ed25519"
$ git config commit.gpgsign false
```

## Provenance

Consolidated from `speisehof/caterbill-deployment` (retired) and from the `speisehof`, `nowak-reisen` and `neon` pieces of `uhlig-it/infrastructure`.
