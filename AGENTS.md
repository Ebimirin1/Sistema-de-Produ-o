# Instruções para agentes de código — Sistema de Produção

Este repositório contém um aplicativo interno de produção. Leia este arquivo antes de planejar ou alterar código. Use `spec.md`, `spec2.md.txt`, `task.md`, `design.md` e os arquivos SQL existentes como fontes de requisitos; confira quais deles realmente existem e registre divergências antes de decidir. Não invente regras de produção.

## Estado conhecido e objetivo

- O frontend é estático (HTML, CSS e JavaScript), destinado ao GitHub Pages. O backend é Supabase (PostgreSQL, Auth e API). Não introduza servidor obrigatório de Express, FastAPI ou similar.
- A Tela 1 (ordens de produção e sabores) já foi testada pelo usuário com login e dados reais no Supabase: uma OP de teste com quatro sabores, total de 165 kg. Preserve esse fluxo e não recrie a OP de teste.
- `supabase_migration.sql` criou 14 tabelas com RLS ativo e duas views. `supabase_policies.sql` contém acesso para o usuário autorizado somente a `ordem_producao` e `ordem_sabor`, além da função de gravação atômica. Confira os arquivos atuais, pois podem ter evoluído.
- O usuário configurou URL e chave **pública/publishable** em uma cópia local do `index.html`, fora do Jules. Não suponha que esses valores estão no repositório. Nunca peça a senha do usuário.
- Meta: todas as telas descritas nas especificações devem ser navegáveis e, quando marcadas como prontas, usar dados reais e permissões adequadas. A entrega parcial deve indicar claramente o que ainda falta.

## Prioridade de trabalho

1. **P0 — Segurança e integridade:** preserve login e RLS; corrija exposição de dados, gravações parciais, erros de relacionamento, SQL incompatível e regressões da Tela 1 antes de novas funções. Não coloque `service_role`, chaves secretas, senha, token ou string de conexão no frontend, commits ou mensagens. Chaves publishable podem ser públicas, mas não substituem RLS. Não crie políticas anônimas amplas nem `USING (true)` para liberar tabelas de produção.
2. **P1 — Caminho completo da operação:** implemente menu e navegação, depois as telas pendentes conforme a ordem e dependências descritas na especificação: preparação/separação de temperos e recebimento, produção/embutimento e expedição/pedidos. Para cada tela, entregue leitura, validação, gravação e retorno de erros reais antes de marcar como concluída. Confira nomes de tabelas e campos existentes; use migrações incrementais quando necessário.
3. **P2 — Clareza e acabamento:** corrija o aviso de configuração do Supabase para aparecer apenas quando faltarem valores válidos; ajuste acessibilidade, visual para celular e textos. Mantenha as decisões D-04 (seleção de colaborador sem fingir assinatura), D-05 (diferença de peso informativa, sem bloqueio e sem tolerância presumida) e D-06 ("Cliente de atacado" em pedidos/expedição).

## Método de implementação

- Trabalhe em incrementos revisáveis. Antes de codificar, identifique o próximo fluxo incompleto mais crítico pelas especificações e pelo estado real do código. Não pare apenas em uma proposta de plano: implemente o incremento solicitado, valide e relate o resultado.
- Ao terminar um fluxo, confira que ele é acessível pelo menu, que persiste dados onde aplicável, que o estado reaparece após recarregar a página e que erros são mostrados sem expor informações sensíveis. Não apresente dados fictícios como dados do banco.
- Para gravações em mais de uma tabela, prefira transação/função no banco; não deixe uma etapa salva pela metade. Faça validação no banco, não apenas no navegador. Evite HTML injetado a partir de dados de usuários.
- Para tabelas adicionais, prepare SQL separado e incremental com políticas RLS mínimas para o usuário autenticado autorizado; confira compatibilidade com o esquema existente. Views devem respeitar RLS (`security_invoker` quando aplicável). Não execute SQL no Supabase remoto. Explique ao usuário a ordem exata de execução e as verificações de leitura antes de qualquer migração.
- Não execute operações destrutivas (`DROP TABLE`, limpeza de dados, sobrescrita de produção) nem publique o GitHub Pages durante uma tarefa de implementação. Dados internos de produção não devem ficar embutidos no HTML público.
- Valide sintaxe do JavaScript e do SQL com ferramentas disponíveis; teste a navegação e os fluxos alterados com dados locais/mocks identificados, sem afirmar que houve teste remoto se não houve. Evite testes que espelham a implementação sem verificar comportamento.

## Registro e entrega no GitHub

- Mantenha `docs/PROGRESSO.md` atualizado em cada tarefa com: funcionalidades concluídas, telas pendentes, SQL ainda não aplicado no Supabase, testes executados e impedimentos. Crie o arquivo se não existir.
- Faça commits claros em uma branch de trabalho. Ao fim da tarefa, use a opção disponível no Jules para **Publish PR** (ou **Publish branch**, caso PR não esteja disponível), para que o código fique no GitHub e seja revisável. Informe o link da PR/branch e o commit. Não confunda arquivo baixado em ZIP com atualização do GitHub.
- Não faça merge automático em `main` nem ative publicação automática do Pages para código ou SQL ainda não revisado. A aplicação da migração no banco e o merge da PR são etapas separadas.
- Se o ambiente não permitir publicar a branch ou PR, relate isso de forma explícita e mostre o botão/ação que o usuário deve executar. Não diga que o GitHub foi atualizado sem confirmar a publicação.

## Resposta ao usuário

Explique em português simples: o que passou a funcionar, onde clicar para testar, qual SQL precisa de revisão e execução, o que permanece pendente e se a mudança já está no GitHub (branch/PR ou apenas na sessão do Jules).
