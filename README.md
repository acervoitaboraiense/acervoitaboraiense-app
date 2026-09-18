# Aplicativo Acervo Itaboraiense

O **Aplicativo Acervo Itaboraiense** é o aplicativo oficial do projeto Acervo Itaboraiense, desenvolvido com o objetivo de preservar, catalogar e difundir a memória histórica, cultural e patrimonial do município de Itaboraí, Rio de Janeiro. O aplicativo atua como uma extensão mobile e interativa da plataforma.

Este projeto foi construído utilizando o framework **Flutter**, permitindo uma experiência performática e fluida.

---

## Estrutura do Repositório

A organização dos arquivos segue o padrão recomendado para projetos Flutter:

* **`.github/workflows/`**: Contém as esteiras de automação para testes, builds ou deploy do aplicativo.
* **`assets/`**: Recursos estáticos do aplicativo, como imagens, ícones da identidade visual local, fontes personalizadas e arquivos de dados locais.
* **`lib/`**: Código-fonte em Dart contendo a arquitetura do app (telas, componentes, gerenciamento de estado e integrações de API).
* **`pubspec.yaml`**: Arquivo de configuração de dependências do Flutter, metadados do projeto e declaração de assets.

---

## Como Executar o Projeto Localmente

### Pré-requisitos
Antes de começar, certifique-se de ter o ambiente Flutter configurado na sua máquina:
1. Instale o [Flutter SDK](https://docs.flutter.dev/get-started/install) (versão estável).
2. Configure um emulador (Android/iOS) ou conecte um dispositivo físico com a depuração USB ativada.
3. Garanta que o comando `flutter doctor` não apresente erros críticos.

### Passo a Passo

1. **Clonar o Repositório:**
   ```bash
   git clone https://github.com/acervoitaboraiense/aplicativo-acervoitaboraiense.git
   cd aplicativo-acervoitaboraiense
   ```

2. **Instalar as Dependências:**
   Obtenha todos os pacotes listados no `pubspec.yaml`:
   ```bash
   flutter pub get
   ```

3. **Executar o Aplicativo:**
   Inicie o app no dispositivo ou emulador conectado:
   ```bash
   flutter run
   ```

---

## Licença

Este projeto está sob a licença **MIT**. Consulte o arquivo [LICENSE](LICENSE) para obter mais detalhes.

---

## Contribuição

Contribuições são muito bem-vindas para valorizar a história de Itaboraí! Se você deseja reportar um bug, sugerir melhorias ou adicionar novos recursos:
1. Faça um **Fork** do repositório.
2. Crie uma branch para sua modificação (`git checkout -b feature/NovaFuncionalidade`).
3. Envie um **Pull Request** detalhando suas alterações.
