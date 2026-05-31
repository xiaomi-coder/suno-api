FROM node:20-slim AS builder
WORKDIR /src
COPY package*.json ./
RUN npm install --prefer-offline
COPY . .
RUN npm run build

FROM node:20-slim
WORKDIR /app

# Chromium uchun kerakli kutubxonalar
RUN apt-get update && apt-get install -y --no-install-recommends \
    libnss3 libdbus-1-3 libatk1.0-0 libatk-bridge2.0-0 \
    libxcomposite1 libxdamage1 libxfixes3 libxrandr2 \
    libgbm1 libxkbcommon0 libasound2 libcups2 \
    wget ca-certificates \
    && rm -rf /var/lib/apt/lists/*

COPY package*.json ./
RUN npm install --only=production --prefer-offline

# Faqat Chromium
RUN npx playwright install --with-deps chromium

COPY --from=builder /src/.next ./.next

ENV BROWSER_DISABLE_GPU=true
ENV BROWSER_HEADLESS=true
ENV NODE_ENV=production

EXPOSE 3000
CMD ["npm", "run", "start"]
