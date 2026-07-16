-- =============================================================================
-- African College — Lot 2 · Notifications (Telegram + e-mail)
-- =============================================================================
-- Modèle outbox : l'écriture de la notification est découplée de son envoi.
-- Un workflow n8n (Phase 2) videra la file vers Telegram et Resend (e-mail).

-- Destinataires humains (le fondateur + future équipe).
create table people (
  id                uuid primary key default gen_random_uuid(),
  name              text not null,
  email             text,
  telegram_chat_id  text,
  role              text,
  active            boolean not null default true,
  created_at        timestamptz not null default now()
);

-- Outbox des notifications.
create table notifications (
  id              uuid primary key default gen_random_uuid(),
  recipient_type  text not null check (recipient_type in ('agent', 'human')),
  recipient_id    uuid,
  channel         text not null check (channel in ('telegram', 'email', 'inapp')),
  event           text not null,     -- assigned | mentioned | review_requested | blocked | due_soon | overdue…
  task_id         uuid references tasks(id) on delete cascade,
  title           text,
  body            text,
  payload         jsonb not null default '{}',
  status          text not null default 'pending'
                    check (status in ('pending', 'sent', 'failed', 'skipped')),
  created_at      timestamptz not null default now(),
  sent_at         timestamptz
);
create index idx_notifications_status on notifications (status);
create index idx_notifications_recipient on notifications (recipient_type, recipient_id);

-- Préférences : qui reçoit quel type d'événement, sur quel canal ('*' = tous).
create table notification_preferences (
  id               uuid primary key default gen_random_uuid(),
  subscriber_type  text not null check (subscriber_type in ('agent', 'human')),
  subscriber_id    uuid not null,
  channel          text not null check (channel in ('telegram', 'email', 'inapp')),
  event_type       text not null default '*',
  enabled          boolean not null default true,
  unique (subscriber_type, subscriber_id, channel, event_type)
);
