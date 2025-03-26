#!/bin/bash

# Função de uso
usage() {
    echo "Usage:"
    echo "  For remote repository: $0 <git-repository-url> <destination-directory> [app-type]"
    echo "  For local project: $0 --local <project-name> <destination-directory> [app-type]"
    echo "  app-type (optional): Type of .NET project to create in the App layer (default: webapi)"
    exit 1
}

# Verifica os argumentos mínimos
if [ $# -lt 3 ]; then
    usage
fi

# Define o tipo de projeto na camada App (padrão: webapi)
APP_TYPE=${4:-webapi}

# Processamento dos argumentos
if [ "$1" == "--local" ]; then
    IS_LOCAL=true
    PROJECT_NAME=$2
    DESTINATION_DIR=$3
    GIT_REPO_URL=""
else
    IS_LOCAL=false
    GIT_REPO_URL=$1
    DESTINATION_DIR=$2
    PROJECT_NAME=$(basename -s .git "$GIT_REPO_URL")
fi

FULL_DESTINATION_PATH=$(readlink -f "$DESTINATION_DIR")

# Formata o nome do projeto
PROJECT_NAME_CAMEL=$(echo "$PROJECT_NAME" | tr '-' '.' | awk -F. '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) substr($i,2)} 1' OFS=.)

# Entra no diretório de destino
cd "$FULL_DESTINATION_PATH" || exit 1

# Clona o repositório ou cria diretório local
if [ "$IS_LOCAL" = false ]; then
    git clone "$GIT_REPO_URL"
else
    mkdir -p "$PROJECT_NAME"
fi

# Entra no diretório do projeto
cd "$PROJECT_NAME" || exit 1

# Inicializa git se for projeto local
if [ "$IS_LOCAL" = true ]; then
    git init
fi

# Criação das pastas
mkdir -p src test

# Criação da solução vazia
dotnet new sln -n "$PROJECT_NAME_CAMEL" || exit 1

# Criação dos projetos
dotnet new classlib -n "$PROJECT_NAME_CAMEL.Domain" -o "src/$PROJECT_NAME_CAMEL.Domain" || exit 1
dotnet new classlib -n "$PROJECT_NAME_CAMEL.Infra" -o "src/$PROJECT_NAME_CAMEL.Infra" || exit 1
dotnet new "$APP_TYPE" -n "$PROJECT_NAME_CAMEL.App" -o "src/$PROJECT_NAME_CAMEL.App" || exit 1

dotnet new xunit -n "$PROJECT_NAME_CAMEL.Domain.Test" -o "test/$PROJECT_NAME_CAMEL.Domain.Test" || exit 1
dotnet new xunit -n "$PROJECT_NAME_CAMEL.Infra.Test" -o "test/$PROJECT_NAME_CAMEL.Infra.Test" || exit 1
dotnet new xunit -n "$PROJECT_NAME_CAMEL.App.Test" -o "test/$PROJECT_NAME_CAMEL.App.Test" || exit 1

# Adicionando os projetos à solução
dotnet sln add src/$PROJECT_NAME_CAMEL.Domain/$PROJECT_NAME_CAMEL.Domain.csproj
dotnet sln add src/$PROJECT_NAME_CAMEL.Infra/$PROJECT_NAME_CAMEL.Infra.csproj
dotnet sln add src/$PROJECT_NAME_CAMEL.App/$PROJECT_NAME_CAMEL.App.csproj

dotnet sln add test/$PROJECT_NAME_CAMEL.Domain.Test/$PROJECT_NAME_CAMEL.Domain.Test.csproj
dotnet sln add test/$PROJECT_NAME_CAMEL.Infra.Test/$PROJECT_NAME_CAMEL.Infra.Test.csproj
dotnet sln add test/$PROJECT_NAME_CAMEL.App.Test/$PROJECT_NAME_CAMEL.App.Test.csproj

# Referências entre projetos
dotnet add src/$PROJECT_NAME_CAMEL.Infra/$PROJECT_NAME_CAMEL.Infra.csproj reference src/$PROJECT_NAME_CAMEL.Domain/$PROJECT_NAME_CAMEL.Domain.csproj
dotnet add src/$PROJECT_NAME_CAMEL.App/$PROJECT_NAME_CAMEL.App.csproj reference src/$PROJECT_NAME_CAMEL.Domain/$PROJECT_NAME_CAMEL.Domain.csproj
dotnet add src/$PROJECT_NAME_CAMEL.App/$PROJECT_NAME_CAMEL.App.csproj reference src/$PROJECT_NAME_CAMEL.Infra/$PROJECT_NAME_CAMEL.Infra.csproj

dotnet add test/$PROJECT_NAME_CAMEL.Domain.Test/$PROJECT_NAME_CAMEL.Domain.Test.csproj reference src/$PROJECT_NAME_CAMEL.Domain/$PROJECT_NAME_CAMEL.Domain.csproj
dotnet add test/$PROJECT_NAME_CAMEL.Infra.Test/$PROJECT_NAME_CAMEL.Infra.Test.csproj reference src/$PROJECT_NAME_CAMEL.Infra/$PROJECT_NAME_CAMEL.Infra.csproj
dotnet add test/$PROJECT_NAME_CAMEL.App.Test/$PROJECT_NAME_CAMEL.App.Test.csproj reference src/$PROJECT_NAME_CAMEL.App/$PROJECT_NAME_CAMEL.App.csproj

# Adicionando pacotes NuGet na camada App
dotnet add src/$PROJECT_NAME_CAMEL.App/$PROJECT_NAME_CAMEL.App.csproj package AWSSDK.SecurityToken
dotnet add src/$PROJECT_NAME_CAMEL.App/$PROJECT_NAME_CAMEL.App.csproj package AWSSDK.SSO
dotnet add src/$PROJECT_NAME_CAMEL.App/$PROJECT_NAME_CAMEL.App.csproj package AWSSDK.SSOOIDC

# Adicionando pacotes NuGet nos projetos de Test
dotnet add test/$PROJECT_NAME_CAMEL.Domain.Test/$PROJECT_NAME_CAMEL.Domain.Test.csproj package JUnitXml.TestLogger
dotnet add test/$PROJECT_NAME_CAMEL.Domain.Test/$PROJECT_NAME_CAMEL.Domain.Test.csproj package coverlet.msbuild

dotnet add test/$PROJECT_NAME_CAMEL.Infra.Test/$PROJECT_NAME_CAMEL.Infra.Test.csproj package JUnitXml.TestLogger
dotnet add test/$PROJECT_NAME_CAMEL.Infra.Test/$PROJECT_NAME_CAMEL.Infra.Test.csproj package coverlet.msbuild

dotnet add test/$PROJECT_NAME_CAMEL.App.Test/$PROJECT_NAME_CAMEL.App.Test.csproj package JUnitXml.TestLogger
dotnet add test/$PROJECT_NAME_CAMEL.App.Test/$PROJECT_NAME_CAMEL.App.Test.csproj package coverlet.msbuild

# Cria README.md inicial
echo "# $PROJECT_NAME

## Descrição
Projeto .NET inicializado automaticamente.

## Estrutura
- src/: Código fonte da aplicação
- test/: Projetos de teste" > README.md

# Primeiro commit para projetos locais
if [ "$IS_LOCAL" = true ]; then
    git add .
    git commit -m "Estrutura inicial do projeto"
fi

echo "✅ Project structure created successfully in $FULL_DESTINATION_PATH/$PROJECT_NAME"
