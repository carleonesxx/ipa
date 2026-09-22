# FITLY iOS Build

## Development

Откройте `ios/Fitly.xcodeproj` на macOS в Xcode 16.2+. Для Simulator используйте Debug-конфигурацию и `FITLY_API_BASE_URL=http://localhost:4000/api`. Для устройства задайте HTTPS API или адрес компьютера в локальной сети.

В Xcode выберите target `Fitly`, свой Team и уникальный Bundle Identifier. HealthKit capability уже объявлена в `ios/Fitly/Fitly.entitlements`; usage descriptions находятся в `ios/Fitly/Resources/Info.plist`.

## Personal Team

Для личного тестирования можно выбрать Apple Account → Personal Team и подключить iPhone по USB. Personal Team подходит для Build & Run на личном устройстве, но не даёт полноценную App Store/TestFlight-дистрибуцию и имеет ограничения по сроку и capabilities.

## GitHub Actions

`/.github/workflows/ios.yml` имеет два режима:

- Pull request или обычный запуск: macOS runner проверяет project, собирает Simulator и запускает unit tests без signing.
- Manual `workflow_dispatch` с `distribute=true`: после успешной проверки создаёт archive, экспортирует настоящий `Fitly.ipa`, загружает его в TestFlight и сохраняет IPA/archive как artifact.

Release workflow завершается ошибкой `Apple signing credentials are not configured`, если secrets не заданы. Фиктивный IPA не создаётся.

## Required GitHub Secrets

Добавьте secrets в Settings → Secrets and variables → Actions:

`APPLE_TEAM_ID`, `APPLE_KEY_ID`, `APPLE_ISSUER_ID`, `APPLE_API_PRIVATE_KEY_BASE64`, `SIGNING_CERTIFICATE_BASE64`, `SIGNING_CERTIFICATE_PASSWORD`, `PROVISIONING_PROFILE_BASE64`, `IOS_PROFILE_NAME`, `IOS_BUNDLE_ID`, `IOS_PRODUCTION_API_URL`.

`APPLE_API_PRIVATE_KEY_BASE64` — base64 содержимого App Store Connect `.p8`; `SIGNING_CERTIFICATE_BASE64` — base64 `.p12`; `PROVISIONING_PROFILE_BASE64` — base64 `.mobileprovision`. Секреты не добавляются в repository.

## TestFlight and IPA

После добавления credentials запустите Actions → FITLY iOS → Run workflow → `distribute=true`. Артефакт `FITLY-release` содержит `Fitly.ipa` и `FITLY.xcarchive`; build также отправляется в App Store Connect через `iTMSTransporter`.

Без Apple Developer Program, App Store Connect API key, distribution certificate и provisioning profile подписанный IPA/TestFlight недоступны.

Release-конфигурация содержит только локальный URL по умолчанию. Для устройства и cloud release обязательно задайте реальный HTTPS API через `IOS_PRODUCTION_API_URL`.
