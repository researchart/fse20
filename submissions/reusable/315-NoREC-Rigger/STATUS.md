# Reusable badge

We are applying for a reusable badge due to the following reasons:

## Availability

* Our tool is publicly available on [GitHub](https://github.com/sqlancer/sqlancer), and a long-term snapshot is archived on [Zenodo](http://doi.org/10.5281/zenodo.3877105).
* We intend to maintain and extend SQLancer to increase the impact of NoREC, and of [the other DBMS testing approaches (which are unpublished)](https://www.manuelrigger.at/dbms-bugs/) that we designed and implemented.

## Completeness

* The artifact includes a list of all bugs that we found using NoREC.
* The artifact includes SQLancer and the NoREC implementations for SQLite, MariaDB, PostgreSQL, and CockroachDB.

## Documentation

* We believe that SQLancer is sufficiently documented. We are in the process of further enhancing and extending its documentation.

## Reusability

* The database and query generation is designed to be reusable, and is, in fact, shared by our DBMS testing approaches PQS, NoREC, and TLP (see [here](https://www.manuelrigger.at/dbms-bugs/)).
* We implemented NoREC not only for the DBMS mentioned in the paper, but also for DuckDB, demonstrating that SQLancer is extensible.
* We use [Travis CI](https://travis-ci.com/) on the GitHub repository to check that the code is and stays compilable as well as executable.
* We have been using extensive tool support to improve and check the code quality of SQLancer (specifically the Eclipse code formatter, Checkstyle, PMD, and SpotBugs), which are also automatically checked as part of the Travis CI gate.

## Reception

* We invested significant effort to make the tool re-usable and attractive to the wider community, which is reflected by the increasing number of GitHub stars; note that we released SQLancer only on June 2, 2020.
