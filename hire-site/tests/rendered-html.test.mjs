import assert from "node:assert/strict";
import test from "node:test";

async function render() {
  const workerUrl = new URL("../dist/server/index.js", import.meta.url);
  workerUrl.searchParams.set("test", `${process.pid}-${Date.now()}`);
  const { default: worker } = await import(workerUrl.href);

  return worker.fetch(
    new Request("http://localhost/", {
      headers: { accept: "text/html" },
    }),
    {
      ASSETS: {
        fetch: async () => new Response("Not found", { status: 404 }),
      },
    },
    {
      waitUntil() {},
      passThroughOnException() {},
    },
  );
}

test("server-renders the Home IT service page", async () => {
  const response = await render();
  assert.equal(response.status, 200);
  assert.match(response.headers.get("content-type") ?? "", /^text\/html\b/i);

  const html = await response.text();
  assert.match(html, /<title>Natural Carr \| Home IT &amp; Smart Home Support<\/title>/i);
  assert.match(html, /Home tech,/);
  assert.match(html, /Home Assistant deployment/);
  assert.match(html, /Monitoring &amp; management/);
  assert.match(html, /Remote \+ onsite/);
  assert.match(html, /mailto:hello@naturalcarr\.com/);
  assert.match(html, /Currently taking new clients/);
});
