GitLab config: '<SHORT_FILE_NAME>' does not specify the exact version of all dependencies
---
To fully benefit from the advantages of CI/CD, developers need to follow certain principles. Many of these principles have been introduced in the landmark book [Continuous Delivery: Reliable Software Releases through Build, Test, and Deployment Automation](https://www.oreilly.com/library/view/continuous-delivery-reliable/9780321670250/) and are nowadays widely accepted. One of these principles is:

> A build configuration should always specify exact versions of external libraries to make a build reproduceable.
A lack of exact versions can cause problems when new versions of a dependency become available in the future that might introduce incompatible changes.

**Problem**: We analyzed your project and found that the following dependency in [<SHORT_FILE_NAME>](<LINK_TO_FILE>#L<LINE_NUMBER>) (line <LINE_NUMBER>) violates this principle, because it does not define an exact version (<MESSAGE>).

* [<DEP_NAME>](<LINK_TO_FILE>#L<LINE_NUMBER>)

**Suggested Fix:** Specify the exact version.

**Disclaimer:**
This issue has been automatically reported by [CD-Linter](https://bitbucket.org/sealuzh/cd-linter/), a tool developed at the [University of Zurich](https://www.uzh.ch/) that detects CI/CD violations in the GitLab CI/CD pipeline configuration.
We are currently evaluating the effectiveness of our tool and we are monitoring this issue.

*Please up/downvote this issue to indicate whether you agree/disagree with the report.*