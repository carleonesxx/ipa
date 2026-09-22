# FITLY

FITLY — wellness-приложение для питания, активности и привычек. Пользовательские данные хранятся в MySQL/MariaDB через Prisma, auth использует scrypt-хеширование и подписанные bearer-сессии.

## Быстрый старт

Требуется Node.js 20+ и pnpm 9+.

```bash
pnpm install
docker compose up -d mysql redis
$env:DATABASE_URL="mysql://fitly:fitly@localhost:3306/fitly"
pnpm db:migrate -- --name init
pnpm db:seed
pnpm dev
```

Откройте `http://localhost:5173`. Для запуска API в отдельном терминале:

```bash
pnpm api
```

Проверки перед релизом:

```bash
pnpm lint
pnpm typecheck
pnpm build
```

## Environment

Скопируйте `.env.example` в `.env`. Обязательны `DATABASE_URL` и `JWT_SECRET`. Без доступной MySQL/MariaDB API отвечает `503`, локального JSON fallback нет.

## Архитектура

- `src/main.tsx` — модульный UI и пользовательские сценарии MVP.
- `src/styles.css` — responsive design system, light/dark theme, states and motion styling.
- `server/index.mjs` — API-контур на Prisma: auth, профиль, настройки, питание, вода, привычки, цели, активность, сон, избранное, planner, shopping и analytics.
- `ios/` — нативный SwiftUI-клиент с Keychain auth, HealthKit adapter, локальными уведомлениями и cloud-build конфигурацией. См. `ios/README.md`.
- Prisma ownership checks выполняются на каждом пользовательском запросе.

## Интеграции

AI Scanner и AI Coach работают в безопасном локальном fallback-режиме. Для подключения провайдера реализуйте `FoodScannerService` и `CoachService` на backend, храните ключи только в environment. Barcode подключается через `BarcodeProvider`, а Apple Health, Health Connect, Fitbit, Garmin и Samsung Health — через общий `HealthIntegrationAdapter`.

Для production рекомендуемый стек: Next.js/React + React Query + React Hook Form/Zod, NestJS + Prisma/MySQL, Redis, JWT rotation, Docker Compose и Nginx. Текущая Vite-версия специально остаётся лёгкой и запускается одной командой, чтобы MVP можно было сразу проверить.
