# SPEC.md — Sistema Interno de Produção · Famosa Linguiça

Versão: 0.1 (protótipo) · Idioma da interface: pt-BR
Escopo: substituir quatro documentos em papel por quatro telas integradas.
Dados: fictícios, identificados como exemplo. Nenhuma receita, validade ou dado fiscal é inventado pelo sistema.

---

## 1. Objetivo e princípios

1. Uma informação cadastrada em uma etapa é reaproveitada nas seguintes — nunca redigitada.
2. Cada ordem de produção tem identificador único; bateladas, sabores e pedidos mantêm vínculo com ela.
3. Planejado, produzido de fato e destinado ficam sempre separados, para comparação posterior.
4. Toda regra operacional não definida é configurável ou sinalizada como decisão pendente.

---

## 2. Mapa das telas e fluxo de informação

| Tela | Nome | Produz | Consome |
|---|---|---|---|
| 0 | Painel inicial | — | ordens, massadas, pedidos (somente leitura) |
| 1 | Planejamento geral da produção | OP (número, data, responsável, situação) e linhas por sabor com planejado | — |
| 2 | Separação de temperos e massadas | massadas, bateladas, temperos, confirmação de mistura, início e fim de cura | OP e sabores da tela 1 |
| 3 | Ordem de produção por sabor e separação de insumos | insumos por sabor, liberação para embutimento, quantidade embutida | OP e sabores da tela 1 |
| 4 | Ordem de expedição e pedidos de parceiros | pedidos, itens, separação, conservação, encaminhamento ao faturamento | OP e sabores da tela 1; embutido da tela 3 |

