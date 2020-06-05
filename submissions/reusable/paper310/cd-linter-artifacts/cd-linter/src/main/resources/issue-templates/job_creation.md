GitLab config: Job '<JOB_NAME>' is not created when certain new commits are pushed
---
To fully benefit from the advantages of CI/CD, developers need to follow certain principles. Many of these principles have been introduced in the landmark book [Continuous Delivery: Reliable Software Releases through Build, Test, and Deployment Automation](https://www.oreilly.com/library/view/continuous-delivery-reliable/9780321670250/) and are nowadays widely accepted. One of these principles is:

> Every committed change has to be built through the entire CI/CD pipeline (meaning that every defined job should be executed). 
If not, defects, that can only be reported during a certain job, might be discovered later in the development process (becoming harder to fix) or even discovered by users in production.

TODO: This template does not seem to be complete!

**Problem**: We analyzed your project and found that the file [`<SHORT_FILE_NAME>`](<REPO_LINK>/<RELATIVE_PATH>#L<LINE_NUMBER>) (line <LINE_NUMBER>) violates this principle. Job `<JOB_NAME>` is set to <SUB_CATEGORY_ONLY_EXCEPT_MSG> be created in stage `<STAGE_NAME>` if developers commit changes <SUB_CATEGORY_MSG>

**Suggested Fix:** TODO: You can either add entries in .gitignore, skip the build in the commit message, or modify the config file (suggest a way to keep the exclusion but including all the other commits).

**Disclaimer:**
This issue has been automatically reported by [CD-Linter](https://bitbucket.org/sealuzh/cd-linter/), a tool developed at the [University of Zurich](https://www.uzh.ch/) that detects CI/CD violations in the GitLab CI/CD pipeline configuration.
We are currently evaluating the effectiveness of our tool and we are monitoring this issue.

*Please up/downvote this issue to indicate whether you agree/disagree with the report.*