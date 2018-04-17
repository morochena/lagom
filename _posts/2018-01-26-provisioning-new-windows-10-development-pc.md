---
layout: post
title:  "How I set up new Windows PCs for development"
date:   2018-01-25
categories: windows webdev setup ruby elixir python wsl productivity
---

I thought I'd document my process for setting up new Windows PCs that I use for development work. This is just how I do it given my workflow and development requirements, but I thought it might be useful for other people as a reference. 

The idea here is that you're going to be running all of your editors & tools on Windows, while running development environment inside WSL. 

Example: 
- Outside WSL: Open C:\Users\Marcus\projects\rails_project in Visual Studio Code 
- Inside WSL: `$ cd /mnt/c/Users/Marcus/projects/rails_project`
- Inside WSL: `$ rails server`
- Outside WSL: Open localhost:3000 in your browser of choice 

Note: Any sections meant to be run from inside WSL are prefixed with `WSL:` Other commands are presumed to be run from PowerShell as an administrator.

## Run Tron

> Tron is a glorified collection of batch files that automate the process of disinfecting and cleaning up Windows systems. It is built with heavy reliance on community input and updated regularly.
> Tron supports all versions of Windows from XP to 10 (server variants included).

[/r/TronScript](https://www.reddit.com/r/TronScript/)

## Manual App Installations

Chocolatey is my package manager of choice, and I use it to install almost everything except Firefox. I install Firefox seperately because I haven't found a package that installs the Developer Edition yet.

- Install [Chocolatey](https://chocolatey.org/install)
- Install [Firefox (Developer Edition)](https://www.mozilla.org/en-US/firefox/channel/desktop/)

## Chocolatey Installations

`$ cinst -y git emacs64 VisualStudioCode VisualStudio2017Community dashlane unity steam hyper dejavufonts`

## Windows Subsystem for Linux Install 

- `$ Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux`
- Download Ubuntu from Microsoft App Store
- Open Ubuntu app, configure username and password
- Configure Hyper to use bash `shell: 'C:\\Windows\\System32\\bash.exe',` in Hyper's config.

## WSL: Install Ansible 

- `$ sudo apt-get update`
- `$ sudo apt-get install python-pip python-dev`
- `$ sudo pip install ansible`
- add `localhost ansible_connection=local` to /etc/ansible/hosts (ensure your user has permissions to read the file)

## WSL: Install Elixir, Ruby, Node, Python using ASDF

- `$ ansible-galaxy install cimon-io.asdf`
- `$ ansible-playbook asdf-playbook.yml`

``` yaml
- hosts: all
  roles:
  - role: cimon-io.asdf
    asdf_user: "morochena"
    asdf_plugin_dependencies:
    - automake
    - autoconf
    - build-essential
    - libncurses-dev
    - libssl-dev
    - libyaml-dev
    - libxslt-dev
    - libffi-dev
    - libtool
    - unzip
    - zlib1g-dev
    - libbz2-dev
    - libreadline-dev
    - libsqlite3-dev
    - wget
    - curl
    - llvm
    - xz-utils
    - tk-dev
    asdf_plugins:
    - name: "erlang"
      versions: ["20.1"]
      global: "20.1"

    - name: "elixir"
      versions: ["1.6.0"]
      global: "1.6.0"

    - name: "ruby"
      versions: ["2.5.0"]
      global: "2.5.0"

    - name: "python"
      versions: ["anaconda3-5.0.1"]
      global: "anaconda3-5.0.1"
```

## Install Spacemacs 

```
$ git clone https://github.com/syl20bnr/spacemacs \
   C:\Users\$USERNAME$\AppData\Roaming\.emacs.d
```

- copy .spacemacs from my dotfiles

## Set up SSH keys however you see fit

Personally I share SSH keys between my Windows environment and my subsystem. 

You can see how to do that here: [https://florianbrinkmann.com/en/3436/ssh-key-and-the-windows-subsystem-for-linux/](https://florianbrinkmann.com/en/3436/ssh-key-and-the-windows-subsystem-for-linux/)

## WSL: Install Torus 

For managing secrets, it's my preferred solution.

[Torus](https://www.torus.sh/)

## Bonus: Install Nord theme for everything

[Nord](https://github.com/arcticicestudio/nord)