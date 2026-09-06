alter table login_qr_tokens add column expires_at timestamptz;
update login_qr_tokens set expires_at = created_at + interval '10 minutes' where expires_at is null;
alter table login_qr_tokens alter column expires_at set not null;
