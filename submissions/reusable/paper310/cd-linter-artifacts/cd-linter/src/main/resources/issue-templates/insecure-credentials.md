GitLab config: Hard-coded credentials in '<SHORT_FILE_NAME>'
---
To fully benefit from the advantages of CI/CD, developers need to follow certain principles. Many of these principles have been introduced in the landmark book [Continuous Delivery: Reliable Software Releases through Build, Test, and Deployment Automation](https://www.oreilly.com/library/view/continuous-delivery-reliable/9780321670250/) and are nowadays widely accepted. One of these principles is:

> Credentials should not be hard-coded in the source code or in configuration files.
They are accessible by the public, which can be exploited to gain access to the project's resources (e.g., remote repository, deployment servers).

**Problem**: We analyzed your project and found that the file [<SHORT_FILE_NAME>](<LINK_TO_FILE>#L<LINE_NUMBER>) (line <LINE_NUMBER>) contains the following credentials:

```
<LINE_TEXT>
```

**Suggested Fix:** Remove the credentials from [<SHORT_FILE_NAME>](<LINK_TO_FILE>#L<LINE_NUMBER>). Either configure them as variables in your GitLab environment or store them in a location that is not accessible by everybody.

**Disclaimer:**
This issue has been automatically reported by [CD-Linter](https://bitbucket.org/sealuzh/cd-linter/), a tool developed at the [University of Zurich](https://www.uzh.ch/) that detects CI/CD violations in the GitLab CI/CD pipeline configuration.
We are currently evaluating the effectiveness of our tool and we are monitoring this issue.

*Please up/downvote this issue to indicate whether you agree/disagree with the report.*