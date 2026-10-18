# machine-setup

One command to turn a fresh Linux VM into a working development machine:
firewall locked down, SSH key generated, Git identity set, commits signed, and
optionally this repository's remotes switched to SSH.

## What it does

Running `configure-machine.sh` prompts for your name, your email, and whether to
switch this repository's remotes to SSH, then runs these steps in order:

| Step | Script | Effect |
| --- | --- | --- |
| 1 | `ufw.sh` | Resets UFW, denies all incoming, allows all outgoing, and permits SSH **only from the IP you are currently connected from** |
| 2 | `generate-ssh-key.sh` | Creates an ed25519 key at `~/.ssh/id_ed25519`, commented with your email |
| 3 | `git.sh` | Sets global `user.name` and `user.email` |
| 4 | `sign-local-commits.sh` | Configures Git to sign every commit with that SSH key |
| 5 | `ssh-remote.sh` | **Only if you answer `y`:** rewrites this repository's GitHub HTTPS remotes to SSH (`git@github.com:owner/repo.git`). Answering anything else leaves the remotes as they are |

## Requirements

- Debian or Ubuntu with `ufw` installed
- `sudo` privileges
- Git 2.34 or newer (SSH commit signing needs `gpg.format ssh`)
- **You must be connected over SSH.** The firewall step reads `SSH_CONNECTION`
  to learn which IP to allow. It refuses to run otherwise rather than risk
  locking you out.

## Usage

```bash
git clone https://github.com/calleia/machine-setup.git
cd machine-setup
./configure-machine.sh
```

## Read before running

This script makes changes that can lock you out of the machine or affect keys
you already have. In particular:

- **All existing UFW rules are erased.** The script runs `ufw --force reset`
  before applying its own policy.
- **Only your current IP can reach port 22 afterwards.** If your address is
  dynamic, or you connect later from somewhere else, you will not be able to
  SSH back in. Keep console access to the VM available, or add another rule:

  ```bash
  sudo ufw allow from <other-ip> to any port 22 proto tcp
  ```

- **The SSH key is created without a passphrase**, so the run needs no
  attention. This means anyone who can read `~/.ssh/id_ed25519` can sign
  commits and authenticate as you. If you would rather have a passphrase,
  generate the key yourself first — the script skips generation when
  `~/.ssh/id_ed25519` already exists:

  ```bash
  ssh-keygen -t ed25519 -C "you@example.com" -f ~/.ssh/id_ed25519
  ```

- **Your global Git config is overwritten** for `user.name`, `user.email`,
  `gpg.format`, `user.signingkey`, and `commit.gpgsign`.

## After running

Add `~/.ssh/id_ed25519.pub` to GitHub twice — once as an **authentication key**
and once as a **signing key**. They are separate entries, and commits will not
show as Verified until the signing key is registered.

### HTTPS clones and SSH remotes

Git picks how to authenticate from the remote URL, not from the keys on the
machine. A repository cloned over HTTPS keeps asking for a username and token on
every `fetch` or `push` (unless a credential helper stores them), even after
the SSH key above is on GitHub. Only `git@github.com:...` remotes use the key.

If you cloned this repository over HTTPS, answer `y` to the remote prompt, or
switch it afterwards. Once the authentication key is on GitHub, confirm SSH
works:

```bash
bash ssh-remote.sh /path/to/repo   # defaults to the current directory
ssh -T git@github.com              # accept the host fingerprint on first use
git fetch
```

Until the key is added as an **authentication key**, fetches over the SSH
remote fail with `Permission denied (publickey)`.

Check the result:

```bash
git config --global --list | grep -E 'user|gpg|sign'
sudo ufw status verbose
```

## Running steps individually

Each script works on its own, and they take their input as arguments:

```bash
bash ufw.sh
bash generate-ssh-key.sh "you@example.com"
bash git.sh "you@example.com" "Your Name"
bash sign-local-commits.sh
bash ssh-remote.sh /path/to/repo
```
