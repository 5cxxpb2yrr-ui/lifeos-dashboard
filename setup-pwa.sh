#!/bin/bash

# LifeOS Dashboard PWA Icon Generator Helper
# This script helps you set up the PWA with proper icon structure

set -e

echo "🎨 LifeOS Dashboard PWA Setup Helper"
echo "===================================="
echo ""

# Create directories
echo "📁 Creating icon directories..."
mkdir -p public/icons
mkdir -p public/screenshots
mkdir -p public/splash

echo "✓ Directories created:"
echo "  - public/icons/"
echo "  - public/screenshots/"
echo "  - public/splash/"
echo ""

# Check if Node modules are installed
if [ ! -d "node_modules" ]; then
    echo "📦 Installing dependencies..."
    npm install
    echo "✓ Dependencies installed"
else
    echo "✓ Dependencies already installed"
fi

echo ""
echo "📋 Next Steps:"
echo "1. Generate icons from: https://www.pwabuilder.com/imageGenerator"
echo "   - Upload a 512x512 PNG image"
echo "   - Select colors and transparency"
echo "   - Download ZIP file"
echo "   - Extract to public/icons/"
echo ""
echo "2. (Optional) Create iOS splash screens"
echo "   - Visit: https://www.pwabuilder.com/imagegenerator"
echo "   - Extract to public/splash/"
echo ""
echo "3. Build the app:"
echo "   npm run build"
echo ""
echo "4. Deploy to production:"
echo "   - Vercel: npx vercel"
echo "   - Netlify: npx netlify deploy --prod"
echo ""
echo "5. Test installation:"
echo "   - iPhone: Share → Add to Home Screen"
echo "   - Android: Menu → Install App"
echo ""
echo "📚 For detailed setup, see PWA-SETUP.md"
echo ""
