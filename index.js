const { hostname } = require('os');
const http = require('http');

const port = 8081;

const server = http.createServer((req, res) => {
    res.statusCode = 200;
    res.setHeader('Content-Type', 'text/plain');
    res.end(`Hello World from ${hostname()}\n`);
});

server.listen(port, hostname, () => {
    console.log(`Server running at http://${hostname()}:${port}/`);
});