# FITLY iOS

Нативный SwiftUI-клиент использует тот же API и аккаунт, что и Web. Реализованы auth через Keychain, dashboard, food diary, water, activity, recipes, goals, habits, settings, devices, HealthKit adapter, локальные уведомления и тестовый `MockHealthProvider`.

## Локальный запуск

1. Откройте `Fitly.xcodeproj` в Xcode 16+ на macOS.
2. В Target `Fitly` задайте `FITLY_API_BASE_URL`: Simulator — `http://localhost:4000/api`; физическое устройство — адрес компьютера в сети или HTTPS API.
3. Выберите Team и уникальный Bundle Identifier.
4. В Signing & Capabilities добавьте HealthKit и Associated Domains при использовании Universal Links.
5. Запустите API (`pnpm api`) и приложение.

## HealthKit и TestFlight

Приложение запрашивает только шаги, дистанцию, активную энергию и сон. `Connected` показывается только после успешной авторизации. Остальные провайдеры отображаются как `Not configured`.

Подписанный `.ipa` нельзя получить без Apple Developer Team, сертификатов и provisioning profile. Полная инструкция, secret names и ручной release trigger находятся в `docs/IOS_BUILD.md`.
