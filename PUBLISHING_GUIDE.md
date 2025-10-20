# Publishing Guide for TripCost

## Initial GitHub Setup

### 1. Create GitHub Repository

1. Go to [GitHub](https://github.com/new)
2. Create a new repository named `TripCost`
3. Set it to Public or Private
4. **Don't initialize with README** (we already have one)

### 2. Push Code to GitHub

```bash
cd /Users/soft/Desktop/Codebase/macOSApps/TripCost

# Initialize git (if not already done)
git init

# Add all files
git add .

# Commit
git commit -m "Initial commit: TripCost macOS app with glass UI"

# Add remote (replace YOUR_USERNAME with your GitHub username)
git remote add origin https://github.com/SOFTowaha/TripCost.git

# Push to GitHub
git branch -M main
git push -u origin main
```

## Creating a Release

### Method 1: Using GitHub Actions (Automated)

1. **Tag your release**:
   ```bash
   git tag -a v1.0.0 -m "Release v1.0.0"
   git push origin v1.0.0
   ```

2. **GitHub Actions will automatically**:
   - Build the app
   - Create DMG and ZIP files
   - Create a GitHub release with release notes
   - Upload the files to the release

3. **Check the release**:
   - Go to `https://github.com/SOFTowaha/TripCost/releases`
   - You'll see your new release with downloadable files

### Method 2: Manual Release

1. **Build the app in Xcode**:
   - Open Xcode
   - Select "Any Mac" as destination
   - Product → Archive
   - Wait for build to complete

2. **Export the app**:
   - In Organizer window, click "Distribute App"
   - Choose "Copy App"
   - Save the app

3. **Create DMG** (optional but recommended):
   ```bash
   # Create a folder for the DMG
   mkdir TripCost-DMG
   cp -R /path/to/exported/TripCost.app TripCost-DMG/
   
   # Create DMG
   hdiutil create -volname "TripCost" -srcfolder TripCost-DMG -ov -format UDZO TripCost-v1.0.0.dmg
   ```

4. **Create Release on GitHub**:
   - Go to `https://github.com/SOFTowaha/TripCost/releases/new`
   - Tag: `v1.0.0`
   - Title: `TripCost v1.0.0`
   - Upload DMG and/or ZIP file
   - Write release notes
   - Click "Publish release"

## Version Numbering

Use [Semantic Versioning](https://semver.org/):
- **v1.0.0** - Major release
- **v1.1.0** - Minor release (new features)
- **v1.0.1** - Patch release (bug fixes)

## Release Checklist

Before releasing:

- [ ] All features work as expected
- [ ] No critical bugs
- [ ] Code is clean and documented
- [ ] README is up to date
- [ ] Version number updated in Xcode project
- [ ] Tested on target macOS version
- [ ] Screenshots added (optional)
- [ ] Release notes prepared

## CI/CD Workflows

### Build Workflow
- **Trigger**: Every push and PR
- **Purpose**: Ensure code builds successfully
- **Status**: Shows build badge on README

### Release Workflow
- **Trigger**: When you push a tag (e.g., `v1.0.0`)
- **Purpose**: Automatically build and release
- **Output**: DMG and ZIP files on GitHub Releases

## Monitoring

- Check workflow status: `https://github.com/SOFTowaha/TripCost/actions`
- View releases: `https://github.com/SOFTowaha/TripCost/releases`
- Monitor issues: `https://github.com/SOFTowaha/TripCost/issues`

## Tips

1. **Test releases first**: Use pre-release tags like `v1.0.0-beta.1`
2. **Keep changelog**: Document what changed in each release
3. **Respond to issues**: Engage with users who report bugs
4. **Update regularly**: Keep dependencies and code up to date

## Troubleshooting

### Build fails on GitHub Actions
- Check Xcode version in workflow file
- Ensure project builds locally first
- Check workflow logs for errors

### DMG creation fails
- Ensure folder structure is correct
- Try building locally first
- Check file permissions

### Release not appearing
- Check that you pushed the tag: `git push origin v1.0.0`
- Check GitHub Actions logs
- Ensure workflow has write permissions

## Next Steps

1. Push your code to GitHub
2. Tag version `v1.0.0`
3. Watch GitHub Actions build
4. Share your release!

---

Good luck with your release! 🚀
