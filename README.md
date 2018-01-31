NAV Utvikler Ansible Playbook
=============================

Automatiserer oppsett av Linux utviklerimage og Jenkins byggservere.

## Komme i gang

### Fra et helt fersk Linuximage

Vi trenger `git` og `ansible` for å komme i gang.

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
