# DDD Project Creation Script

## Descrição

Este script automatiza a criação de uma estrutura de projeto .NET com arquitetura DDD (Domain-Driven Design), incluindo:

- Clonagem de repositório Git ou criação de projeto local
- Criação de estrutura de pastas
- Geração de projetos .NET (Domain, Infra, App) com opção de definir o tipo de projeto na camada `App`
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

### Sintaxe para Repositório Remoto

```bash
ddd <url-repositorio-git> <diretorio-destino> [tipo-app]
```

### Sintaxe para Projeto Local

```bash
ddd --local <nome-projeto> <diretorio-destino> [tipo-app]
```

> **Nota:** O parâmetro `[tipo-app]` é opcional. Se não for informado, o padrão será `webapi`.

### Exemplos

```bash
# Cria projeto a partir de repositório remoto no diretório atual (padrão webapi)
ddd https://github.com/seu-usuario/seu-projeto .

# Cria projeto a partir de repositório remoto com um tipo de App diferente (ex: console)
ddd https://github.com/seu-usuario/seu-projeto /caminho/para/projetos console

# Cria novo projeto local (padrão webapi)
ddd --local meu-novo-projeto /caminho/para/projetos

# Cria novo projeto local com um tipo de App diferente (ex: worker)
ddd --local meu-novo-projeto /caminho/para/projetos worker
```

## Estrutura de Projeto Gerada

```sh
projeto/
├── src/
│   ├── Projeto.Domain/
│   ├── Projeto.Infra/
│   └── Projeto.App/  # Tipo de projeto pode ser webapi, console, worker, etc.
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

## Novidades

- Suporte para criação de projetos locais
- Inicialização automática de repositório Git para projetos locais
- Geração de README.md inicial
- Commit inicial para projetos locais
- **Novo:** Suporte para definir o tipo de projeto na camada `App` (padrão: `webapi`)

## Solução de Problemas

- Certifique-se de ter .NET SDK instalado
- Verifique conexão com a internet
- Garanta permissões de execução do script
- Para projetos locais, certifique-se de fornecer um nome de projeto válido
- Se um tipo de projeto inválido for informado, o comando `dotnet new` pode falhar. Consulte `dotnet new --list` para ver os tipos disponíveis.

## Contribuição

Pull requests são bem-vindos. Para mudanças importantes, abra um issue primeiro para discutir as alterações propostas.
