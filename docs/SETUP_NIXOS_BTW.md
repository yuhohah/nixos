# 🚀 Guia de Configuração: OmniRoute + T3 Code no `nixos-btw`

Este documento contém os passos necessários para finalizar a configuração do **OmniRoute** e do **T3 Code** no desktop (**`nixos-btw`**) e permitir o acesso remoto a partir do notebook (**`arrow`**) via túnel SSH seguro.

---

## 📌 1. Dados de Referência do Host `arrow` (Notebook)

Estes dados podem ser necessários durante a configuração entre as duas máquinas:

| Dado | Valor |
| :--- | :--- |
| **Hostname / mDNS** | `arrow.local` |
| **IP na Rede Local (LAN)** | `192.168.1.226` |
| **Usuário** | `luan` |
| **Chave Pública SSH do Arrow** | `ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDWIovLxUNhoNHtYwSVduhurWeQkttct4dOrNALPrhNB luan@arrow` |
| **Porta T3 Code** | `3773` |
| **Porta OmniRoute** | `20128` |
| **Caminho Banco OmniRoute** | `~/.local/share/omniroute/storage.sqlite` |

> **Nota:** A chave pública do `arrow` já foi inserida no arquivo `hosts/nixos-btw/default.nix` como chave autorizada (`authorizedKeys`), portanto, assim que o desktop for reconstruído, o notebook conectará sem pedir senha.

---

## 🖥️ 2. Passos para Executar no Desktop (`nixos-btw`)

Execute os passos a seguir no terminal do seu **desktop** (`nixos-btw`):

### Passo 1: Atualizar o Repositório NixOS
Puxe as atualizações que foram enviadas a partir do notebook:
```bash
cd ~/Configuration/nixos
git pull origin main
```

---

### Passo 2: Configurar o Agenix (Segredos do OmniRoute)
O OmniRoute e o T3 Code utilizam segredos decriptados em `/run/user/1000/agenix/` (chave de API e ambiente). Escolha uma das duas opções:

#### Opção A (Recomendada — Chave própria para o Desktop):
1. Verifique a chave pública SSH do desktop:
   ```bash
   cat ~/.ssh/id_ed25519.pub
   ```
   *(Caso não exista, crie com `ssh-keygen -t ed25519 -C "luan@nixos-btw"`).*

2. Edite `~/Configuration/nixos/secrets/secrets.nix` e adicione a chave do desktop:
   ```nix
   let
     luan-arrow = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDWIovLxUNhoNHtYwSVduhurWeQkttct4dOrNALPrhNB luan@arrow";
     luan-nixos-btw = "<COLE_AQUI_A_CHAVE_DO_DESKTOP>";

     users = [ luan-arrow luan-nixos-btw ];
   in
   {
     "omniroute-api-key.age".publicKeys = users;
     "omniroute-env.age".publicKeys = users;
   }
   ```

3. Re-cripte os segredos e comite:
   ```bash
   cd ~/Configuration/nixos/secrets
   nix run github:ryantm/agenix -- -r
   git commit -am "chore(secrets): add nixos-btw to agenix recipients"
   ```

#### Opção B (Rápida — Reutilizar a Chave do Notebook):
Se preferir não re-criptar os segredos agora, copie a chave privada do notebook diretamente para o desktop:
```bash
# Executado no desktop puxando do notebook:
scp luan@192.168.1.226:~/.ssh/id_ed25519 ~/.ssh/id_ed25519
chmod 600 ~/.ssh/id_ed25519
```

---

### Passo 3: Aplicar a Nova Configuração no Desktop
Reconstrua o sistema no desktop:
```bash
cd ~/Configuration/nixos
sudo nixos-rebuild switch --flake .#nixos-btw
```

O que este rebuild ativa no desktop:
- **OpenSSH Server** ativo na porta `22`.
- **Firewall** liberando a porta `22` e o tráfego do Avahi mDNS.
- **Avahi mDNS** anunciando `nixos-btw.local` na rede.
- **Lingering do usuário luan** (`users.users.luan.linger = true`).
- Serviços de background **`omniroute.service`** e **`t3code.service`** iniciando no boot automaticamente.

---

### Passo 4: Migrar o Banco de Dados do OmniRoute (Opcional, mas Recomendado)
Para não ter que cadastrar novamente as credenciais da **Kiro AI**, **OpenRouter**, **NVIDIA NIM** e **Antigravity** no desktop, copie o banco de dados do notebook para o desktop:

```bash
# Executado no desktop puxando do notebook (arrow):
scp -r luan@192.168.1.226:~/.local/share/omniroute/ ~/.local/share/
```
*(Ou, se preferir rodar a partir do notebook para o desktop: `scp -r ~/.local/share/omniroute/ luan@nixos-btw.local:~/.local/share/`)*.

---

### Passo 5: Confirmar os Serviços no Desktop
Verifique se os serviços subiram corretamente:
```bash
systemctl --user status omniroute.service
systemctl --user status t3code.service
```

Se desejar reiniciar após copiar o banco:
```bash
systemctl --user restart omniroute.service t3code.service
```

---

## 💻 3. Como Conectar e Usar no Notebook (`arrow`)

Após finalizar os passos acima no desktop:

### 1. Atualizar o notebook para ativar as configurações de SSH e alias:
No terminal do notebook:
```bash
sudo nixos-rebuild switch --flake .#arrow
```

### 2. Abrir o Túnel SSH:
No terminal do notebook, basta rodar:
```bash
ai-tunnel
```
*(Esse comando executa por baixo dos panos: `ssh -N nixos-ai-tunnel`, que encaminha localmente as portas `3773` e `20128` de `nixos-btw.local`).*

### 3. Acessar no Navegador no Notebook:
- **T3 Code Workspace**: [http://localhost:3773](http://localhost:3773)
- **OmniRoute Dashboard**: [http://localhost:20128/dashboard](http://localhost:20128/dashboard)

---

## 🔍 4. Resolução de Problemas (Troubleshooting)

- **Se o comando `ai-tunnel` der erro de resolução de nome (`nixos-btw.local`):**
  - Obtenha o IP do desktop rodando `ip -br a` no desktop.
  - Conecte diretamente pelo IP:
    ```bash
    ssh -N -L 3773:localhost:3773 -L 20128:localhost:20128 luan@<IP_DO_DESKTOP>
    ```

- **Se a porta `3773` já estiver em uso localmente no notebook:**
  - Se você tiver uma instância local do T3 Code rodando no notebook, pare-a com:
    ```bash
    systemctl --user stop t3code.service
    ```
