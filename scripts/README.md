# Deployment Scripts

SAFAR-Nexus supports both **FREE** and **Paid** deployment options.

---

## 🎉 FREE Deployment (Recommended for MVP)

**Cost:** $0/month - No credit card required!

### Quick Start

```bash
./scripts/deploy-free.sh
```

### What You Get (FREE)

| Service | Purpose | FREE Tier |
|---------|---------|-----------|
| **Railway** | Backend Hosting | 500 hrs/month + $5 credit |
| **Neon** | PostgreSQL + PostGIS | 3GB storage |
| **Cloudinary** | Image Storage | 25GB storage, 25GB bandwidth |

**Total:** $0/month ✨

### Setup Time

- **5 minutes** - Automated script handles everything
- **No credit card** required for any service
- **No surprises** - Completely free

### Perfect For

- ✅ MVP development
- ✅ Hackathon demos
- ✅ Portfolio projects
- ✅ 100-1000 users
- ✅ Learning and testing

### Documentation

- Quick Start: `../QUICKSTART_FREE.md`
- Full Guide: `../docs/DEPLOY_FREE.md`
- Alternative Options: `../FREE_DEPLOYMENT.md`

---

## 💰 Paid Deployment (Google Cloud Platform)

**Cost:** ~$11-270/month

### Quick Start

```bash
./scripts/deploy-backend-gcp.sh
```

### What You Get (Paid)

| Service | Purpose | Cost |
|---------|---------|------|
| **Cloud Run** | Backend Hosting | ~$5-50/month |
| **Cloud SQL** | PostgreSQL + PostGIS | ~$5-200/month |
| **Cloud Storage** | Image Storage | ~$1-20/month |

**Total:** ~$11-270/month

### Setup Time

- **10-15 minutes** - Manual GCP configuration required
- **Credit card required** - Even for free trial
- **Billing enabled** - Charges apply after free tier

### Perfect For

- ✅ Production apps
- ✅ Enterprise needs
- ✅ 10,000+ users
- ✅ 24/7 guaranteed uptime
- ✅ Advanced features

### Documentation

- GCP Deployment: `../docs/DEPLOYMENT.md`
- Full README: `../README.md`

---

## 🆚 Comparison

| Feature | FREE (Railway+Neon+Cloudinary) | Paid (Google Cloud) |
|---------|-------------------------------|---------------------|
| **Cost** | $0/month | ~$11-270/month |
| **Credit Card** | Not required | Required |
| **Setup Time** | 5 minutes (automated) | 10-15 minutes (manual) |
| **Database Storage** | 3GB | Unlimited (paid) |
| **Image Storage** | 25GB | Unlimited (paid) |
| **Backend Hours** | 500 hrs/month | Unlimited |
| **Uptime** | Apps sleep after 30min idle | 24/7 guaranteed |
| **Scalability** | Good for MVP | Enterprise-grade |
| **Best For** | Hackathons, MVPs, demos | Production, enterprise |

---

## 🚀 Recommendation

**For SAFAR-Nexus Hackathon Project:**

Use the **FREE deployment** option!

Why?
- ✅ No cost during development and demo
- ✅ No credit card needed
- ✅ 5-minute automated setup
- ✅ Perfect for 100-1000 users
- ✅ Easy to upgrade later if needed

**Command:**
```bash
./scripts/deploy-free.sh
```

---

## 🔄 Switching Between Options

The backend automatically detects which storage to use via environment variable:

**For FREE (Cloudinary):**
```bash
USE_CLOUDINARY=true
CLOUDINARY_CLOUD_NAME=your_cloud_name
CLOUDINARY_API_KEY=your_api_key
CLOUDINARY_API_SECRET=your_api_secret
```

**For Paid (Google Cloud Storage):**
```bash
USE_CLOUDINARY=false
GCS_BUCKET_NAME=your-bucket
GOOGLE_APPLICATION_CREDENTIALS=/path/to/key.json
```

No code changes needed - just environment variables!

---

## 📚 More Information

- **FREE Deployment Full Guide:** [docs/DEPLOY_FREE.md](../docs/DEPLOY_FREE.md)
- **FREE Quick Start:** [QUICKSTART_FREE.md](../QUICKSTART_FREE.md)
- **GCP Deployment:** [docs/DEPLOYMENT.md](../docs/DEPLOYMENT.md)
- **Main README:** [README.md](../README.md)

---

**Ready to deploy?**

```bash
# FREE option (recommended)
./scripts/deploy-free.sh

# OR paid option
./scripts/deploy-backend-gcp.sh
```
