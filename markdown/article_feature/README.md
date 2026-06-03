# Article Feature

This folder documents the Article feature: endpoints, data models, dataflow, error handling, and integration guidance for the Flutter app.

Files created:
- `dataflow.md` — data flow overview (Mermaid)
- `datadiagram.md` — data model / ER diagram (Mermaid)
- `flowdiagram.md` — sequence / flow diagram (Mermaid)

API endpoints (server):

- GET /api/articles/ — list articles (paginated)
- POST /api/articles/{article_id}/react — react to an article (body: { "reaction": "like" })
- GET /api/articles/recommended/ — recommended articles (paginated)
- GET /api/articles/trending/ — trending articles (paginated)

Integration summary (Flutter):

- Model mapping: `ArticleModel` in `lib/feature/articles/data/models/article_model.dart`
- Domain entity: `ArticleEntity` in `lib/feature/articles/domain/entities/article_entities.dart`
- Networking: `ArticlesRemoteDataSourceImpl` in `lib/feature/articles/data/datasources/articles_remote_datasource.dart` — handles HTTP requests and error mapping
- Repository: `ArticlesRepositoryImpl` in `lib/feature/articles/data/repositories/articles_repository_impl.dart` — provides clean methods for the Cubit
- State management: `ArticlesCubit` + `ArticlesState` in `lib/feature/articles/presentation/cubits/articles_cubit.dart` (uses Cubit pattern)
- UI: `ArticlesHomeSection`, `ArticlesListScreen`, and `ArticleCardWidget` in `lib/feature/articles/presentation/widgets` and `lib/feature/articles/presentation/screens`

Error handling

- Network and API errors map to `ApiException` (user-friendly messages). Cubit emits `ArticlesError` with safe messages to display.
- All network calls use try/catch and map status codes (4xx -> client message, 5xx -> server error message, others -> connectivity message).

Next steps

- Wire `ArticlesCubit` into the app's route where appropriate and test on device.
- Adjust base URL in `ArticlesApi` to match backend configuration (see `baseUrl` constant).

See the diagrams for dataflow and model relationships.
