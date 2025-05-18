# 🩺 TouchScreening - App de Triagem e Anamnese para a UPA de Tucuruí

TouchScreening é um aplicativo mobile desenvolvido para modernizar e otimizar o processo de triagem e anamnese na **Unidade de Pronto Atendimento (UPA) de Tucuruí - PA**, visando reduzir o tempo de espera, aumentar a eficiência da equipe de enfermagem e proporcionar um atendimento mais digno e ágil à população.

---

## 🎯 Objetivo do Projeto

O projeto tem como missão:

- Facilitar o registro digital da anamnese dos pacientes no momento da triagem.
- Substituir os formulários manuais por um sistema acessível, rápido e seguro.
- Auxiliar enfermeiros na classificação dos pacientes com base no **Protocolo de Manchester**.
- Melhorar a organização interna e o histórico dos atendimentos prestados na unidade.

---

## 🧰 Tecnologias Utilizadas

- **Flutter** — Framework multiplataforma para desenvolvimento de apps nativos Android e iOS.
- **Firebase Authentication** — Autenticação segura para controle de acesso dos profissionais.
- **Cloud Firestore** — Banco de dados em tempo real para armazenar as fichas de pacientes.
- **Provider** — Gerenciamento de estado do aplicativo.
- **flutter_tts** — Integração de acessibilidade com leitura por voz (Texto para Fala).
- **Material Design** — Interface limpa, responsiva e adaptada ao ambiente hospitalar.

---

## 📋 Funcionalidades Implementadas

- Autenticação de enfermeiros (Login e Cadastro).
- Registro completo de ficha de anamnese com:
  - Identificação do paciente (nome, data de nascimento, idade, sexo, RG/CPF, SUS, endereço, mãe).
  - Informações clínicas (sintomas, alergias, peso, nível e origem da dor).
  - Classificação de risco (prioridade) com base na cor (Manchester).
- Listagem de atendimentos ativos e finalizados.
- Marcar ficha como concluída.
- Leitura por voz ao abrir o formulário (acessibilidade).
- Responsividade e usabilidade com foco em simplicidade e rapidez.

---

## 🚀 Como executar

Clone o repositório:

```bash
git clone https://github.com/seu-usuario/touchscreening.git
cd touchscreening
