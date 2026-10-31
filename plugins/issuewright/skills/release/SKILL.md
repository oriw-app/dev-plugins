---
name: release
description: Prepare a release at the end of a milestone - changelog, version bump, tag plan and checks - for the owner to authorise. Use when a milestone is complete or the user runs /release. Never publishes on its own.
---

# Prepare a release

1. **Check the milestone:** every issue in it is closed or deliberately moved; the main branch is green.
2. **Changelog** from merged pull requests since the last tag, grouped by feature, fix and change, in plain words for users.
3. **Version bump** in a `chore/release-<version>` branch and pull request.
4. **Hand over:** list the exact commands or steps to tag and publish. The owner authorises and runs the release; hooks block you from tagging or publishing.
5. **Afterwards:** close the milestone and move any open issues to the next one.
