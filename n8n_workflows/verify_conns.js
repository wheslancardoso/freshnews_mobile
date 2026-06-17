const fs = require('fs');
const data = JSON.parse(fs.readFileSync('n8n_workflows/Fresh_News_SPORTS.json', 'utf8'));

// Check connections from "É notícia nova?1"
console.log("Conexões de 'É notícia nova?1':");
console.log(JSON.stringify(data.connections['\u00c9 not\u00edcia nova?1'], null, 2));

// Extract DB credentials
const dbNode = data.nodes.find(n => n.name === 'DB: Verifica URL');
console.log("DB Creds:", JSON.stringify(dbNode.credentials, null, 2));

// Extract OpenAI credentials
const aiNode = data.nodes.find(n => n.type === '@n8n/n8n-nodes-langchain.openAi');
console.log("OpenAI Creds:", JSON.stringify(aiNode.credentials, null, 2));

// Find original node names matching exactly to handle encoding
const nodeName = Object.keys(data.connections).find(k => k.includes('nova?1'));
console.log("Nome exato do nó de filtro:", nodeName);
