# Firebase Blaze Plan Setup Guide

## Why Blaze Plan is Required

Firebase Cloud Functions require the **Blaze (pay-as-you-go) plan** because:
- Cloud Functions use Google Cloud Platform resources
- The Artifact Registry API (`artifactregistry.googleapis.com`) needs to be enabled
- This API is only available on paid plans

## Important: Blaze Plan is FREE for Most Use Cases

**Good news:** The Blaze plan has a **generous free tier**:
- **2 million function invocations/month** - FREE
- **400,000 GB-seconds compute time/month** - FREE
- **200,000 CPU-seconds/month** - FREE
- **5 GB egress/month** - FREE

For a small to medium app, you'll likely stay within the free tier!

## How to Upgrade to Blaze Plan

### Step 1: Go to Firebase Console
1. Visit: https://console.firebase.google.com/
2. Select your project: **clgjone**

### Step 2: Upgrade Plan
1. Click on the **⚙️ Settings** (gear icon) → **Usage and billing**
2. Click **"Modify plan"** or **"Upgrade"**
3. Select **Blaze (pay-as-you-go)** plan
4. Click **"Continue"**

### Step 3: Add Payment Method
1. You'll be asked to add a payment method (credit card)
2. **Don't worry** - You won't be charged unless you exceed the free tier
3. Enter your payment details
4. Complete the upgrade

### Step 4: Enable Required APIs
After upgrading, Firebase will automatically enable:
- `artifactregistry.googleapis.com` (Artifact Registry)
- `cloudfunctions.googleapis.com` (Cloud Functions)
- Other required APIs

### Step 5: Deploy Functions
Once upgraded, run:
```bash
cd functions
npm install
npm run build
cd ..
firebase deploy --only functions
```

---

## Cost Estimation for Your App

### Typical Usage (Small App):
- **Function invocations**: ~10,000/month = **FREE** (well under 2M limit)
- **Compute time**: ~50 GB-seconds/month = **FREE** (well under 400K limit)
- **Egress**: ~1 GB/month = **FREE** (well under 5 GB limit)

### Estimated Monthly Cost: **$0.00** (within free tier)

---

## Monitoring Usage

### Check Your Usage:
1. Firebase Console → **Usage and billing**
2. View real-time usage metrics
3. Set up billing alerts (optional)

### Set Billing Alerts (Recommended):
1. Go to **Usage and billing** → **Alerts**
2. Set alert at $1 or $5 (to be notified if usage spikes)
3. This helps you stay within free tier

---

## Alternative: Use Firebase Emulators (Development Only)

If you want to test functions locally without upgrading:
```bash
cd functions
npm install
npm run serve
```

**Note:** Emulators are for development only. Production requires Blaze plan.

---

## FAQ

### Q: Will I be charged immediately?
**A:** No. You only pay if you exceed the free tier limits.

### Q: What if I exceed the free tier?
**A:** You'll pay only for what you use beyond the free tier. For example:
- Extra invocations: $0.40 per million
- Extra compute: $0.0000025 per GB-second

### Q: Can I downgrade later?
**A:** Yes, but you'll lose Cloud Functions. You can switch back to Spark (free) plan, but functions won't work.

### Q: Is there a way to avoid Blaze plan?
**A:** No, Cloud Functions require Blaze plan. However, the free tier is very generous for most apps.

---

## Next Steps

1. **Upgrade to Blaze plan** (follow steps above)
2. **Deploy functions** after upgrade completes
3. **Monitor usage** to ensure you stay within free tier
4. **Set billing alerts** for peace of mind

---

## Support

If you have issues upgrading:
- Firebase Support: https://firebase.google.com/support
- Check billing FAQ: https://firebase.google.com/pricing
