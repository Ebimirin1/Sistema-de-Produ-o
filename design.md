# Design system — Sistema de Produção Famosa Linguiça

Versão 1.0 · 24/09/2026

## Direção visual

Interface operacional clara, direta e legível em computadores e celulares. A identidade usa as cinco cores fornecidas na paleta Adobe Color. Áreas extensas de conteúdo ficam em tons neutros para destacar números, alertas e ações.

## Paleta

| Papel | Cor | Aplicação |
| --- | --- | --- |
| Destaque dourado | `#D99311` | Indicadores de atenção, detalhes de marca e elementos de destaque sobre fundo escuro. Não usar para textos pequenos sobre branco. |
| Vermelho principal | `#D90404` | Botão principal, seleção ativa e destaque pontual. Usar com texto branco apenas em componentes de tamanho adequado e verificar contraste. |
| Vermelho profundo | `#8C0303` | Cabeçalhos, botões principais com texto branco e títulos em fundo claro. |
| Vinho | `#590202` | Barra lateral, navegação e superfícies escuras com texto branco. |
| Quase preto avermelhado | `#260101` | Texto principal, rodapé e fundo de painéis de destaque com texto branco. |

**Neutros de apoio (propostos para a interface):** branco `#FFFFFF` para cartões e campos; fundo `#F8F6F4`; linhas `#E8E1DF`; texto secundário `#5C5150`. Essas cores não integram a paleta original, mas garantem leitura em telas densas.

**Cores funcionais (propostas):** sucesso `#176B45`; informação `#205A85`; atenção usa texto `#4A2C00` em fundo `#FFF2D6`; erro usa texto `#8C0303` em fundo `#FDE8E8`. Nunca depender apenas da cor: escrever também o estado por extenso e, quando útil, usar ícone.

## Tipografia

- **Fonte de identidade:** Ruwudu. Aplicar ao nome do sistema e a títulos curtos, com pesos disponíveis na família. Testar os caracteres do português na implementação.
- **Fonte de interface:** `system-ui, Arial, sans-serif` em tabelas, formulários, etiquetas, botões e textos longos. Facilita a leitura de lotes, datas, pesos e números de ordens.
- Título da página: 28–32 px; seção: 20–24 px; texto e campos: 16 px; informação secundária: 14 px. Entrelinha de 1,4 a 1,5.
- Números em tabelas alinhados à direita; unidades sempre visíveis (`kg`, `g`, `un`). Datas no formato brasileiro (`dd/mm/aaaa`).

## Componentes

| Componente | Regra |
| --- | --- |
| Barra lateral | Fundo `#590202`, texto branco; página ativa identificada também por faixa lateral e rótulo em destaque. |
| Cabeçalho | Título claro, identificação da ordem ou do setor e ações principais à direita. |
| Botão principal | Fundo `#8C0303`, texto branco, altura mínima de 44 px; para confirmar ações críticas, explicitar o verbo: “Liberar embutimento”. |
| Botão secundário | Fundo branco, texto `#590202`, borda `#590202`. |
| Campos | Rótulo acima, borda neutra, ajuda e erro abaixo; foco com contorno visível. Nunca usar somente placeholder como rótulo. |
| Cartões | Fundo branco, borda sutil, raio de 8 px; mostrar título, valor, unidade e referência temporal. |
| Tabelas | Cabeçalho fixo quando houver rolagem; filtros por data, situação, ordem e sabor; valores numéricos alinhados à direita. |
| Confirmações | Informar o que vai mudar, qual ordem será afetada e permitir cancelar antes de gravar. |

## Telas e informações prioritárias

1. **Ordens de produção:** número, data, situação, sabores e totais planejados, produzidos e embutidos.
2. **Massadas e bateladas:** peso de carne, temperos, peso total, limite de capacidade, início e previsão de término da cura.
3. **Insumos e embutimento:** separado, necessário, entregue, responsável e bloqueios para liberação.
4. **Pedidos e expedição:** parceiro, conservação, quantidade solicitada, separada e saldo; distinguir “separado” de “encaminhado ao faturamento”.

Em telas estreitas, substituir tabelas extensas por cartões de registro sem ocultar número da ordem, situação, quantidade e ação principal.

## Estados operacionais

Exibir **texto + cor + ação possível**. Exemplos: “Rascunho”, “Planejada”, “Em produção”, “Concluída” e “Cancelada”. A condição “Em cura” deve mostrar o horário de início e o prazo previsto. Uma pendência de insumos deve indicar qual insumo falta e a quantidade; um bloqueio de batelada deve mostrar o limite e o peso calculado. Reservar o vermelho vivo para ações ou problemas relevantes, evitando uma tela inteira de alertas vermelhos.

## Tokens CSS iniciais

```css
:root {
  --brand-gold: #D99311;
  --brand-red: #D90404;
  --brand-red-dark: #8C0303;
  --brand-wine: #590202;
  --brand-ink: #260101;
  --surface: #FFFFFF;
  --page: #F8F6F4;
  --border: #E8E1DF;
  --text: #260101;
  --text-muted: #5C5150;
  --success: #176B45;
  --info: #205A85;
  --font-brand: 'Ruwudu', Georgia, serif;
  --font-ui: system-ui, Arial, sans-serif;
  --radius: 8px;
}
```

## Entrega para a etapa de protótipo

Fornecer este arquivo `design.md` com `spec.md` e os requisitos de cada tela. Solicitar que o protótipo siga os tokens, use Ruwudu nos títulos curtos e mantenha legíveis os dados de produção e expedição.
