# PUBLIC_HARDENING

Imagem Linux hardenizada, no **padrão do gordão**, validada em ambientes reais e pensada como **Golden Image** para laboratórios, clientes e pipelines de segurança.

Projeto orientado a:
- Reprodutibilidade
- Auditoria
- Hardening baseado em CIS / OpenSCAP
- Consumo via Vagrant

---

## Estrutura do Projeto
my-hardened-linux/
├── packer/
│ ├── ol8.pkr.hcl
│ ├── alma8.pkr.hcl # futuro
│ ├── fedora.pkr.hcl # futuro
│ ├── http/ # kickstart / preseed
│ └── scripts/
│ ├── 00-base.sh
│ ├── 01-openscap-install.sh
│ ├── 02-openscap-hardening.sh
│ └── 03-cleanup.sh
└── vagrant/
├── hardened.box
└── insecure.box


---

## Estado Atual (Checkpoint)

✔ Packer funcionando  
✔ Plugin VirtualBox instalado  
✔ Validação de template OK  
✔ Fluxo Packer → VirtualBox testado  

Neste estágio, o build **ainda é interativo** (sem kickstart).

---

## Template Atual (Oracle Linux 8)

Arquivo: `packer/ol8.pkr.hcl`

```hcl
packer {
  required_plugins {
    virtualbox = {
      source  = "github.com/hashicorp/virtualbox"
      version = ">= 1.0.0"
    }
  }
}

source "virtualbox-iso" "ol8" {
  iso_url      = "https://yum.oracle.com/ISOS/OracleLinux/OL8/u10/x86_64/OracleLinux-R8-U10-x86_64-dvd.iso"
  iso_checksum = "none"   # laboratório

  vm_name      = "ol8-test"
  cpus         = 2
  memory       = 2048
  disk_size    = 20000

  ssh_username = "root"
  ssh_password = "packer"
  ssh_timeout  = "30m"

  shutdown_command = "shutdown -h now"
}

build {
  sources = ["source.virtualbox-iso.ol8"]
}


packer init .
packer validate .
packer build .



Próximos Passos (Roadmap Técnico)
1. Kickstart mínimo

Instalação automática

Root + SSH

Network configurada

Desligamento automático

2. Provisioning

00-base.sh: sistema base

01-openscap-install.sh

02-openscap-hardening.sh

03-cleanup.sh

3. Hardening

Perfil CIS / HITSS custom

Execução controlada (audit → remediate)

Artefatos de evidência (XML / logs)

4. Empacotamento

Exportar .box

Separar:

insecure.box

hardened.box

5. Consumo

Vagrant

Ambientes de teste

Pipelines CI/CD

Objetivo Final

Entregar imagens Linux seguras, auditáveis e reproduzíveis, prontas para:

Laboratórios de segurança

Ambientes corporativos

Demonstrações de compliance

Automação de hardening