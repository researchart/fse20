GitLab config: Job '<JOB_NAME>' is manually triggered
---
To fully benefit from the advantages of CI/CD, developers need to follow certain principles. Many of these principles have been introduced in the landmark book [Continuous Delivery: Reliable Software Releases through Build, Test, and Deployment Automation](https://www.oreilly.com/library/view/continuous-delivery-reliable/9780321670250/) and are nowadays widely accepted. One of these principles is:

> The build process has to be fully automated. 
Manual steps might introduce errors and delay the delivery of code changes to the clients.

**Problem**: We analyzed your project and found that the job `<JOB_NAME>` in your [GitLab config](<LINK_TO_FILE>#L<LINE_NUMBER>) (line <LINE_NUMBER>) violates this principle, because it is set to be executed manually.

```
<JOB_NAME>:
    ...
    when:manual
    ...
```

**Suggested Fix:** Remove ```when:manual``` from the job definition to execute the job on every build.

**Disclaimer:**
This issue has been automatically reported by [CD-Linter](https://bitbucket.org/sealuzh/cd-linter/), a tool developed at the [University of Zurich](https://www.uzh.ch/) that detects CI/CD violations in the GitLab CI/CD pipeline configuration.
We are currently evaluating the effectiveness of our tool and we are monitoring this issue.

*Please up/downvote this issue to indicate whether you agree/disagree with the report.*