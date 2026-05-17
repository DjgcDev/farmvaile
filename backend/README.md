# FarmVaile Gemini Proxy

This proxy forwards Flutter Web requests to Google Gemini and avoids browser CORS restrictions.

## Requirements

- Node.js 16+ installed
- A valid Gemini API key

## Setup

1. Open a terminal inside `backend`
2. Run `npm install`
3. Create a `.env` file with your Gemini key, or copy the example:
   ```bash
   cp .env.example .env
   ```
4. Edit `.env` and set:
   ```text
   GEMINI_API_KEY=YOUR_API_KEY
   ```

## Run

```bash
npm start
```

The proxy listens on `http://localhost:8080`.

## Flutter Web

When running in Flutter Web, the app now sends AI requests through this proxy instead of calling Gemini directly from the browser.
