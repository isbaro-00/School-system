import { withSupabase } from "npm:@supabase/server@1";

const json = (body: unknown, status = 200) =>
  Response.json(body, {
    status,
    headers: { "Content-Type": "application/json" },
  });

// Compatibility endpoint. The real verification logic lives in the same
// database RPC used by resolve-account, so this endpoint never returns demo data.
export default {
  fetch: withSupabase({ auth: "publishable" }, async (req, ctx) => {
    if (req.method !== "POST") return json({ error: "Method not allowed" }, 405);

    try {
      const body = await req.json();
      const schoolAccessCode = String(body.school_access_code ?? "").trim();
      const accountType = String(body.account_type ?? "").trim();
      const identifier = String(body.identifier ?? "").trim();

      if (!schoolAccessCode || !accountType || !identifier) {
        return json({ error: "Invalid verification data." }, 400);
      }

      const { data: rows, error } = await ctx.supabaseAdmin.rpc(
        "find_login_account",
        {
          p_school_access_code: schoolAccessCode,
          p_account_type: accountType,
          p_identifier: identifier,
        },
      );

      if (error || !rows || rows.length !== 1) {
        return json({ error: "Account could not be verified." }, 400);
      }

      const account = rows[0];
      return json({
        verified: true,
        activated: Boolean(account.already_activated),
        setup_required: !Boolean(account.already_activated),
        display_name: account.display_name,
        auth_login_email: account.already_activated
          ? account.auth_login_email
          : undefined,
      });
    } catch (_) {
      return json({ error: "Invalid request." }, 400);
    }
  }),
};
