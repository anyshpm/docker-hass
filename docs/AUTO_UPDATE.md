# 🔄 Automated Home Assistant Version Updates

This document explains the automated system for keeping the Home Assistant base image up to date in this Docker project.

## 📋 Overview

The project includes an automated workflow that:
- ✅ Checks daily for new Home Assistant releases
- ✅ Updates the Dockerfile automatically when new versions are available
- ✅ Updates documentation badges
- ✅ Tests the build to ensure compatibility
- ✅ Creates commits and tags automatically
- ✅ Triggers CI builds for the new version
- ✅ Creates tracking issues for manual review

## 🤖 Automated Workflow

### File: `.github/workflows/update-homeassistant.yml`

**Trigger Schedule:**
- 🕕 Daily at 06:00 UTC
- 🖱️ Manual trigger via GitHub Actions UI
- 🔧 Manual trigger with force update option

**Process Flow:**
1. **Version Detection**: Fetches the latest Home Assistant version from Docker Hub API
2. **Comparison**: Compares with current version in Dockerfile
3. **Update**: Updates Dockerfile and README badges if newer version found
4. **Testing**: Performs a test build to verify compatibility
5. **Commit**: Creates an automated commit with detailed message
6. **Tagging**: Creates a release tag matching the Home Assistant version
7. **Notification**: Creates a GitHub issue for manual review
8. **CI Trigger**: Automatically triggers the CI build workflow

**Permissions Required:**
- `contents: write` - To commit and push changes
- `pull-requests: write` - To create review issues
- `actions: write` - To trigger other workflows

## 🛠️ Manual Scripts

### Bash Script: `scripts/update-homeassistant.sh`

A bash script for Linux/macOS users for local testing and manual updates.

**Usage:**
```bash
# Basic update check and apply
./scripts/update-homeassistant.sh

# Force update even if version is same
./scripts/update-homeassistant.sh --force

# Dry run to see what would be changed
./scripts/update-homeassistant.sh --dry-run

# Help
./scripts/update-homeassistant.sh --help
```

### PowerShell Script: `scripts/update-homeassistant.ps1`

A PowerShell script for Windows users with the same functionality.

**Usage:**
```powershell
# Basic update check and apply
.\scripts\update-homeassistant.ps1

# Force update even if version is same
.\scripts\update-homeassistant.ps1 -Force

# Dry run to see what would be changed
.\scripts\update-homeassistant.ps1 -DryRun

# Help
.\scripts\update-homeassistant.ps1 -Help
```

**Features:**
- 🔍 Version comparison with Docker Hub API
- 📦 Automatic backup creation
- 🧪 Optional Docker build testing
- 🎨 Colored output for better readability
- 🛡️ Safety checks and error handling

## 🔧 Configuration

### Environment Variables

The workflow can be configured through repository settings:

| Variable | Description | Default |
|----------|-------------|---------|
| `GITHUB_TOKEN` | GitHub token for API access | Automatic |

### Repository Secrets

Required secrets for the workflow:

| Secret | Description | Required |
|--------|-------------|----------|
| `DOCKERHUB_USERNAME` | Docker Hub username | Yes (for CI) |
| `DOCKERHUB_TOKEN` | Docker Hub access token | Yes (for CI) |

### Workflow Inputs

Manual trigger supports:

| Input | Type | Description | Default |
|-------|------|-------------|---------|
| `force_update` | boolean | Force update even if version is same | false |

## 📊 Monitoring

### GitHub Actions Dashboard
- Monitor workflow runs in the "Actions" tab
- View detailed logs for each step
- Check job summaries for quick status overview

### Notifications
- 📧 GitHub issue created for each update
- 🏷️ Release tags created automatically
- 📝 Detailed commit messages with changelog links

### Manual Review Points
When an automated update occurs, review:
- ✅ Dockerfile changes are correct
- ✅ Build compatibility (check CI results)
- ✅ No breaking changes in new Home Assistant version
- ✅ Telegram proxy functionality still works
- ✅ Documentation is up to date

## 🚨 Troubleshooting

### Common Issues

#### Workflow Fails to Fetch Latest Version
**Symptoms:** API request to Docker Hub fails
**Solutions:**
- Check Docker Hub API status
- Verify network connectivity
- Review API rate limits

#### Build Test Fails
**Symptoms:** Docker build fails with new version
**Solutions:**
- Check Home Assistant breaking changes
- Review patch file compatibility
- Manual testing with new version

#### Push Fails
**Symptoms:** Git push rejected
**Solutions:**
- Check repository permissions
- Verify GITHUB_TOKEN scope
- Review branch protection rules

#### Version Detection Issues
**Symptoms:** Wrong version detected or parsed
**Solutions:**
- Verify Docker Hub API response format
- Check version regex pattern
- Review jq query syntax

### Debug Steps

1. **Manual Testing:**
   ```bash
   # Test the manual script first
   ./scripts/update-homeassistant.sh --dry-run
   ```

2. **API Testing:**
   ```bash
   # Test Docker Hub API directly
   curl -s "https://registry.hub.docker.com/v2/repositories/homeassistant/home-assistant/tags?page_size=10"
   ```

3. **Build Testing:**
   ```bash
   # Test build with specific version
   docker build --build-arg HA_VERSION=2025.4.1 -t test .
   ```

### Workflow Debugging

Enable debug logging:
1. Go to repository Settings → Secrets and variables → Actions
2. Add `ACTIONS_STEP_DEBUG` = `true`
3. Re-run the workflow for detailed logs

## 🔐 Security Considerations

### Token Permissions
- Workflow uses minimal required permissions
- GITHUB_TOKEN is scoped to repository only
- No external credentials exposed in logs

### Automated Changes
- All changes are committed with clear attribution
- Changes are traceable through Git history
- Manual review process via GitHub issues

### Build Security
- Test builds performed in isolated environment
- No credentials or secrets in build context
- Base image verified through official channels

## 🔄 Workflow Maintenance

### Regular Tasks
- 📅 Monthly: Review workflow performance and logs
- 📅 Quarterly: Update action versions (checkout, docker actions, etc.)
- 📅 Annually: Review and update API endpoints and authentication

### Version Updates
Keep these actions updated:
- `actions/checkout@v4`
- `docker/setup-buildx-action@v3`
- `actions/github-script@v7`

### Monitoring Health
- Set up notifications for workflow failures
- Monitor GitHub Actions usage quotas
- Review update frequency and patterns

## 📚 References

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Docker Hub API Documentation](https://docs.docker.com/docker-hub/api/latest/)
- [Home Assistant Release Notes](https://github.com/home-assistant/core/releases)
- [Semantic Versioning](https://semver.org/)

---

For questions or issues with the automated update system, please create an issue in this repository.