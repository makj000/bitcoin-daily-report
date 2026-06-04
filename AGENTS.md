Daily BTC + ETH Market Report

# Task
You are running an automated daily crypto market report. Execute all steps autonomously without asking questions.

Search for the latest Bitcoin (BTC) and Ethereum (ETH) market news from the past 24 hours, produce a bilingual (English + Chinese) report, save it to disk, and send it via email.

# Schedule
Run daily in the morning, cron: 0 6 * * *  # 6am Pacific Time (America/Los_Angeles)

## Step 1: Fetch Prices
Search for the current prices of BTC and ETH and their prices ~24 hours ago. Calculate the 24h change ($ and %) for each. Also fetch:
 - Crypto Fear & Greed Index
 - BTC and ETH 24h trading volume
 - BTC dominance % and ETH dominance %
 - BTC and ETH 7-day price trend (%)

Replace `[DATE]` with today's date (YYYY-MM-DD) and `[DATE-1]` with yesterday's date in all search queries below.

Search queries to use:
 - "Bitcoin price today [DATE]"
 - "Ethereum price today [DATE]"
 - "Bitcoin price yesterday [DATE-1]"
 - "Ethereum price yesterday [DATE-1]"
 - "Crypto Fear Greed Index today"

If the Fear & Greed Index is unavailable, note it as "N/A" in the report and continue.

## Step 2: Fetch News
Search for the top news stories from the past 24 hours affecting BTC and ETH. Cover:
 - Macroeconomic events (CPI, PCE, Fed policy, DXY, bond yields)
 - Regulatory news (SEC, CFTC, global)
 - Institutional activity (ETF flows, corporate buys/sells)
 - On-chain data (whale moves, exchange flows, liquidations)
 - Ethereum-specific: L2 activity, staking changes, protocol upgrades, DeFi/NFT trends
 - Geopolitical events with crypto impact
 - Sentiment shifts
Use multiple searches (substitute actual dates for `[DATE]`), e.g.:
 - "Bitcoin news today [DATE]"
 - "Ethereum news today [DATE]"
 - "Bitcoin ETF flows [DATE]"
 - "crypto regulation news [DATE]"
 - "Ethereum staking DeFi [DATE]"

## Step 3: Write the Report
Format the report as follows (bilingual English + Chinese throughout):
# 📊 Daily Crypto Report — [DATE]
# 每日加密货币报告 — [DATE]
## 💰 Price Summary / 价格摘要
[Pivoted table with metrics as rows, tickers as columns:]

| Metric         | BTC                      | ETH                      |
|----------------|--------------------------|--------------------------|
| Price          | $X                       | $X                       |
| Yesterday      | $X                       | $X                       |
| 24h Change     | +/-$X (+/-X%) 🟢/🔴      | +/-$X (+/-X%) 🟢/🔴      |
| 7d Trend       | +/-X% 🟢/🔴              | +/-X% 🟢/🔴              |
| 24h Volume     | ~$XB                     | ~$XB                     |
| Dominance      | X%                       | X%                       |
| Notes          | ...                      | ...                      |

Total Market Cap: $X | Fear & Greed: X (label)
## ₿ Bitcoin — Top News / 比特币头条
[3-5 stories, each with: headline, 1-2 sentence summary in English, 1-2 sentence summary in Chinese, Sentiment emoji (🟢 bullish / 🟡 neutral / 🔴 bearish), estimated impact (High/Medium/Low)]
## Ξ Ethereum — Top News / 以太坊头条
[3-5 stories, same format as BTC]
## 🔗 News-to-Price Correlation / 新闻与价格走势关联
[Use a compact list format, one entry per line — no wide table. Format each item as:]
🔴/🟡/🟢 **High/Med/Low** — News headline → one-sentence explanation of price impact
## 📋 Overall Assessment / 综合评估
[2-3 paragraph bilingual summary. Explain whether price moves are well-explained by news, note any unexplained factors (liquidations, thin liquidity, technical levels). Call out key support/resistance levels for BTC and ETH.]

## Step 4: Save Report
Save the full report as a markdown file in the working directory: `daily_crypto_report_YYYY-MM-DD.md`
Do NOT commit this file to git — it is intentionally gitignored.

## Step 5: Send Notification
Send a push notification via ntfy.sh:

```
curl -d "📊 BTC/ETH Daily [DATE] | BTC: $[PRICE] ([CHANGE]%) | ETH: $[PRICE] ([CHANGE]%) | F&G: [FNG] | Report saved to Google Drive" \
  -H "Title: Daily Crypto Report" \
  -H "Priority: default" \
  https://ntfy.sh/crypto-daily-kma9f
```

Also include the Google Drive view URL in the ntfy Click and Actions headers so the notification links directly to the report.

Also save the report to Google Drive using the Google Drive MCP:
- Title: `📊 BTC/ETH Daily Report — YYYY-MM-DD`
- Parent folder ID: `1zHhZ19pRyuunHunyEDVU8Lm5xhjypWW8` (Daily Crypto Reports)

If ntfy.sh is unavailable, append a one-line summary to `notifications.log` in the same directory as this AGENTS.md:
Format: [DATETIME] BTC: $X (X%) | ETH: $X (X%) | Report: daily_crypto_report_YYYY-MM-DD.md

Configuration Notes:
ntfy.sh topic: crypto-daily-kma9f
Google Drive folder: Daily Crypto Reports (ID: 1zHhZ19pRyuunHunyEDVU8Lm5xhjypWW8)
Language: Bilingual English + Chinese (中英双语)


# Execution Notes

Run autonomously. Make reasonable assumptions. Do not ask clarifying questions.
If a search returns no results for today's date, try yesterday's date.
If price data is inconsistent across sources, use the median value and note the variance.
Always complete all 5 steps even if some data is unavailable — note gaps in the report.
