# Article Feature — Data Flow

```mermaid
flowchart LR
  subgraph UI
    A[ArticlesPage] -->|dispatch fetch| B(ArticlesCubit)
  end
  B -->|calls| C(ArticlesRepository)
  C -->|calls| D(ArticlesApi)
  D -->|HTTP| E[(Backend API)]
  E -->|JSON| D
  D -->|models| C
  C -->|entities| B
  B -->|states| A
```

Notes:
- The UI dispatches events to the Cubit, which orchestrates repository calls.
- Repository maps API models to domain entities and centralizes errors.
- API layer is responsible for HTTP status mapping and conversion to models.
