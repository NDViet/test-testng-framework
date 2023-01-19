## Introduction

Test repository with test case is created and executed in TestNG Framework.<br>

## List dependency repositories

1. [test-parent-pom](../../../test-parent-pom)
2. [test-automation-fwk](../../../test-automation-fwk)

## Source code usage

1. Clone repository "test-parent-pom" (**mandatory**)

```shell
git clone git@github.com:vietnd96/test-parent-pom.git
```

2. Clone this test repository to the same directory

```shell
git clone git@github.com:vietnd96/test-testng-framework.git
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
```

Noted:

* **[includes]** property is used to provide Test Suite xml file would be executed.

## Reference

A sample project with entire repositories together for the test execution.<br>

* [test-automation-project](../../../test-automation-project)
