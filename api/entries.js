import { auth, db } from "hatchable";

export const access = "user";
export const methods = ["GET", "POST"];

function todayInNigeria() {
  return new Intl.DateTimeFormat("en-CA", {
    timeZone: "Africa/Lagos", year: "numeric", month: "2-digit", day: "2-digit"
  }).format(new Date());
}
function cleanAmount(value) {
  if (typeof value === "number") return value;
  if (typeof value !== "string") return NaN;
  return Number(value.replace(/[₦,\s]/g, ""));
}
export default async function (req, res) {
  const user = req.user || await auth.getUser(req);
  if (!user) return res.status(401).json({ error: "Not signed in. Please sign in again." });
  const userId = String(user.id);
  if (req.method === "GET") {
    const requestedDate = typeof req.query?.date === "string" ? req.query.date : "";
    const date = /^\d{4}-\d{2}-\d{2}$/.test(requestedDate) ? requestedDate : todayInNigeria();
    const result = await db.query(`SELECT id, entry_type, amount, note, entry_date, created_at FROM money_entries WHERE user_id = $1 AND entry_date = $2 ORDER BY id DESC`, [userId, date]);
    const totals = await db.query(`SELECT COALESCE(SUM(CASE WHEN entry_type = 'money_in' THEN amount ELSE 0 END), 0) AS money_in, COALESCE(SUM(CASE WHEN entry_type = 'money_out' THEN amount ELSE 0 END), 0) AS money_out FROM money_entries WHERE user_id = $1 AND entry_date = $2`, [userId, date]);
    const moneyIn = Number(totals.rows[0]?.money_in || 0);
    const moneyOut = Number(totals.rows[0]?.money_out || 0);
    return res.json({ date, entries: result.rows, totals: { money_in: moneyIn, money_out: moneyOut, left: moneyIn - moneyOut } });
  }
  const body = req.body || {};
  const entryType = body.entry_type;
  const amount = cleanAmount(body.amount);
  const note = typeof body.note === "string" ? body.note.trim() : "";
  const entryDate = typeof body.entry_date === "string" && /^\d{4}-\d{2}-\d{2}$/.test(body.entry_date) ? body.entry_date : todayInNigeria();
  if (entryType !== "money_in" && entryType !== "money_out") return res.status(400).json({ error: "Please choose Money came in or Money went out." });
  if (!Number.isFinite(amount) || amount <= 0 || amount > 1000000000) return res.status(400).json({ error: "Please enter a valid amount greater than ₦0." });
  if (note.length > 160) return res.status(400).json({ error: "The note is too long. Keep it under 160 characters." });
  try {
    const result = await db.query(`INSERT INTO money_entries (user_id, entry_type, amount, note, entry_date) VALUES ($1, $2, $3, NULLIF($4, ''), $5) RETURNING id, entry_type, amount, note, entry_date, created_at`, [userId, entryType, amount, note, entryDate]);
    return res.status(201).json({ ok: true, entry: result.rows[0] });
  } catch (error) {
    console.error("money_entries insert failed", error);
    return res.status(500).json({ error: "We could not save this entry. Please try again." });
  }
}
