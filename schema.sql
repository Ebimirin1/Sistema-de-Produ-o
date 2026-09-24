-- ============================================================
-- SCHEMA.sql — Sistema Interno de Produção · Famosa Linguiça
-- Compatível com SQLite (protótipo) e adaptável a MySQL/PostgreSQL.
-- Dados de exemplo marcados como fictícios.
-- ============================================================

PRAGMA foreign_keys = ON;

-- ------------------------------------------------------------
-- CONFIGURAÇÃO (regras que o pedido deixou em aberto)
-- ------------------------------------------------------------
CREATE TABLE configuracao (
  chave         TEXT PRIMARY KEY,
  valor         TEXT NOT NULL,
  descricao     TEXT
);

INSERT INTO configuracao (chave, valor, descricao) VALUES
 ('empresa',                'Famosa Linguiça', 'Nome exibido no cabeçalho'),
 ('capacidade_batelada_kg', '150',             'Máximo somando carne + temperos'),
 ('horas_cura',             '12',              'Horas de cura da massa'),
 ('termo_parceiro',         'fornecedor',      'fornecedor | comprador | cliente de atacado'),
 ('versao_prototipo',       '0.1',             'Versão do protótipo');

-- ------------------------------------------------------------
-- ORDEM DE PRODUÇÃO (Tela 1)
-- ------------------------------------------------------------
CREATE TABLE ordem_producao (
  id             TEXT PRIMARY KEY,              -- identificador único (ex.: OP-2026-001)
  numero         TEXT NOT NULL UNIQUE,
  data           DATE NOT NULL,
  responsavel    TEXT,
  situacao       TEXT NOT NULL DEFAULT 'Rascunho'
                 CHECK (situacao IN ('Rascunho','Planejada','Em produção','Concluída','Cancelada')),
  observacoes    TEXT,
  criado_em      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  atualizado_em  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- SABORES da ordem (planejado × produzido × embutido)
CREATE TABLE ordem_sabor (
  id             TEXT PRIMARY KEY,
  ordem_id       TEXT NOT NULL REFERENCES ordem_producao(id) ON DELETE CASCADE,
  nome           TEXT NOT NULL,
  planejado_kg   REAL NOT NULL DEFAULT 0 CHECK (planejado_kg >= 0),
  produzido_kg   REAL NOT NULL DEFAULT 0 CHECK (produzido_kg >= 0), -- produção real, parcial permitida
  embutido_kg    REAL NOT NULL DEFAULT 0 CHECK (embutido_kg >= 0),  -- vem da Tela 3
  liberado       INTEGER NOT NULL DEFAULT 0,                        -- 1 = liberado para embutimento
  atualizado_em  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX ix_ordem_sabor_ordem ON ordem_sabor(ordem_id);

-- ------------------------------------------------------------
-- FICHA TÉCNICA (por sabor — nenhuma proporção é inventada)
-- ------------------------------------------------------------
CREATE TABLE ficha_tecnica (
  id          TEXT PRIMARY KEY,
  sabor_nome  TEXT NOT NULL,
  origem      TEXT,            -- ex.: 'Exemplo do enunciado (ilustrativo)'
  observacao  TEXT,
  criado_em   TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE ficha_tecnica_item (
  id           TEXT PRIMARY KEY,
  ficha_id     TEXT NOT NULL REFERENCES ficha_tecnica(id) ON DELETE CASCADE,
  insumo       TEXT NOT NULL,
  unidade      TEXT NOT NULL CHECK (unidade IN ('kg','g','ml','un')),
  base_kg      REAL NOT NULL DEFAULT 10 CHECK (base_kg > 0), -- base da proporção
  quantidade   REAL NOT NULL CHECK (quantidade >= 0),        -- quantidade por base_kg
  categoria    TEXT
);
CREATE INDEX ix_ficha_item_ficha ON ficha_tecnica_item(ficha_id);

-- Exemplo apenas ilustrativo (valores informados no pedido)
INSERT INTO ficha_tecnica (id, sabor_nome, origem, observacao) VALUES
 ('FT-001','Linguiça de gorgonzola e mel (EXEMPLO)','Exemplo do enunciado',
  'Valores ilustrativos. Não aplicar a outros sabores sem cadastro próprio.');

INSERT INTO ficha_tecnica_item (id, ficha_id, insumo, unidade, base_kg, quantidade, categoria) VALUES
 ('FTI-001','FT-001','Gorgonzola','kg',10, 1.0,'Queijo'),
 ('FTI-002','FT-001','Mel',       'ml',10, 200,'Complemento');

-- ------------------------------------------------------------
-- MASSADA e BATELADAS (Tela 2)
-- ------------------------------------------------------------
CREATE TABLE massada (
  id             TEXT PRIMARY KEY,
  ordem_id       TEXT NOT NULL REFERENCES ordem_producao(id) ON DELETE CASCADE,
  ordem_sabor_id TEXT REFERENCES ordem_sabor(id) ON DELETE SET NULL,
  data           DATE NOT NULL,
  resp_separacao TEXT,
  resp_mexedeira TEXT,        -- responsável pelo recebimento na mexedeira
  criado_em      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX ix_massada_ordem ON massada(ordem_id);

CREATE TABLE batelada (
  id                 TEXT PRIMARY KEY,
  massada_id         TEXT NOT NULL REFERENCES massada(id) ON DELETE CASCADE,
  data               DATE NOT NULL,
  carne_kg           REAL NOT NULL DEFAULT 0 CHECK (carne_kg >= 0),
  resp_separacao     TEXT,
  resp_mexedeira     TEXT,
  mistura_confirmada INTEGER NOT NULL DEFAULT 0,
  inicio_cura        TIMESTAMP,       -- informado pelo usuário
  fim_cura_previsto  TIMESTAMP,       -- inicio_cura + horas_cura
  criado_em          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CHECK (carne_kg <= (SELECT CAST(valor AS REAL) FROM configuracao WHERE chave='capacidade_batelada_kg'))
);
CREATE INDEX ix_batelada_massada ON batelada(massada_id);

CREATE TABLE batelada_tempero (
  id          TEXT PRIMARY KEY,
  batelada_id TEXT NOT NULL REFERENCES batelada(id) ON DELETE CASCADE,
  nome        TEXT NOT NULL,
  unidade     TEXT NOT NULL CHECK (unidade IN ('kg','g','ml','un')),
  quantidade  REAL NOT NULL CHECK (quantidade >= 0),
  origem      TEXT,   -- 'manual' | 'Ficha FT-001 (sabor)'
  somavel_kg  INTEGER NOT NULL DEFAULT 0  -- 1 quando unidade de massa
);
CREATE INDEX ix_bat_tempero_bat ON batelada_tempero(batelada_id);

-- ------------------------------------------------------------
-- INSUMOS POR SABOR (Tela 3)
-- ------------------------------------------------------------
CREATE TABLE sabor_insumo (
  id             TEXT PRIMARY KEY,
  ordem_sabor_id TEXT NOT NULL REFERENCES ordem_sabor(id) ON DELETE CASCADE,
  nome           TEXT NOT NULL,
  unidade        TEXT NOT NULL CHECK (unidade IN ('kg','g','ml','un')),
  necessario     REAL NOT NULL DEFAULT 0 CHECK (necessario >= 0),
  separado       REAL NOT NULL DEFAULT 0 CHECK (separado >= 0),
  responsavel    TEXT,
  entregue       INTEGER NOT NULL DEFAULT 0,  -- confirmação de entrega à produção
  atualizado_em  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX ix_sabor_insumo_sabor ON sabor_insumo(ordem_sabor_id);

-- ------------------------------------------------------------
-- EXPEDIÇÃO — PARCEIRO e PEDIDOS (Tela 4)
-- ------------------------------------------------------------
CREATE TABLE parceiro (
  id        TEXT PRIMARY KEY,
  nome      TEXT NOT NULL,
  tipo      TEXT NOT NULL DEFAULT 'fornecedor'
            CHECK (tipo IN ('fornecedor','comprador','cliente de atacado')),
  destino   TEXT
);

CREATE TABLE pedido (
  id             TEXT PRIMARY KEY,
  numero         TEXT NOT NULL UNIQUE,
  parceiro_id    TEXT REFERENCES parceiro(id) ON DELETE SET NULL,
  parceiro_nome  TEXT NOT NULL,               -- preserva o nome usado no pedido
  data           DATE NOT NULL,
  destino        TEXT,
  responsavel    TEXT,
  situacao       TEXT NOT NULL DEFAULT 'Recebido'
                 CHECK (situacao IN ('Recebido','Separado','Encaminhado ao faturamento','Atendido','Cancelado')),
  conservacao    TEXT CHECK (conservacao IN ('Resfriado','Congelado','A definir')),
  observacoes    TEXT,
  encaminhado_em TIMESTAMP,                   -- momento do envio ao faturamento
  criado_em      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE pedido_item (
  id             TEXT PRIMARY KEY,
  pedido_id      TEXT NOT NULL REFERENCES pedido(id) ON DELETE CASCADE,
  ordem_id       TEXT NOT NULL REFERENCES ordem_producao(id),
  ordem_sabor_id TEXT NOT NULL REFERENCES ordem_sabor(id),
  solicitado_kg  REAL NOT NULL DEFAULT 0 CHECK (solicitado_kg >= 0),
  separado_kg    REAL NOT NULL DEFAULT 0 CHECK (separado_kg >= 0),
  conservacao    TEXT CHECK (conservacao IN ('Resfriado','Congelado','A definir')),
  reservado_em   TIMESTAMP,                   -- quando entrou na reserva de disponibilidade
  atualizado_em  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX ix_pedido_item_pedido ON pedido_item(pedido_id);
CREATE INDEX ix_pedido_item_sabor  ON pedido_item(ordem_sabor_id);

-- ------------------------------------------------------------
-- HISTÓRICO DE ALTERAÇÕES (RF-05.3)
-- ------------------------------------------------------------
CREATE TABLE historico (
  id            INTEGER PRIMARY KEY AUTOINCREMENT,
  quando        TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  usuario       TEXT,
  entidade      TEXT NOT NULL,   -- 'ordem_producao' | 'ordem_sabor' | 'batelada' | 'pedido' | ...
  entidade_id   TEXT,
  campo         TEXT,
  valor_antes   TEXT,
  valor_depois  TEXT,
  texto         TEXT NOT NULL    -- descrição legível
);
CREATE INDEX ix_historico_entidade ON historico(entidade, entidade_id);

-- ------------------------------------------------------------
-- VIEWS — as fórmulas de integração em um só lugar
-- ------------------------------------------------------------

-- Planejado, produzido, embutido, destinado e saldo por sabor
CREATE VIEW vw_disponibilidade_sabor AS
SELECT
  os.id                                   AS ordem_sabor_id,
  os.ordem_id,
  op.numero                               AS ordem_numero,
  os.nome                                 AS sabor,
  os.planejado_kg,
  os.produzido_kg,
  os.embutido_kg,
  COALESCE(SUM(pi.separado_kg), 0)        AS destinado_kg,
  MAX(os.embutido_kg - COALESCE(SUM(pi.separado_kg), 0), 0) AS disponivel_kg,
  MAX(os.embutido_kg - COALESCE(SUM(pi.separado_kg), 0), 0) AS saldo_emporio_kg,
  os.embutido_kg - os.planejado_kg         AS diferenca_kg
FROM ordem_sabor os
JOIN ordem_producao op ON op.id = os.ordem_id
LEFT JOIN pedido_item pi ON pi.ordem_sabor_id = os.id
GROUP BY os.id;

-- Totais por ordem de produção (Tela 1)
CREATE VIEW vw_resumo_ordem AS
SELECT
  op.id,
  op.numero,
  op.data,
  op.responsavel,
  op.situacao,
  SUM(v.planejado_kg)  AS total_planejado_kg,
  SUM(v.produzido_kg)  AS total_produzido_kg,
  SUM(v.embutido_kg)   AS total_embutido_kg,
  SUM(v.destinado_kg)  AS total_destinado_kg,
  SUM(v.saldo_emporio_kg) AS total_saldo_emporio_kg
FROM ordem_producao op
LEFT JOIN vw_disponibilidade_sabor v ON v.ordem_id = op.id
GROUP BY op.id;

-- Peso da batelada: carne + temperos de massa
CREATE VIEW vw_batelada_peso AS
SELECT
  b.id                          AS batelada_id,
  b.massada_id,
  m.ordem_id,
  b.carne_kg,
  COALESCE(SUM(CASE WHEN bt.somavel_kg = 1
                    THEN CASE bt.unidade WHEN 'kg' THEN bt.quantidade
                                         WHEN 'g'  THEN bt.quantidade / 1000.0
                                         ELSE 0 END
                    ELSE 0 END), 0) AS temperos_kg,
  b.carne_kg + COALESCE(SUM(CASE WHEN bt.somavel_kg = 1
                    THEN CASE bt.unidade WHEN 'kg' THEN bt.quantidade
                                         WHEN 'g'  THEN bt.quantidade / 1000.0
                                         ELSE 0 END
                    ELSE 0 END), 0) AS peso_total_kg
FROM batelada b
JOIN massada m ON m.id = b.massada_id
LEFT JOIN batelada_tempero bt ON bt.batelada_id = b.id
GROUP BY b.id;

-- Pendência de insumos por sabor (bloqueia liberação para embutimento)
CREATE VIEW vw_pendencia_insumo AS
SELECT
  os.id                AS ordem_sabor_id,
  os.ordem_id,
  os.nome              AS sabor,
  COUNT(si.id)                                             AS total_insumos,
  SUM(CASE WHEN si.entregue = 0
             OR si.separado < si.necessario THEN 1 ELSE 0 END) AS insumos_pendentes
FROM ordem_sabor os
LEFT JOIN sabor_insumo si ON si.ordem_sabor_id = os.id
GROUP BY os.id;

-- Pedidos ainda não atendidos
CREATE VIEW vw_pedido_pendente AS
SELECT
  p.id,
  p.numero,
  p.parceiro_nome,
  p.situacao,
  SUM(pi.solicitado_kg)                                  AS solicitado_kg,
  SUM(pi.separado_kg)                                    AS separado_kg,
  SUM(pi.solicitado_kg) - SUM(pi.separado_kg)            AS pendente_kg
FROM pedido p
LEFT JOIN pedido_item pi ON pi.pedido_id = p.id
WHERE p.situacao IN ('Recebido','Separado','Encaminhado ao faturamento')
GROUP BY p.id;

-- Resumo para faturamento (informação, nunca faturamento automático)
CREATE VIEW vw_resumo_faturamento AS
SELECT
  p.numero           AS pedido,
  p.parceiro_nome    AS parceiro,
  os.nome            AS produto,
  pi.separado_kg     AS quantidade_separada_kg,
  COALESCE(pi.conservacao, p.conservacao) AS conservacao,
  p.situacao         AS situacao_pedido,
  p.encaminhado_em
FROM pedido p
JOIN pedido_item pi ON pi.pedido_id = p.id
JOIN ordem_sabor os ON os.id = pi.ordem_sabor_id;

-- ------------------------------------------------------------
-- TRIGGERS — validações que o banco garante
-- ------------------------------------------------------------

-- Capacidade da batelada (carne + temperos de massa) ≤ 150 kg
CREATE TRIGGER trg_batelada_capacidade
BEFORE INSERT ON batelada_tempero
FOR EACH ROW
BEGIN
  SELECT CASE
    WHEN (SELECT CAST(valor AS REAL) FROM configuracao WHERE chave='capacidade_batelada_kg') <
         (SELECT v.peso_total_kg FROM vw_batelada_peso v WHERE v.batelada_id = NEW.batelada_id) +
         CASE NEW.unidade WHEN 'kg' THEN NEW.quantidade
                          WHEN 'g'  THEN NEW.quantidade / 1000.0
                          ELSE 0 END
    THEN RAISE(ABORT, 'Batelada excede 150 kg somando carne + temperos.')
  END;
END;

-- Alteração que pede confirmação e histórico (exemplo sobre ordem_sabor.planejado_kg)
CREATE TRIGGER trg_ordem_sabor_hist
AFTER UPDATE OF planejado_kg, embutido_kg ON ordem_sabor
FOR EACH ROW
WHEN OLD.planejado_kg <> NEW.planejado_kg OR OLD.embutido_kg <> NEW.embutido_kg
BEGIN
  INSERT INTO historico (usuario, entidade, entidade_id, campo, valor_antes, valor_depois, texto)
  VALUES (
    NULL, 'ordem_sabor', NEW.id,
    CASE WHEN OLD.planejado_kg <> NEW.planejado_kg THEN 'planejado_kg' ELSE 'embutido_kg' END,
    CAST(OLD.planejado_kg AS TEXT) || '/' || CAST(OLD.embutido_kg AS TEXT),
    CAST(NEW.planejado_kg AS TEXT) || '/' || CAST(NEW.embutido_kg AS TEXT),
    'Alteração de quantidade em sabor da ordem ' || NEW.ordem_id
  );
END;

-- Separação não pode exceder a disponibilidade real
CREATE TRIGGER trg_pedido_item_disponivel
BEFORE UPDATE OF separado_kg ON pedido_item
FOR EACH ROW
BEGIN
  SELECT CASE
    WHEN NEW.separado_kg >
         (SELECT os.embutido_kg FROM ordem_sabor os WHERE os.id = NEW.ordem_sabor_id)
         - (SELECT COALESCE(SUM(pi2.separado_kg),0) FROM pedido_item pi2
            WHERE pi2.ordem_sabor_id = NEW.ordem_sabor_id AND pi2.id <> NEW.id)
    THEN RAISE(ABORT, 'Separação acima da quantidade disponível.')
  END;
END;

-- Situação 'Separado' não marca faturamento
CREATE TRIGGER trg_pedido_separado_sem_faturamento
AFTER UPDATE OF situacao ON pedido
FOR EACH ROW
WHEN NEW.situacao = 'Separado' AND OLD.situacao <> NEW.situacao
BEGIN
  INSERT INTO historico (usuario, entidade, entidade_id, campo, valor_antes, valor_depois, texto)
  VALUES (NULL, 'pedido', NEW.id, 'situacao', OLD.situacao, NEW.situacao,
          'Produto separado — pedido NÃO faturado.');
END;

-- ------------------------------------------------------------
-- DADOS DE EXEMPLO (FICTÍCIOS)
-- ------------------------------------------------------------
INSERT INTO ordem_producao (id, numero, data, responsavel, situacao, observacoes) VALUES
 ('OP-2026-001','OP-2026-001', date('now'), 'Exemplo: Ana (Planejamento)','Em produção','Dados fictícios de demonstração.');

INSERT INTO ordem_sabor (id, ordem_id, nome, planejado_kg, produzido_kg, embutido_kg, liberado) VALUES
 ('S1','OP-2026-001','Linguiça de gorgonzola e mel (EXEMPLO)',10, 0, 0, 0),
 ('S2','OP-2026-001','Linguiça toscana (EXEMPLO)',             40, 0, 0, 0);

INSERT INTO parceiro (id, nome, tipo, destino) VALUES
 ('P-001','Exemplo: Distribuidora Central (fictícia)','cliente de atacado','Depósito Central');

INSERT INTO pedido (id, numero, parceiro_id, parceiro_nome, data, destino, responsavel, situacao, conservacao, observacoes) VALUES
 ('PED-001','PED-001','P-001','Exemplo: Distribuidora Central (fictícia)', date('now'),'Depósito Central','Exemplo: Bruno (Expedição)','Recebido','Resfriado','Dados fictícios.');

INSERT INTO pedido_item (id, pedido_id, ordem_id, ordem_sabor_id, solicitado_kg, separado_kg, conservacao) VALUES
 ('IT-001','PED-001','OP-2026-001','S1', 6, 0,'Resfriado'),
 ('IT-002','PED-001','OP-2026-001','S2',12, 0,'Resfriado');
