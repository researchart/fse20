# Artifact for "Detecting Optimization Bugs in Database Engines via Non-Optimizing Reference Engine Construction"

The artifact consists of two main components:

1. SQLancer, the tool which we created, and in which we implemented NoREC, to find all bugs reported in the paper.
2. A SQLite database with a list of bugs that we reported and additional meta information.

## Video

To help getting started with the artifact, we recorded a video to explain and demonstrate its main functionality. Please consider watching it (see [video.mp4](video.mp4)).

## SQLancer

SQLancer is a tool to find logic bugs in Database Management Systems (DBMS) that we created, and in which we implemented NoREC. We recommend obtaining the latest source code from its [GitHub repository](https://github.com/sqlancer/sqlancer/) and following the instructions from the GitHub repository. As stated in the `INSTALL.md` document, the easiest way to get started is the following:

```
git clone https://github.com/sqlancer/sqlancer
cd sqlancer
mvn package
cd target
java -jar SQLancer-0.0.1-SNAPSHOT.jar sqlite3 --oracle NoREC
```
The command `sqlite3` specifies that the embedded SQLite driver should be used. NoREC is also supported for other DBMS using the `cockroachdb`, `mariadb`, and `postgres` commands. For these, it is required that you have the respective DBMS versions installed and ready to accept connections. Note that you need to create a dummy database named `test`, if you want to use SQLancer on DBMS other than SQLite. The option `--oracle NoREC` specifies that the oracle to be used is the one described in the paper; SQLancer also supports other test oracles. SQLancer is highly configurable. Launching it without options prints a list of all supported commands and options:

```
java -jar SQLancer-0.0.1-SNAPSHOT.jar
```

SQLancer runs in two phases when using NoREC:
1. It generates a random database.
2. It generates a random "optimized" query and checks that it yields the same result as the "unoptimized" query.

Both phases are coordinated in the `*Provider` classes. For example, the `sqlancer.sqlite3.SQLite3Provider` class first generates tables, then randomly picks applicable SQL statements, and then uses a `TestOracle` that is executed the specified number of times. The NoREC test oracle is implemented in classes `*NoRECOracle`. For example, for SQLite, NoREC is implemented in the `sqlancer.sqlite3.oracle.SQLite3NoRECOracle` class.

## List of Bugs

To provide evidence for the bugs we found, we provide a SQLite database `bugs.db` that can be opened with a tool such as [DB Browser for SQLite](https://sqlitebrowser.org/) or the [SQLite3 CLI](https://www.sqlite.org/index.html).

### Tables

* `DMBS_BUGS`: This table contains all the bugs that we reported. It contains also a column `REPRODUCIBLE_WITH_PQS` to denote whether a bug could have been found by PQS (see Section 4.4).
* `PQS_BUGS`: This table contains a list of bugs found by Pivoted Query Synthesis (PQS). The `REPRODUCIBLE_WITH_NOREC` column indicates whether the bug could have been found by NoREC (see Section 4.4).
* `BUG_TAGS`: This table contains tags that are associated with a bug ID.
* `BUG_TEST_CASES`: This table breaks down test cases to reproduce a bug to single SQL statements.

In addition, a number of views are defined, which aggregate and filter data from these tables. For example, the view `DBMS_BUGS_TRUE_POSITIVES` contains a list of all *true* bugs, excluding false positive bug reports.

### Validating the Main Results of the Paper

#### Section 4.3 "Bugs Overview"


Determine the total number of bugs found by each DBMS:

```sql
SELECT database, COUNT(database) FROM DBMS_BUGS_TRUE_POSITIVES GROUP BY database;
```

Determine the total number of bug reports assigned to each bug report status:

```sql
SELECT STATUS, SUM(count) FROM DBMS_BUGS_STATUS GROUP BY STATUS;
```

Determine the total number of bug reports assigned to each bug report status, broken down by the DBMS (see Table 2): 

```sql
SELECT DATABASE, STATUS, count FROM DBMS_BUGS_STATUS UNION SELECT DATABASE, 'fixedInDocsOrCode' as STATUS, SUM(count) FROM DBMS_BUGS_STATUS WHERE STATUS IN ('fixed', 'fixed (in documentation)') GROUP BY database;
```

Determine the test oracles and how many bugs they found (see Table 3):

```sql
SELECT DATABASE, ORACLE, count FROM ORACLES_AGGREGATED
UNION 
SELECT 'sum' as DATABASE, ORACLE, sum(count) FROM ORACLES_AGGREGATED GROUP BY ORACLE;
```

#### Section 4.4 "Comparison to PQS"

Determine the percentage of bugs found by NoREC that could also have been found by PQS (see paragraph "Bugs found only by NoREC"):

```sql
SELECT ROUND(COUNT(*) * 100.00 / (SELECT COUNT(*) FROM ORACLE_COMPARISONS), 1) FROM ORACLE_COMPARISONS WHERE REPRODUCIBLE_WITH_PQS; -- 56.9
```

Bugs only found by NoREC and their reasons (see paragraph "Bugs found only by NoREC"):
```sql
SELECT COUNT(*) as count, reproducible_with_pqs_reason FROM ORACLE_COMPARISONS WHERE REPRODUCIBLE_WITH_PQS_REASON NOT NULL GROUP BY REPRODUCIBLE_WITH_PQS_REASON
```

Also taking into account that PQS could check for pivot rows that are not fetched (see paragraph "Bugs found only by PQS"):

```sql
SELECT ROUND(COUNT(*) * 100.00 / (SELECT COUNT(*) FROM ORACLE_COMPARISONS), 1) FROM ORACLE_COMPARISONS WHERE REPRODUCIBLE_WITH_PQS OR REPRODUCIBLE_WITH_PQS_REASON="incorrectly fetched"; -- 82.4
```

Bugs found only by PQS and their reasons (see paragraph "Bugs found only by PQS"):

```sql
SELECT COUNT(*) as count, reason FROM PQS_BUGS WHERE NOT reproducible_with_norec GROUP BY reason
```
