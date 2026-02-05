# 🏠 Malta Real Estate PRO

[![Live Demo](https://img.shields.io/badge/demo-live-success)](https://dumitrascunela5-cell.github.io/malta-real-estate-pwa/)
[![Version](https://img.shields.io/badge/version-2.0-blue)]()
[![PWA](https://img.shields.io/badge/PWA-ready-orange)]()

> Professional real estate management platform built for Malta property professionals

## 🚀 What's New in v2.0

- ✅ **Auto-Update System** - Users get updates automatically
- ✅ **Install Banner** - One-click installation on any device
- ✅ **Daily Notes** - Track daily client interactions
- ✅ **Deals & Commissions** - Calculate and track earnings
- ✅ **Simplified Forms** - Removed email fields, phone only
- ✅ **Bug Fixes** - Clients button and other issues resolved

## 🎯 Features

### Smart Property-Client Matching
- Price tolerance ±15% for negotiations
- Location proximity matching (Sliema → Gzira, St. Julians, etc.)
- Intelligent scoring algorithm
- Real-time match updates

### Interactive Map
- Live property markers on Malta map
- Zone-based filtering
- Nearby areas intelligence
- Detailed property popups

### Professional Management
- Property listings management
- Client database with requirements
- Viewing schedules and tracking
- Communication logs
- Document storage
- Price history tracking
- Reminder system

### Modern UI/UX
- Dark/Light mode toggle
- Mobile-first responsive design
- Professional color scheme (Orange/Teal)
- Smooth animations
- PWA - works offline

## 📱 Installation

### Live Demo
Visit: [https://dumitrascunela5-cell.github.io/malta-real-estate-pwa/](https://dumitrascunela5-cell.github.io/malta-real-estate-pwa/)

### Install as App

**Desktop (Chrome/Edge):**
1. Visit the website
2. Click install banner (appears after 3 seconds)
3. Click "Install Now"
4. App installed on desktop!

**Android:**
1. Visit in Chrome
2. Install banner appears
3. Tap "Install Now"
4. App on home screen!

**iOS:**
1. Open in Safari
2. Tap Share button
3. "Add to Home Screen"
4. Done!

## 🔧 Setup for Developers

### Prerequisites
- GitHub account (for hosting)
- Supabase account (for database)

### Quick Setup

1. **Fork this repository**

2. **Enable GitHub Pages**
   - Settings → Pages
   - Source: `main` branch
   - Save

3. **Setup Supabase**
   - Create new project at [supabase.com](https://supabase.com)
   - Run SQL from `supabase-setup.sql`
   - Get your credentials

4. **Update Config**
   - Edit `index.html`
   - Replace `SUPABASE_URL` and `SUPABASE_KEY` (around line 160)

5. **Deploy**
   - Push to GitHub
   - Wait 2-3 minutes
   - Visit your GitHub Pages URL

## 🛠️ Technology Stack

- **Frontend**: React 18 (via CDN)
- **Database**: Supabase (PostgreSQL)
- **Maps**: Leaflet.js
- **Hosting**: GitHub Pages (Free!)
- **PWA**: Service Worker for offline support
- **Styling**: Custom CSS with CSS Variables

## 📊 Database Schema

### Core Tables
- `properties` - Property listings
- `clients` - Client database
- `deals` - Closed deals and commissions
- `daily_notes` - Daily updates and notes
- `reminders` - Tasks and reminders
- `communications` - Interaction logs
- `viewings` - Viewing schedules
- `documents` - File storage
- `price_history` - Price tracking

## 🔄 Updating the App

### For Users
Updates happen automatically! When a new version is available:
1. Banner appears: "🎉 New version available!"
2. Click "Update Now"
3. App refreshes with new version
4. Done!

### For Developers

1. **Make your changes** in `index.html`

2. **Bump version** in `service-worker.js`:
   ```javascript
   const CACHE_VERSION = 'malta-real-estate-v3'; // increment number
   ```

3. **Commit and push**:
   ```bash
   git add .
   git commit -m "Your update message"
   git push
   ```

4. **Users get update automatically!**
   - They see update banner
   - Click to update
   - No reinstall needed

## 🎨 Customization

### Add Custom Zones

Edit `MALTA_ZONES` in `index.html`:
```javascript
const MALTA_ZONES = {
    'Your Area': { 
        lat: 35.XXXX, 
        lng: 14.XXXX, 
        nearby: ['Nearby1', 'Nearby2'] 
    }
};
```

### Change Theme Colors

Edit CSS variables in `index.html`:
```css
:root {
    --accent-primary: #f97316; /* Orange */
    --accent-secondary: #14b8a6; /* Teal */
    /* ... */
}
```

## 📱 Screenshots

*Coming soon*

## 🤝 Contributing

Contributions welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## 📄 License

MIT License - Free to use and modify

## 💡 Use Cases

Perfect for:
- Real estate agents in Malta
- Property management companies
- Individual landlords with multiple properties
- Real estate agencies managing teams

## 🆘 Support

Having issues?
1. Check the [documentation](./ACTUALIZARE.md)
2. Open an issue on GitHub
3. Check browser console (F12) for errors

## 🎯 Roadmap

- [ ] WhatsApp integration
- [ ] Email automation
- [ ] SMS notifications
- [ ] Multi-agent support
- [ ] Analytics dashboard
- [ ] Export to PDF/Excel
- [ ] Native mobile apps

## ⭐ Credits

Built with ❤️ for Malta real estate professionals

**Tools used:**
- React
- Supabase
- Leaflet
- GitHub Pages
- OpenStreetMap

---

**Live App**: https://dumitrascunela5-cell.github.io/malta-real-estate-pwa/

**Made in Malta** 🇲🇹
