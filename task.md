# TASK.md — Plano de execução · Sistema Interno de Produção · Famosa Linguiça

Referências: `SPEC.md` (requisitos) e `SCHEMA.sql` (modelo de dados).
Estado atual: protótipo funcional em `index.html` com as quatro telas e dados fictícios.
Objetivo deste arquivo: transformar o protótipo em sistema interno utilizável pela empresa.

Legenda: `[ ]` pendente · `[~]` em andamento · `[x]` concluído no protótipo

---

## FASE 0 — Decisões de negócio (bloqueiam a Fase 3)

- [ ] **D-01** Fator de conversão de temperos em `ml` e `un` para o peso da batelada (ou decisão de não contar).
- [ ] **D-02** Regra de validade e rastreabilidade dos produtos.
- [ ] **D-03** Dados fiscais, preços e regra de faturamento.
- [ ] **D-04** Lista oficial de colaboradores e papéis (quem separa, quem recebe na mexedeira, quem libera).
- [ ] **D-05** Tolerância aceitável de diferença entre planejado e embutido.
- [ ] **D-06** Nomenclatura definitiva do parceiro (fornecedor | comprador | cliente de atacado).

> Nenhuma dessas decisões foi presumida no código. Fator de conversão, validade e fiscal seguem fora do sistema até D-01/D-02/D-03.

---

## FASE 1 — Base técnica

- [x] **T-1.1** Protótipo navegável com as quatro telas + painel inicial + configurações.
- [x] **T-1.2** Persistência local com exportar/importar JSON.
- [x] **T-1.3** Schema relacional consolidado (`SCHEMA.sql`) com views e triggers.
- [ ] **T-1.4** Escolher banco e hospedagem (SQLite + servidor estático para piloto; PostgreSQL para produção).
- [ ] **T-1.5** Migrar as regras das views para a API; front passa a ler do backend.
- [ ] **T-1.6** Autenticação simples (usuário/senha) e sessão.
- [ ] **T-1.7** Registrar `usuario` em toda linha de histórico.

---

## FASE 2 — Requisitos por tela

### Tela 1 — Planejamento geral da produção
- [x] **T-2.1** Criar OP com número único, data, responsável e situação.
- [x] **T-2.2** Bloquear número de OP duplicado.
- [x] **T-2.3** Linhas por sabor e total planejado automático.
- [x] **T-2.4** Separar planejado × produzido de fato × destinado.
- [x] **T-2.5** Produção parcial sem apagar o planejado.
- [ ] **T-2.6** Paginação/ordenação para ordens com muitos sabores.
- [ ] **T-2.7** Bloquear exclusão de OP com etapas posteriores (hoje só avisa).

### Tela 2 — Separação de temperos e massadas
- [x] **T-2.8** Massada vinculada à OP e ao sabor.
- [x] **T-2.9** Bateladas com limite de 150 kg somando carne + temperos.
- [x] **T-2.10** Última batelada menor permitida.
- [x] **T-2.11** Alertar excesso de peso e impedir confirmação da mistura.
- [x] **T-2.12** Ficha técnica cadastrada ou temperos manuais.
- [x] **T-2.13** Confirmação da mistura e cálculo do fim da cura (início + 12 h).
- [x] **T-2.14** Avisar quando a unidade não é convertível, sem presumir fator.
- [ ] **T-2.15** Cadastro de fichas técnicas pela interface (hoje só a ficha de exemplo).
- [ ] **T-2.16** Alerta de cura concluída / vencida no painel.

### Tela 3 — Sabores e separação de insumos
- [x] **T-2.17** Planejado, produzido de fato e embutido por sabor.
- [x] **T-2.18** Insumos com unidade própria, necessário, separado, responsável e confirmação de entrega.
- [x] **T-2.19** Pendência bloqueia liberação para embutimento.
- [x] **T-2.20** Diferença entre embutido e planejado.
- [ ] **T-2.21** Puxar insumos automaticamente da ficha técnica do sabor.
- [ ] **T-2.22** Guardar insumos por sabor no banco (hoje em memória da tela).

### Tela 4 — Expedição e pedidos de parceiros
- [x] **T-2.23** Termo do parceiro configurável.
- [x] **T-2.24** Pedido com número, parceiro, data, destino, responsável, situação e observações.
- [x] **T-2.25** Itens por sabor com solicitado, separado e diferença pendente.
- [x] **T-2.26** Disponibilidade real descontando o já reservado por outros pedidos.
- [x] **T-2.27** Bloquear separação acima do disponível.
- [x] **T-2.28** Saldo Empório do que não foi destinado.
- [x] **T-2.29** Conservação resfriado/congelado/a definir.
- [x] **T-2.30** Separar visualmente recebido / separado / encaminhado ao faturamento.
- [ ] **T-2.31** Exportar o resumo de faturamento em CSV para o setor responsável.
- [ ] **T-2.32** Baixa de estoque a partir do item separado.

---

## FASE 3 — Integração, impressão e qualidade

- [x] **T-3.1** Identificador único da OP como amarração entre as quatro telas.
- [x] **T-3.2** Confirmação obrigatória antes de alterar quantidade já usada adiante.
- [x] **T-3.3** Histórico de alterações com data, texto e origem.
- [x] **T-3.4** Validações de negativos, batelada ≤ 150 kg e separação ≤ disponível.
- [x] **T-3.5** Painel com andamento das ordens e pendências por setor.
- [x] **T-3.6** Layout de desktop com responsividade para celular.
- [x] **T-3.7** Impressão dos quatro documentos com cabeçalho de OP.
- [ ] **T-3.8** Testes dos critérios de aceite de `SPEC.md` seção 8.
- [ ] **T-3.9** Backup automático diário do banco.
- [ ] **T-3.10** Log de acesso e trilha de auditoria por usuário.

---

## FASE 4 — Implantação

- [ ] **T-4.1** Piloto em uma semana de produção real, em paralelo ao papel.
- [ ] **T-4.2** Treinamento por setor: planejamento, temperos, insumos e expedição.
- [ ] **T-4.3** Definir responsável interno pelo sistema.
- [ ] **T-4.4** Aposentar os formulários em papel após o piloto estável.

---

## Riscos

| Risco | Efeito | Mitigação |
|---|---|---|
| D-01 indefinida | Batelada calculada errada para temperos em ml | Manter alerta; não somar até haver decisão |
| D-02/D-03 indefinidas | Produto sem validade ou nota | Fora do escopo até decisão formal |
| Ficha técnica incompleta | Insumos digitados à mão e erros | Cadastro de fichas por sabor na T-2.15 |
| Duas pessoas editando a mesma OP | Divergência de números | Bloqueio por registro na T-1.5 |
| Perda de dados no protótipo | Retrabalho | Exportação JSON + backup na T-3.9 |

---

## Ordem sugerida de execução

1. Fechar D-01 e D-04 (destravam o cálculo da batelada e os responsáveis).
2. T-1.4 → T-1.5 → T-1.6 (banco, API, login).
3. T-2.15, T-2.21, T-2.22, T-2.31 (fecham lacunas funcionais).
4. T-3.8 e T-3.9 (teste e backup).
5. Fase 4 em piloto paralelo ao papel.
