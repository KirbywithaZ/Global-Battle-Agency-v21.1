// Storage

export default {
  async fetch(request, env) {
    const url = new URL(request.url);
    const SUPABASE_URL = env.SUPABASE_URL;
    const SUPABASE_KEY = env.SUPABASE_KEY;

    const corsHeaders = {
      "Access-Control-Allow-Origin": "*",
      "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
      "Access-Control-Allow-Headers": "*",
    };

    if (request.method === "OPTIONS") return new Response(null, { headers: corsHeaders });

    // --- DEPOSIT (Save to Supabase) ---
    if (url.pathname.includes("save")) {
      const bodyText = await request.text();
      const params = new URLSearchParams(bodyText);
      const id = params.get("id");
      const data = params.get("data");

      await fetch(`${SUPABASE_URL}/rest/v1/gba_storage`, {
        method: "POST",
        headers: {
          "apikey": SUPABASE_KEY,
          "Authorization": `Bearer ${SUPABASE_KEY}`,
          "Content-Type": "application/json",
          "Prefer": "resolution=merge-upsert" // This updates the row if it already exists
        },
        body: JSON.stringify({ id: id, data: data })
      });

      return new Response("OK", { headers: corsHeaders });
    }

    // --- WITHDRAW (Get from Supabase) ---
    if (url.pathname.includes("get")) {
      const id = url.searchParams.get("id");
      const response = await fetch(`${SUPABASE_URL}/rest/v1/gba_storage?id=eq.${id}&select=data`, {
        headers: {
          "apikey": SUPABASE_KEY,
          "Authorization": `Bearer ${SUPABASE_KEY}`
        }
      });
      const result = await response.json();
      const data = result.length > 0 ? result[0].data : "NOT_FOUND";
      return new Response(data, { headers: corsHeaders });
    }

    // --- DELETE (Anti-Cloning) ---
    if (url.pathname.includes("delete")) {
      const id = url.searchParams.get("id");
      await fetch(`${SUPABASE_URL}/rest/v1/gba_storage?id=eq.${id}`, {
        method: "DELETE",
        headers: {
          "apikey": SUPABASE_KEY,
          "Authorization": `Bearer ${SUPABASE_KEY}`
        }
      });
      return new Response("DELETED", { headers: corsHeaders });
    }

    return new Response("GBA Online: Supabase Mode Active", { headers: corsHeaders });
  }
};
