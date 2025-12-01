#!/usr/bin/env bash
set -euo pipefail

echo "[security] Starting npm audit and fix..."

# Ensure correct git identity configured (set in shell, not hardcoded in bootstrap files)
git config user.name "Seongho Bae"
git config user.email "seonghobae@hyosung.com"

# Commit this script addition (first time only)
if git ls-files --error-unmatch scripts/fix_vulnerabilities.sh >/dev/null 2>&1; then
  echo "[git] Script already tracked."
else
  git add scripts/fix_vulnerabilities.sh
  git commit -m "chore(security): add fix_vulnerabilities.sh for reproducible npm audit fixes" || true
fi

# Initial audit
echo "[security] Running initial npm audit..."
npm audit || true

# Attempt automatic fixes
echo "[security] Applying npm audit fix..."
npm audit fix || true

# Re-audit
echo "[security] Re-running npm audit after fix..."
npm audit || true

# Run build to verify integrity
echo "[build] Verifying build passes..."
npm run build

# Stage changes produced by audit fix
echo "[git] Staging changes..."
git add package-lock.json package.json 2>/dev/null || true

# Commit security fixes if any
if ! git diff --cached --quiet; then
  echo "[git] Committing security fixes..."
  git commit -m "chore(security): apply npm audit fix to address vulnerabilities"
else
  echo "[git] No changes to commit for security fixes."
fi

echo "[security] Completed."
