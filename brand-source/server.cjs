const http = require("http");
const fs = require("fs");
const path = require("path");

const ROOT = __dirname;
const CORS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "POST, GET, OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type",
};

http
  .createServer((req, res) => {
    if (req.method === "OPTIONS") {
      res.writeHead(204, CORS);
      return res.end();
    }

    if (req.method === "POST" && req.url === "/save") {
      let body = "";
      req.on("data", (c) => (body += c));
      req.on("end", () => {
        try {
          const { name, dataUrl } = JSON.parse(body);
          const safe = path.basename(name);
          const b64 = dataUrl.split(",")[1];
          fs.writeFileSync(path.join(ROOT, safe), Buffer.from(b64, "base64"));
          res.writeHead(200, { "Content-Type": "application/json", ...CORS });
          res.end(JSON.stringify({ ok: true, file: safe, bytes: Buffer.from(b64, "base64").length }));
        } catch (e) {
          res.writeHead(400);
          res.end(String(e));
        }
      });
      return;
    }

    let f = req.url.split("?")[0];
    if (f === "/") f = "/trace.html";
    const fp = path.join(ROOT, f);
    if (!fp.startsWith(ROOT) || !fs.existsSync(fp) || fs.statSync(fp).isDirectory()) {
      res.writeHead(404);
      return res.end("not found");
    }
    const ext = path.extname(fp);
    const type = ext === ".png" ? "image/png" : ext === ".svg" ? "image/svg+xml" : "text/html";
    res.writeHead(200, { "Content-Type": type });
    fs.createReadStream(fp).pipe(res);
  })
  .listen(8899, () => console.log("asset server on http://localhost:8899"));
