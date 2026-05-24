---
disable-model-invocation: true
name: crypto-trading-strategy
description: Cryptocurrency and algorithmic trading strategy patterns — indicators, position sizing formulas, backtesting methodology, anti-bias checklists, and Python tool references for systematic trading.
origin: AMS
---

# Crypto Trading Strategy Patterns

Systematic trading framework for cryptocurrency markets. Every strategy must pass bias validation before being considered real.

## When to Activate

- Designing or evaluating a trading strategy
- Setting up a backtesting pipeline
- Calculating position sizes or stop-loss levels
- Reviewing a strategy for overfitting or lookahead bias
- Analyzing trading indicators and signals

## Strategy Design Workflow

```
1. Hypothesis → 2. Indicator Selection → 3. Signal Rules → 4. Backtest (in-sample)
→ 5. Bias Audit → 6. Out-of-Sample Test → 7. Paper Trade → 8. Live (small)
```

Never skip steps 5–7. Strategies that skip OOS validation are backtest fiction.

## Technical Indicators Quick Reference

### Trend / Momentum

```python
import pandas_ta as ta

# EMA crossover
df["ema9"]  = ta.ema(df["close"], length=9)
df["ema21"] = ta.ema(df["close"], length=21)
df["ema200"] = ta.ema(df["close"], length=200)
signal_bull = df["ema9"] > df["ema21"]   # trend filter

# MACD (12, 26, 9)
macd = ta.macd(df["close"], fast=12, slow=26, signal=9)
df["macd_hist"] = macd["MACDh_12_26_9"]  # positive = bullish momentum

# ADX — trend strength (>25 trend, <20 range)
adx = ta.adx(df["high"], df["low"], df["close"], length=14)
df["adx"] = adx["ADX_14"]
is_trending = df["adx"] > 25
```

### Oscillators / Mean Reversion

```python
# RSI
df["rsi"] = ta.rsi(df["close"], length=14)
oversold  = df["rsi"] < 30
overbought = df["rsi"] > 70

# Bollinger Bands (20, 2σ)
bb = ta.bbands(df["close"], length=20, std=2)
df["bb_lower"] = bb["BBL_20_2.0"]
df["bb_upper"] = bb["BBU_20_2.0"]
df["bb_pct"]   = bb["BBP_20_2.0"]   # 0 = at lower, 1 = at upper

near_lower = df["bb_pct"] < 0.2
near_upper = df["bb_pct"] > 0.8
```

### Volatility / Sizing

```python
# ATR — Average True Range
df["atr"] = ta.atr(df["high"], df["low"], df["close"], length=14)

# Stop distance = 1.5–2.0 × ATR
df["stop_dist"] = df["atr"] * 1.5

# Bollinger Band Width — squeeze detector
df["bb_width"] = (bb["BBU_20_2.0"] - bb["BBL_20_2.0"]) / bb["BBM_20_2.0"]
squeeze = df["bb_width"] < df["bb_width"].rolling(50).quantile(0.1)
```

## Position Sizing Formulas

### ATR-Based (Recommended Default)

```python
def size_atr(account: float, risk_pct: float, entry: float, stop: float) -> float:
    """Returns number of units to buy/sell."""
    risk_amount = account * risk_pct / 100   # e.g. 1% of $10,000 = $100
    stop_distance = abs(entry - stop)        # per unit
    return risk_amount / stop_distance

# Example
account = 10_000
entry = 50_000   # BTC price
atr14 = 1_200    # ATR value
stop = entry - 1.5 * atr14   # = 48,200
units = size_atr(account, risk_pct=1.0, entry=entry, stop=stop)
```

### Kelly Criterion (Use 0.25–0.5× Only)

```python
def kelly_fraction(win_rate: float, avg_win: float, avg_loss: float) -> float:
    """Full Kelly. Apply 0.25x–0.5x multiplier to this result."""
    b = avg_win / avg_loss   # win/loss ratio
    p = win_rate
    q = 1 - p
    f = (b * p - q) / b
    return max(f, 0)   # never negative

# NEVER use full Kelly in live trading
# full_kelly → ~50% drawdown with 33% probability
f = kelly_fraction(win_rate=0.55, avg_win=1.5, avg_loss=1.0)
recommended_size_pct = f * 0.25  # quarter-Kelly
```

## Backtest Implementation

### vectorbt (Fastest)

```python
import vectorbt as vbt
import pandas as pd

# Signals from indicators
entries = (rsi < 30) & (ema9 > ema21)
exits   = (rsi > 65) | (ema9 < ema21)

# Run portfolio simulation
portfolio = vbt.Portfolio.from_signals(
    close,
    entries=entries,
    exits=exits,
    size=0.95,           # 95% of available cash per trade
    fees=0.001,          # 0.1% per side (taker fee)
    slippage=0.001,      # 0.1% slippage
    freq="1h",
)

print(portfolio.stats())
portfolio.plot().show()
```

### Walk-Forward Validation

```python
def walk_forward(df, strategy_fn, in_window=365, out_window=90):
    """
    Prevents overfitting: fit parameters on in-sample, evaluate on OOS.
    Returns OOS-only equity curve.
    """
    results = []
    start = 0
    while start + in_window + out_window <= len(df):
        in_sample  = df.iloc[start : start + in_window]
        out_sample = df.iloc[start + in_window : start + in_window + out_window]

        params = strategy_fn.optimize(in_sample)     # fit on in-sample
        oos_returns = strategy_fn.evaluate(out_sample, params)  # test on OOS
        results.append(oos_returns)
        start += out_window   # roll forward by OOS window

    return pd.concat(results)
```

