# My Money Book — Market Money Tracker

A simple, mobile-first money tracker designed for market traders. It answers three questions: what came in, what went out, and what is left.

## Features
- Money came in / Money went out
- Daily totals and remaining balance
- Simple optional notes
- Nigerian Naira formatting
- Passwordless email authentication
- PostgreSQL persistence
- Responsive mobile-first interface
- Nigeria/Lagos date handling

## Architecture
- Hatchable static frontend under `public/`
- Hatchable API under `api/entries.js`
- PostgreSQL migrations under `migrations/`
- Passwordless email auth through Hatchable

## UX principle
This is intentionally not a bookkeeping system. The interface uses everyday language and large touch targets so a trader with little or no formal education can understand it quickly.
