# Changelog

이 프로젝트는 Keep a Changelog 형식을 참고하고, 버전은 Semantic Versioning(SemVer: MAJOR.MINOR.PATCH)을 따릅니다.

## [1.0.0] - 2025-12-01

### Breaking Changes
- 응답 기본 형식 변경: `search` 도구가 반환하는 기본 응답이 기존 `items` 배열에서 `{"items": [...], "meta": {...}}` 구조로 변경되었습니다.
  - 새 기본 응답: `{ "items": [...], "meta": { "totalResults": "..." } }`

### Backward Compatibility
- 아래 조건에서 기존 배열 응답(`items`만)으로 자동 또는 강제 변환됩니다:
  - `arguments.compat = true` 전달 시
  - `arguments.version = 1` 전달 시 (문자열 `"1"`도 동일)
  - `meta`가 비어있는 경우(예: `searchInformation.totalResults`가 정의되지 않은 경우 등)
- 기본 응답은 구조화된 객체 `{ items, meta }`입니다.

### Migration Guide
- 새 구조 사용(권장):
```json
{ "q": "ai", "size": 5 }
// 또는
{ "q": "ai", "size": 5, "version": 2 }
```

- 레거시 배열 유지(옵션 1):
```json
{ "q": "ai", "compat": true }
```

- 레거시 배열 유지(옵션 2):
```json
{ "q": "ai", "version": 1 }
```

### Versioning Notes
- SemVer: 본 변경은 인터페이스 브레이킹이므로 다음 릴리스에서 MAJOR 버전 증가가 필요합니다(예: 현재 0.x.y라면 1.0.0으로 승격).
- API 버저닝: MCP 도구의 특성상 HTTP 헤더 기반 버저닝 대신, 인자 기반 버전 선택(`version` 파라미터)을 제공합니다. 필요 시 별도의 버전드 도구/엔드포인트(예: `search_v1`, `search_v2`) 도입을 고려할 수 있습니다.
- 변경 사항은 README의 Breaking Change 섹션에도 문서화되어 있으며, 마이그레이션 예시를 제공합니다.

### Authentication/Authorization
- Google Custom Search 호출 실패 시(특히 401/403) 인증/인가 힌트를 함께 반환합니다. API_KEY, CX 설정 및 Google Cloud에서 Custom Search JSON API 활성화 여부를 점검하십시오. 인증을 무력화하지 않고 정상화가 필요합니다.

### Also Changed (이전 릴리스에서의 주요 변경 상기)
- `siteRestricted` 기본값이 `true → false`로 변경되었습니다. 기본값 변경은 /v1/siterestrict → /v1로의 전환을 유발할 수 있습니다. 이전 동작 유지가 필요한 경우 설정/호출 인자에 `siteRestricted: true`를 명시하십시오. (자세한 내용은 README의 Breaking Change 섹션 참조)

---

## [0.2.1] - 2025-XX-XX
- 내부 개선 및 문서 업데이트(레거시). 최신 브레이킹/마이그레이션 정보는 [1.0.0] 섹션을 참고하십시오.
