#!/bin/bash

# Verifica se foi passado o link do repositório e o diretório de destino
if [ $# -ne 2 ]; then
    echo "Usage: create-dotnet-project <git-repository-url> <destination-directory>"
    exit 1
fi

# Captura o link do repositório e diretório de destino
GIT_REPO_URL=$1
DESTINATION_DIR=$2

# Expande o caminho para o diretório de destino
FULL_DESTINATION_PATH=$(readlink -f "$DESTINATION_DIR")

# Extrai o nome do repositório
PROJECT_NAME=$(basename -s .git "$GIT_REPO_URL")

# Formata o nome do projeto
PROJECT_NAME_CAMEL=$(echo "$PROJECT_NAME"|tr '-' '.'|awk -F. '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) substr($i,2)} 1' OFS=.)

# Entra no diretório de destino
cd "$FULL_DESTINATION_PATH" || exit 1

# Clona o repositório
git clone "$GIT_REPO_URL"

# Entra no diretório do projeto
cd "$PROJECT_NAME" || exit 1

# Criação das pastas
mkdir -p src test

# Criação da solução vazia
dotnet new sln -n "$PROJECT_NAME_CAMEL"

# Criação dos projetos
dotnet new classlib -n "$PROJECT_NAME_CAMEL.Domain" -o "src/$PROJECT_NAME_CAMEL.Domain"
dotnet new classlib -n "$PROJECT_NAME_CAMEL.Infra" -o "src/$PROJECT_NAME_CAMEL.Infra"
dotnet new webapi -n "$PROJECT_NAME_CAMEL.App" -o "src/$PROJECT_NAME_CAMEL.App"

dotnet new xunit -n "$PROJECT_NAME_CAMEL.Domain.Test" -o "test/$PROJECT_NAME_CAMEL.Domain.Test"
dotnet new xunit -n "$PROJECT_NAME_CAMEL.Infra.Test" -o "test/$PROJECT_NAME_CAMEL.Infra.Test"
dotnet new xunit -n "$PROJECT_NAME_CAMEL.App.Test" -o "test/$PROJECT_NAME_CAMEL.App.Test"

# Adicionando os projetos à solução
dotnet sln add src/$PROJECT_NAME_CAMEL.Domain/$PROJECT_NAME_CAMEL.Domain.csproj
dotnet sln add src/$PROJECT_NAME_CAMEL.Infra/$PROJECT_NAME_CAMEL.Infra.csproj
dotnet sln add src/$PROJECT_NAME_CAMEL.App/$PROJECT_NAME_CAMEL.App.csproj

dotnet sln add test/$PROJECT_NAME_CAMEL.Domain.Test/$PROJECT_NAME_CAMEL.Domain.Test.csproj
dotnet sln add test/$PROJECT_NAME_CAMEL.Infra.Test/$PROJECT_NAME_CAMEL.Infra.Test.csproj
dotnet sln add test/$PROJECT_NAME_CAMEL.App.Test/$PROJECT_NAME_CAMEL.App.Test.csproj

# Referências entre projetos
dotnet add src/$PROJECT_NAME_CAMEL.Infra/$PROJECT_NAME_CAMEL.Infra.csproj \
    reference src/$PROJECT_NAME_CAMEL.Domain/$PROJECT_NAME_CAMEL.Domain.csproj

dotnet add src/$PROJECT_NAME_CAMEL.App/$PROJECT_NAME_CAMEL.App.csproj \
    reference src/$PROJECT_NAME_CAMEL.Domain/$PROJECT_NAME_CAMEL.Domain.csproj \
    reference src/$PROJECT_NAME_CAMEL.Infra/$PROJECT_NAME_CAMEL.Infra.csproj

dotnet add test/$PROJECT_NAME_CAMEL.Domain.Test/$PROJECT_NAME_CAMEL.Domain.Test.csproj \
    reference src/$PROJECT_NAME_CAMEL.Domain/$PROJECT_NAME_CAMEL.Domain.csproj

dotnet add test/$PROJECT_NAME_CAMEL.Infra.Test/$PROJECT_NAME_CAMEL.Infra.Test.csproj \
    reference src/$PROJECT_NAME_CAMEL.Infra/$PROJECT_NAME_CAMEL.Infra.csproj

dotnet add test/$PROJECT_NAME_CAMEL.App.Test/$PROJECT_NAME_CAMEL.App.Test.csproj \
    reference src/$PROJECT_NAME_CAMEL.App/$PROJECT_NAME_CAMEL.App.csproj

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

echo "✅ Project structure created successfully in $FULL_DESTINATION_PATH/$PROJECT_NAME"
