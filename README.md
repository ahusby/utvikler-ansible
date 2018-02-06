NAV Utvikler Ansible Playbook
=============================

Automatiserer oppsett av Linux utviklerimage og Jenkins byggservere.

## Komme i gang

### ... fra et helt fersk Linuximage eller Jenkins-server

Vi trenger `git` og `ansible` for å komme i gang. Installer som `root` (det kan hende brukeren din ikke er satt opp med `sudo` enda):

```
su - 
yum install git ansible
exit

# ... fortsett med kommandoene under "Generelt" 
```


### Generelt

Start med å klone dette repositoriet:
```
git clone https://github.com/navikt/utvikler-ansible.git
```

I enkelte tilfeller er det nødvendig å spesifisere proxy-innstillinger:
```
HTTPS_PROXY=http://webproxy.company.com \
  git clone -c http.sslVerify=false \
  https://github.com/navikt/utvikler-ansible.git
```

Gå inn i mappa, endre inventory-fila og kjør playbooken:
```
cd utvikler-ansible

cp example-inventory inventory
# update inventory with your own hosts

ansible-playbook -i inventory setup-playbook.yml
```

**PS**: Du bør logge ut og inn igjen etterpå siden enkelte installasjonsprosesser og endringer vil tre i kraft da.

### Kun sette opp jenkins?

Viss du kun har behov for å installere en jenkins-server så kan du klare deg med en minimal inventory-fil:

```
[all:vars]
http_proxy=http://webproxy.company.com:8088
https_proxy=http://webproxy.company.com:8088
no_proxy="localhost,127.0.0.1,.company.com,{{ansible_default_ipv4.address}}"

[jenkins]
localhost ansible_connection=local ansible_become_method=sudo

[jenkins:vars]
git_config_name=<jenkins git user>
git_config_email=<jenkins git email>
```
Jenkins-hosten i eksemplet over er tilfeldigvis den samme maskinen vi kjører ansible-playbooken fra, 
eksempelvis en server i iApp-sonen.

#### Integrasjon mot AD

##### Azure AD

Integrasjon mot Azure AD blir automatisk satt opp dersom du definerer:

* `azure_ad_tenant`
* `azure_ad_client`
* `azure_ad_secret`

##### Internal AD

Integrasjon mot internal AD blir automatisk satt opp dersom du definerer:

* `internal_ad_domain` (feks `adeo.no`)

### Ekstra

Ønsker du å starte `bash` hver gang terminalen din starter, så kan du legge følgende i `.kshrc`:

```
test -z "$BASH" && test -x /usr/bin/bash && exec /usr/bin/bash -l
```


## Roles

### `common` - Standardoppsett for alle hosts

Linux utviklerimage og Jenkins-servere deler både operativsystem (`RHEL`) og hvilken sone de befinner seg i, og har dermed endel oppsett til felles:

* Proxy-innstillinger, dersom dette er konfigurert
* Interne sertifikater
* Docker
* Google Chrome
* Git
* Java (OpenJDK 1.7 og 1.8)
* Maven
* Node og NPM

Hvilke versjoner som installeres beskrives i `group_vars/all`.

### `jenkins` - Jenkins byggserver

Det eneste som blir installert her, utover det som er beskrevet for `common`, er:

* Jenkins
* Git-config for `jenkins`-brukeren (`user.name` og `user.email`)

### `linuximage` - Linux utviklerimage

Foreløpig utfører `common` alle de nødvendige stegene, med untak av:

* Gir `sudo`-tilgang til brukeren din
* Mounter hjemmeområde og fellesdisk
* Git-config (`user.name` og `user.email`)
* Installerer HipChat og ICAClient

### `kubernetes` - Kubernetes og Kubectl

Installerer Kubernetes og Kubectl

### `kubectx` - Kubectx og completions

Installerer Kubectx og Kubens, pluss oppsett for KUBECONFIG og completions for kubectx, kubens, og kubectl.
