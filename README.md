[![MseeP.ai Security Assessment Badge](https://mseep.net/pr/rendyfebry-google-pse-mcp-badge.png)](https://mseep.ai/app/rendyfebry-google-pse-mcp)

# Google Programmable Search Engine (PSE) MCP Server

A Model Context Protocol (MCP) server for the Google Programmable Search Engine (PSE) API. This server exposes tools for searching the web with Google Custom Search engine, making them accessible to MCP-compatible clients such as VSCode, Copilot, and Claude Desktop.

## Installation Steps

You do NOT need to clone this repository manually or run any installation commands yourself. Simply add the configuration below to your respective MCP client—your client will automatically install and launch the server as needed.

### VS Code Copilot Configuration 

Open Command Palette → Preferences: Open Settings (JSON), then add:

`settings.json`
```jsonc
{
  // Other settings...
  "mcp": {
    "servers": {
      "google-pse-mcp": {
        "command": "npx",
        "args": [
          "-y",
          "google-pse-mcp",
          "https://www.googleapis.com/customsearch",
          "<api_key>",
          "<cx>",
          "<siteRestricted>" // optional: true/false, defaults to false
        ]
      }
    }
  }
}
```

### Cline MCP Configuration Example

If you are using [Cline](https://github.com/saoudrizwan/cline), add the following to your `cline_mcp_settings.json` (usually found in your VSCode global storage or Cline config directory):

- macOS: `~/Library/Application Support/Code/User/globalStorage/saoudrizwan.claude-dev/settings/cline_mcp_settings.json`
- Windows: `%APPDATA%\Code\User\globalStorage\saoudrizwan.claude-dev\settings\cline_mcp_settings.json`

```json
{
  "mcpServers": {
    "google-pse-mcp": {
      "disabled": false,
      "timeout": 60,
      "command": "npx",
      "args": [
        "-y",
        "google-pse-mcp",
        "https://www.googleapis.com/customsearch",
        "<api_key>",
        "<cx>",
        "<siteRestricted>" // optional flag, true/false, defaults to false
      ],
      "transportType": "stdio"
    }
  }
}
```


### Important Notes

Don't forget to replace `<api_key>` and `<cx>` with your credentials in the configuration above.
You can also provide an optional `<siteRestricted>` flag (`true` or `false`) as the last argument to control which Google Custom Search endpoint is used. If omitted, it defaults to `false`.


## Breaking Change: siteRestricted 기본값 변경(true → false)

이 버전부터 siteRestricted의 기본값이 true에서 false로 변경되었다. 기본값 변경은 기존 사용자에게 동작 변화(표준 /v1 엔드포인트로 전환)를 유발할 수 있으므로 아래 마이그레이션 가이드를 따른다.

- 변경사항
  - 기존: 기본값 true → /v1/siterestrict 사용(사이트 제한 엔드포인트)
  - 현재: 기본값 false → /v1 사용(일반/전체 웹 엔드포인트)
- 영향
  - 기존 설정에서 마지막 인자 `<siteRestricted>`를 생략한 경우, 이전에는 사이트 제한(/v1/siterestrict)으로 동작했을 수 있으나, 이제는 일반(/v1)로 동작한다.
- 이전 동작 유지 방법(명시적 true 설정)
  - CLI/설정의 마지막 인자 `<siteRestricted>`를 "true"로 명시하거나, 툴 호출 시 arguments.siteRestricted=true를 지정한다.

정확한 파라미터/기본값
- CLI 마지막 인자: `<siteRestricted>` (boolean, optional)
  - 생략: false(기본) → /v1
  - "true": /v1/siterestrict
  - "false": /v1
- Tool 호출 인자: `siteRestricted` (boolean, optional)
  - 생략: 서버 기본값(현재 false)을 따른다
  - true: /v1/siterestrict
  - false: /v1

Migration 예시

1) Cline 설정에서 이전 동작 유지(사이트 제한 유지)
```json
{
  "mcpServers": {
    "google-pse-mcp": {
      "disabled": false,
      "timeout": 60,
      "transportType": "stdio",
      "command": "npx",
      "args": [
        "-y",
        "google-pse-mcp",
        "https://www.googleapis.com/customsearch",
        "<api_key>",
        "<cx>",
        "true" // 이전 동작 유지: /v1/siterestrict
      ]
    }
  }
}
```

2) VS Code Copilot 설정에서 이전 동작 유지
```jsonc
{
  "mcp": {
    "servers": {
      "google-pse-mcp": {
        "command": "npx",
        "args": [
          "-y",
          "google-pse-mcp",
          "https://www.googleapis.com/customsearch",
          "<api_key>",
          "<cx>",
          "true" // 이전 동작 유지
        ]
      }
    }
  }
}
```

3) Tool 호출에서 per-call로 이전 동작 유지
```json
{
  "q": "site restricted search",
  "size": 5,
  "siteRestricted": true
}
```

