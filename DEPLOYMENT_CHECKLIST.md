# SAFAR-Nexus Deployment Checklist

Use this checklist to ensure successful deployment.

---

## Pre-Deployment

### Prerequisites Setup

- [ ] Google Cloud Platform account created
- [ ] Billing enabled on GCP project
- [ ] gcloud CLI installed and authenticated
- [ ] Docker installed (for local testing)
- [ ] Flutter SDK installed (for mobile build)
- [ ] Git repository configured

### Acquire Resources

- [ ] Google Maps API key obtained (Android)
- [ ] Google Maps API key obtained (iOS)
- [ ] AI model (.tflite) downloaded/trained
- [ ] Service account created for GCP

### Configuration Files

- [ ] `.env` file created from `.env.example`
- [ ] JWT secret key generated (32+ characters)
- [ ] Database password generated
- [ ] All sensitive data added to `.gitignore`

---

## Local Testing

### Backend Testing

- [ ] Docker Compose services started
- [ ] Database accessible on localhost:5432
- [ ] Backend running on localhost:8000
- [ ] Health endpoint responds: `curl http://localhost:8000/health`
- [ ] Register endpoint works
- [ ] Login endpoint works
- [ ] Hazard upload endpoint tested (requires multipart)
- [ ] Nearby hazards query works

### Mobile App Testing

- [ ] Backend URL updated to local IP
- [ ] Google Maps API keys added
- [ ] App builds successfully
- [ ] App runs on emulator/device
- [ ] Camera preview loads
- [ ] Map displays correctly
- [ ] GPS location acquired
- [ ] Login/Register flow works
- [ ] API calls successful

---

## Production Deployment - Backend

### Google Cloud Setup

- [ ] GCP project created
- [ ] Project ID noted: ________________
- [ ] Billing account linked
- [ ] Required APIs enabled:
  - [ ] Cloud Run API
  - [ ] Cloud SQL Admin API
  - [ ] Cloud Storage API
  - [ ] Cloud Build API
  - [ ] Container Registry API

### Database Setup

- [ ] Cloud SQL instance created
- [ ] PostgreSQL 15 selected
- [ ] Instance name: ________________
- [ ] Region selected: ________________
- [ ] Root password set securely
- [ ] Database `safar_nexus` created
- [ ] PostGIS extension enabled
- [ ] UUID extension enabled
- [ ] Connection string noted

### Storage Setup

- [ ] Cloud Storage bucket created
- [ ] Bucket name: ________________
- [ ] Region matches database region
- [ ] Public access configured (or signed URLs)
- [ ] CORS configured if needed

### Service Account Setup

- [ ] Service account created for backend
- [ ] Storage Admin role granted
- [ ] Cloud SQL Client role granted
- [ ] Service account key JSON downloaded
- [ ] Key stored securely (not in git)

### Backend Deployment

- [ ] Docker image built
- [ ] Image pushed to Container Registry
- [ ] Cloud Run service created
- [ ] Service name: ________________
- [ ] Environment variables configured:
  - [ ] DATABASE_URL
  - [ ] JWT_SECRET_KEY
  - [ ] GCS_BUCKET_NAME
  - [ ] GOOGLE_APPLICATION_CREDENTIALS
- [ ] Cloud SQL connection added
- [ ] Service deployed successfully
- [ ] Service URL obtained: ________________

### Backend Verification

- [ ] Service health check passes
- [ ] API documentation accessible at `/docs`
- [ ] User registration works
- [ ] User login returns valid JWT
- [ ] Hazard upload works with test image
- [ ] Database records created correctly
- [ ] Images uploaded to Cloud Storage
- [ ] Spatial queries work (nearby hazards)

---

## Production Deployment - Mobile

### Configuration

- [ ] Backend URL updated in `constants.dart`
- [ ] Production API URL: ________________
- [ ] Google Maps API key added (Android manifest)
- [ ] Google Maps API key added (iOS Info.plist)
- [ ] AI model placed in `assets/models/`
- [ ] Model file size checked (<10MB)

### Android Build

- [ ] Signing key generated/obtained
- [ ] Signing configuration added
- [ ] Release APK built
- [ ] APK tested on physical device
- [ ] App Bundle (AAB) built for Play Store
- [ ] Version code/name updated

### iOS Build (if applicable)

