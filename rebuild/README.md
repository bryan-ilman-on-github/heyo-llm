# Heyo Rebuild

This folder contains the rebuilt Heyo stack:

1. `app/` is the Flutter client with local encrypted storage, local retrieval, entity views, attachment ingestion, quota UI, and local export.
2. `server/` is the FastAPI backend with provider abstraction, EmbeddingGemma embeddings, prepare and respond planning, attachment inspection, entity summaries, and shared daily quota enforcement.

## Run Locally

1. Start the backend with `cd rebuild/server` and `uvicorn app.main:app --reload`
2. Start the client with `cd rebuild/app` and `flutter pub get`
3. Launch the app with `flutter run`

## Core Guarantees

1. User messages, memories, entities, attachments, and vectors remain local to the device.
2. Server storage is limited to quota and minimal client identity records.
3. Retrieval stays local in the app after server-side planning.
4. Attachment raw text stays local and only summaries are embedded.

## Branding State

The rebuild now uses the Heyo logo asset in the primary chat shell and ships generated launcher icons, favicons, and desktop icons from `app/assets/images/logo_square.jpg`.

## Cutover Checklist

1. Replace the placeholder bundle identifiers `com.heyo.app` and related test identifiers with your owned production identifiers before store submission.
2. Add production signing config for Android, iOS, macOS, Windows, and Linux packaging.
3. Set real provider keys and generation model defaults in the server environment.
4. Confirm quota limits and database path for the deployment environment.
5. Run `flutter analyze`, `flutter test --no-pub`, and `python -m pytest` before any release build.
6. Smoke test attachment ingestion, export save, quota exhaustion, and provider failover on a release build.
