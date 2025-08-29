const express = require('express');
const { Client } = require('pg');
const path = require('path');
const http = require('http');
const socketIo = require('socket.io');

const app = express();
const server = http.createServer(app);
const io = socketIo(server);

const port = 80;

// PostgreSQL connection
const client = new Client({
  host: 'postgres',
  port: 5432,
  user: 'postgres',
  password: 'postgres',
  database: 'votes'
});

// Connect to PostgreSQL and create table if it doesn't exist
async function initDatabase() {
  try {
    await client.connect();
    
    await client.query(`
      CREATE TABLE IF NOT EXISTS votes (
        id SERIAL PRIMARY KEY,
        vote VARCHAR(255) NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);
    
    console.log('Database initialized successfully');
  } catch (err) {
    console.error('Database initialization error:', err);
    setTimeout(initDatabase, 5000);
  }
}

// Get vote counts
async function getVotes() {
  try {
    const result = await client.query(`
      SELECT vote, COUNT(*) as count 
      FROM votes 
      GROUP BY vote 
      ORDER BY count DESC
    `);
    
    const voteCounts = {};
    result.rows.forEach(row => {
      voteCounts[row.vote] = parseInt(row.count);
    });
    
    return voteCounts;
  } catch (err) {
    console.error('Error fetching votes:', err);
    return {};
  }
}

// Serve static files
app.use(express.static('views'));

// Main route
app.get('/', async (req, res) => {
  const votes = await getVotes();
  res.sendFile(path.join(__dirname, 'views', 'index.html'));
});

// API endpoint for vote data
app.get('/api/votes', async (req, res) => {
  const votes = await getVotes();
  res.json(votes);
});

// Socket.io connection
io.on('connection', (socket) => {
  console.log('Client connected for real-time updates');
  
  // Send initial data
  getVotes().then(votes => {
    socket.emit('votes', votes);
  });
});

// Poll for updates and emit to clients
setInterval(async () => {
  const votes = await getVotes();
  io.emit('votes', votes);
}, 2000);

// Initialize database and start server
initDatabase().then(() => {
  server.listen(port, () => {
    console.log(`Result service listening on port ${port}`);
  });
});