- [ ] Xcode project opened
- [ ] Signing certificate configured
- [ ] Provisioning profile set
- [ ] Release build created
- [ ] App tested on physical device
- [ ] Archive created for App Store

### Mobile App Verification

- [ ] App installs successfully
- [ ] Permissions requested and granted
- [ ] Login screen displays
- [ ] Registration works with backend
- [ ] Login works with backend
- [ ] Camera preview shows
- [ ] AI service initializes (no crash)
- [ ] Map loads with Google Maps
- [ ] User location marker shows
- [ ] Hazard markers display
- [ ] Hazard upload works end-to-end

---

## CI/CD Setup (Optional)

### GitHub Repository

- [ ] Code pushed to GitHub
- [ ] Main branch protected
- [ ] `.github/workflows/ci-cd.yml` present

### GitHub Secrets

- [ ] `GCP_PROJECT_ID` added
- [ ] `GCP_SA_KEY` added (service account JSON)
- [ ] `DATABASE_URL` added
- [ ] `JWT_SECRET_KEY` added
- [ ] `GCS_BUCKET_NAME` added
- [ ] `CLOUD_SQL_CONNECTION` added

### CI/CD Verification

- [ ] Push to main triggers workflow
- [ ] Backend tests pass
- [ ] Docker image builds
- [ ] Image pushes to registry
- [ ] Cloud Run deployment succeeds
- [ ] Mobile APK builds successfully

---

## Post-Deployment

### Security Verification

- [ ] JWT secret is strong (32+ chars)
- [ ] Database password is strong
- [ ] Service account has minimal permissions
- [ ] HTTPS enforced (automatic on Cloud Run)
- [ ] API keys not exposed in code
- [ ] `.gitignore` blocks sensitive files
- [ ] Environment variables secured

### Performance Checks

- [ ] API response time <500ms
- [ ] Image upload completes <3s
- [ ] Database queries optimized
- [ ] Cloud Run cold start acceptable (<2s)
- [ ] Mobile app frame rate adequate

### Monitoring Setup

- [ ] Cloud Run logs accessible
- [ ] Cloud SQL logs accessible
- [ ] Error tracking configured
- [ ] Uptime monitoring configured
- [ ] Alert policies created

### Documentation

- [ ] API URL documented
- [ ] Database connection details saved
- [ ] Service account keys backed up
- [ ] Deployment process documented
- [ ] Team members have access

---

## Cost Optimization

- [ ] Cloud Run min instances set to 0
- [ ] Cloud SQL instance size appropriate
- [ ] Storage lifecycle policies set
- [ ] Unused resources cleaned up
- [ ] Budget alerts configured
- [ ] Estimated monthly cost: $__________

---

## Maintenance Plan

### Regular Tasks

- [ ] Weekly backup verification
- [ ] Monthly cost review
- [ ] Quarterly dependency updates
- [ ] Security patch schedule defined

### Backup Configuration

- [ ] Database automated backups enabled
- [ ] Backup retention period set
- [ ] Storage versioning enabled
- [ ] Recovery procedure tested

---

## Troubleshooting Prepared

### Have Ready

- [ ] Backend logs access command
- [ ] Database connection command
- [ ] Service restart command
- [ ] Rollback procedure documented

### Emergency Contacts

- [ ] Backend developer: ________________
- [ ] Mobile developer: ________________
- [ ] DevOps contact: ________________
- [ ] GCP support (if applicable)

---

## Launch Readiness

### Final Checks

- [ ] All previous sections completed
- [ ] End-to-end test successful
- [ ] Performance acceptable
- [ ] Security verified
- [ ] Team trained on system
- [ ] User documentation ready
- [ ] Support process defined

### Go/No-Go Decision

**Status:** ⬜ GO  ⬜ NO-GO

**Deployment Date:** ________________

**Deployed By:** ________________

**Notes:**
```
_____________________________________________________
_____________________________________________________
_____________________________________________________
```

---

## Post-Launch (After 24 Hours)

- [ ] No critical errors in logs
- [ ] User registrations working
- [ ] Hazard uploads successful
- [ ] Mobile app stable
- [ ] Performance metrics normal
- [ ] No unexpected costs

---

**Checklist Version:** 1.0
**Last Updated:** November 2024
**For:** SAFAR-Nexus MVP Deployment
