# Security Policy

This is an MVP starter and is not yet suitable for sensitive or high-risk communication.

## Reporting a vulnerability

Do not post secrets, tokens, or exploitable details in a public issue. For a public deployment, configure a private security reporting channel in the repository settings.

## Current security boundaries

- Supabase Auth handles password authentication.
- Row Level Security limits lobby table access to authenticated users and binds inserts to `auth.uid()`.
- The mobile client must only use the Supabase anon/public key; never include the service-role key.
- Lobby messages are readable by all authenticated users in the project and are not end-to-end encrypted.
- Client-supplied display names are not trusted for authorization.

Before public launch, conduct a security review, test RLS using separate accounts, add abuse controls and moderation, and publish clear privacy and retention policies.
