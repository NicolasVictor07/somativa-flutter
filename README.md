# ☕ Cafeteria App - Situação de Aprendizagem (SENAI)

Aplicativo móvel para gerenciamento de cardápio e realização de pedidos em uma cafeteria, desenvolvido em **Flutter** com a linguagem **Dart**, atendendo aos critérios de persistência local, consumo de serviços web e orientação a objetos.

---

## 📱 Diferenciação de Linguagens de Programação Mobile

Neste projeto, a escolha técnica foi o ecossistema **Dart / Flutter**, diferenciando-se das abordagens tradicionais de desenvolvimento mobile:

* **Linguagens Nativas (Android / iOS):**
  * *Android (Kotlin / Java):* Executadas sobre a máquina virtual Android Runtime (ART), exigem desenvolvimento exclusivo para a plataforma Android.
  * *iOS (Swift / Objective-C):* Compiladas exclusivamente para o ecossistema Apple com acesso direto às APIs nativas.
* **Linguagens Baseadas em Pontes / WebView (Híbridas):**
  * *JavaScript / TypeScript (React Native):* Utilizam uma ponte de comunicação assíncrona (JavaScript Bridge) para renderizar os componentes nativos de cada sistema.
* **Dart (Flutter - Abordagem Adotada):**
  * O **Dart** compila diretamente para código de máquina nativo (*Ahead-of-Time - AOT*), eliminando pontes de comunicação.
  * O **Flutter** utiliza um motor gráfico próprio de renderização (Skia/Impeller), garantindo desempenho consistente em múltiplas plataformas com base de código única, suporte estrito a tipagem estática e Orientação a Objetos.

---

## 🧱 Arquitetura e Orientação a Objetos (POO)

* **Abstração e Classes:** Modelagem da classe base `ItemCardapio` contendo atributos essenciais do produto (`id`, `nome`, `preco`, `urlImagem`).
* **Herança (Subclasse Especializada):** Criação da subclasse `Bebida`, estendendo `ItemCardapio` e adicionando propriedades específicas como `tamanhoMl`.
* **Componentização:** Isolamento de componentes visuais reutilizáveis, como o widget `ProdutoCard`.

---

## 💾 Persistência de Dados (Local vs. Nuvem)

Seguindo os requisitos da atividade, os dados foram divididos de acordo com sua sensibilidade e escopo:

1. **Cache Local (Dados Sensíveis e Preferências):**
   * Implementado com a biblioteca `shared_preferences`.
   * Armazena de forma privada e persistente o nome do usuário e as preferências visuais de tema (claro/escuro).
2. **Armazenamento Interno do Dispositivo:**
   * Utilização do `path_provider` para gravar e recuperar o histórico de pedidos em arquivo texto local (`pedidos.txt`) no diretório privado da aplicação.
3. **Armazenamento Externo do Dispositivo:**
   * Função para exportação de relatório de vendas em arquivo `.csv` para a memória externa do aparelho.

---

## 🌐 Serviços Web e Integração de Múltiplas APIs

O aplicativo consome dois serviços web externos simultaneamente:

1. **API RESTful do Cardápio (MockAPI):**
   * **Endpoint:** `https://6adf36788e42963c8d5d9824.mockapi.io/produtos`
   * **Métodos HTTP implementados:**
     * `GET`: Listagem e sincronização do cardápio em tempo real.
     * `PUT`: Atualização de preços de produtos existentes.
     * `POST`: Cadastro de novos itens no cardápio.
     * `DELETE`: Remoção de itens do cardápio.
2. **API de Consulta de Endereço (ViaCEP):**
   * **Endpoint:** `https://viacep.com.br/ws/{cep}/json/`
   * Integrada ao fechamento do carrinho de compras para busca e preenchimento automático de logradouro, bairro e cidade a partir do CEP informado.

---
## 🚀 Como Executar o Projeto

### Pré-requisitos
* Flutter SDK instalado e configurado
* Dispositivo Android conectado via USB ou emulador ativo

### Instalação das dependências
```bash
flutter pub get
```

### Executar em modo de desenvolvimento
```bash
flutter run
```

### Compilar executável de produção (APK Release)
```bash
flutter build apk --release
```

O arquivo instalável é gerado em:  
`build/app/outputs/flutter-apk/app-release.apk`
