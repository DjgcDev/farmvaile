require('dotenv').config();

const express = require('express');
const cors = require('cors');
const fetch = require('node-fetch');

const app = express();
const PORT = process.env.PORT || 8080;
const GEMINI_API_KEY = process.env.GEMINI_API_KEY;

app.use(cors());
app.use(express.json());

if (!GEMINI_API_KEY) {
  console.warn('Warning: GEMINI_API_KEY is not set. The proxy will return 500 until the key is configured.');
} else {
  console.log('GEMINI_API_KEY is configured for the backend proxy.');
}

app.post('/api/gemini', async (req, res) => {
  const { message } = req.body;
  console.log('Received request:', req.body);
  if (!message) {
    return res.status(400).json({ error: { code: 400, message: 'Missing required field: message' } });
  }

  if (!GEMINI_API_KEY) {
    return res.status(500).json({ error: { code: 500, message: 'GEMINI_API_KEY is not configured on the server.' } });
  }

  try {
    const systemPrompt = `You are FarmBot, a farming-only AI assistant for smallholder farmers in General Trias, Cavite, Philippines (CALABARZON region).

STRICT TOPIC RESTRICTION:
You ONLY answer questions about:
- Crop farming (planting, growing, harvesting, soil, irrigation, fertilizers, pest/disease control)
- Specific crops: sitaw, ampalaya, talong, kamatis, pechay, okra, and other local crops
- Weather and seasonal farming advice for Cavite/CALABARZON
- Market prices for crops in Philippine Peso (CALABARZON region)
- Post-harvest handling and storage of crops
- Farming tools, techniques, and best practices

If the user asks about ANYTHING else (news, politics, entertainment, general knowledge, coding, relationships, health, etc.), you must respond ONLY with:
"🌱 Pasensya na! Ang FarmBot ay para lamang sa mga tanong tungkol sa pagsasaka at presyo ng mga pananim. (Sorry! FarmBot only answers questions about farming and crop market prices.) Mayroon ka bang tanong tungkol sa iyong farm? 👨‍🌾"

RESPONSE RULES:
- Use Filipino crop names alongside English
- Use emojis to make responses friendly and easy to read
- Format tips as numbered lists when applicable
- Reference Cavite weather and CALABARZON market prices in PHP when relevant
- Make responses clear, practical, and complete without an overly strict word limit
- The area has sandy-loam soil and a warm humid climate`;
    const requestBody = {
      contents: [
        {
          parts: [
            {
              text: `${systemPrompt}\n\nFarmer asks: ${message}`,
            },
          ],
        },
      ],
      generationConfig: {
        temperature: 0.7,
        maxOutputTokens: 1024,
      },
    };
    console.log('Sending to Gemini:', requestBody);
    const response = await fetch(
      `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=${encodeURIComponent(GEMINI_API_KEY)}`,
      {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(requestBody),
      }
    );
    const data = await response.json();
    console.log('Gemini response status:', response.status);
    console.log('Gemini response data:', data);
    return res.status(response.status).json(data);
  } catch (error) {
    console.log('Proxy error:', error);
    return res.status(500).json({
      error: 'proxy_request_failed',
      message: error.message || 'An unknown error occurred while contacting Gemini.',
    });
  }
});


app.get('/health', (req, res) => {
  res.json({
    status: 'ok',
    apiKeySet: !!GEMINI_API_KEY,
    apiKeyPrefix: GEMINI_API_KEY ? GEMINI_API_KEY.substring(0, 6) + '...' : 'NOT SET',
  });
});

app.listen(PORT, () => {
  console.log(`FarmVaile proxy server listening on http://localhost:${PORT}`);
});
