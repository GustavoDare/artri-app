# Testes das Features do Aplicativo ARTRI
Link do vídeo sobre os testes: [Testes das Features do Aplicativo ARTRI - Disciplina de Desenvolvimento Móvel](https://www.youtube.com/watch?v=pKiHctmmCEU)

## 1) Bugs Identificados
**Tela de Login**
- O botão "Esqueci minha senha" não tem nenhuma ação;
- Usuários não cadastrados ou senha incorretas são impedidos de entrar, porém não é devolvido nenhum aviso na tela a respeito do erro de digitação.

**Tela de Cadastro**
- O botão "Enviar" não possui nenhuma ação;
- O botão de voltar nativo da tela não tem nenhuma ação.

**Navegação**
- O atalho de "voltar" do celular fecha o aplicativo de forma abrupta quando utilizado nas páginas "Evolução", "Informações", "Exercício", "Diário", "Configurações" e "Medicamentos".

**Tela Medicamentos"
- Não possui nenhum botão na interface para voltar à página inicial;
- Não é possível adicionar novos medicamentos na lista;
- Não existe a possibilidade de fornecer/salvar mais detalhes e informações osbre dose e horário de um remédio.

**Tela de Configurações**
- Para sair das "Configurações", é necessário clicar novamente no ícone de engrenagem ou em algum ícone da barra inferior, fugindo do padrão de navegação de retorno;
- Tanto o botão "Alterar Email" como o botão "Alterar Senha" levam para uma nova página, mas não implementam a funcionalidade;
- Quando o usuário entra nas páginas de alteração de e-mail ou senha, não há botão de voltar na interface, e usar o atalho de voltar do celular fecha o aplicativo;
- O botão "Permissões" não foi implementado.

**Tela Inicial e Avaliações**
- Na página inicial, não é possível habilitar ou desabilitar a caixa de quiz de "mitos e verdades";
- Os botões de interrogação ao lado dos títulos nas avaliações e na página inicial não possuem ação;
- A rolagem da página trava e não funciona quando o usuário toca dentro das áreas de "regiões das dores" e nas áreas de notas das "avaliações";
- Para conseguir rolar a tela de avaliação de dores, é necessário arrastar o dedo pelas bordas do aparelho ou na área superior;
- O botão "Salvar" nas avaliações de dor não tem ação: ele não salva o valor, não exibe mensagem de preenchimento e não limpa os valores previamente selecionados;
- Não é exibida nenhuma mensagem pedindo para o usuário completar as avalliações de todas as regiões caso ele tente salvar com dados faltando;
- As avaliações de Fadiga, Sono e Inchaço possuem exatamente os mesmo problemas e bugs de salvamento e botões (?) sem ação identificados na avaliação de dores.

**Tela de Evolução**
- A página "Evolução" já aparece preenchida com valores de dor e fadiga no gráfico, mesmo quando o usuário não forneceu nenhum valor;
- O valor de dor fornecido legitimamente pelo usuário na avaliação não é enviado nem atualizado no gráfico;
- O valor da avaliação de fadiga também não é computado e nem enviado para o gráfico.

**Tela Exercícios**
- O botão principal "Exercícios" na home não foi implementado;
- Os ícones de "Play" na lista de exercícios não possuem interação com o usuário, respondendo apenas quando se clica no texto à frente deles;
- Para conseguir iniciar a série de exercícios, o usuário é obrigado a clicar duas vezes no botão "Começar" (uma para abrir o aviso, e outra para abrir a série de fato);
- Ao voltar para um exercício já marcado como "FEITO", o ícone fica verde claro, mas o botão perde sua função e não é mais possível clicar em "FEITO" novamente para prosseguir;
- Mesmo sem ter marcado todos os exercícios anteriores da série como "FEITO", o usuário é indevidamente direcionado para a tela de "Parabéns" ao simplesmente passar pelo último exercício;
- Ao clicar no botão de voltar durante um exercício, a lista não é finalizada. Em vez disso, o processo fica salvo pela metade, exigindo clicar novamente duas vezes em "Começar" para retornar;
- O botão de tela cheia no player de vídeo força o aplicativo a ficar no modo horizontal;
- Ao tentar sair do vídeo em tela cheia pelo sistema, o app não volta ao modo vertical automaticamente, exigindo que o usuário clique obrigatoriamente no botão de minimizar no próprio player;
- Alguns vídeos nas listas Intermediário e Avançado não estão disponíveis para visualização;
- Há uma troca de conteúdos incorreta: a página "Relaxamento Guiado" exibe vídeos de respiração, enquanto a página "Técnicas de Respiração" exibe, erroneamente, vídeos de exercícios de mãos;
- As listas Iniciante, Intermediário e Avançado dos exercícios para Pés sofrem de todos os bugs de interface, player e salvamento já identificados na lista de Mãos.  

## 2) Potenciais Problemas (UX/UI)
- O texto do botão "Informações sobre atividadee físicas" possui quebra incorreta e está sendo exibido cortado na interface;
- O título da página de categoria de exercícios físicos encontra-se cortado na barra superior;
- O título da página individual do exercício também não é exibido de forma completa no cabeçalho;
- O gráfico da página "Evolução" não fornece a opção de selecionar qual a região específica do corpo daquela dor está sendo avaliada;
- A página de "Evolução" restringe a visualização gráfica apenas para 'Dor' e 'Fadiga', não deixando disponíveis os parâmetros de acompanhamento de 'Sono' e 'Inchaço' inseridos no diário;
- Inconsistência visual de interface: os títulos de todas as páginas ramificadas de "Informações" possuem uma formatação de fonte e estilo diferente das demais telas do aplicativo.

## 3) Sugestões de Melhoria
- Retirar da lista os exercícios que já foram concluídos e marcados como "FEITO" pode gerar menos confusão para o usuário ao tentar dar prosseguimento na atividade;
- Rever a altura dos textos informativos nos exercícios de Pés, pois as instruções longas geram barra de rolagem na página, o que pode causar desconforto durante o uso do app;
- Alguns quizzes de "Mitos e Verdades" possuem tamanho diferentes e geram rolagem no layout da página inicial quando interagem, o que pode gerar incômodo e prejudicar a experiência visual.
