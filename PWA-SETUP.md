# PWA Setup & Deployment Guide

## Table of Contents
1. [Local Development](#local-development)
2. [App Icons & Graphics](#app-icons--graphics)
3. [Build & Optimization](#build--optimization)
4. [Deployment Options](#deployment-options)
5. [Installation on Devices](#installation-on-devices)
6. [Testing & Verification](#testing--verification)
7. [Service Worker Strategy](#service-worker-strategy)
8. [Troubleshooting](#troubleshooting)
9. [Performance Monitoring](#performance-monitoring)
10. [Update Strategy](#update-strategy)
11. [Security Checklist](#security-checklist)

---

## Local Development

### Prerequisites
- Node.js 18+ installed
- npm or yarn package manager
- HTTPS required for service worker (automatic in dev)

### Setup
```bash
# Clone repository
git clone https://github.com/5cxxpb2yrr-ui/lifeos-dashboard.git
cd lifeos-dashboard

# Install dependencies
npm install

# Run development server
npm run dev

# Access at http://localhost:5173
```

### Testing Service Worker Locally
1. Open DevTools (F12)
2. Go to Application → Service Workers
3. Check "Offline" to simulate offline mode
4. Refresh page - app should work without network

---

## App Icons & Graphics

### Icon Requirements

#### Minimum Set (Required)
- **192x192** - Android home screen
- **512x512** - Splash screen & app stores
- **192x192 Maskable** - Adaptive icon (Android 12+)
- **512x512 Maskable** - Adaptive splash (Android 12+)

#### Complete Set (Recommended)
- 72x72, 96x96, 128x128, 144x144, 152x152, 384x384 (all non-maskable)
- Plus all sizes as maskable variants

### How to Generate Icons

#### Option 1: PWA Builder (Easiest)
1. Visit https://www.pwabuilder.com/imageGenerator
2. Upload 512x512 PNG image
3. Select background color (#0f172a for LifeOS)
4. Choose transparency and padding
5. Download ZIP file
6. Extract to `public/icons/`

#### Option 2: Icon Kitchen
1. Visit https://icon.kitchen/
2. Create 512x512 icon design
3. Export all sizes
4. Extract to `public/icons/`

#### Option 3: Command Line with ImageMagick
```bash
# Create icons from source image
convert source.png -resize 72x72 public/icons/icon-72x72.png
convert source.png -resize 96x96 public/icons/icon-96x96.png
convert source.png -resize 128x128 public/icons/icon-128x128.png
convert source.png -resize 144x144 public/icons/icon-144x144.png
convert source.png -resize 152x152 public/icons/icon-152x152.png
convert source.png -resize 192x192 public/icons/icon-192x192.png
convert source.png -resize 384x384 public/icons/icon-384x384.png
convert source.png -resize 512x512 public/icons/icon-512x512.png
```

#### Option 4: Sharp (Node.js)
```bash
npm install sharp
node -e "
const sharp = require('sharp');
const src = 'source.png';
[72, 96, 128, 144, 152, 192, 384, 512].forEach(size => {
  sharp(src).resize(size).png().toFile(\`public/icons/icon-\${size}x\${size}.png\`);
});
"
```

### Icon Directory Structure
```
public/
├── icons/
│   ├── icon-72x72.png
│   ├── icon-96x96.png
│   ├── icon-128x128.png
│   ├── icon-144x144.png
│   ├── icon-152x152.png
│   ├── icon-192x192.png
│   ├── icon-192x192-maskable.png
│   ├── icon-384x384.png
│   ├── icon-512x512.png
│   └── icon-512x512-maskable.png
├── screenshots/
│   ├── screenshot-192.png
│   └── screenshot-512.png
└── splash/
    ├── splash-640x1136.png (iPhone SE)
    ├── splash-750x1334.png (iPhone 6/7)
    └── splash-1242x2208.png (iPhone X)
```

### Maskable Icon Design Tips
- Keep safe zone in center 80% of image
- Use meaningful symbol/logo
- Works on various background colors
- Test with https://maskable.app

---

## Build & Optimization

### Production Build
```bash
npm run build
```

This creates:
- `dist/` folder with optimized files
- Automatic service worker generation
- Code splitting for better caching
- CSS/JS minification
- Image optimization

### Build Output
```
dist/
├── index.html (injection point)
├── assets/
│   ├── react-vendor-xxx.js (React + ReactDOM)
│   ├── lucide-icons-xxx.js (Lucide icons)
│   ├── index-xxx.js (Main app)
│   ├── index-xxx.css
│   └── manifest-xxx.webmanifest
├── manifest.json (PWA manifest)
├── sw.js (Service worker)
└── (other assets)
```

### Performance Checklist
- [ ] gzip compression enabled on server
- [ ] Browser caching headers configured
- [ ] Service worker caches assets
- [ ] Code splitting working (check Network tab)
- [ ] Images optimized
- [ ] Lighthouse score > 90

---

## Deployment Options

### Option 1: Vercel (Recommended)

#### Setup
```bash
npm i -g vercel
vercel login
```

#### Deploy
```bash
# First deployment
vercel

# Production deployment
vercel --prod
```

#### Automatic Deployments
1. Connect GitHub repo to Vercel
2. Auto-deploys on push to `main`
3. Preview URLs for PRs

#### Configuration (vercel.json)
```json
{
  "buildCommand": "npm run build",
  "outputDirectory": "dist",
  "headers": [
    {
      "source": "/sw.js",
      "headers": [
        {"key": "Cache-Control", "value": "public, max-age=0, must-revalidate"}
      ]
    },
    {
      "source": "/manifest.json",
      "headers": [
        {"key": "Cache-Control", "value": "public, max-age=3600"}
      ]
    },
    {
      "source": "/assets/(.*)",
      "headers": [
        {"key": "Cache-Control", "value": "public, max-age=31536000, immutable"}
      ]
    }
  ]
}
```

### Option 2: Netlify

#### Setup
```bash
npm i -g netlify-cli
netlify login
```

#### Deploy
```bash
netlify deploy --prod --dir=dist
```

#### Configuration (netlify.toml)
```toml
[build]
  command = "npm run build"
  publish = "dist"

[[headers]]
  for = "/sw.js"
  [headers.values]
    Cache-Control = "public, max-age=0, must-revalidate"

[[headers]]
  for = "/manifest.json"
  [headers.values]
    Cache-Control = "public, max-age=3600"

[[headers]]
  for = "/assets/*"
  [headers.values]
    Cache-Control = "public, max-age=31536000, immutable"
```

### Option 3: GitHub Pages

#### Setup
```bash
git branch -M main
git remote add origin https://github.com/5cxxpb2yrr-ui/lifeos-dashboard.git
git push -u origin main
```

#### GitHub Actions Workflow
Create `.github/workflows/deploy.yml`:
```yaml
name: Deploy to GitHub Pages

on:
  push:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: 18
          cache: 'npm'
      - run: npm ci
      - run: npm run build
      - uses: actions/upload-pages-artifact@v2
        with:
          path: dist

  deploy:
    runs-on: ubuntu-latest
    needs: build
    permissions:
      pages: write
      id-token: write
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}
    steps:
      - uses: actions/deploy-pages@v2
        id: deployment
```

Then enable GitHub Pages in repo settings.

### Option 4: Self-Hosted (Docker)

#### Dockerfile
```dockerfile
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM nginx:alpine
COPY --from=builder /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

#### nginx.conf
```nginx
server {
  listen 80;
  server_name _;
  root /usr/share/nginx/html;

  # Cache service worker with no-cache
  location = /sw.js {
    add_header Cache-Control "public, max-age=0, must-revalidate";
  }

  # Cache manifest
  location = /manifest.json {
    add_header Cache-Control "public, max-age=3600";
  }

  # Cache assets forever (versioned)
  location /assets/ {
    add_header Cache-Control "public, max-age=31536000, immutable";
  }

  # Fallback for SPA
  location / {
    try_files $uri /index.html;
  }
}
```

#### Build & Run
```bash
docker build -t lifeos-dashboard .
docker run -p 80:80 lifeos-dashboard
```

---

## Installation on Devices

### iPhone (iOS 12+)

1. **Open in Safari**
   - Visit app URL in Safari browser

2. **Share Menu**
   - Tap Share icon (or action menu)
   - Scroll down, tap "Add to Home Screen"

3. **Customize**
   - Edit name (default: app title from manifest)
   - Tap "Add"

4. **Result**
   - Icon appears on home screen
   - App launches fullscreen (standalone mode)
   - Works offline with cached data

### Android (Chrome/Edge)

1. **Open in Browser**
   - Use Chrome, Edge, or Samsung Internet
   - Visit app URL

2. **Install Banner**
   - Usually appears automatically after 2-3 visits
   - Tap "Install" on banner

3. **Manual Install** (if no banner)
   - Tap menu (three dots)
   - Select "Install app"
   - Choose "Install"

4. **Result**
   - App installed to home screen + app drawer
   - Works offline with service worker
   - Can uninstall like normal app

### Desktop (PWA)

#### Windows 11
- Click menu (three dots in Chrome)
- "Save and share" → "Install app"
- App launches in standalone window

#### Mac
- Chrome menu → "Create Shortcut" → "Open as Window"
- Or use "Save and share" (Chrome 108+)

---

## Testing & Verification

### Manual Testing Checklist

#### Installation
- [ ] iPhone: Can add to home screen
- [ ] iPhone: Launches fullscreen (no browser UI)
- [ ] Android: Can install app
- [ ] Android: Icon appears in app drawer
- [ ] Desktop: Can install as PWA

#### Offline Functionality
- [ ] Open DevTools → Application → Offline
- [ ] Refresh page - app still works
- [ ] All data persists
- [ ] Navigation works
- [ ] Tasks/bills/events load from cache

#### Performance
- [ ] First load < 3 seconds
- [ ] Subsequent loads instant (cached)
- [ ] Scrolling smooth
- [ ] No layout shift

#### Data Persistence
- [ ] Add task offline
- [ ] Go online
- [ ] Data still present (localStorage)
- [ ] Can sync to router backup

#### App Shortcuts
- [ ] Android: Long-press icon
- [ ] See "Quick Task", "Money", "Work" options
- [ ] Tap shortcut goes to correct tab

### Lighthouse Audit

```bash
# Install Lighthouse globally
npm i -g lighthouse

# Run audit
lighthouse https://your-app-url.com --view

# Or use Chrome DevTools
# F12 → Lighthouse → Analyze page load
```

### Expected Scores
- Performance: 90+
- Accessibility: 95+
- Best Practices: 92+
- SEO: 100
- PWA: All checks passing

### Chrome DevTools Testing

1. **Service Worker Status**
   - F12 → Application → Service Workers
   - Check registration and status

2. **Cache Storage**
   - F12 → Application → Cache Storage
   - Verify cache contents and sizes

3. **Local Storage**
   - F12 → Application → Local Storage
   - Check `lifeos-dashboard-v13` key

4. **Manifest**
   - F12 → Application → Manifest
   - Verify all icons and metadata

5. **Network Throttling**
   - F12 → Network tab → Throttling
   - Test with 4G/3G speeds

---

## Service Worker Strategy

### Network-First (HTML)
- Try network first for fresh content
- Fall back to cached version if offline
- Best for: index.html, dynamic content

### Cache-First (Assets)
- Check cache first for speed
- Fall back to network if not cached
- Best for: CSS, JS, images, fonts

### Cache Times
- **Service Worker**: No cache (always check for updates)
- **Manifest**: 1 hour
- **Google Fonts**: 1 year
- **Assets**: 1 year (versioned by Vite)
- **HTML**: No cache (network-first)

### Manual Cache Clearing
```javascript
// In browser console
caches.keys().then(names => 
  Promise.all(names.map(name => caches.delete(name)))
).then(() => location.reload());
```

---

## Troubleshooting

### Service Worker Not Registering

**Symptoms**: Offline mode fails, app not installable

**Causes**:
- HTTPS not enabled (required)
- Service worker file missing (public/sw.js)
- Browser blocking (check DevTools errors)

**Fix**:
```bash
# Verify file exists
ls -la public/sw.js

# Check DevTools Application → Service Workers
# Look for error messages

# Clear and re-register
caches.keys().then(names => 
  Promise.all(names.map(name => caches.delete(name)))
)
location.reload()
```

### App Won't Install

**Symptoms**: No install banner/option on Android or iOS

**Causes**:
- Not using HTTPS
- Manifest invalid/missing
- Icons missing or invalid format
- Service worker not registered

**Fix**:
1. Verify manifest.json is valid
   ```bash
   curl https://your-app.com/manifest.json | python -m json.tool
   ```

2. Check icon sizes and formats
   - Must be PNG with correct dimensions
   - Maskable icons need transparency

3. Verify service worker registration
   - F12 → Application → Service Workers

### Offline Mode Shows Blank Page

**Symptoms**: App works online but blank offline

**Causes**:
- Manifest not cached
- index.html not in cache list
- Service worker fallback missing

**Fix**: Check sw.js fallback handling:
```javascript
// Should be at end of fetch handler
.catch(() => caches.match('/index.html'))
```

### Data Not Persisting

**Symptoms**: Refresh loses tasks, bills, etc.

**Causes**:
- localStorage disabled in browser
- Private/Incognito mode
- Storage quota exceeded
- Service worker not caching

**Fix**:
```javascript
// Check if localStorage available
if (typeof(Storage) !== "undefined") {
  localStorage.setItem('test', 'test');
  console.log('localStorage available');
} else {
  console.log('localStorage not available');
}

// Check quota
navigator.storage?.estimate().then(estimate => {
  console.log(`Using ${estimate.usage} bytes of ${estimate.quota}`);
});
```

### Update Not Showing

**Symptoms**: Deploy new version but browser shows old one

**Causes**:
- Service worker cached old version
- Browser cache not cleared
- Update check not running

**Fix**:
```javascript
// Manually check for updates
navigator.serviceWorker?.controller?.postMessage({
  type: 'SKIP_WAITING'
});
```

Or hard refresh:
- Windows/Linux: Ctrl + Shift + R
- Mac: Cmd + Shift + R

### Too Much Data Cached

**Symptoms**: Storage quota exceeded error

**Causes**:
- Cache sizes too large
- Old caches not cleaned up
- Browser storage limit reached

**Fix**:
```javascript
// Clear specific cache
caches.delete('lifeos-dashboard-v13').then(() => {
  console.log('Cache cleared');
  location.reload();
});

// Check storage usage
navigator.storage?.estimate().then(estimate => {
  const used = (estimate.usage / 1048576).toFixed(2);
  const total = (estimate.quota / 1048576).toFixed(2);
  console.log(`${used}MB of ${total}MB used`);
});
```

---

## Performance Monitoring

### Lighthouse Metrics
- **FCP** (First Contentful Paint): < 1.8s
- **LCP** (Largest Contentful Paint): < 2.5s
- **CLS** (Cumulative Layout Shift): < 0.1
- **TTI** (Time to Interactive): < 3.8s

### Monitor in Production
```javascript
// Core Web Vitals
import {getCLS, getFID, getFCP, getLCP, getTTFB} from 'web-vitals';

getCLS(console.log);
getFID(console.log);
getFCP(console.log);
getLCP(console.log);
getTTFB(console.log);
```

### Service Worker Performance
```javascript
// Monitor cache hits/misses
let cacheHits = 0;
let cacheMisses = 0;

// In sw.js fetch handler
caches.match(request).then(response => {
  if (response) cacheHits++;
  else cacheMisses++;
  console.log(`Hits: ${cacheHits}, Misses: ${cacheMisses}`);
});
```

---

## Update Strategy

### Automatic Updates
Service worker checks for updates every 60 seconds (configured in index.html):

```javascript
setInterval(() => {
  registration.update();
}, 60000);
```

### Manual Update Prompt
Users can force update:
```javascript
navigator.serviceWorker.addEventListener('controllerchange', () => {
  window.location.reload();
});
```

### Staged Rollout
1. Deploy to staging first
2. Test thoroughly
3. Deploy to production
4. Monitor for errors
5. Roll back if needed (old version still cached)

---

## Security Checklist

- [ ] HTTPS enforced (no HTTP)
- [ ] CSP headers configured
- [ ] Service worker validated
- [ ] No sensitive data in localStorage
- [ ] API keys in environment variables
- [ ] Icons optimized (no embedded scripts)
- [ ] Dependencies kept updated
- [ ] No inline scripts
- [ ] Form inputs sanitized
- [ ] CORS headers configured properly

---

## Quick Reference

### Useful Commands
```bash
npm run dev          # Start development
npm run build        # Production build
npm run preview      # Preview build locally
npm run lint         # Lint code

# Deploy commands
vercel --prod        # Deploy to Vercel
netlify deploy --prod  # Deploy to Netlify
```

### URLs to Know
- Local dev: http://localhost:5173
- PWA Builder: https://www.pwabuilder.com
- Icon Kitchen: https://icon.kitchen
- Maskable Icons: https://maskable.app
- Lighthouse: https://developers.google.com/web/tools/lighthouse

### Support
- GitHub Issues: https://github.com/5cxxpb2yrr-ui/lifeos-dashboard/issues
- PWA Docs: https://web.dev/progressive-web-apps/
- Service Worker: https://developer.mozilla.org/en-US/docs/Web/API/Service_Worker_API
