---
description: Review PR changes and identify issues
---

You are responsible for performing a complete PR/code review.

Analyze all changed files carefully and review the implementation quality, architecture, security, maintainability, and possible regressions.

Your goal is to behave like a senior engineer performing a production-ready review.

Focus on identifying:

- bugs
- regressions
- security issues
- performance problems
- bad practices
- missing validations
- edge cases
- maintainability problems
- scalability concerns
- accessibility issues
- inconsistent patterns
- unnecessary complexity
- missing error handling
- possible race conditions
- breaking changes
- database risks
- frontend UX issues

Review Guidelines:

- Be extremely critical and detailed
- Prefer pointing out real risks over generic compliments
- Explain WHY something is a problem
- Suggest better approaches when applicable
- Identify possible production impacts
- Detect anti-patterns
- Validate naming consistency
- Validate folder/file organization
- Validate architecture decisions
- Check for duplicated logic
- Check for dead code
- Check for missing tests
- Check for missing loading/error states
- Check for improper state handling
- Check for missing backend validations
- Check for possible N+1/database inefficiencies
- Check for cache inconsistencies
- Check for authorization/authentication flaws
- Check for improper environment/config usage
- Check for possible memory leaks
- Check for unnecessary re-renders
- Check for responsiveness/accessibility issues
- Check for possible type safety problems

For every issue found, provide:

## Issue
Short title describing the problem.

## Severity
One of:
- Low
- Medium
- High
- Critical

## File
Mention the affected file(s).

## Problem
Explain the issue clearly and technically.

## Impact
Explain what could happen in production.

## Recommendation
Suggest how to improve/fix it.

If no major issues are found:
- still provide improvement suggestions
- mention possible risks
- mention areas deserving attention before merge

Also provide:

# General Summary
High-level overview of the PR quality.

# Positive Points
List good implementation details.

# Risks Before Merge
List anything that deserves extra validation before merge.

# Final Assessment
Choose one:
- Approve
- Approve with minor changes
- Request changes
- Block merge

IMPORTANT:
- Do not generate fake issues
- Do not praise unnecessarily
- Prefer actionable technical feedback
- Be concise but highly valuable
- Prioritize production-impacting problems
- Think like a staff/senior engineer reviewing mission-critical code