권장 롤아웃/마이그레이션 단계
- 1) 기존 mcpServers 설정을 점검해 사이트 제한 동작에 의존하는지 확인
- 2) 사이트 제한이 필요한 설정에는 `<siteRestricted>`를 "true"로 명시적으로 추가
- 3) 전체 웹 검색이 필요하면 `<siteRestricted>`를 생략하거나 "false"로 명시
- 4) 개발/스테이징에서 검색 결과와 엔드포인트(/v1 vs /v1/siterestrict)를 확인 후 프로덕션에 적용

## Breaking Change: 응답 형식 변경(items 배열 → { items, meta })

이 버전부터 `search` 도구의 응답 기본 형식이 기존 `items` 배열에서 `{"items": [...], "meta": {...}}` 구조로 변경되었습니다. 이는 브레이킹 체인지이며, 아래 방법으로 역호환을 유지할 수 있습니다.

- 역호환 유지 방법:
  - `arguments.compat = true` 전달 시 기존 배열(`items`)만 반환
  - `arguments.version = 1` 전달 시 기존 배열만 반환
  - `meta`가 비어있는 경우(검색 정보가 없는 경우) 자동으로 기존 배열 응답을 반환
- 기본 동작은 구조화된 객체 `{ items, meta }`를 반환합니다.

마이그레이션 예시:
```json
// 기본(새 구조)
{ "q": "ai", "size": 5 }
// 또는
{ "q": "ai", "size": 5, "version": 2 }

// 레거시 배열 유지(옵션1)
{ "q": "ai", "compat": true }

// 레거시 배열 유지(옵션2)
{ "q": "ai", "version": 1 }
```

Release Notes / Versioning:
- SemVer: 본 변경은 브레이킹 체인지이므로 다음 릴리스에서 MAJOR 버전 증가(예: 1.0.0) 권고
- API 버저닝: MCP 도구 특성상 HTTP 헤더 기반 버저닝은 적용되지 않으며, 본 서버는 인자 기반 버전 선택(`version` 파라미터)을 제공합니다. 필요 시 별도의 버전드 엔드포인트/도구 제공을 고려하십시오.

## Available Tools

This MCP server provides the following tool:

1. `search`: Search the web with Google Programmable Search Engine

   - Parameters:
     - `q` (string, required): Search query
     - `page` (integer, optional): Page number
     - `size` (integer, optional): Number of search results to return per page (1-10)
     - `sort` (string, optional): Sort expression (only 'date' is supported)
     - `safe` (boolean, optional): Enable safe search filtering
     - `lr` (string, optional): Restrict search to a particular language (e.g., lang_en)
     - `siteRestricted` (boolean, optional): Use the Site Restricted API endpoint; defaults to false unless overridden via CLI flag
     - `compat` (boolean, optional): 이전 클라이언트를 위한 레거시 배열 응답을 강제합니다(`true` 시 `items` 배열만 반환).
     - `version` (integer|string, optional): 1은 레거시 배열, 2는 구조화된 `{ items, meta }` 응답. 기본값은 2.

   - 응답 형식:
     - 기본: `{ "items": [...], "meta": { "totalResults": "..." } }`
     - 역호환(배열): `[...]` (`compat=true`, `version=1`, 또는 `meta`가 비어있는 경우 배열로 반환)

## Example Usage

```python
# Search for "artificial intelligence"
result = await use_mcp_tool(
    server_name="google-pse-mcp",
    tool_name="search",
    arguments={
        "q": "artificial intelligence",
        "size": 5,
        "safe": True
    }
)
```

## Useful Links

- [Model Context Protocol Servers](https://github.com/modelcontextprotocol/servers)
- [Google Programmable Search Engine Intro](https://developers.google.com/custom-search/v1/overview)
