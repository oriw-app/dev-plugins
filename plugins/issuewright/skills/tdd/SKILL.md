---
name: tdd
description: Test-driven development - red, green, refactor - for every rule, core first. Use whenever writing or changing code, fixing a bug, or planning the order of work.
---

# TDD

1. **Red:** write a unit test for one rule and run it; it must fail for the right reason.
2. **Green:** write the least code that makes it pass. Domain and application code first.
3. **Refactor:** tidy names and structure with all tests still green.
4. Repeat rule by rule; then adapters, each tested against its port's contract; then wiring; then the scenarios pass.

Rules:
- No rule without a unit test written before it. The `test-first` hook blocks editing source code until a test or scenario for it has changed on the branch.
- **Bug fixes start with a failing test** that reproduces the bug, committed first. The `tests-locked` hook then stops it being edited: fix the code, not the test. If the test itself is wrong, stop and ask the owner.
- Tests are fast and offline: unit tests in milliseconds; slow parameters (crypto costs, big data) are reduced in tests.
- Commit order shows test before code where practical.
