#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
COMPOSE_FILE="${SCRIPT_DIR}/containers/docker-compose.selenium-grid.yml"

TEST_IMAGE="${TEST_IMAGE:-ndviet/test-automation-java-common:latest}"
BROWSER="${BROWSER:-chrome}"
TESTNG_SUITE="${TESTNG_SUITE:-EasyUpload_io.xml}"
GRID_NETWORK="${GRID_NETWORK:-ta-selenium-grid-testng}"
KEEP_GRID_UP="${KEEP_GRID_UP:-false}"
MAVEN_SETTINGS_FILE="${MAVEN_SETTINGS_FILE:-${HOME}/.m2/settings.xml}"
MAVEN_OFFLINE="${MAVEN_OFFLINE:-true}"
MAVEN_NO_SNAPSHOT_UPDATES="${MAVEN_NO_SNAPSHOT_UPDATES:-true}"
MAVEN_AUTO_FALLBACK_ONLINE="${MAVEN_AUTO_FALLBACK_ONLINE:-true}"

if ! command -v docker >/dev/null 2>&1; then
  echo "docker is required but was not found in PATH"
  exit 1
fi

if ! docker compose version >/dev/null 2>&1; then
  echo "docker compose plugin is required but was not found"
  exit 1
fi

if ! command -v curl >/dev/null 2>&1; then
  echo "curl is required but was not found in PATH"
  exit 1
fi

if [ ! -f "${COMPOSE_FILE}" ]; then
  echo "Compose file not found: ${COMPOSE_FILE}"
  exit 1
fi

cleanup() {
  if [ "${KEEP_GRID_UP}" != "true" ]; then
    docker compose -f "${COMPOSE_FILE}" down --remove-orphans >/dev/null 2>&1 || true
  fi
}
trap cleanup EXIT

echo "[grid] Starting Selenium Grid containers"
docker compose -f "${COMPOSE_FILE}" up -d

echo "[grid] Waiting for Selenium Grid to be ready at http://localhost:4444/status"
for _ in $(seq 1 60); do
  if curl -fsS "http://localhost:4444/status" | grep -q '"ready"[[:space:]]*:[[:space:]]*true'; then
    echo "[grid] Selenium Grid is ready"
    break
  fi
  sleep 2
done

if ! curl -fsS "http://localhost:4444/status" | grep -q '"ready"[[:space:]]*:[[:space:]]*true'; then
  echo "[grid] Selenium Grid was not ready in time"
  docker compose -f "${COMPOSE_FILE}" logs
  exit 1
fi

MAVEN_BASE_CMD=(
  mvn
  -B
  -f
  test-testng-framework/pom.xml
  test
  -DskipTests=false
  -Dincludes="${TESTNG_SUITE}"
  -Dselenium.web_driver.target=remote
  -Dselenium.hub.url=http://selenium:4444
  -Dselenium.browser.type="${BROWSER}"
)

echo "[runner] Executing tests in ${TEST_IMAGE}"
DOCKER_RUN_ARGS=(
  --rm
  --network "${GRID_NETWORK}"
  -v "${WORKSPACE_ROOT}:/workspace"
  -w /workspace
)

if [ -f "${MAVEN_SETTINGS_FILE}" ]; then
  echo "[runner] Using Maven settings from ${MAVEN_SETTINGS_FILE}"
  DOCKER_RUN_ARGS+=(-v "${MAVEN_SETTINGS_FILE}:/root/.m2/settings.xml:ro")
fi

if [ -n "${GITHUB_ACTOR:-}" ]; then
  DOCKER_RUN_ARGS+=(-e GITHUB_ACTOR)
fi
if [ -n "${GITHUB_TOKEN:-}" ]; then
  DOCKER_RUN_ARGS+=(-e GITHUB_TOKEN)
fi

if [ "${MAVEN_AUTO_FALLBACK_ONLINE}" = "true" ] && [ ! -f "${MAVEN_SETTINGS_FILE}" ]; then
  echo "[runner] Maven settings file not found at ${MAVEN_SETTINGS_FILE}."
  echo "[runner] Online fallback may fail for private GitHub Packages."
fi

run_maven() {
  local offline_mode="$1"
  local -a cmd=("${MAVEN_BASE_CMD[@]}")

  if [ "${MAVEN_NO_SNAPSHOT_UPDATES}" = "true" ]; then
    cmd+=(-nsu)
  fi
  if [ "${offline_mode}" = "true" ]; then
    cmd+=(-o)
  fi

  echo "[runner] Maven command: ${cmd[*]}"
  set +e
  docker run \
    "${DOCKER_RUN_ARGS[@]}" \
    "${TEST_IMAGE}" \
    "${cmd[@]}"
  local exit_code=$?
  set -e
  return "${exit_code}"
}

if [ "${MAVEN_OFFLINE}" = "true" ]; then
  if ! run_maven "true"; then
    if [ "${MAVEN_AUTO_FALLBACK_ONLINE}" = "true" ]; then
      echo "[runner] Offline execution failed. Retrying online (without -o)."
      run_maven "false"
    else
      exit 1
    fi
  fi
else
  run_maven "false"
fi
