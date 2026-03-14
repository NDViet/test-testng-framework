## Introduction

Test repository with test case is created and executed in TestNG Framework.<br>

## List dependency repositories

1. [test-parent-pom](../../../test-parent-pom)
2. [test-automation-fwk](../../../test-automation-fwk)

## Source code usage

1. Clone repository "test-parent-pom" (**mandatory**)

```shell
git clone git@github.com:ndviet/test-parent-pom.git
```

2. Clone this test repository to the same directory

```shell
git clone git@github.com:ndviet/test-testng-framework.git
```

3. Build source code in each repository following the order

- test-parent-pom
- test-testng-framework

4. Run test cases in test repository

```shell
cd test-testng-framework
```

```shell
mvn test -DskipTests=false -Dincludes="EasyUpload_io.xml"
mvn test -DskipTests=false -Dincludes="OnlyTestingBlog.xml"
mvn test -DskipTests=false -Dincludes="DemoQA_Download.xml"
```

Noted:

* **[includes]** property is used to provide Test Suite xml file would be executed.

## Run UI tests in shared container image + Selenium Grid

Use `ndviet/test-automation-java-common` as test runner container and start Selenium Grid from Docker Compose:

```shell
./test-testng-framework/run-in-container.sh
```

No local build of `test-parent-pom` or `test-automation-fwk` is required.
Dependencies are resolved from GitHub Maven repositories.
If package access is private, configure GitHub Packages credentials in `~/.m2/settings.xml`.

```xml
<settings>
  <servers>
    <server>
      <id>github-test-parent-pom</id>
      <username>${env.GITHUB_ACTOR}</username>
      <password>${env.GITHUB_TOKEN}</password>
    </server>
    <server>
      <id>github-test-automation-fwk</id>
      <username>${env.GITHUB_ACTOR}</username>
      <password>${env.GITHUB_TOKEN}</password>
    </server>
  </servers>
</settings>
```

Override suite, browser, or image:

```shell
TESTNG_SUITE=DemoQA_Download.xml BROWSER=chrome TEST_IMAGE=ndviet/test-automation-java-common:latest ./test-testng-framework/run-in-container.sh
```

Keep Grid containers running after test execution:

```shell
KEEP_GRID_UP=true ./test-testng-framework/run-in-container.sh
```

Execution mode defaults:

1. `MAVEN_OFFLINE=true`: run immediately using dependencies pre-seeded in `test-automation-java-common`.
2. `MAVEN_NO_SNAPSHOT_UPDATES=true`: skip snapshot metadata checks (`-nsu`).
3. `MAVEN_AUTO_FALLBACK_ONLINE=true`: if offline fails, retry online automatically.

If you need to force remote Maven resolution:

```shell
MAVEN_OFFLINE=false MAVEN_NO_SNAPSHOT_UPDATES=false ./test-testng-framework/run-in-container.sh
```

## GitHub Actions UI workflow

Workflow file:

```text
.github/workflows/testng-ui-container.yml
```

The workflow:

1. Pulls shared test image `ndviet/test-automation-java-common` (or `DOCKERHUB_JAVA_COMMON_IMAGE` repo variable).
2. Starts Selenium Grid containers.
3. Runs TestNG UI tests remotely against `http://selenium:4444`.
4. Uploads `target/reports` and `target/surefire-reports` as artifacts.

## Reference

A sample project with entire repositories together for the test execution.<br>

* [test-automation-project](../../../test-automation-project)
