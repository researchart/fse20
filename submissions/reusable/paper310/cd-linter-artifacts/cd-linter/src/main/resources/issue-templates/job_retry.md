GitLab config: Job '<JOB_NAME>' is retried in case of failures
---
To fully benefit from the advantages of CI/CD, developers need to follow certain principles. Many of these principles have been introduced in the landmark book [Continuous Delivery: Reliable Software Releases through Build, Test, and Deployment Automation](https://www.oreilly.com/library/view/continuous-delivery-reliable/9780321670250/) and are nowadays widely accepted. One of these principles is:

> The build process has to be deterministic. Flaky behavior, e.g., tests that sometimes fail, should be avoided at all cost, because this causes maintenance issues. However, addressing this issue through retries after failures might not only hide the underlying problem, but makes issues also harder to debug when they only occur sometimes.

**Problem**: We analyzed your project and found that the file [<SHORT_FILE_NAME>](<LINK_TO_FILE>#L<LINE_NUMBER>) (line <LINE_NUMBER>) violates this principle. The job `<JOB_NAME>` (in stage `<STAGE_NAME>`) is set to be retried in case of failures:

```
<JOB_NAME>:
    ...
    retry: <RETRIES_NUMBER>
    ...
```

**Suggested Fix:** Remove ```retry: <RETRIES_NUMBER>``` from the job definition or consider adding the option ```when``` to specify failures cases (e.g., ```runner_system_failure```) in which the job can be retried without hiding flaky tests.

**Disclaimer:**
This issue has been automatically reported by [CD-Linter](https://bitbucket.org/sealuzh/cd-linter/), a tool developed at the [University of Zurich](https://www.uzh.ch/) that detects CI/CD violations in the GitLab CI/CD pipeline configuration.
We are currently evaluating the effectiveness of our tool and we are monitoring this issue.

*Please up/downvote this issue to indicate whether you agree/disagree with the report.*