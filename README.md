# DDD Project Creation Script

## Descrição

Este script automatiza a criação de uma estrutura de projeto .NET com arquitetura DDD (Domain-Driven Design), incluindo:

- Clonagem de repositório Git
- Criação de estrutura de pastas
- Geração de projetos .NET (Domain, Infra, App)
- Configuração de projetos de teste
- Adição de pacotes NuGet padrão

## Pré-requisitos

- Git Bash
- .NET SDK
- Git
- Dotnet CLI

## Instalação

### 1. Crie o diretório de scripts

```bash
mkdir -p ~/bin
```

### 2. Copie o script

```bash
cp /caminho/para/ddd.sh ~/bin/ddd
```

### 3. Torne o script executável

```bash
chmod +x ~/bin/ddd
```

### 4. Configure o PATH

Adicione ao `~/.bashrc` ou `~/.bash_profile`:

```bash
export PATH="$HOME/bin:$PATH"
```

### 5. Recarregue as configurações

```bash
source ~/.bashrc
# ou
source ~/.bash_profile
```

## Uso

### Sintaxe

```bash
ddd <url-repositorio-git> <diretorio-destino>
```

### Exemplo

```bash
# Cria projeto no diretório atual
ddd https://github.com/seu-usuario/seu-projeto .

# Cria projeto em um diretório específico
ddd https://github.com/seu-usuario/seu-projeto /caminho/para/projetos
```

## Estrutura de Projeto Gerada

```
projeto/
├── src/
│   ├── Projeto.Domain/
│   ├── Projeto.Infra/
│   └── Projeto.App/
└── test/
    ├── Projeto.Domain.Test/
    ├── Projeto.Infra.Test/
    └── Projeto.App.Test/
```

## Pacotes Adicionados

### Camada App

- AWSSDK.SecurityToken
- AWSSDK.SSO
- AWSSDK.SSOOIDC

### Projetos de Teste

- JUnitXml.TestLogger
- coverlet.msbuild

## Solução de Problemas

- Certifique-se de ter .NET SDK instalado
- Verifique conexão com a internet
- Garanta permissões de execução do script

## Contribuição

Pull requests são bem-vindos. Para mudanças importantes, abra um issue primeiro para discutir as alterações propostas.
