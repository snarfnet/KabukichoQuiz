const fs = require('fs/promises');
const path = require('path');

const root = __dirname;
let fetchImage;

const assets = [
  {
    file: 'Assets/Characters/easy_character.png',
    prompt:
      'anime illustration, gentle and dreamy Japanese girl with pastel pink wavy long hair, droopy eyes, prominent under-eye bags, white frilly blouse and pink jumper skirt, heart-shaped choker, Kabukicho neon background at night, soft pastel colors, cute kawaii style.',
  },
  {
    file: 'Assets/Characters/medium_character.png',
    prompt:
      'anime illustration, tsundere Japanese girl with black twin tails, blunt bangs, strong eyeliner, quantity-produced fashion, black ribbon blouse and plaid mini skirt, Kabukicho neon background at night, vivid colors, cute kawaii style.',
  },
  {
    file: 'Assets/Characters/hard_character.png',
    prompt:
      'anime illustration, yandere Japanese girl with white straight long hair, dark circles under eyes, red-purple irises, black and white lace one-piece dress, bandage-style arm covers, yami-kawaii aesthetic, Kabukicho neon background at night.',
  },
  {
    file: 'Assets/Icons/app_icon.png',
    prompt:
      'app icon design, dark purple and neon pink color scheme, Kabukicho-inspired, large question mark symbol, jirai-kei cute aesthetic, clean icon design, no text.',
  },
  {
    file: 'Assets/UI/splash_background.png',
    prompt:
      'Kabukicho Tokyo night cityscape, dark navy background, neon pink and purple lights, neon signs, rainy streets reflection, no characters, cinematic atmosphere.',
  },
  {
    file: 'Assets/UI/background_quiz.png',
    prompt:
      'dark purple gradient background with Kabukicho neon atmosphere, heart silhouettes, street lamp silhouettes, neon glow effects, quiz game background, no characters.',
  },
];

async function downloadImage(url, targetPath) {
  const response = await fetchImage(url);
  if (!response.ok) {
    throw new Error(`download failed ${response.status}: ${await response.text()}`);
  }

  const arrayBuffer = await response.arrayBuffer();
  await fs.writeFile(targetPath, Buffer.from(arrayBuffer));
}

async function generateAsset(client, asset) {
  const targetPath = path.join(root, asset.file);
  await fs.mkdir(path.dirname(targetPath), { recursive: true });

  const result = await client.images.generate({
    model: 'dall-e-3',
    prompt: asset.prompt,
    n: 1,
    size: '1024x1024',
    response_format: 'url',
  });

  const url = result.data?.[0]?.url;
  if (!url) {
    throw new Error(`OpenAI response did not include an image URL for ${asset.file}`);
  }

  await downloadImage(url, targetPath);
  const stat = await fs.stat(targetPath);
  console.log(`saved ${asset.file} (${stat.size} bytes)`);
}

async function verifyFiles() {
  const missing = [];

  for (const asset of assets) {
    const targetPath = path.join(root, asset.file);
    try {
      const stat = await fs.stat(targetPath);
      if (!stat.isFile() || stat.size === 0) {
        missing.push(asset.file);
      }
    } catch {
      missing.push(asset.file);
    }
  }

  if (missing.length > 0) {
    throw new Error(`Missing or empty files: ${missing.join(', ')}`);
  }
}

async function main() {
  if (!process.env.OPENAI_API_KEY) {
    throw new Error('OPENAI_API_KEY environment variable is required.');
  }

  const OpenAI = require('openai');
  fetchImage = (...args) => import('node-fetch').then(({ default: fetch }) => fetch(...args));
  const client = new OpenAI({ apiKey: process.env.OPENAI_API_KEY });

  for (const asset of assets) {
    await generateAsset(client, asset);
  }

  await verifyFiles();
  console.log('All requested PNG files exist.');
}

main().catch((error) => {
  console.error(error.message);
  process.exitCode = 1;
});
