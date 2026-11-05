// Appel de Claude par le SDK officiel d'Anthropic (phase 12) : consignes
// fixes en cache, réponse JSON imposée, effort bas (fiches structurées).
import Anthropic from "@anthropic-ai/sdk";
import { CONSIGNES, type Fiche, SCHEMA } from "./consignes.ts";

export async function appelerClaude(
  p: { cle: string; modele: string; texte: string },
): Promise<{ fiche: Fiche; usage: { entree: number; sortie: number; cacheLu: number; cacheEcrit: number } }> {
  const client = new Anthropic({ apiKey: p.cle });
  const r = await client.messages.create({
    model: p.modele,
    max_tokens: 8000,
    system: [{ type: "text", text: CONSIGNES, cache_control: { type: "ephemeral" } }],
    messages: [{ role: "user", content: p.texte }],
    output_config: { effort: "low", format: { type: "json_schema", schema: SCHEMA } },
    // deno-lint-ignore no-explicit-any
  } as any);
  if (r.stop_reason === "refusal") throw new Error("refus");
  if (r.stop_reason === "max_tokens") throw new Error("trop_long");
  const bloc = r.content.find((b) => b.type === "text");
  if (!bloc || bloc.type !== "text") throw new Error("vide");
  const u = r.usage;
  return {
    fiche: JSON.parse(bloc.text) as Fiche,
    usage: {
      entree: u.input_tokens ?? 0,
      sortie: u.output_tokens ?? 0,
      cacheLu: u.cache_read_input_tokens ?? 0,
      cacheEcrit: u.cache_creation_input_tokens ?? 0,
    },
  };
}