## Bias Prevention Checklist

Run this BEFORE interpreting any backtest result:

### Lookahead Bias
- [ ] Signals only use data with timestamp ≤ signal bar close
- [ ] Entry executes at **next bar open** (not signal bar close)
- [ ] Stop-loss and target calculated from signal bar's data (not future bars)
- [ ] OHLCV data is end-of-period (bar close) not tick-by-tick with future context

### Survivorship Bias
- [ ] Backtest universe includes **delisted tokens** (dead coins)
- [ ] No selection of "coins that did well" to backtest
- [ ] Use database with historical listings, not just current ones

### Overfitting
- [ ] ≤ 5 free parameters for a simple strategy
- [ ] Walk-forward validation performed (not just in-sample optimization)
- [ ] Out-of-sample period ≥ 30% of total data
- [ ] Perturb each parameter ±20% — performance must stay positive
- [ ] OOS Sharpe ≥ 50% of in-sample Sharpe (if < 50% = overfit)

### Cost Model
- [ ] Trading fees modeled (maker and taker separately)
- [ ] Slippage modeled (function of trade size vs avg volume)
- [ ] Funding payments included for perpetual strategies
- [ ] Gas costs included for DeFi strategies

## Strategy Performance Metrics

```python
import quantstats as qs

# Full report
qs.reports.html(returns, benchmark="BTC", output="report.html")

# Quick metrics
qs.stats.sharpe(returns)          # Sharpe ratio
qs.stats.sortino(returns)         # Sortino ratio (downside vol only)
qs.stats.max_drawdown(returns)    # Maximum drawdown
qs.stats.calmar(returns)          # CAGR / max drawdown
qs.stats.profit_factor(returns)   # Gross profit / gross loss
qs.stats.win_rate(returns)        # Fraction of winning trades
```

| Metric | Minimum | Good | Excellent |
|--------|---------|------|-----------|
| Sharpe | 1.0 | 1.5 | 2.0+ |
| Sortino | 1.2 | 2.0 | 3.0+ |
| Max Drawdown | < 30% | < 20% | < 10% |
| Profit Factor | 1.2 | 1.5 | 2.0+ |
| OOS/IS Sharpe ratio | 50% | 75% | > 90% |

## Funding Rate Arbitrage

```python
# Strategy: Long spot + Short perpetual when funding is positive
# Collect funding every 8h (00:00, 08:00, 16:00 UTC)

# Annualized yield from funding
funding_rate_8h = 0.015 / 100   # 0.015%
annual_yield = funding_rate_8h * 3 * 365  # ~16.4% APR

# Risk monitoring
# Alert if funding reverses (you start paying instead of collecting)
# Alert if basis (perp - spot) widens > 1% (deleveraging risk)
# Max position: 20% of account (counterparty + liquidation risk)
```

## Exchange Data with ccxt

```python
import ccxt

exchange = ccxt.binance({
    "rateLimit": 1200,
    "enableRateLimit": True,
})

# Fetch OHLCV
ohlcv = exchange.fetch_ohlcv("BTC/USDT", timeframe="1h", limit=500)
df = pd.DataFrame(ohlcv, columns=["timestamp","open","high","low","close","volume"])
df["timestamp"] = pd.to_datetime(df["timestamp"], unit="ms")

# Fetch funding rates (perpetuals)
funding = exchange.fetch_funding_rate_history("BTC/USDT:USDT", limit=100)
```

## On-Chain Data Sources

| Signal | Source | Bullish | Bearish |
|--------|--------|---------|---------|
| Exchange inflow | Glassnode, CryptoQuant | ↓ low inflow | ↑ high inflow |
| Exchange outflow | Glassnode | ↑ accumulation | — |
| Stablecoin supply | DeFiLlama, Glassnode | ↑ minting = liquidity | ↓ burning |
| MVRV ratio | Glassnode | < 1 (undervalued) | > 3.5 (overvalued) |
| SOPR | Glassnode | < 1 (capitulation) | > 1.3 sustained (sell pressure) |
| Funding rates | Coinglass | Negative (shorts crowded) | > 0.1% per 8h extreme |
| Open Interest + Price | Coinglass | OI↑ + Price↑ | OI↑ + Price↓ (shorts piling) |

## Critical Anti-Patterns

- **Lookahead bias** — using tomorrow's close to decide today's trade
- **Survivorship bias** — only testing coins that still exist and did well
- **Full Kelly sizing** — mathematically guarantees ruin given enough time
- **No OOS test** — in-sample optimization is not validation
- **Ignoring fees and slippage** — turns losing strategies into "winners"
- **Over-leveraging perps** — one cascade liquidation event wipes the account
- **Averaging down without invalidation** — "buying the dip" without a stop is not a strategy
- **Treating correlated alts as diversification** — 10 alts all correlated to BTC = 1 position
- **Chasing FOMO entries** — entering after +20% move buys tops
- **No regime filter** — running momentum in a chop or mean reversion in a strong trend
