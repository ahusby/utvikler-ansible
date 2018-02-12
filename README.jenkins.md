Jenkins
=======

Denne guiden forutsetter at du har bestilt server i Basta og har du har 
ssh-tilgang til den aktuelle maskinen. 
Du velger selv om du ønsker å konfigurere integrasjon mot Azure AD eller internal AD (eller ingen av delene).

## Let's go

Vi trenger `git` og `ansible` for å komme i gang.

```
sudo yum install git ansible
```

Klon repoet og `cd` inn i mappa:
```
HTTPS_PROXY=http://webproxy-utvikler.nav.no:8088 \
  git clone -c http.sslVerify=false \
  https://github.com/navikt/utvikler-ansible.git
  
cd utvikler-ansible
```

### Inventory

Vi bruker `inventory`-fila til å konfigurere de ulike hostene våre, inkludert evt. konfigurasjon
av AD:

```
[all:vars]
http_proxy=http://webproxy-utvikler.nav.no:8088
https_proxy=http://webproxy-utvikler.nav.no:8088
no_proxy="localhost,127.0.0.1,{{ ansible_default_ipv4.address }},.local,.adeo.no,.nav.no,.aetat.no,.devillo.no,.oera.no"
maven_internal_url=http://maven.adeo.no

[jenkins]
localhost ansible_connection=local ansible_become_method=sudo

[jenkins:vars]
git_config_name=<git name for jenkins>
git_config_email=<git email for jenkins>

# kommenter ut om azure AD skal konfigureres:
# azure_ad_tenant=tenant
# azure_ad_client=clientId
# azure_ad_secret=superSecret
# azure_ad_group=0000-GA-UTVIKLING-FRA-LAPTOP (c10e6466-4d28-4467-8e93-43cacfbcff92)

# kommenter ut om internal AD skal konfigureres:
# internal_ad_domain=adeo.no

# dersom verken azure AD eller internal AD settes opp vil standard Jenkins autentisering gjelde 
# (sjekk ut /var/lib/jenkins/secrets/initialAdminPassword)
```

### Kjøre playbook
Kjør `ansible-playbook` og slapp av:
```
ansible-playbook -i inventory setup-playbook.yml
```

Dersom alt går som det skal er Jenkins tilgjengelig på både port `8080` og `8443`.
