---
description: Execute tests with coverage
---

You are responsible for reviewing the PR and generating a manual QA/testing guide.

Analyze all changes made in the PR and generate a detailed step-by-step validation guide for the implemented feature/fix.

In addition to the chat response, you MUST automatically create a markdown file at:

/pr-how-to-test/[name].md

Rules:
- The file name must represent the feature or fix implemented
- Use kebab-case for the file name
- Examples:
  - /pr-how-to-test/login-fix.md
  - /pr-how-to-test/create-user-flow.md

IMPORTANT:
- The generated markdown file is for local documentation/testing purposes only
- NEVER stage, commit, or push this file
- NEVER include this file in the PR commit
- If needed, automatically add the file or folder to `.git/info/exclude` or `.gitignore`
- Treat `/pr-how-to-test/*.md` as temporary local QA documentation

The markdown file content must include:

# Objective
Briefly explain what was changed.

# Affected Flows
List affected screens, routes, APIs, commands, or behaviors.

# Prerequisites
List everything required before testing.

# How to Test
Create a detailed numbered step-by-step guide.

Example:
1. Open page X
2. Click button Y
3. Fill form Z
4. Validate the expected behavior

# Expected Result
Explain the expected outcome after testing.

# Edge Cases
List important additional scenarios to validate.

# Risks
List possible impacts or sensitive areas.

# Quick Checklist
- [ ] Main flow works
- [ ] No regression introduced
- [ ] Responsiveness OK
- [ ] Errors properly handled
- [ ] Loading states working

If backend changes exist:
- explain how to validate endpoints
- include request examples
- validate status codes
- mention possible database/cache/queue impacts

If frontend changes exist:
- explain visual validations
- loading/error states
- responsiveness
- basic accessibility validations

Automatically detect whether the changes are related to frontend, backend, infrastructure, or database, and adapt the testing guide accordingly.

Also include:
- possible regressions
- review attention points
- scenarios that could break in production

The result must be practical, concise, and ready to be used for QA/review purposes.
