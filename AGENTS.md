# Agent context

- Rules live in `.cursor/rules/`
- Backend changes → run `docker compose exec app bundle exec rspec`
- Frontend changes → run `docker compose exec frontend npm run build`
- Full-stack API changes → update Jbuilder + TS types + request spec

## Quick reference

| Layer | Container | Test command |
|-------|-----------|--------------|
| Rails API | `app` | `docker compose exec app bundle exec rspec` |
| React UI | `frontend` | `docker compose exec frontend npm run build` |
| Database | `app` | `docker compose exec app bundle exec rails db:migrate` |
