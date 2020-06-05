GitLab config: Failures in job '<JOB_NAME>' cannot fail the build
---
To fully benefit from the advantages of CI/CD, developers need to follow certain principles. Many of these principles have been introduced in the landmark book [Continuous Delivery: Reliable Software Releases through Build, Test, and Deployment Automation](https://www.oreilly.com/library/view/continuous-delivery-reliable/9780321670250/) and are nowadays widely accepted. One of these principles is:

> Every executed job should be able to fail the build.
If not, developers can miss or ignore the underlying issue, which adds technical debt and might result in problems later.

**Problem**: We analyzed your project and found that the file [<SHORT_FILE_NAME>](<LINK_TO_FILE>#L<LINE_NUMBER>) (line <LINE_NUMBER>) violates this principle. Failures of job `<JOB_NAME>` (in stage `<STAGE_NAME>`), cannot fail the build:

```
<JOB_NAME>:
    ...
    allow_failure: true
    ...
```

**Suggested Fix:** To follow the principle, you should set ```allow_failure: false```.

**Disclaimer:**
This issue has been automatically reported by [CD-Linter](https://bitbucket.org/sealuzh/cd-linter/), a tool developed at the [University of Zurich](https://www.uzh.ch/) that detects CI/CD violations in the GitLab CI/CD pipeline configuration.
We are currently evaluating the effectiveness of our tool and we are monitoring this issue.

*Please up/downvote this issue to indicate whether you agree/disagree with the report.*