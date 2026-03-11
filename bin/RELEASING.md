# Release guide

## Why releases are done manually (not CI/CD)

The compilation step cannot be automated in a headless CI environment (e.g. GitHub Actions), for a fundamental reason:

The main script uses `tell application (keynoteAppName)` where `keynoteAppName` is a runtime variable, not a string literal. This dynamic targeting is intentional — it lets the script auto-detect whether Keynote Creator Studio or legacy Keynote is running. However, `osacompile` (the command-line AppleScript compiler) needs a static app name at compile time to load the Keynote scripting dictionary and resolve Keynote-specific terms like `current slide` and `skipped`. Without it, compilation fails with a syntax error.

The workaround `using terms from application "Keynote"` requires Keynote to be installed on the machine doing the compilation. GitHub Actions macOS runners do not have Keynote (or any App Store app) pre-installed, and installing it via `mas` requires an interactive App Store login which is not possible in CI.

Script Editor handles all of this transparently because it is interactive and can resolve terms at edit time. This is why step 3 below (the export from Script Editor) must be done by hand on a Mac with Keynote installed.

If Apple ever exposes a headless compilation path that loads app dictionaries without the app being present, CI/CD becomes viable again. Until then, the manual step is unavoidable.

---

## Prerequisites (one-time setup)

- Xcode installed with the **KeynoteProgressBarHelper** scheme building successfully.
- Developer ID certificate in your keychain:
  `Developer ID Application: Andrea Alberti (9V3X7C8VCK)`
- `notarytool` credentials stored (only needed once per machine):
  ```bash
  xcrun notarytool store-credentials "notary-profile" \
    --apple-id "YOUR_APPLE_ID_EMAIL" \
    --team-id "9V3X7C8VCK" \
    --password "APP_SPECIFIC_PASSWORD"
  ```
  Generate the app-specific password at https://appleid.apple.com → Sign-In and Security → App-Specific Passwords.

---

## Step-by-step release process

### 1. Write release notes

```bash
vi release-notes/release-vX.Y.Z.md
```

### 2. Build the Objective-C framework

Open `Objective-C/KeynoteProgressBarHelper.xcodeproj` in Xcode.
Select the **KeynoteProgressBarHelper** scheme, **Release** configuration, and build (`⌘B`).
Note the path to the built framework (shown in the build log, or find it via **Product → Show Build Folder in Finder**).

### 3. Export the AppleScript app from Script Editor

- Open `AppleScript/Add Progress Bar to Keynote.applescript` in **Script Editor**.
- **File → Export…**
  - File Format: **Application**
  - Save as: `Add Progress Bar to Keynote.app` (anywhere convenient, e.g. your Desktop)

### 4. Embed the framework into the app

```bash
mkdir -p "Add Progress Bar to Keynote.app/Contents/Frameworks"
cp -R "/path/to/KeynoteProgressBarHelper.framework" \
      "Add Progress Bar to Keynote.app/Contents/Frameworks/"
```

### 5. Sign, notarize, and package as DMG

From the repo root:

```bash
bin/notarize_app.sh "Add Progress Bar to Keynote.app"
```

This script:
1. Stages a clean copy (strips resource forks and xattrs)
2. Signs the embedded framework
3. Signs the app
4. Creates a DMG with an Applications symlink
5. Signs the DMG
6. Submits to Apple Notary Service and waits
7. Staples the ticket to the DMG
8. Runs a Gatekeeper check

Output: `Add_Progress_Bar_to_Keynote.dmg` in the current directory.

### 6. Commit, tag, and push

```bash
git add release-notes/release-vX.Y.Z.md
git commit -m "Add release notes for vX.Y.Z"
git tag vX.Y.Z
git push origin main
git push origin vX.Y.Z
```

### 7. Create the GitHub release

```bash
gh release create vX.Y.Z Add_Progress_Bar_to_Keynote.dmg \
  --title "vX.Y.Z" \
  --notes-file release-notes/release-vX.Y.Z.md \
  --latest
```

---

## Notarizing the framework standalone (optional)

Only needed if you distribute the framework separately (e.g. for developers using it as a dependency):

```bash
bin/notarize_framework.sh "/path/to/KeynoteProgressBarHelper.framework"
```

Output: `KeynoteProgressBarHelper.framework.zip` in the current directory.
